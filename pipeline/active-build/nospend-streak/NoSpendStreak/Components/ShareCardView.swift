import SwiftUI

struct ShareCardView: View {
    let streakCount: Int
    let totalSaved: Double
    let successRate: Double

    var body: some View {
        VStack(spacing: Theme.Spacing.lg) {
            // Header
            VStack(spacing: Theme.Spacing.sm) {
                Image(systemName: "star.fill")
                    .font(.system(size: 40))
                    .foregroundStyle(Theme.Color.primary)

                Text("NoSpend Streak")
                    .font(Theme.Font.heading())
                    .foregroundStyle(.white)
            }

            // Stats
            VStack(spacing: Theme.Spacing.md) {
                HStack(spacing: Theme.Spacing.lg) {
                    shareStatItem(value: "\(streakCount)", label: "Day Streak")
                    shareStatItem(value: "$\(Int(totalSaved))", label: "Saved")
                }

                // Success rate bar
                VStack(spacing: Theme.Spacing.xs) {
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: Theme.Radius.pill)
                                .fill(Theme.Color.border)
                                .frame(height: 8)

                            RoundedRectangle(cornerRadius: Theme.Radius.pill)
                                .fill(
                                    LinearGradient(
                                        colors: [Theme.Color.primary, Theme.Color.accent],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .frame(width: geo.size.width * successRate, height: 8)
                        }
                    }
                    .frame(height: 8)

                    Text("\(Int(successRate * 100))% Success Rate")
                        .font(Theme.Font.caption())
                        .foregroundStyle(Theme.Color.muted)
                }
            }
            .padding(Theme.Spacing.lg)
            .background(
                RoundedRectangle(cornerRadius: Theme.Radius.large)
                    .fill(Theme.Color.surface)
            )
        }
        .padding(Theme.Spacing.lg)
        .frame(width: 320)
        .background(
            RoundedRectangle(cornerRadius: Theme.Radius.large)
                .fill(Theme.Color.background)
                .overlay(
                    RoundedRectangle(cornerRadius: Theme.Radius.large)
                        .strokeBorder(
                            LinearGradient(
                                colors: [Theme.Color.primary.opacity(0.5), Theme.Color.accent.opacity(0.3)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 2
                        )
                )
        )
    }

    private func shareStatItem(value: String, label: String) -> some View {
        VStack(spacing: Theme.Spacing.xs) {
            Text(value)
                .font(Theme.Font.statMedium())
                .foregroundStyle(Theme.Color.primary)
            Text(label)
                .font(Theme.Font.caption())
                .foregroundStyle(Theme.Color.muted)
        }
    }
}

// MARK: - Share Card Renderer
extension ShareCardView {
    @MainActor
    func renderToImage() -> UIImage? {
        let renderer = ImageRenderer(content: self)
        renderer.scale = 3.0
        return renderer.uiImage
    }
}
