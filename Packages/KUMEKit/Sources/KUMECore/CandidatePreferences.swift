public import Foundation

/// Frontend preferences scoped to an exact schema, input code and candidate text.
/// They reorder/filter the current page; they never edit Rime's learned dictionary.
public struct CandidatePreferences: Codable, Sendable, Equatable {
    public enum Action: String, Codable, Sendable { case pin, lower, hide }
    public struct Rule: Codable, Sendable, Equatable, Identifiable {
        public var schema: String
        public var input: String
        public var text: String
        public var action: Action
        public var id: String { [schema, input, text].joined(separator: "\u{0}") }
        public init(schema: String, input: String, text: String, action: Action) {
            self.schema = schema; self.input = input; self.text = text; self.action = action
        }
    }
    public var rules: [Rule] = []
    public var undoRules: [Rule]?
    public init() {}
    public static let changed = Notification.Name("app.kriszu.kume.candidatePreferencesChanged")

    public static func supports(input: String, selectionKeys: String) -> Bool {
        !input.isEmpty && selectionKeys == "1234567890" && input.unicodeScalars.allSatisfy {
            (97...122).contains($0.value) || $0 == "'" || $0 == ";" || $0 == " "
        }
    }

    public func order(schema: String, input: String, texts: [String]) -> [Int] {
        let matching = rules.filter { $0.schema == schema && $0.input == input }
        let actions = Dictionary(matching.map { ($0.text, $0.action) }, uniquingKeysWith: { _, last in last })
        func rank(_ index: Int) -> Int { actions[texts[index]] == .pin ? -1 : actions[texts[index]] == .lower ? 1 : 0 }
        return texts.indices.filter { actions[texts[$0]] != .hide }.sorted {
            rank($0) == rank($1) ? $0 < $1 : rank($0) < rank($1)
        }
    }
    public mutating func set(_ rule: Rule) {
        undoRules = rules
        rules.removeAll { $0.id == rule.id }
        rules.append(rule)
    }
    public mutating func remove(id: String) {
        undoRules = rules
        rules.removeAll { $0.id == id }
    }
    public mutating func undo() {
        guard let previous = undoRules else { return }
        rules = previous; undoRules = nil
    }
    private static func url(_ paths: KUMEPaths) -> URL { paths.kumeDir.appendingPathComponent("candidate-preferences.json") }
    public static func load(_ paths: KUMEPaths) throws -> Self {
        let file = url(paths)
        guard FileManager.default.fileExists(atPath: file.path) else { return Self() }
        return try JSONDecoder().decode(Self.self, from: Data(contentsOf: file))
    }
    /// Read/modify/write under a dedicated lock so Settings and the input method do not
    /// overwrite each other's edits. No deployment or userdb lock is required.
    @discardableResult
    public static func update(_ paths: KUMEPaths, _ edit: (inout Self) -> Void) throws -> Self {
        try FileManager.default.createDirectory(at: paths.kumeDir, withIntermediateDirectories: true)
        let fd = open(url(paths).appendingPathExtension("lock").path, O_CREAT | O_RDWR, 0o600)
        guard fd >= 0 else { throw CocoaError(.fileWriteUnknown) }
        defer { close(fd) }
        guard flock(fd, LOCK_EX | LOCK_NB) == 0 else { throw CocoaError(.fileLocking) }
        defer { flock(fd, LOCK_UN) }
        var value = try load(paths)
        edit(&value)
        try JSONEncoder().encode(value).write(to: url(paths), options: .atomic)
        return value
    }
}
