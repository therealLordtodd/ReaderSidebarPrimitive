# ReaderSidebarPrimitive

> Claude Code loads this file automatically at the start of every session.

## Package Purpose

`ReaderSidebarPrimitive` owns the shared reader sidebar chrome. It provides the typed pane enum (`ReaderSidebarPane`), the sidebar shell view (`ReaderSidebarChrome`), a typed header-action model (`ReaderSidebarAction`), and a themed empty-state view (`ReaderSidebarEmptyState`).

`ReaderView` composes this primitive internally. Hosts using `ReaderView` do not need to import this package directly. Hosts building custom reader surfaces or non-reader surfaces that reuse the typed-pane pattern import this package.

**Tech stack:** Swift 6.0 / SwiftUI.

## Key Types

- `ReaderSidebarPane` — enum with cases `.none`, `.all`, `.highlights`, `.comments`, `.bookmarks`; exposes titles, system images, and a `toggled(from:)` helper
- `ReaderSidebarPane.standardAnnotationPanes` — `[.highlights, .comments, .bookmarks]`
- `ReaderSidebarChrome<Content>` — the sidebar shell view
- `ReaderSidebarAction` — typed header-action value (id, title, icon, helpText, isDisabled, action)
- `ReaderSidebarEmptyState` — themed empty-state view

## Dependencies

- `ReaderChromeThemePrimitive` — theme tokens consumed via environment

## Architecture Rules

- **Shell owns layout; content is host-injected.** The sidebar chrome does not know what a highlight, comment, or bookmark *is*. The host or composer passes per-pane content via `@ViewBuilder`. That keeps the primitive independent of annotation primitive internals.
- **Pane state is bound, not owned.** The active pane is a `Binding<ReaderSidebarPane>`; the host owns the state so the toolbar and sidebar stay in sync.
- **Header actions are typed.** Actions use stable IDs, accessibility labels, SF Symbols, and optional help text + disabled state. Do not add ad-hoc buttons outside `ReaderSidebarAction` — it short-circuits the accessibility + help contract.
- **No bulk operations here.** Bulk delete, export, archive, drag-to-reorder, and tagging are app-level or future-primitive concerns. Do not add them to the sidebar shell.
- **Empty-state consistency.** Panes that have no content should render `ReaderSidebarEmptyState`. Hosts should not ship their own empty-state UI for annotation panes.

## Primary Documentation

- Host-facing usage + API reference: `/Users/todd/Programming/Packages/ReaderSidebarPrimitive/README.md`
- Portfolio integration guide: `/Users/todd/Programming/Packages/ReaderKit/docs/reader-stack-integration-guide.md`

When answering sidebar questions, prefer the README first. For how the sidebar fits into the broader reader stack — including the merged-annotation coordinator behind the `(All)` tab — go to the integration guide.

## Primitives-First Development

This primitive does one thing: it is the reader sidebar shell. Questions before extending:

1. Is the proposed addition sidebar-shaped, or is it annotation-data behavior that should live in `BookmarkPrimitive`, `CommentPrimitive`, or `HighlightPrimitive`?
2. Is it sidebar-content behavior that should live in the host (grouping providers, sort order, filter state)?
3. Is it layout-only and consumed by more than one host? Then it belongs here.

## GitHub Repository Visibility

- This repository is **private**. Do not change visibility without Todd's explicit request.
