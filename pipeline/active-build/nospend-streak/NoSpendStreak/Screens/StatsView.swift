import SwiftUI
import SwiftData

struct StatsView: View {
    @Query private var allDays: [SpendDay]
    @Bindable var settings: UserSettings

    var body: some View {
        ZStack {
            Theme.Color.background.ignoresSafeArea()

            ScrollView {
                VStack(spacing: Theme.Spacing.lg) {
                    // Hero streak
                    StreakBadge(
                        count: currentStreak,
                        label: "Current Streak"
                    )
                    .padding(.top, Theme.Spacing.md)

                    // Stat cards grid
                    LazyVGrid(columns: [
                        GridItem(.flexible(), spacing: Theme.Spacing.sm),
                        GridItem(.flexible(), spacing: Theme.Spacing.sm)
                    ], spacing: Theme.Spacing.sm) {
                        StatCard(
                            title: "Longest Streak",
                            value: "\(longestStreak)d",
                            icon: "flame.fill",
                            valueColor: Theme.Color.accent
                        )
                        StatCard(
                            title: "No-Spend Days",
                            value: "\(totalNoSpendDays)",
                            icon: "star.fill"
                        )
                        StatCard(
                            title: "Success Rate",
                            value: "\(Int(successRate * 100))%",
                            icon: "chart.pie.fill",
                            valueColor: Theme.Color.success
                        )
                        StatCard(
                            title: "Total Saved",
                            value: "$\(Int(totalSaved))",
                            icon: "dollarsign.circle.fill",
                            valueColor: Theme.Color.success
                        )
                    }

                    // Monthly bar chart
                    monthlyChart

                    // Milestones
                    milestonesSection

                    Spacer(minLength: Theme.Spacing.xl)
                }
                .padding(.horizontal, Theme.Spacing.md)
            }
        }
        .overlay {
            if allDays.isEmpty {
                emptyState
            }
        }
    }

    // MARK: - Monthly Chart

    private var monthlyChart: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            Text("Monthly Overview")
                .font(Theme.Font.subheading())
                .foregroundStyle(.white)

            HStack(alignment: .bottom, spacing: Theme.Spacing.sm) {
                ForEach(last3Months, id: \.self) { month in
                    let data = monthData(for: month)
                    VStack(spacing: Theme.Spacing.xs) {
                        // Bar
                        ZStack(alignment: .bottom) {
                            RoundedRectangle(cornerRadius: Theme.Radius.small)
                                .fill(Theme.Color.border)
                                .frame(height: 120)

                            RoundedRectangle(cornerRadius: Theme.Radius.small)
                                .fill(
                                    LinearGradient(
                                        colors: [Theme.Color.primary, Theme.Color.primary.opacity(0.6)],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                                .frame(height: max(4, 120 * data.rate))
                        }
                        .frame(maxWidth: .infinity)

                        Text(data.label)
                            .font(Theme.Font.caption())
                            .foregroundStyle(Theme.Color.muted)

                        Text("\(Int(data.rate * 100))%")
                            .font(Theme.Font.caption())
                            .foregroundStyle(Theme.Color.primary)
                    }
                }
            }
        }
        .padding(Theme.Spacing.md)
        .background(
            RoundedRectangle(cornerRadius: Theme.Radius.medium)
                .fill(Theme.Color.surface)
        )
    }

    // MARK: - Milestones

    private var milestonesSection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            Text("Milestones")
                .font(Theme.Font.subheading())
                .foregroundStyle(.white)

            HStack(spacing: Theme.Spacing.md) {
                ForEach([7, 14, 30, 60, 100], id: \.self) { target in
                    MilestoneBadge(
                        days: target,
                        isAchieved: longestStreak >= target
                    )
                }
            }
            .frame(maxWidth: .infinity)
        }
        .padding(Theme.Spacing.md)
        .background(
            RoundedRectangle(cornerRadius: Theme.Radius.medium)
                .fill(Theme.Color.surface)
        )
    }

    // MARK: - Empty State

    private var emptyState: some View {
        ZStack {
            Theme.Color.background.ignoresSafeArea()

            VStack(spacing: Theme.Spacing.md) {
                Image(systemName: "chart.bar")
                    .font(.system(size: 48))
                    .foregroundStyle(Theme.Color.muted.opacity(0.4))

                Text("Start logging to see your stats grow")
                    .font(Theme.Font.body())
                    .foregroundStyle(Theme.Color.muted)
                    .multilineTextAlignment(.center)
            }
        }
    }

    // MARK: - Computed Properties

    private var currentStreak: Int {
        StreakCalculator.currentStreak(from: allDays)
    }

    private var longestStreak: Int {
        StreakCalculator.longestStreak(from: allDays)
    }

    private var totalNoSpendDays: Int {
        allDays.filter { $0.isNoSpend }.count
    }

    private var successRate: Double {
        StreakCalculator.monthlySuccessRate(from: allDays, in: Date())
    }

    private var totalSaved: Double {
        StreakCalculator.totalSaved(from: allDays.filter { $0.isNoSpend }, dailyBudget: settings.dailyBudget)
    }

    private var last3Months: [Date] {
        let calendar = Calendar.current
        return (0..<3).reversed().compactMap {
            calendar.date(byAdding: .month, value: -$0, to: Date())
        }
    }

    private func monthData(for month: Date) -> (label: String, rate: CGFloat) {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM"
        let label = formatter.string(from: month)
        let rate = StreakCalculator.monthlySuccessRate(from: allDays, in: month)
        return (label, CGFloat(rate))
    }
}
