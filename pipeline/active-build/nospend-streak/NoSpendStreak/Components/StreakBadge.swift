import SwiftUI

struct StreakBadge: View {
    let count: Int
    let label: String

    @State private var glowOpacity: Double = 0.3

    var body: some View {
        VStack(spacing: Theme.Spacing.xs) {
            ZStack {
                // Glow ring
                Circle()
                    .fill(Theme.Color.primary.opacity(glowOpacity))
                    .frame(width: 100, height: 100)
                    .blur(radius: 20)

                // Badge circle
                Circle()
                    .fill(Theme.Color.surface)
                    .frame(width: 80, height: 80)
                    .overlay(
                        Circle()
                            .strokeBorder(
                                LinearGradient(
                                    colors: [Theme.Color.primary, Theme.Color.accent],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 3
                            )
                    )

                // Count
                Text("\(count)")
                    .font(Theme.Font.statLarge())
                    .foregroundStyle(Theme.Color.primary)
            }

            Text(label)
                .font(Theme.Font.label())
                .foregroundStyle(Theme.Color.muted)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                glowOpacity = 0.6
            }
        }
    }
}

// MARK: - Stat Card
struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    var valueColor: Color = Theme.Color.primary

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
            HStack(spacing: Theme.Spacing.xs) {
                Image(systemName: icon)
                    .font(.system(size: 12))
                    .foregroundStyle(Theme.Color.muted)
                Text(title)
                    .font(Theme.Font.caption())
                    .foregroundStyle(Theme.Color.muted)
            }

            Text(value)
                .font(Theme.Font.statMedium())
                .foregroundStyle(valueColor)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(Theme.Spacing.md)
        .background(
            RoundedRectangle(cornerRadius: Theme.Radius.medium)
                .fill(Theme.Color.surface)
        )
    }
}

// MARK: - Milestone Badge
struct MilestoneBadge: View {
    let days: Int
    let isAchieved: Bool

    var body: some View {
        VStack(spacing: Theme.Spacing.xs) {
            ZStack {
                Circle()
                    .fill(isAchieved ? Theme.Color.primary.opacity(0.15) : Theme.Color.surface)
                    .frame(width: 56, height: 56)

                Image(systemName: isAchieved ? "star.fill" : "star")
                    .font(.system(size: 24))
                    .foregroundStyle(isAchieved ? Theme.Color.primary : Theme.Color.muted.opacity(0.4))
            }

            Text("\(days)d")
                .font(Theme.Font.caption())
                .foregroundStyle(isAchieved ? Theme.Color.primary : Theme.Color.muted.opacity(0.4))
        }
    }
}
