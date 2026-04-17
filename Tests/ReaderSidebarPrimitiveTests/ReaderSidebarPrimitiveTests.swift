import Testing
import SwiftUI
@testable import ReaderSidebarPrimitive

@Test func readerSidebarPaneTogglingIsStable() {
    #expect(ReaderSidebarPane.highlights.toggled(from: .none) == .highlights)
    #expect(ReaderSidebarPane.highlights.toggled(from: .highlights) == .none)
    #expect(ReaderSidebarPane.comments.toggled(from: .bookmarks) == .comments)
}

@MainActor
@Test func readerSidebarViewsPublicSurfaceLoad() {
    let activePane = Binding.constant(ReaderSidebarPane.highlights)

    _ = ReaderSidebarChrome(
        activePane: activePane,
        currentPane: .highlights,
        title: "Highlights",
        headerActions: [
            ReaderSidebarAction(
                id: "export",
                title: "Export",
                systemImage: "square.and.arrow.up",
                action: {}
            )
        ],
        onClose: {}
    ) {
        Text("Highlights content")
    }

    _ = ReaderSidebarEmptyState(
        systemImage: "highlighter",
        title: "No highlights yet",
        message: "Select text and highlight it."
    )
}
