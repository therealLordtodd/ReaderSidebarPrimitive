# ReaderSidebarPrimitive

`ReaderSidebarPrimitive` is the shared reader sidebar chrome for the portfolio. It provides a typed pane model (`ReaderSidebarPane`), a sidebar shell container (`ReaderSidebarChrome`), header-action support, and an empty-state view — with consistent layout and theming across every reader surface in the portfolio.

Use it when a host exposes annotations in a sidebar. Do not build a parallel sidebar shell; the primitive is deliberately thin so every host inherits the same pane tabs, header layout, and empty-state behavior.

## What The Package Gives You

- `ReaderSidebarPane` — the typed pane enum (`.none`, `.all`, `.highlights`, `.comments`, `.bookmarks`) with titles, SF Symbols, and a toggle helper
- `ReaderSidebarPane.standardAnnotationPanes` — convenience constant for the three common panes
- `ReaderSidebarChrome<Content>` — the sidebar shell view that hosts per-pane content
- `ReaderSidebarAction` — a typed header action model (id, title, icon, help text, disabled state, handler)
- `ReaderSidebarEmptyState` — a themed empty-state view for empty panes

## When To Use It

- You are using `ReaderView` from `ReaderKit` (it composes this primitive internally; no need to import directly)
- You are building a custom reader and want the same sidebar shape
- You are building a non-reader surface that needs a similar typed-pane sidebar (library inspectors, ops consoles) — borrow `ReaderSidebarChrome` and pass your own pane enum mapped to `ReaderSidebarPane` if the shape fits

## When Not To Use It

- You want a sidebar for non-annotation content unrelated to reader chrome (use SwiftUI's `NavigationSplitView` or your own layout)
- You need bulk-annotation operations (delete-all, export-all) — those are host concerns, not sidebar concerns
- You need drag-to-reorder, tagging, or categorization of annotations — out of v3 scope; file in the reader stack roadmap instead

## Install

```swift
dependencies: [
    .package(path: "../ReaderSidebarPrimitive"),
],
targets: [
    .target(
        name: "MyReaderHost",
        dependencies: ["ReaderSidebarPrimitive"]
    )
]
```

This package depends on `ReaderChromeThemePrimitive` transitively.

## Basic Usage

### Inside `ReaderView` (the common case)

If you are using `ReaderView` from `ReaderKit`, you already get this sidebar. Do not import this package directly.

### In a custom reader surface

```swift
import ReaderChromeThemePrimitive
import ReaderSidebarPrimitive
import SwiftUI

struct CustomSidebar: View {
    @Binding var activePane: ReaderSidebarPane

    var body: some View {
        ReaderSidebarChrome(
            activePane: $activePane,
            currentPane: activePane,
            availablePanes: ReaderSidebarPane.standardAnnotationPanes,
            title: paneTitle,
            headerActions: [
                ReaderSidebarAction(
                    id: "clear",
                    title: "Clear filter",
                    systemImage: "line.3.horizontal.decrease.circle",
                    helpText: "Remove the current filter"
                ) {
                    clearFilter()
                }
            ],
            onClose: { activePane = .none }
        ) {
            paneContent
        }
        .readerChromeTheme(.default)
    }

    private var paneTitle: String {
        switch activePane {
        case .highlights: return "Highlights"
        case .comments: return "Comments"
        case .bookmarks: return "Bookmarks"
        case .all: return "All annotations"
        case .none: return ""
        }
    }

    @ViewBuilder
    private var paneContent: some View {
        switch activePane {
        case .highlights:
            HighlightsList()
        case .comments:
            CommentsList()
        case .bookmarks:
            BookmarksList()
        case .all:
            MergedAnnotationList()
        case .none:
            EmptyView()
        }
    }
}
```

### Empty states

```swift
import ReaderSidebarPrimitive

ReaderSidebarEmptyState(
    systemImage: "highlighter",
    title: "No highlights yet",
    message: "Select text to highlight a passage. Highlights appear here."
)
```

Use the empty-state view whenever a pane has no content — consistent empty-state UX across all three kinds of annotations.

### Header actions

Header actions are typed and accessible: each carries an id (stable across sessions), a title (used for accessibility labels), a system image (SF Symbol), optional help text, and an optional disabled flag. Use them for pane-local controls like filter, sort, or export — not for navigation.

```swift
let actions: [ReaderSidebarAction] = [
    ReaderSidebarAction(
        id: "sort.newest",
        title: "Sort newest first",
        systemImage: "arrow.up.arrow.down",
        helpText: "Sort annotations by most recent first"
    ) {
        sortOrder = .newest
    },
    ReaderSidebarAction(
        id: "filter.author",
        title: "Filter by author",
        systemImage: "person.circle",
        isDisabled: authorList.isEmpty
    ) {
        showAuthorPicker = true
    }
]
```

## Pane Semantics

The five panes have well-defined roles:

| Pane | Typical content |
|------|-----------------|
| `.none` | sidebar is collapsed; no pane is visible |
| `.all` | merged view across all annotation kinds, ordered by position |
| `.highlights` | `Highlight` annotations only |
| `.comments` | `Comment` annotations only |
| `.bookmarks` | `Bookmark` annotations only |

`ReaderSidebarPane.toggled(from:)` flips the pane off when called with the currently active pane, which is the right behavior for tab-button taps.

## Integration Guide

This package is one of the shared reader chrome primitives. For how the sidebar fits into the broader reader stack — including the merged-annotation coordinator behind the `(All)` tab and how the host wires per-kind list content — see:

- `Packages/ReaderKit/docs/reader-stack-integration-guide.md`

## Design Notes

The sidebar shell is intentionally thin. It owns:

- pane tab layout
- header layout
- close-button handling
- empty-state presentation
- theme integration

It does not own:

- the actual list content for each pane (content view is host-injected via `@ViewBuilder`)
- annotation data (lives in `BookmarkPrimitive`, `CommentPrimitive`, and `HighlightPrimitive`)
- merged-view aggregation (lives in `ReaderKit`'s `ReaderSessionMergedAnnotationCoordinator`)
- filtering, sorting, or grouping logic (host can add header actions but the state is host-owned)

This split is what lets the same sidebar shell work for Noema's reader, Vantage's workspace surfaces, and Data Estate's LOI/OM review without forking.
