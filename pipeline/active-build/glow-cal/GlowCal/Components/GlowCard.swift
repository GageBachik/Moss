import SwiftUI

struct GlowCard<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .padding(Theme.Spacing.md)
            .background(Theme.Color.surface)
            .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.medium))
            .overlay(
                RoundedRectangle(cornerRadius: Theme.Radius.medium)
                    .stroke(Theme.Color.border.opacity(0.3), lineWidth: 0.5)
            )
    }
}

struct GlowButton: View {
    let title: String
    let icon: String?
    let style: ButtonStyle
    let action: () -> Void

    enum ButtonStyle {
        case primary, secondary, destructive
    }

    init(_ title: String, icon: String? = nil, style: ButtonStyle = .primary, action: @escaping () -> Void) {
        self.title = title
        self.icon = icon
        self.style = style
        self.action = action
    }

    private var backgroundColor: Color {
        switch style {
        case .primary: return Theme.Color.primary
        case .secondary: return Theme.Color.surface
        case .destructive: return Theme.Color.accent
        }
    }

    private var foregroundColor: Color {
        switch style {
        case .primary: return Theme.Color.background
        case .secondary: return Theme.Color.primary
        case .destructive: return .white
        }
    }

    var body: some View {
        Button {
            Theme.Haptic.tap()
            action()
        } label: {
            HStack(spacing: Theme.Spacing.sm) {
                if let icon {
                    Image(systemName: icon)
                        .font(.system(size: 14, weight: .semibold))
                }
                Text(title)
                    .font(Theme.Font.label())
            }
            .foregroundStyle(foregroundColor)
            .padding(.horizontal, Theme.Spacing.lg)
            .padding(.vertical, Theme.Spacing.md)
            .frame(maxWidth: .infinity)
            .background(backgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.medium))
            .overlay(
                RoundedRectangle(cornerRadius: Theme.Radius.medium)
                    .stroke(
                        style == .secondary ? Theme.Color.border.opacity(0.4) : .clear,
                        lineWidth: 1
                    )
            )
        }
    }
}

struct CategoryProgressRing: View {
    let progress: Double
    let accentColor: Color
    let size: CGFloat

    var body: some View {
        ZStack {
            Circle()
                .stroke(Theme.Color.muted.opacity(0.2), lineWidth: 3)
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    accentColor,
                    style: StrokeStyle(lineWidth: 3, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(Theme.Anim.default, value: progress)
        }
        .frame(width: size, height: size)
    }
}
