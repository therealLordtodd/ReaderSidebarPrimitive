import ReaderChromeThemePrimitive
import SwiftUI

public enum ReaderSidebarPane: String, CaseIterable, Sendable {
    case none
    case all
    case highlights
    case comments
    case bookmarks

    public static let standardAnnotationPanes: [ReaderSidebarPane] = [
        .highlights,
        .comments,
        .bookmarks,
    ]

    public var title: String {
        switch self {
        case .none:
            return "None"
        case .all:
            return "All"
        case .highlights:
            return "Highlights"
        case .comments:
            return "Comments"
        case .bookmarks:
            return "Bookmarks"
        }
    }

    public var systemImage: String {
        switch self {
        case .none:
            return "sidebar.trailing"
        case .all:
            return "tray.full"
        case .highlights:
            return "highlighter"
        case .comments:
            return "text.bubble"
        case .bookmarks:
            return "bookmark"
        }
    }

    public func toggled(from activePane: ReaderSidebarPane) -> ReaderSidebarPane {
        activePane == self ? .none : self
    }
}

public struct ReaderSidebarAction: Identifiable {
    public let id: String
    public let title: String
    public let systemImage: String
    public let helpText: String?
    public let isDisabled: Bool
    public let action: () -> Void

    public init(
        id: String,
        title: String,
        systemImage: String,
        helpText: String? = nil,
        isDisabled: Bool = false,
        action: @escaping () -> Void
    ) {
        self.id = id
        self.title = title
        self.systemImage = systemImage
        self.helpText = helpText
        self.isDisabled = isDisabled
        self.action = action
    }
}

public struct ReaderSidebarChrome<Content: View>: View {
    @Binding public var activePane: ReaderSidebarPane

    public let currentPane: ReaderSidebarPane
    public let availablePanes: [ReaderSidebarPane]
    public let title: String
    public let headerActions: [ReaderSidebarAction]
    public let onClose: (() -> Void)?

    @Environment(\.readerChromeTheme) private var theme

    private let content: Content

    public init(
        activePane: Binding<ReaderSidebarPane>,
        currentPane: ReaderSidebarPane,
        availablePanes: [ReaderSidebarPane] = ReaderSidebarPane.standardAnnotationPanes,
        title: String,
        headerActions: [ReaderSidebarAction] = [],
        onClose: (() -> Void)? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self._activePane = activePane
        self.currentPane = currentPane
        self.availablePanes = availablePanes
        self.title = title
        self.headerActions = headerActions
        self.onClose = onClose
        self.content = content()
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if availablePanes.count > 1 {
                paneTabs
                    .padding(.horizontal, theme.spacing.large)
                    .padding(.top, theme.spacing.large)
                    .padding(.bottom, theme.spacing.small)

                Divider()
            }

            HStack(spacing: theme.spacing.small) {
                Text(title)
                    .font(theme.typography.title3)
                    .foregroundStyle(theme.colors.primaryText)

                Spacer()

                ForEach(headerActions) { action in
                    Button(action: action.action) {
                        Image(systemName: action.systemImage)
                            .font(theme.typography.caption)
                    }
                    .buttonStyle(.plain)
                    .foregroundStyle(theme.colors.secondaryText)
                    .accessibilityLabel(action.title)
                    .help(action.helpText ?? action.title)
                    .disabled(action.isDisabled)
                }

                if let onClose {
                    Button(action: onClose) {
                        Image(systemName: "xmark")
                            .font(theme.typography.caption)
                    }
                    .buttonStyle(.plain)
                    .foregroundStyle(theme.colors.secondaryText)
                    .accessibilityLabel("Close panel")
                    .help("Close panel")
                }
            }
            .padding(theme.spacing.large)

            Divider()

            content
        }
    }

    private var paneTabs: some View {
        HStack(spacing: theme.spacing.small) {
            ForEach(availablePanes, id: \.self) { pane in
                Button {
                    activePane = pane
                } label: {
                    Label(pane.title, systemImage: pane.systemImage)
                        .font(theme.typography.caption)
                        .padding(.horizontal, theme.spacing.small)
                        .padding(.vertical, theme.spacing.xSmall)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.plain)
                .background(
                    RoundedRectangle(
                        cornerRadius: theme.metrics.activeTabCornerRadius,
                        style: .continuous
                    )
                        .fill(activePane == pane ? theme.colors.inputBackground : Color.clear)
                )
                .foregroundStyle(
                    activePane == pane
                        ? theme.colors.infoTint
                        : theme.colors.secondaryText
                )
            }
        }
    }
}

public struct ReaderSidebarEmptyState: View {
    public let systemImage: String
    public let title: String
    public let message: String

    @Environment(\.readerChromeTheme) private var theme

    public init(
        systemImage: String,
        title: String,
        message: String
    ) {
        self.systemImage = systemImage
        self.title = title
        self.message = message
    }

    public var body: some View {
        VStack(spacing: theme.spacing.small) {
            Image(systemName: systemImage)
                .font(theme.typography.title3)
                .foregroundStyle(theme.colors.secondaryText)

            Text(title)
                .font(theme.typography.callout)
                .foregroundStyle(theme.colors.secondaryText)

            Text(message)
                .font(theme.typography.caption)
                .foregroundStyle(theme.colors.tertiaryText)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(theme.spacing.large)
    }
}
