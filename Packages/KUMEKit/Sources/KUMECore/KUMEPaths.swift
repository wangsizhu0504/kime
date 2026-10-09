public import Foundation

/// Well-known locations. Everything KUME writes lives under `userDataDir`; the
/// Squirrel directory is only ever read.
public struct KUMEPaths: Sendable, Equatable {
    public var userDataDir: URL
    public var logDir: URL
    /// Read-only shipped data (KUME.app/Contents/SharedSupport). Needed to compose the
    /// `kume/defaults` layer; nil in contexts that only touch user layers.
    public var sharedDataDir: URL?

    public init(userDataDir: URL, logDir: URL? = nil, sharedDataDir: URL? = nil) {
        self.userDataDir = userDataDir
        self.logDir = logDir ?? userDataDir.appendingPathComponent("logs", isDirectory: true)
        self.sharedDataDir = sharedDataDir
    }

    /// `~/Library/KUME/Rime`, overridable with `KUME_USER_DIR` for tests and scripting.
    public static var standard: KUMEPaths {
        let env = ProcessInfo.processInfo.environment
        if let override = env["KUME_USER_DIR"], !override.isEmpty {
            return KUMEPaths(userDataDir: URL(fileURLWithPath: (override as NSString).expandingTildeInPath, isDirectory: true))
        }
        let library = FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent("Library", isDirectory: true)
        return KUMEPaths(
            userDataDir: library.appendingPathComponent("KUME/Rime", isDirectory: true),
            logDir: library.appendingPathComponent("Logs/KUME", isDirectory: true)
        )
    }

    /// The Squirrel (鼠须管) user directory, used as an import source only.
    public static var squirrelUserDir: URL {
        FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent("Library/Rime", isDirectory: true)
    }

    public var stagingDir: URL { userDataDir.appendingPathComponent("build", isDirectory: true) }
    public var kumeDir: URL { userDataDir.appendingPathComponent("kume", isDirectory: true) }
    public var importedDir: URL { kumeDir.appendingPathComponent("imported", isDirectory: true) }
    public var generatedDir: URL { kumeDir.appendingPathComponent("generated", isDirectory: true) }
    public var packagesDir: URL { kumeDir.appendingPathComponent("packages", isDirectory: true) }
    public var cacheDir: URL { kumeDir.appendingPathComponent("cache", isDirectory: true) }
    public var customPhraseFile: URL { userDataDir.appendingPathComponent("custom_phrase.txt") }

    public func builtConfig(_ configID: String) -> URL {
        stagingDir.appendingPathComponent("\(configID).yaml")
    }
}

/// Rime's own file-name convention for the configs KUME manages.
public enum ConfigTarget: Sendable, Hashable, CustomStringConvertible {
    /// `default.yaml`
    case `default`
    /// `<id>.schema.yaml`
    case schema(String)
    /// `kume.yaml` — the frontend config; same keys as Squirrel's `squirrel.yaml`.
    case frontend

    /// Config id as used by `config_open` / the `build/` directory.
    public var configID: String {
        switch self {
        case .default: "default"
        case let .schema(id): "\(id).schema"
        case .frontend: "kume"
        }
    }

    /// Base name of the `*.custom.yaml` patch file Rime auto-applies.
    public var customName: String {
        switch self {
        case .default: "default"
        case let .schema(id): id
        case .frontend: "kume"
        }
    }

    public var description: String { configID }

    public init?(file: String, schemaID: String?) {
        switch file {
        case "default": self = .default
        case "frontend", "kume", "squirrel": self = .frontend
        case "schema":
            guard let schemaID else { return nil }
            self = .schema(schemaID)
        default: return nil
        }
    }
}
