import Foundation
import SwiftData

@Model
final class MaintenanceCategory {
    var id: UUID
    var name: String
    var icon: String
    var frequencyDays: Int
    var costPerVisit: Double?
    var accentHex: String
    var createdAt: Date
    @Relationship(deleteRule: .cascade) var completions: [Completion]

    init(
        name: String,
        icon: String = "sparkles",
        frequencyDays: Int = 21,
        costPerVisit: Double? = nil,
        accentHex: String = "#E8A87C"
    ) {
        self.id = UUID()
        self.name = name
        self.icon = icon
        self.frequencyDays = frequencyDays
        self.costPerVisit = costPerVisit
        self.accentHex = accentHex
        self.createdAt = Date()
        self.completions = []
    }

    var lastCompleted: Date? {
        completions.sorted { $0.date > $1.date }.first?.date
    }

    var nextDueDate: Date {
        guard let last = lastCompleted else {
            return createdAt
        }
        return Calendar.current.date(byAdding: .day, value: frequencyDays, to: last) ?? last
    }

    var daysUntilDue: Int {
        Calendar.current.dateComponents([.day], from: Calendar.current.startOfDay(for: Date()), to: Calendar.current.startOfDay(for: nextDueDate)).day ?? 0
    }

    var isOverdue: Bool {
        daysUntilDue < 0
    }

    var cycleProgress: Double {
        guard let last = lastCompleted else { return 1.0 }
        let totalDays = Double(frequencyDays)
        let elapsed = Date().timeIntervalSince(last) / 86400.0
        return min(elapsed / totalDays, 1.0)
    }

    var accentColor: SwiftUI.Color {
        SwiftUI.Color(hex: accentHex)
    }
}

import SwiftUI

@Model
final class Completion {
    var id: UUID
    var date: Date
    var cost: Double?
    var notes: String?

    init(date: Date = Date(), cost: Double? = nil, notes: String? = nil) {
        self.id = UUID()
        self.date = date
        self.cost = cost
        self.notes = notes
    }
}
