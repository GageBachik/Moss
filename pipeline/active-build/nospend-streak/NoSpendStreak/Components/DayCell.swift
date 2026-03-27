import SwiftUI

struct DayCell: View {
    let dayNumber: Int
    let isToday: Bool
    let isNoSpend: Bool
    let isSpent: Bool
    let isFuture: Bool
    let onTap: () -> Void

    @State private var starScale: CGFloat = 0
    @State private var showParticles: Bool = false

    var body: some View {
        Button(action: {
            Theme.Haptic.tap()
            onTap()
        }) {
            ZStack {
                // Background
                RoundedRectangle(cornerRadius: Theme.Radius.small)
                    .fill(cellBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: Theme.Radius.small)
                            .strokeBorder(isToday ? Theme.Color.primary.opacity(0.6) : .clear, lineWidth: 2)
                    )

                VStack(spacing: 2) {
                    // Day number
                    Text("\(dayNumber)")
                        .font(Theme.Font.label())
                        .foregroundStyle(dayNumberColor)

                    // Star or dot indicator
                    if isNoSpend {
                        Image(systemName: "star.fill")
                            .font(.system(size: 14))
                            .foregroundStyle(Theme.Color.primary)
                            .scaleEffect(starScale)
                            .onAppear {
                                withAnimation(Theme.Anim.stamp) {
                                    starScale = 1.0
                                }
                            }
                    } else if isSpent {
                        Circle()
                            .fill(Theme.Color.danger.opacity(0.7))
                            .frame(width: 6, height: 6)
                    } else {
                        Spacer()
                            .frame(height: 14)
                    }
                }
                .padding(.vertical, Theme.Spacing.xs)

                // Gold particle burst
                if showParticles {
                    ParticleBurst()
                }
            }
            .frame(height: 52)
        }
        .buttonStyle(.plain)
        .disabled(isFuture)
        .opacity(isFuture ? 0.3 : 1.0)
    }

    private var cellBackground: some ShapeStyle {
        if isToday {
            return Theme.Color.surface.opacity(0.8)
        }
        return Theme.Color.surface.opacity(0.4)
    }

    private var dayNumberColor: Color {
        if isNoSpend { return Theme.Color.primary }
        if isSpent { return Theme.Color.danger.opacity(0.8) }
        if isFuture { return Theme.Color.muted.opacity(0.5) }
        return Theme.Color.muted
    }
}

// MARK: - Star Stamp Animation
struct StarStampView: View {
    @State private var scale: CGFloat = 0
    @State private var rotation: Double = -30

    var body: some View {
        Image(systemName: "star.fill")
            .font(.system(size: 16))
            .foregroundStyle(Theme.Color.primary)
            .scaleEffect(scale)
            .rotationEffect(.degrees(rotation))
            .onAppear {
                withAnimation(Theme.Anim.stamp) {
                    scale = 1.0
                    rotation = 0
                }
            }
    }
}

// MARK: - Particle Burst
struct ParticleBurst: View {
    @State private var particles: [(offset: CGSize, opacity: Double)] = []

    var body: some View {
        ZStack {
            ForEach(0..<8, id: \.self) { i in
                Circle()
                    .fill(Theme.Color.primary)
                    .frame(width: 3, height: 3)
                    .offset(particles.indices.contains(i) ? particles[i].offset : .zero)
                    .opacity(particles.indices.contains(i) ? particles[i].opacity : 0)
            }
        }
        .onAppear {
            let angles = stride(from: 0.0, to: 360.0, by: 45.0).map { $0 }
            particles = angles.map { _ in (offset: .zero, opacity: 1.0) }

            withAnimation(.easeOut(duration: 0.5)) {
                particles = angles.enumerated().map { index, angle in
                    let rad = angle * .pi / 180
                    let distance: CGFloat = 20
                    return (
                        offset: CGSize(width: cos(rad) * distance, height: sin(rad) * distance),
                        opacity: 0.0
                    )
                }
            }
        }
    }
}
