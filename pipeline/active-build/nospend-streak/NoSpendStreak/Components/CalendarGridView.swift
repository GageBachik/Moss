import SwiftUI
import SwiftData

struct CalendarGridView: View {
    let currentMonth: Date
    let spendDays: [SpendDay]
    let onDayTap: (Date) -> Void

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 4), count: 7)
    private let weekdaySymbols = Calendar.current.veryShortWeekdaySymbols

    var body: some View {
        VStack(spacing: Theme.Spacing.sm) {
            // Weekday headers
            HStack(spacing: 4) {
                ForEach(weekdaySymbols, id: \.self) { symbol in
                    Text(symbol)
                        .font(Theme.Font.caption())
                        .foregroundStyle(Theme.Color.muted)
                        .frame(maxWidth: .infinity)
                }
            }

            // Day grid
            LazyVGrid(columns: columns, spacing: 4) {
                // Leading empty cells
                ForEach(0..<leadingEmptyDays, id: \.self) { _ in
                    Color.clear.frame(height: 52)
                }

                // Day cells
                ForEach(1...daysInMonth, id: \.self) { day in
                    let date = dateFor(day: day)
                    let spendDay = spendDayFor(date: date)
                    DayCell(
                        dayNumber: day,
                        isToday: isToday(date),
                        isNoSpend: spendDay?.isNoSpend == true,
                        isSpent: spendDay?.didSpend == true,
                        isFuture: isFuture(date),
                        onTap: { onDayTap(date) }
                    )
                }
            }
        }
    }

    // MARK: - Calendar Math

    private var calendar: Calendar { Calendar.current }

    private var monthStart: Date {
        calendar.date(from: calendar.dateComponents([.year, .month], from: currentMonth))!
    }

    private var leadingEmptyDays: Int {
        let weekday = calendar.component(.weekday, from: monthStart)
        return weekday - calendar.firstWeekday
    }

    private var daysInMonth: Int {
        calendar.range(of: .day, in: .month, for: currentMonth)!.count
    }

    private func dateFor(day: Int) -> Date {
        calendar.date(byAdding: .day, value: day - 1, to: monthStart)!
    }

    private func spendDayFor(date: Date) -> SpendDay? {
        let target = calendar.startOfDay(for: date)
        return spendDays.first { calendar.startOfDay(for: $0.date) == target }
    }

    private func isToday(_ date: Date) -> Bool {
        calendar.isDateInToday(date)
    }

    private func isFuture(_ date: Date) -> Bool {
        date > Date()
    }
}
