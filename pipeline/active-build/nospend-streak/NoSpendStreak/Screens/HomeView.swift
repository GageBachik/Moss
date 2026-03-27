import SwiftUI
import SwiftData

struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var allDays: [SpendDay]
    @State private var currentMonth = Date()
    @State private var showLogSheet = false
    @State private var selectedDate: Date?
    @Bindable var settings: UserSettings

    var body: some View {
        ZStack {
            Theme.Color.background.ignoresSafeArea()

            ScrollView {
                VStack(spacing: Theme.Spacing.lg) {
                    // Streak badge
                    StreakBadge(
                        count: currentStreak,
                        label: currentStreak == 1 ? "day streak" : "day streak"
                    )
                    .padding(.top, Theme.Spacing.md)

                    // Month navigation
                    monthHeader

                    // Calendar grid
                    CalendarGridView(
                        currentMonth: currentMonth,
                        spendDays: monthDays,
                        onDayTap: { date in
                            selectedDate = date
                            showLogSheet = true
                        }
                    )
                    .padding(.horizontal, Theme.Spacing.sm)

                    // Savings card
                    savingsCard

                    Spacer(minLength: 80)
                }
                .padding(.horizontal, Theme.Spacing.md)
            }

            // FAB
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    logTodayButton
                        .padding(.trailing, Theme.Spacing.lg)
                        .padding(.bottom, Theme.Spacing.md)
                }
            }
        }
        .sheet(isPresented: $showLogSheet) {
            LogDaySheet(
                date: selectedDate ?? Date(),
                existingDay: spendDayFor(date: selectedDate ?? Date()),
                onSave: { didSpend, amount, note in
                    logDay(date: selectedDate ?? Date(), didSpend: didSpend, amount: amount, note: note)
                }
            )
            .presentationDetents([.medium])
            .presentationDragIndicator(.visible)
        }
    }

    // MARK: - Subviews

    private var monthHeader: some View {
        HStack {
            Button {
                Theme.Haptic.selection()
                withAnimation(Theme.Anim.default) {
                    currentMonth = Calendar.current.date(byAdding: .month, value: -1, to: currentMonth)!
                }
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(Theme.Color.muted)
                    .frame(width: 44, height: 44)
            }

            Spacer()

            Text(monthYearString)
                .font(Theme.Font.subheading())
                .foregroundStyle(.white)

            Spacer()

            Button {
                Theme.Haptic.selection()
                withAnimation(Theme.Anim.default) {
                    currentMonth = Calendar.current.date(byAdding: .month, value: 1, to: currentMonth)!
                }
            } label: {
                Image(systemName: "chevron.right")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(Theme.Color.muted)
                    .frame(width: 44, height: 44)
            }
        }
    }

    private var savingsCard: some View {
        HStack {
            VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                Text("Estimated saved this month")
                    .font(Theme.Font.caption())
                    .foregroundStyle(Theme.Color.muted)
                Text("$\(Int(monthlySaved))")
                    .font(Theme.Font.statMedium())
                    .foregroundStyle(Theme.Color.success)
            }

            Spacer()

            Image(systemName: "dollarsign.circle.fill")
                .font(.system(size: 32))
                .foregroundStyle(Theme.Color.success.opacity(0.6))
        }
        .padding(Theme.Spacing.md)
        .background(
            RoundedRectangle(cornerRadius: Theme.Radius.medium)
                .fill(Theme.Color.surface)
        )
    }

    private var logTodayButton: some View {
        Button {
            Theme.Haptic.tap()
            selectedDate = Date()
            showLogSheet = true
        } label: {
            Image(systemName: "plus")
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(Theme.Color.background)
                .frame(width: 56, height: 56)
                .background(
                    Circle()
                        .fill(Theme.Color.primary)
                        .shadow(color: Theme.Color.primary.opacity(0.4), radius: 12, y: 4)
                )
        }
    }

    // MARK: - Computed

    private var currentStreak: Int {
        StreakCalculator.currentStreak(from: allDays)
    }

    private var monthDays: [SpendDay] {
        let calendar = Calendar.current
        let start = calendar.date(from: calendar.dateComponents([.year, .month], from: currentMonth))!
        let end = calendar.date(byAdding: .month, value: 1, to: start)!
        return allDays.filter { $0.date >= start && $0.date < end }
    }

    private var monthlySaved: Double {
        StreakCalculator.totalSaved(from: monthDays.filter { $0.isNoSpend }, dailyBudget: settings.dailyBudget)
    }

    private var monthYearString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: currentMonth)
    }

    // MARK: - Helpers

    private func spendDayFor(date: Date) -> SpendDay? {
        let target = Calendar.current.startOfDay(for: date)
        return allDays.first { Calendar.current.startOfDay(for: $0.date) == target }
    }

    private func logDay(date: Date, didSpend: Bool, amount: Double, note: String) {
        let target = Calendar.current.startOfDay(for: date)
        if let existing = spendDayFor(date: target) {
            existing.didSpend = didSpend
            existing.amountSpent = amount
            existing.note = note
        } else {
            let day = SpendDay(date: target, didSpend: didSpend, amountSpent: amount, note: note)
            modelContext.insert(day)
        }

        if !didSpend {
            Theme.Haptic.stamp()
        }
    }
}

