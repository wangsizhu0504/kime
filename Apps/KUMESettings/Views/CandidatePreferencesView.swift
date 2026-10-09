import KUMECore
import SwiftUI

struct CandidatePreferencesView: View {
    @Environment(SettingsModel.self) private var model
    @State private var preferences = CandidatePreferences()
    @State private var query = ""
    @State private var error: String?

    var body: some View {
        Form {
            Section { PaneHeader(title: "候选词管理", subtitle: "输入时右键点击候选词，可调整当前页的显示顺序或隐藏该词。适用于普通字母编码、数字选词；规则仅作用于对应方案和编码，不删除词库记录。", symbol: "text.badge.checkmark") }
            Section {
                TextField("搜索词语、编码或方案", text: $query)
                Button("撤销上次候选调整") { update { $0.undo() } }.disabled(preferences.undoRules == nil)
                if let error { Text(error).foregroundStyle(.red) }
            }
            Section("已保存的调整") {
                if preferences.rules.isEmpty { Text("暂无调整。在候选窗中右键点击一个词即可开始。").foregroundStyle(.secondary) }
                ForEach(preferences.rules.filter { query.isEmpty || "\($0.schema) \($0.input) \($0.text)".localizedCaseInsensitiveContains(query) }) { rule in
                    HStack {
                        VStack(alignment: .leading, spacing: 3) {
                            Text(rule.text).font(.body.weight(.medium))
                            Text("\(rule.schema) · \(rule.input) · \(title(rule.action))").font(.caption).foregroundStyle(.secondary)
                        }
                        Spacer()
                        Button("恢复默认") { update { $0.remove(id: rule.id) } }
                    }
                }
            }
        }
        .formStyle(.cards)
        .task { reload() }
        .onReceive(DistributedNotificationCenter.default().publisher(for: CandidatePreferences.changed)) { _ in reload() }
    }
    private func title(_ action: CandidatePreferences.Action) -> String {
        switch action { case .pin: "本页优先"; case .lower: "本页降低优先级"; case .hide: "隐藏" }
    }
    private func reload() {
        do { preferences = try CandidatePreferences.load(model.paths); error = nil }
        catch { self.error = "无法读取候选偏好：\(error.localizedDescription)" }
    }
    private func update(_ body: (inout CandidatePreferences) -> Void) {
        do {
            preferences = try CandidatePreferences.update(model.paths, body)
            error = nil
            DistributedNotificationCenter.default().postNotificationName(CandidatePreferences.changed, object: nil, userInfo: nil, deliverImmediately: true)
        } catch { self.error = "未能保存：\(error.localizedDescription)" }
    }
}
