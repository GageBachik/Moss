import SwiftUI

/// A custom view that evokes a compact mirror — the app's design metaphor.
/// Uses layered circles, a reflective gradient, and a hinge detail.
struct CompactMirrorIcon: View {
    let size: CGFloat
    var useGradient: Bool = false

    private var outerColor: Color {
        useGradient ? Theme.Color.primary : Theme.Color.surface
    }

    var body: some View {
        ZStack {
            // Outer case — rose-gold rim
            Circle()
                .fill(
                    useGradient
                        ? LinearGradient(
                            colors: [Theme.Color.primary, Theme.Color.border],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                        : LinearGradient(
                            colors: [Theme.Color.surface, Theme.Color.surface],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                )
                .frame(width: size, height: size)

            // Gold trim ring
            Circle()
                .stroke(Theme.Color.border.opacity(0.6), lineWidth: size * 0.025)
                .frame(width: size * 0.88, height: size * 0.88)

            // Mirror surface — inner reflective circle
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color.white.opacity(0.35),
                            Theme.Color.primary.opacity(0.15),
                            Theme.Color.border.opacity(0.08)
                        ],
                        center: .init(x: 0.35, y: 0.35),
                        startRadius: 0,
                        endRadius: size * 0.4
                    )
                )
                .frame(width: size * 0.72, height: size * 0.72)

            // Shine highlight — top-left reflection spot
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color.white.opacity(0.5),
                            Color.white.opacity(0.0)
                        ],
                        center: .center,
                        startRadius: 0,
                        endRadius: size * 0.12
                    )
                )
                .frame(width: size * 0.24, height: size * 0.24)
                .offset(x: -size * 0.16, y: -size * 0.16)

            // Hinge notch at the bottom
            RoundedRectangle(cornerRadius: size * 0.02)
                .fill(Theme.Color.border.opacity(0.5))
                .frame(width: size * 0.12, height: size * 0.04)
                .offset(y: size * 0.44)

            // Small sparkle accent
            Image(systemName: "sparkle")
                .font(.system(size: size * 0.14))
                .foregroundStyle(useGradient ? Theme.Color.background.opacity(0.7) : Theme.Color.primary.opacity(0.6))
                .offset(x: size * 0.12, y: -size * 0.08)
        }
    }
}
