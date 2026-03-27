import SwiftUI

struct ItemReviewView: View {
    @Environment(\.dismiss) private var dismiss
    @State var session: SplitSession
    @State private var selectedItemId: UUID?
    @State private var selectedFriend: Friend?
    @State private var showAddFriend = false
    @State private var newFriendName = ""
    @State private var tipPercentage: Double = 18
    @State private var showSummary = false
    var onComplete: (SplitSession) -> Void

    private var tipAmount: Double {
        session.subtotal * (tipPercentage / 100)
    }

    private var allItemsAssigned: Bool {
        session.items.allSatisfy { $0.assignedTo != nil }
    }

    var body: some View {
        ZStack {
            Theme.Color.background
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Top bar
                HStack {
                    Button(action: {
                        Theme.Haptic.tap()
                        dismiss()
                    }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(width: 36, height: 36)
                            .background(Circle().fill(.white.opacity(0.15)))
                    }

                    Spacer()

                    Text("Split Items")
                        .font(Theme.Font.subheading())
                        .foregroundColor(Theme.Color.textOnDark)

                    Spacer()

                    Button(action: {
                        Theme.Haptic.success()
                        var finalSession = session
                        finalSession.tip = tipAmount
                        showSummary = true
                    }) {
                        Text("Done")
                            .font(Theme.Font.label())
                            .foregroundColor(allItemsAssigned ? Theme.Color.primary : Theme.Color.textLight)
                            .padding(.horizontal, Theme.Spacing.md)
                            .padding(.vertical, Theme.Spacing.sm)
                            .background(
                                Capsule()
                                    .fill(allItemsAssigned ? Theme.Color.primary.opacity(0.15) : .clear)
                            )
                    }
                }
                .padding(.horizontal, Theme.Spacing.md)
                .padding(.top, Theme.Spacing.md)

                // Receipt items
                ScrollView {
                    VStack(spacing: Theme.Spacing.sm) {
                        ReceiptCard {
                            VStack(spacing: 0) {
                                // Restaurant name
                                Text(session.restaurantName)
                                    .font(Theme.Font.subheading())
                                    .foregroundColor(Theme.Color.text)
                                    .frame(maxWidth: .infinity)
                                    .padding(.bottom, Theme.Spacing.sm)

                                DashedSeparator()

                                // Line items
                                ForEach(Array(session.items.enumerated()), id: \.element.id) { index, item in
                                    ReceiptLineRow(
                                        name: item.name,
                                        price: item.price,
                                        highlightColor: item.assignedTo?.color
                                    ) {
                                        selectedItemId = item.id
                                        if let friend = selectedFriend {
                                            assignItem(at: index, to: friend)
                                        }
                                    }
                                    .background(
                                        selectedItemId == item.id
                                            ? Theme.Color.primary.opacity(0.08)
                                            : Color.clear
                                    )
                                    .cornerRadius(Theme.Radius.small)
                                }

                                DashedSeparator()

                                // Subtotal
                                HStack {
                                    Text("Subtotal")
                                        .font(Theme.Font.label())
                                        .foregroundColor(Theme.Color.textLight)
                                    Spacer()
                                    Text(String(format: "$%.2f", session.subtotal))
                                        .font(Theme.Font.label())
                                        .foregroundColor(Theme.Color.textLight)
                                }
                                .padding(.vertical, Theme.Spacing.xs)

                                // Tax
                                HStack {
                                    Text("Tax")
                                        .font(Theme.Font.label())
                                        .foregroundColor(Theme.Color.textLight)
                                    Spacer()
                                    Text(String(format: "$%.2f", session.tax))
                                        .font(Theme.Font.label())
                                        .foregroundColor(Theme.Color.textLight)
                                }
                                .padding(.vertical, Theme.Spacing.xs)

                                // Tip
                                VStack(spacing: Theme.Spacing.xs) {
                                    HStack {
                                        Text("Tip (\(Int(tipPercentage))%)")
                                            .font(Theme.Font.label())
                                            .foregroundColor(Theme.Color.textLight)
                                        Spacer()
                                        Text(String(format: "$%.2f", tipAmount))
                                            .font(Theme.Font.label())
                                            .foregroundColor(Theme.Color.textLight)
                                    }

                                    // Tip quick select
                                    HStack(spacing: Theme.Spacing.sm) {
                                        ForEach([15, 18, 20, 25], id: \.self) { pct in
                                            Button(action: {
                                                Theme.Haptic.tap()
                                                withAnimation(Theme.Anim.default) {
                                                    tipPercentage = Double(pct)
                                                }
                                            }) {
                                                Text("\(pct)%")
                                                    .font(Theme.Font.caption())
                                                    .foregroundColor(
                                                        Int(tipPercentage) == pct
                                                            ? .white
                                                            : Theme.Color.text
                                                    )
                                                    .padding(.horizontal, Theme.Spacing.sm)
                                                    .padding(.vertical, Theme.Spacing.xs)
                                                    .background(
                                                        Capsule()
                                                            .fill(
                                                                Int(tipPercentage) == pct
                                                                    ? Theme.Color.primary
                                                                    : Theme.Color.textLight.opacity(0.15)
                                                            )
                                                    )
                                            }
                                        }
                                    }
                                }
                                .padding(.vertical, Theme.Spacing.xs)

                                DashedSeparator()

                                // Total
                                HStack {
                                    Text("TOTAL")
                                        .font(Theme.Font.price())
                                        .foregroundColor(Theme.Color.text)
                                    Spacer()
                                    Text(String(format: "$%.2f", session.subtotal + session.tax + tipAmount))
                                        .font(Theme.Font.price())
                                        .foregroundColor(Theme.Color.text)
                                }
                                .padding(.vertical, Theme.Spacing.sm)
                            }
                        }
                        .padding(.horizontal, Theme.Spacing.md)

                        // Split equally button
                        if !session.friends.isEmpty {
                            Button(action: {
                                Theme.Haptic.medium()
                                splitUnassignedEqually()
                            }) {
                                HStack {
                                    Image(systemName: "arrow.triangle.branch")
                                    Text("Split remaining equally")
                                }
                                .font(Theme.Font.label())
                                .foregroundColor(Theme.Color.primary)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, Theme.Spacing.md)
                                .background(
                                    RoundedRectangle(cornerRadius: Theme.Radius.medium)
                                        .stroke(Theme.Color.primary, lineWidth: 1.5)
                                )
                            }
                            .padding(.horizontal, Theme.Spacing.md)
                        }
                    }
                    .padding(.top, Theme.Spacing.md)
                    .padding(.bottom, 160)
                }

                // Friend bar at bottom
                VStack(spacing: Theme.Spacing.sm) {
                    Rectangle()
                        .fill(Theme.Color.textLight.opacity(0.2))
                        .frame(height: 1)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: Theme.Spacing.md) {
                            // Add friend button
                            Button(action: {
                                Theme.Haptic.tap()
                                showAddFriend = true
                            }) {
                                VStack(spacing: Theme.Spacing.xs) {
                                    Circle()
                                        .stroke(style: StrokeStyle(lineWidth: 2, dash: [5]))
                                        .foregroundColor(Theme.Color.textLight)
                                        .frame(width: 48, height: 48)
                                        .overlay(
                                            Image(systemName: "plus")
                                                .foregroundColor(Theme.Color.textLight)
                                        )
                                    Text("Add")
                                        .font(Theme.Font.caption())
                                        .foregroundColor(Theme.Color.textLight)
                                }
                            }

                            ForEach(session.friends) { friend in
                                let itemCount = session.items.filter { $0.assignedTo == friend }.count
                                FriendChip(
                                    friend: friend,
                                    isSelected: selectedFriend == friend,
                                    itemCount: itemCount
                                ) {
                                    selectedFriend = (selectedFriend == friend) ? nil : friend
                                    // If an item is selected, assign it
                                    if let itemId = selectedItemId, selectedFriend != nil {
                                        if let idx = session.items.firstIndex(where: { $0.id == itemId }) {
                                            assignItem(at: idx, to: friend)
                                        }
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, Theme.Spacing.md)
                    }

                    // Per-person totals
                    if !session.friends.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: Theme.Spacing.md) {
                                ForEach(session.friends) { friend in
                                    let share = session.shareForFriend(friend)
                                    HStack(spacing: Theme.Spacing.xs) {
                                        Circle()
                                            .fill(friend.color)
                                            .frame(width: 12, height: 12)
                                        Text(friend.name.split(separator: " ").first.map(String.init) ?? friend.name)
                                            .font(Theme.Font.caption())
                                            .foregroundColor(Theme.Color.textLight)
                                        Text(String(format: "$%.2f", share.total))
                                            .font(Theme.Font.label())
                                            .foregroundColor(Theme.Color.textOnDark)
                                    }
                                }
                            }
                            .padding(.horizontal, Theme.Spacing.md)
                        }
                    }
                }
                .padding(.vertical, Theme.Spacing.sm)
                .background(Theme.Color.background)
            }
        }
        .alert("Add Friend", isPresented: $showAddFriend) {
            TextField("Name", text: $newFriendName)
            Button("Add") {
                if !newFriendName.isEmpty {
                    let friend = Friend(
                        name: newFriendName,
                        colorIndex: session.friends.count
                    )
                    session.friends.append(friend)
                    newFriendName = ""
                    Theme.Haptic.success()
                }
            }
            Button("Cancel", role: .cancel) {
                newFriendName = ""
            }
        }
        .fullScreenCover(isPresented: $showSummary) {
            var finalSession: SplitSession {
                var s = session
                s.tip = tipAmount
                return s
            }
            SummaryView(session: finalSession) {
                onComplete(finalSession)
                dismiss()
            }
        }
    }

    private func assignItem(at index: Int, to friend: Friend) {
        withAnimation(Theme.Anim.spring) {
            if session.items[index].assignedTo == friend {
                session.items[index].assignedTo = nil
            } else {
                session.items[index].assignedTo = friend
            }
        }
        Theme.Haptic.medium()
        selectedItemId = nil
    }

    private func splitUnassignedEqually() {
        let unassigned = session.items.enumerated().filter { $0.element.assignedTo == nil }
        guard !unassigned.isEmpty, !session.friends.isEmpty else { return }

        for (i, pair) in unassigned.enumerated() {
            let friendIndex = i % session.friends.count
            withAnimation(Theme.Anim.spring.delay(Double(i) * Theme.Anim.itemStagger)) {
                session.items[pair.offset].assignedTo = session.friends[friendIndex]
            }
        }
    }
}
