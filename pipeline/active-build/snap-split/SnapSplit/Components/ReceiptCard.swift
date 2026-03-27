import SwiftUI

// MARK: - Receipt Card (wraps content in receipt-paper style)
struct ReceiptCard<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        VStack(spacing: 0) {
            // Torn edge top
            ReceiptTornEdge()
                .fill(Theme.Color.surface)
                .frame(height: 8)

            content
                .padding(.horizontal, Theme.Spacing.md)
                .padding(.vertical, Theme.Spacing.sm)
                .background(Theme.Color.surface)

            // Torn edge bottom
            ReceiptTornEdge()
                .fill(Theme.Color.surface)
                .frame(height: 8)
                .rotation3DEffect(.degrees(180), axis: (x: 1, y: 0, z: 0))
        }
        .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)
    }
}

// MARK: - Torn Edge Shape
struct ReceiptTornEdge: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let zigzagHeight: CGFloat = rect.height
        let zigzagWidth: CGFloat = 8

        path.move(to: CGPoint(x: 0, y: zigzagHeight))

        var x: CGFloat = 0
        while x < rect.width {
            x += zigzagWidth / 2
            path.addLine(to: CGPoint(x: min(x, rect.width), y: 0))
            x += zigzagWidth / 2
            path.addLine(to: CGPoint(x: min(x, rect.width), y: zigzagHeight))
        }

        path.addLine(to: CGPoint(x: rect.width, y: zigzagHeight))
        path.closeSubpath()
        return path
    }
}

// MARK: - Dashed Separator
struct DashedSeparator: View {
    var body: some View {
        HStack(spacing: 3) {
            ForEach(0..<40, id: \.self) { _ in
                Rectangle()
                    .fill(Theme.Color.textLight.opacity(0.4))
                    .frame(width: 4, height: 1)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, Theme.Spacing.xs)
    }
}

// MARK: - Receipt Line Item Row
struct ReceiptLineRow: View {
    let name: String
    let price: Double
    var highlightColor: Color?
    var onTap: (() -> Void)?

    var body: some View {
        Button(action: {
            Theme.Haptic.tap()
            onTap?()
        }) {
            HStack {
                if let color = highlightColor {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(color)
                        .frame(width: 4)
                }

                Text(name)
                    .font(Theme.Font.body())
                    .foregroundColor(Theme.Color.text)
                    .lineLimit(1)

                Spacer()

                Text(String(format: "$%.2f", price))
                    .font(Theme.Font.price())
                    .foregroundColor(Theme.Color.text)
            }
            .padding(.vertical, Theme.Spacing.xs)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Friend Chip
struct FriendChip: View {
    let friend: Friend
    var isSelected: Bool = false
    var itemCount: Int = 0
    var onTap: (() -> Void)?

    var body: some View {
        Button(action: {
            Theme.Haptic.medium()
            onTap?()
        }) {
            VStack(spacing: Theme.Spacing.xs) {
                ZStack {
                    Circle()
                        .fill(friend.color.opacity(isSelected ? 1.0 : 0.3))
                        .frame(width: 48, height: 48)

                    Text(friend.initials)
                        .font(Theme.Font.label())
                        .foregroundColor(isSelected ? .white : friend.color)

                    if isSelected {
                        Circle()
                            .stroke(Theme.Color.primary, lineWidth: 3)
                            .frame(width: 52, height: 52)
                    }

                    if itemCount > 0 {
                        Text("\(itemCount)")
                            .font(Theme.Font.caption())
                            .foregroundColor(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(friend.color)
                            .clipShape(Capsule())
                            .offset(x: 18, y: -18)
                    }
                }

                Text(friend.name.split(separator: " ").first.map(String.init) ?? friend.name)
                    .font(Theme.Font.caption())
                    .foregroundColor(Theme.Color.textOnDark)
                    .lineLimit(1)
            }
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Scan Button
struct ScanButton: View {
    var scansRemaining: Int
    var isPremium: Bool
    var action: () -> Void

    var body: some View {
        VStack(spacing: Theme.Spacing.sm) {
            Button(action: {
                Theme.Haptic.tap()
                action()
            }) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Theme.Color.primary, Theme.Color.primary.opacity(0.8)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 72, height: 72)
                        .shadow(color: Theme.Color.primary.opacity(0.4), radius: 12, x: 0, y: 6)

                    Image(systemName: "camera.fill")
                        .font(.system(size: 28, weight: .semibold))
                        .foregroundColor(.white)
                }
            }

            if !isPremium {
                Text("\(scansRemaining)/\(ScanTracker.freeLimit) free")
                    .font(Theme.Font.caption())
                    .foregroundColor(Theme.Color.textLight)
            }
        }
    }
}

// MARK: - Empty State View
struct EmptyStateView: View {
    let icon: String
    let title: String
    let subtitle: String

    var body: some View {
        VStack(spacing: Theme.Spacing.md) {
            Image(systemName: icon)
                .font(.system(size: 56, weight: .thin))
                .foregroundColor(Theme.Color.textLight)

            Text(title)
                .font(Theme.Font.subheading())
                .foregroundColor(Theme.Color.textOnDark)

            Text(subtitle)
                .font(Theme.Font.body())
                .foregroundColor(Theme.Color.textLight)
                .multilineTextAlignment(.center)
                .padding(.horizontal, Theme.Spacing.xl)
        }
        .padding(.vertical, Theme.Spacing.xl)
    }
}
