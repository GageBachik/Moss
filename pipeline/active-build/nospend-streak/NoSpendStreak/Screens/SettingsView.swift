import SwiftUI
import SwiftData

struct SettingsView: View {
    @Bindable var settings: UserSettings
    @State private var showPaywall = false
    @State private var showShareSheet = false
    @Query private var allDays: [SpendDay]

    var body: some View {
        ZStack {
            Theme.Color.background.ignoresSafeArea()

            ScrollView {
                VStack(spacing: Theme.Spacing.lg) {
                    // Daily Budget
                    settingsSection(title: "Daily Budget") {
                        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                            Text("How much do you typically spend per day?")
                                .font(Theme.Font.caption())
                                .foregroundStyle(Theme.Color.muted)

                            HStack {
                                Text("$")
                                    .font(Theme.Font.statMedium())
                                    .foregroundStyle(Theme.Color.primary)

                                TextField("20", value: $settings.dailyBudget, format: .number)
                                    .font(Theme.Font.statMedium())
                                    .foregroundStyle(.white)
                                    .keyboardType(.decimalPad)
                            }
                            .padding(Theme.Spacing.md)
                            .background(
                                RoundedRectangle(cornerRadius: Theme.Radius.medium)
                                    .fill(Theme.Color.surface)
                            )
                        }
                    }

                    // Challenge Mode
                    settingsSection(title: "Challenge Mode") {
                        VStack(spacing: Theme.Spacing.sm) {
                            ForEach(ChallengeMode.allCases) { mode in
                                Button {
                                    Theme.Haptic.tap()
                                    settings.challengeMode = mode
                                } label: {
                                    HStack {
                                        Text(mode.displayName)
                                            .font(Theme.Font.body())
                                            .foregroundStyle(.white)

                                        Spacer()

                                        if settings.challengeMode == mode {
                                            Image(systemName: "checkmark.circle.fill")
                                                .foregroundStyle(Theme.Color.primary)
                                        } else {
                                            Circle()
                                                .strokeBorder(Theme.Color.border, lineWidth: 2)
                                                .frame(width: 22, height: 22)
                                        }
                                    }
                                    .padding(Theme.Spacing.md)
                                    .background(
                                        RoundedRectangle(cornerRadius: Theme.Radius.medium)
                                            .fill(Theme.Color.surface)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: Theme.Radius.medium)
                                                    .strokeBorder(
                                                        settings.challengeMode == mode ? Theme.Color.primary.opacity(0.4) : .clear,
                                                        lineWidth: 1
                                                    )
                                            )
                                    )
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }

                    // Share
                    settingsSection(title: "Share") {
                        Button {
                            Theme.Haptic.tap()
                            showShareSheet = true
                        } label: {
                            HStack {
                                Image(systemName: "square.and.arrow.up")
                                    .foregroundStyle(Theme.Color.primary)
                                Text("Share Your Streak Card")
                                    .font(Theme.Font.body())
                                    .foregroundStyle(.white)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundStyle(Theme.Color.muted)
                            }
                            .padding(Theme.Spacing.md)
                            .background(
                                RoundedRectangle(cornerRadius: Theme.Radius.medium)
                                    .fill(Theme.Color.surface)
                            )
                        }
                        .buttonStyle(.plain)
                    }

                    // Premium
                    settingsSection(title: "Premium") {
                        Button {
                            Theme.Haptic.tap()
                            showPaywall = true
                        } label: {
                            HStack {
                                Image(systemName: "star.fill")
                                    .foregroundStyle(Theme.Color.primary)
                                Text("Upgrade to Premium")
                                    .font(Theme.Font.body())
                                    .foregroundStyle(.white)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundStyle(Theme.Color.muted)
                            }
                            .padding(Theme.Spacing.md)
                            .background(
                                RoundedRectangle(cornerRadius: Theme.Radius.medium)
                                    .fill(Theme.Color.surface)
                            )
                        }
                        .buttonStyle(.plain)
                    }

                    // App Info
                    VStack(spacing: Theme.Spacing.xs) {
                        Text("NoSpend Streak")
                            .font(Theme.Font.caption())
                            .foregroundStyle(Theme.Color.muted)
                        Text("Version 1.0.0")
                            .font(Theme.Font.caption())
                            .foregroundStyle(Theme.Color.muted.opacity(0.5))
                    }
                    .padding(.top, Theme.Spacing.lg)

                    Spacer(minLength: Theme.Spacing.xl)
                }
                .padding(.horizontal, Theme.Spacing.md)
                .padding(.top, Theme.Spacing.md)
            }
        }
        .sheet(isPresented: $showPaywall) {
            PaywallView()
        }
        .sheet(isPresented: $showShareSheet) {
            shareSheet
        }
    }

    // MARK: - Section Helper

    private func settingsSection(title: String, @ViewBuilder content: () -> some View) -> some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
            Text(title)
                .font(Theme.Font.subheading())
                .foregroundStyle(.white)

            content()
        }
    }

    // MARK: - Share Sheet

    @ViewBuilder
    private var shareSheet: some View {
        let streakCount = StreakCalculator.currentStreak(from: allDays)
        let totalSaved = StreakCalculator.totalSaved(
            from: allDays.filter { $0.isNoSpend },
            dailyBudget: settings.dailyBudget
        )
        let successRate = StreakCalculator.monthlySuccessRate(from: allDays, in: Date())

        let cardView = ShareCardView(
            streakCount: streakCount,
            totalSaved: totalSaved,
            successRate: successRate
        )

        VStack(spacing: Theme.Spacing.lg) {
            cardView

            if let image = cardView.renderToImage() {
                ShareLink(
                    item: Image(uiImage: image),
                    preview: SharePreview("My NoSpend Streak", image: Image(uiImage: image))
                ) {
                    Text("Share")
                        .font(Theme.Font.body())
                        .foregroundStyle(Theme.Color.background)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, Theme.Spacing.md)
                        .background(
                            RoundedRectangle(cornerRadius: Theme.Radius.medium)
                                .fill(Theme.Color.primary)
                        )
                }
                .padding(.horizontal, Theme.Spacing.lg)
            }
        }
        .padding(.top, Theme.Spacing.lg)
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
        .background(Theme.Color.background)
    }
}