// MARK: - Log Day Sheet
struct LogDaySheet: View {
    let date: Date
    let existingDay: SpendDay?
    let onSave: (Bool, Double, String) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var didSpend: Bool = false
    @State private var amount: String = ""
    @State private var note: String = ""

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.Color.background.ignoresSafeArea()

                VStack(spacing: Theme.Spacing.lg) {
                    // Date header
                    Text(dateString)
                        .font(Theme.Font.subheading())
                        .foregroundStyle(.white)

                    // Toggle buttons
                    HStack(spacing: Theme.Spacing.md) {
                        logOptionButton(title: "No Spend", icon: "star.fill", isSelected: !didSpend) {
                            didSpend = false
                            Theme.Haptic.tap()
                        }

                        logOptionButton(title: "Spent", icon: "dollarsign.circle", isSelected: didSpend) {
                            didSpend = true
                            Theme.Haptic.tap()
                        }
                    }

                    if didSpend {
                        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                            Text("Amount spent")
                                .font(Theme.Font.label())
                                .foregroundStyle(Theme.Color.muted)

                            TextField("$0", text: $amount)
                                .font(Theme.Font.statMedium())
                                .foregroundStyle(.white)
                                .keyboardType(.decimalPad)
                                .padding(Theme.Spacing.md)
                                .background(
                                    RoundedRectangle(cornerRadius: Theme.Radius.medium)
                                        .fill(Theme.Color.surface)
                                )
                        }
                        .transition(.opacity.combined(with: .move(edge: .top)))
                    }

                    Spacer()

                    // Save button
                    Button {
                        let amountValue = Double(amount) ?? 0
                        onSave(didSpend, amountValue, note)
                        dismiss()
                    } label: {
                        Text(didSpend ? "Log Spend" : "Earn Your Star ⭐")
                            .font(Theme.Font.body())
                            .foregroundStyle(Theme.Color.background)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, Theme.Spacing.md)
                            .background(
                                RoundedRectangle(cornerRadius: Theme.Radius.medium)
                                    .fill(didSpend ? Theme.Color.danger : Theme.Color.primary)
                            )
                    }
                }
                .padding(Theme.Spacing.lg)
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(Theme.Color.muted)
                    }
                }
            }
        }
        .onAppear {
            if let existing = existingDay {
                didSpend = existing.didSpend
                amount = existing.amountSpent > 0 ? String(format: "%.2f", existing.amountSpent) : ""
                note = existing.note
            }
        }
    }

    private func logOptionButton(title: String, icon: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: Theme.Spacing.sm) {
                Image(systemName: icon)
                    .font(.system(size: 28))
                Text(title)
                    .font(Theme.Font.label())
            }
            .foregroundStyle(isSelected ? (title == "Spent" ? Theme.Color.danger : Theme.Color.primary) : Theme.Color.muted)
            .frame(maxWidth: .infinity)
            .padding(.vertical, Theme.Spacing.lg)
            .background(
                RoundedRectangle(cornerRadius: Theme.Radius.medium)
                    .fill(Theme.Color.surface)
                    .overlay(
                        RoundedRectangle(cornerRadius: Theme.Radius.medium)
                            .strokeBorder(
                                isSelected ? (title == "Spent" ? Theme.Color.danger : Theme.Color.primary) : .clear,
                                lineWidth: 2
                            )
                    )
            )
        }
        .buttonStyle(.plain)
    }

    private var dateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d"
        return formatter.string(from: date)
    }
}

// MARK: - Empty State
struct EmptyCalendarState: View {
    var body: some View {
        VStack(spacing: Theme.Spacing.md) {
            Image(systemName: "star")
                .font(.system(size: 48))
                .foregroundStyle(Theme.Color.primary.opacity(0.4))

            Text("Your first gold star is waiting")
                .font(Theme.Font.subheading())
                .foregroundStyle(.white)

            Text("Tap + to log today")
                .font(Theme.Font.body())
                .foregroundStyle(Theme.Color.muted)
        }
        .padding(Theme.Spacing.xl)
    }
}
