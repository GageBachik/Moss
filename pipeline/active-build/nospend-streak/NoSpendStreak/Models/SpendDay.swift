import Foundation
import SwiftData

@Model
final class SpendDay {
    var date: Date
    var didSpend: Bool
    var amountSpent: Double
    var note: String

    init(date: Date, didSpend: Bool = false, amountSpent: Double = 0, note: String = "") {
        self.date = Calendar.current.startOfDay(for: date)
        self.didSpend = didSpend
        self.amountSpent = amountSpent
        self.note = note
    }

    var isNoSpend: Bool { !didSpend }
}

// MARK: - Calendar Helpers
extension SpendDay {
    static func predicate(for month: Date) -> Predicate<SpendDay> {
        let calendar = Calendar.current
        let start = calendar.date(from: calendar.dateComponents([.year, .month], from: month))!
        let end = calendar.date(byAdding: .month, value: 1, to: start)!
        return #Predicate<SpendDay> { day in
            day.date >= start && day.date < end
        }
    }
}

// MARK: - Streak Calculator
struct StreakCalculator {
    static func currentStreak(from days: [SpendDay]) -> Int {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let sorted = days.filter { $0.isNoSpend }.map { calendar.startOfDay(for: $0.date) }.sorted(by: >)

        guard !sorted.isEmpty else { return 0 }

        var streak = 0
        var expectedDate = today

        // If today isn't logged yet, start from yesterday
        if !sorted.contains(today) {
            expectedDate = calendar.date(byAdding: .day, value: -1, to: today)!
        }

        for date in sorted {
            if date == expectedDate {
                streak += 1
                expectedDate = calendar.date(byAdding: .day, value: -1, to: expectedDate)!
            } else if date < expectedDate {
                break
            }
        }

        return streak
    }

    static func longestStreak(from days: [SpendDay]) -> Int {
        let calendar = Calendar.current
        let sorted = days.filter { $0.isNoSpend }.map { calendar.startOfDay(for: $0.date) }.sorted()

        guard !sorted.isEmpty else { return 0 }

        var longest = 1
        var current = 1

        for i in 1..<sorted.count {
            let diff = calendar.dateComponents([.day], from: sorted[i-1], to: sorted[i]).day ?? 0
            if diff == 1 {
                current += 1
                longest = max(longest, current)
            } else if diff > 1 {
                current = 1
            }
        }

        return longest
    }

    static func totalSaved(from days: [SpendDay], dailyBudget: Double) -> Double {
        Double(days.filter { $0.isNoSpend }.count) * dailyBudget
    }

    static func monthlySuccessRate(from days: [SpendDay], in month: Date) -> Double {
        let calendar = Calendar.current
        let start = calendar.date(from: calendar.dateComponents([.year, .month], from: month))!
        let today = calendar.startOfDay(for: Date())

        let monthDays = days.filter {
            let d = calendar.startOfDay(for: $0.date)
            return d >= start && d <= today
        }

        guard !monthDays.isEmpty else { return 0 }
        let noSpendCount = monthDays.filter { $0.isNoSpend }.count
        return Double(noSpendCount) / Double(monthDays.count)
    }
}
