import Foundation

/// Searches the editable catalog, with a small vocabulary for common user wording.
public enum SettingsSearch {
    public static func results(_ query: String, catalog: SettingCatalog = .bundled) -> [SettingCatalog.Setting] {
        let terms = query.lowercased().split(whereSeparator: \.isWhitespace).map(String.init)
        guard !terms.isEmpty else { return [] }
        let aliases = ["字号": "字体大小 字体", "ascii": "英文 中文 中英", "page": "翻页 候选", "hotkey": "快捷键 按键", "layout": "横排 竖排 布局"]
        return catalog.settings.filter { setting in
            guard setting.type != .custom else { return false }
            var text = "\(setting.title) \(setting.description ?? "") \(setting.id) \(setting.keypath)"
            for (key, words) in aliases where text.localizedCaseInsensitiveContains(key) { text += " " + words }
            return terms.allSatisfy { text.localizedCaseInsensitiveContains($0) }
        }
    }
}

/// Reports overlapping bindings, without pretending to inspect other apps' shortcuts.
public enum ShortcutConflicts {
    public struct Binding: Sendable, Equatable {
        public var key: String
        public var owner: String
        public var condition: String
        public init(key: String, owner: String, condition: String = "always") {
            self.key = key; self.owner = owner; self.condition = condition
        }
    }
    public struct Conflict: Sendable, Equatable {
        public var key: String
        public var owners: [String]
    }
    public static func canonicalKey(_ key: String) -> String {
        var parts = key.split(separator: "+").map(String.init)
        guard var character = parts.popLast() else { return "" }
        var modifiers = Set(parts.map { $0 == "Command" ? "Super" : $0 })
        if character.count == 1, character != character.lowercased() {
            modifiers.insert("Shift"); character = character.lowercased()
        }
        return (modifiers.sorted() + [character]).joined(separator: "+")
    }
    public static func find(_ bindings: [Binding]) -> [Conflict] {
        Dictionary(grouping: bindings, by: { canonicalKey($0.key) }).compactMap { key, group in
            let owners = Set(group.map(\.owner)).sorted()
            guard owners.count > 1 else { return nil }
            return Conflict(key: key, owners: owners)
        }.sorted { $0.key < $1.key }
    }
    public static func bindings(schema: ConfigValue?, switcher: [String]) -> [Binding] {
        var result: [Binding] = [
            .init(key: "Control+Alt+m", owner: "酷米快捷菜单"),
            .init(key: "Control+Alt+p", owner: "酷米文本动作")
        ]
        result += switcher.map { .init(key: $0, owner: "方案选单") }
        result += (schema?.value(at: "key_binder/bindings")?.listValue ?? []).enumerated().compactMap { index, entry in
            guard let key = entry["accept"]?.stringValue else { return nil }
            let action = entry["send"]?.stringValue ?? entry["toggle"]?.stringValue ?? entry["select"]?.stringValue ?? "操作"
            let condition = entry["when"]?.stringValue ?? "always"
            return .init(key: key, owner: "方案绑定 \(index + 1)：\(action)（\(condition)）", condition: condition)
        }
        return result
    }
}
