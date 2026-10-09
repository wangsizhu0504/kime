import AppKit
import QuartzCore
import Testing
@testable import KUMEPanel

@MainActor
@Suite(.serialized)
struct HighlightMotionTests {
    @Test(arguments: [PanelTheme.Layout.linear, .stacked], [false, true])
    func selectionSlidesButNewCandidatesAndReopeningDoNot(layout: PanelTheme.Layout, filled: Bool) async throws {
        let panel = CandidatePanel()
        defer { panel.hide() }
        var theme = PanelTheme.fallback
        theme.layout = layout
        if filled { theme.borderWidth = 0; theme.borderHeight = 0 }
        panel.theme = theme
        let cursor = NSRect(x: 300, y: (NSScreen.main?.frame.height ?? 900) - 300, width: 1, height: 18)
        var state = PanelState(candidates: [
            .init(label: "1", text: "你好"), .init(label: "2", text: "你好世界"), .init(label: "3", text: "拟好")
        ])
        panel.show(state, at: cursor)
        CATransaction.flush()
        try await Task.sleep(for: .milliseconds(160))
        let first = try #require(panel.candidateHighlight.path)
        state.highlightedIndex = 2
        panel.show(state, at: cursor)
        #expect(panel.view.state.highlightedIndex == 2)
        let target = try #require(panel.candidateHighlight.path)
        #expect(first != target)
        if !NSWorkspace.shared.accessibilityDisplayShouldReduceMotion {
            #expect(panel.candidateHighlight.animation(forKey: "selection") != nil)
            CATransaction.flush()
            try await Task.sleep(for: .milliseconds(35))
            let middle = try #require(panel.candidateHighlight.presentation()?.path)
            #expect(middle != first && middle != target)
            // Repeated state must not interrupt a slide already in flight.
            panel.show(state, at: cursor)
            #expect(panel.candidateHighlight.animation(forKey: "selection") != nil)
            state.highlightedIndex = 1
            panel.show(state, at: cursor)
            let animation = try #require(panel.candidateHighlight.animation(forKey: "selection") as? CABasicAnimation)
            let resumedFrom = try #require(animation.fromValue) as! CGPath
            #expect(resumedFrom != target)
        }
        try await Task.sleep(for: .milliseconds(160))
        if let output = ProcessInfo.processInfo.environment["KUME_HIGHLIGHT_SHOT"] {
            let content = try #require(panel.view.window?.contentView)
            content.displayIfNeeded()
            let bitmap = try #require(content.bitmapImageRepForCachingDisplay(in: content.bounds))
            let context = try #require(NSGraphicsContext(bitmapImageRep: bitmap))
            content.layer?.render(in: context.cgContext)
            let png = try #require(bitmap.representation(using: .png, properties: [:]))
            try png.write(to: URL(fileURLWithPath: output + "-\(layout.rawValue)-\(filled).png"))
        }
        state.candidates[0].text = "新候选"
        panel.show(state, at: cursor)
        #expect(panel.candidateHighlight.animation(forKey: "selection") == nil)
        panel.hide()
        state.highlightedIndex = 0
        panel.show(state, at: cursor)
        #expect(panel.candidateHighlight.animation(forKey: "selection") == nil)
        panel.animationsEnabled = false
        state.highlightedIndex = 2
        panel.show(state, at: cursor)
        #expect(panel.candidateHighlight.animation(forKey: "selection") == nil)
    }
}
