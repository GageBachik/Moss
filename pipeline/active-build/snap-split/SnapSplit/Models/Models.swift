import Foundation
import SwiftUI

// MARK: - Receipt Item
struct ReceiptItem: Identifiable, Equatable {
    let id = UUID()
    var name: String
    var price: Double
    var assignedTo: Friend?

    static func == (lhs: ReceiptItem, rhs: ReceiptItem) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Friend
struct Friend: Identifiable, Equatable, Hashable {
    let id = UUID()
    var name: String
    var colorIndex: Int

    var color: Color {
        Theme.friendColors[colorIndex % Theme.friendColors.count]
    }

    var initials: String {
        let parts = name.split(separator: " ")
        if parts.count >= 2 {
            return String(parts[0].prefix(1) + parts[1].prefix(1)).uppercased()
        }
        return String(name.prefix(2)).uppercased()
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

// MARK: - Split Session
struct SplitSession: Identifiable {
    let id = UUID()
    var date: Date
    var restaurantName: String
    var items: [ReceiptItem]
    var friends: [Friend]
    var subtotal: Double
    var tax: Double
    var tip: Double

    var total: Double {
        subtotal + tax + tip
    }

    func shareForFriend(_ friend: Friend) -> FriendShare {
        let friendItems = items.filter { $0.assignedTo == friend }
        let friendSubtotal = friendItems.reduce(0) { $0 + $1.price }

        // Proportional share of tax and tip based on items subtotal
        let proportion = subtotal > 0 ? friendSubtotal / subtotal : 0
        let friendTax = tax * proportion
        let friendTip = tip * proportion

        return FriendShare(
            friend: friend,
            items: friendItems,
            itemsTotal: friendSubtotal,
            taxShare: friendTax,
            tipShare: friendTip,
            total: friendSubtotal + friendTax + friendTip
        )
    }
}

// MARK: - Friend Share (Summary)
struct FriendShare: Identifiable {
    var id: UUID { friend.id }
    let friend: Friend
    let items: [ReceiptItem]
    let itemsTotal: Double
    let taxShare: Double
    let tipShare: Double
    let total: Double
}

// MARK: - Scan Tracking
class ScanTracker: ObservableObject {
    @AppStorage("monthlyScans") private var monthlyScans: Int = 0
    @AppStorage("scanMonth") private var scanMonth: String = ""
    @AppStorage("isPremium") var isPremium: Bool = false

    static let freeLimit = 5

    var scansUsed: Int {
        refreshMonth()
        return monthlyScans
    }

    var scansRemaining: Int {
        if isPremium { return 999 }
        return max(0, Self.freeLimit - scansUsed)
    }

    var canScan: Bool {
        isPremium || scansRemaining > 0
    }

    func recordScan() {
        refreshMonth()
        monthlyScans += 1
    }

    private func refreshMonth() {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM"
        let current = formatter.string(from: Date())
        if scanMonth != current {
            scanMonth = current
            monthlyScans = 0
        }
    }
}
