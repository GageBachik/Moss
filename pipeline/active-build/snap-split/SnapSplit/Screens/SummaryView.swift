import SwiftUI

struct SummaryView: View {
    @Environment(\.dismiss) private var dismiss
    let session: SplitSession
    var onDone: () -> Void
    @State private var appeared = false
    @State private var copiedToClipboard = false

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
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(width: 36, height: 36)
                            .background(Circle().fill(.white.opacity(0.15)))
                    }

                    Spacer()

                    Text("Summary")
                        .font(Theme.Font.subheading())
                        .foregroundColor(Theme.Color.textOnDark)

                    Spacer()

                    Button(action: {
                        Theme.Haptic.success()
                        onDone()
                        dismiss()
                    }) {
                        Image(systemName: "checkmark")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(Theme.Color.accent)
                            .frame(width: 36, height: 36)
                            .background(Circle().fill(Theme.Color.accent.opacity(0.15)))
                    }
                }
                .padding(.horizontal, Theme.Spacing.md)
                .padding(.top, Theme.Spacing.md)

                // Grand total header
                VStack(spacing: Theme.Spacing.xs) {
                    Text("Grand Total")
                        .font(Theme.Font.caption())
                        .foregroundColor(Theme.Color.textLight)
                    Text(String(format: "$%.2f", session.total))
                        .font(Theme.Font.heading())
                        .foregroundColor(Theme.Color.textOnDark)
                    Text(session.restaurantName)
                        .font(Theme.Font.label())
                        .foregroundColor(Theme.Color.textLight)
                }
                .padding(.vertical, Theme.Spacing.lg)

                // Per-friend breakdowns
                ScrollView {
                    LazyVStack(spacing: Theme.Spacing.md) {
                        ForEach(Array(session.friends.enumerated()), id: \.element.id) { index, friend in
                            let share = session.shareForFriend(friend)
                            FriendShareCard(share: share)
                                .opacity(appeared ? 1 : 0)
                                .offset(x: appeared ? 0 : 50)
                                .animation(
                                    Theme.Anim.spring.delay(Double(index) * 0.1),
                                    value: appeared
                                )
                        }

                        // Share as text button
                        Button(action: {
                            Theme.Haptic.tap()
                            copyShareText()
                        }) {
                            HStack {
                                Image(systemName: copiedToClipboard ? "checkmark" : "doc.on.doc")
                                Text(copiedToClipboard ? "Copied!" : "Copy as Text")
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
                        .padding(.top, Theme.Spacing.sm)
                    }
                    .padding(.horizontal, Theme.Spacing.md)
                    .padding(.bottom, Theme.Spacing.xl)
                }
            }
        }
        .onAppear {
            withAnimation {
                appeared = true
            }
        }
    }

    private func copyShareText() {
        var text = "\(session.restaurantName) - Split Summary\n"
        text += String(format: "Total: $%.2f\n\n", session.total)

        for friend in session.friends {
            let share = session.shareForFriend(friend)
            text += "\(friend.name): \(String(format: "$%.2f", share.total))\n"
            for item in share.items {
                text += "  - \(item.name): \(String(format: "$%.2f", item.price))\n"
            }
            text += String(format: "  Tax: $%.2f | Tip: $%.2f\n\n", share.taxShare, share.tipShare)
        }

        UIPasteboard.general.string = text
        copiedToClipboard = true
        Theme.Haptic.success()

        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            copiedToClipboard = false
        }
    }
}

// MARK: - Friend Share Card
struct FriendShareCard: View {
    let share: FriendShare

    var body: some View {
        ReceiptCard {
            VStack(spacing: Theme.Spacing.sm) {
                // Friend header
                HStack {
                    Circle()
                        .fill(share.friend.color)
                        .frame(width: 36, height: 36)
                        .overlay(
                            Text(share.friend.initials)
                                .font(Theme.Font.caption())
                                .foregroundColor(.white)
                        )

                    Text(share.friend.name)
                        .font(Theme.Font.subheading())
                        .foregroundColor(Theme.Color.text)

                    Spacer()

                    Text(String(format: "$%.2f", share.total))
                        .font(Theme.Font.price())
                        .foregroundColor(Theme.Color.text)
                }

                DashedSeparator()

                // Items
                ForEach(share.items) { item in
                    HStack {
                        Text(item.name)
                            .font(Theme.Font.body())
                            .foregroundColor(Theme.Color.text)
                            .lineLimit(1)
                        Spacer()
                        Text(String(format: "$%.2f", item.price))
                            .font(Theme.Font.body())
                            .foregroundColor(Theme.Color.text)
                    }
                }

                if share.items.isEmpty {
                    Text("No items assigned")
                        .font(Theme.Font.caption())
                        .foregroundColor(Theme.Color.textLight)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, Theme.Spacing.sm)
                }

                DashedSeparator()

                // Breakdown
                Group {
                    HStack {
                        Text("Items")
                            .font(Theme.Font.caption())
                            .foregroundColor(Theme.Color.textLight)
                        Spacer()
                        Text(String(format: "$%.2f", share.itemsTotal))
                            .font(Theme.Font.caption())
                            .foregroundColor(Theme.Color.textLight)
                    }
                    HStack {
                        Text("Tax")
                            .font(Theme.Font.caption())
                            .foregroundColor(Theme.Color.textLight)
                        Spacer()
                        Text(String(format: "$%.2f", share.taxShare))
                            .font(Theme.Font.caption())
                            .foregroundColor(Theme.Color.textLight)
                    }
                    HStack {
                        Text("Tip")
                            .font(Theme.Font.caption())
                            .foregroundColor(Theme.Color.textLight)
                        Spacer()
                        Text(String(format: "$%.2f", share.tipShare))
                            .font(Theme.Font.caption())
                            .foregroundColor(Theme.Color.textLight)
                    }
                }

                // Payment links
                HStack(spacing: Theme.Spacing.sm) {
                    PaymentLinkButton(
                        label: "Venmo",
                        icon: "arrow.up.right.square",
                        friend: share.friend,
                        amount: share.total,
                        scheme: "venmo"
                    )

                    PaymentLinkButton(
                        label: "PayPal",
                        icon: "arrow.up.right.square",
                        friend: share.friend,
                        amount: share.total,
                        scheme: "paypal"
                    )
                }
                .padding(.top, Theme.Spacing.xs)
            }
        }
    }
}

// MARK: - Payment Link Button
struct PaymentLinkButton: View {
    let label: String
    let icon: String
    let friend: Friend
    let amount: Double
    let scheme: String

    var body: some View {
        Button(action: {
            Theme.Haptic.tap()
            openPaymentLink()
        }) {
            HStack(spacing: Theme.Spacing.xs) {
                Image(systemName: icon)
                    .font(.system(size: 12))
                Text(label)
                    .font(Theme.Font.caption())
            }
            .foregroundColor(Theme.Color.primary)
            .padding(.horizontal, Theme.Spacing.md)
            .padding(.vertical, Theme.Spacing.sm)
            .background(
                RoundedRectangle(cornerRadius: Theme.Radius.medium)
                    .stroke(Theme.Color.primary, lineWidth: 1.5)
            )
        }
    }

    private func openPaymentLink() {
        let amountStr = String(format: "%.2f", amount)
        var urlString: String

        switch scheme {
        case "venmo":
            urlString = "venmo://paycharge?txn=charge&amount=\(amountStr)&note=\(friend.name)%20-%20Snap%20Split"
        case "paypal":
            urlString = "paypal://paypalme/\(amountStr)"
        default:
            return
        }

        if let url = URL(string: urlString) {
            UIApplication.shared.open(url)
        }
    }
}
