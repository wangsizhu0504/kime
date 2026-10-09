import Foundation
import Testing
@testable import KUMECore

struct InputControlTests {
    @Test func searchFindsFontSizeAndRequiresEveryTerm() {
        #expect(SettingsSearch.results("字体大小").contains { $0.id == "appearance.font_point" })
        #expect(SettingsSearch.results("候选 字号").contains { $0.id == "appearance.font_point" })
        #expect(SettingsSearch.results("不存在的设置词").isEmpty)
        #expect(SettingsSearch.results("  ").isEmpty)
    }
    @Test func shortcutsCompareModifiersAndShiftedLetters() {
        let found = ShortcutConflicts.find([
            .init(key: "Alt+Control+m", owner: "菜单"),
            .init(key: "Control+Alt+m", owner: "方案"),
            .init(key: "Control+M", owner: "另一个")
        ])
        #expect(found.count == 1)
        #expect(found.first?.owners == ["方案", "菜单"])
        #expect(ShortcutConflicts.canonicalKey("Control+M") == ShortcutConflicts.canonicalKey("Shift+Control+m"))
        #expect(ShortcutConflicts.canonicalKey("Command+space") == ShortcutConflicts.canonicalKey("Super+space"))
    }
    @Test func specialInputModesKeepTheirOwnKeys() {
        #expect(CandidatePreferences.supports(input: "ni'hao", selectionKeys: "1234567890"))
        #expect(!CandidatePreferences.supports(input: "V1+2", selectionKeys: "1234567890"))
        #expect(!CandidatePreferences.supports(input: "/rq", selectionKeys: "1234567890"))
        #expect(!CandidatePreferences.supports(input: "ni", selectionKeys: "asdfgh"))
        #expect(!CandidatePreferences.supports(input: "", selectionKeys: "1234567890"))
    }
    @Test func preferencesAreScopedStableAndReversible() throws {
        let paths = KUMEPaths(userDataDir: FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString))
        defer { try? FileManager.default.removeItem(at: paths.userDataDir) }
        let words = ["是", "时", "事", "市"]
        _ = try CandidatePreferences.update(paths) { $0.set(.init(schema: "a", input: "shi", text: "事", action: .pin)) }
        _ = try CandidatePreferences.update(paths) { $0.set(.init(schema: "a", input: "shi", text: "是", action: .lower)) }
        let hidden = try CandidatePreferences.update(paths) { $0.set(.init(schema: "a", input: "shi", text: "时", action: .hide)) }
        #expect(hidden.order(schema: "a", input: "shi", texts: words) == [2, 3, 0])
        #expect(hidden.order(schema: "b", input: "shi", texts: words) == [0, 1, 2, 3])
        #expect(hidden.order(schema: "a", input: "sh", texts: words) == [0, 1, 2, 3])
        let undone = try CandidatePreferences.update(paths) { $0.undo() }
        #expect(undone.order(schema: "a", input: "shi", texts: words) == [2, 1, 3, 0])
        #expect(try CandidatePreferences.load(paths) == undone)
        #expect(undone.undoRules == nil)
    }
    @Test func resettingAnAppsMemoryDoesNotChangeOtherApps() {
        var state = AsciiStatePolicy(scope: .app)
        state.record(true, app: "a", appDefault: false)
        state.record(true, app: "b", appDefault: false)
        state.forget(app: "a")
        #expect(state.state(for: "a", appDefault: false, newSession: false) == false)
        #expect(state.state(for: "b", appDefault: false, newSession: false) == true)
    }
    @Test func appResetBehaviorRoundTripsThroughSettings() throws {
        let paths = KUMEPaths(userDataDir: FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString))
        defer { try? FileManager.default.removeItem(at: paths.userDataDir) }
        let store = SettingsStore(paths: paths)
        let option = SettingsStore.AppOption(bundleID: "test.app", initialMode: .chinese, resetModeOnActivate: true)
        try store.setAppOption(option)
        #expect(store.appOptions() == [option])
    }
}
