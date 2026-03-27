import SwiftUI
import UIKit

enum Theme {

    // MARK: - Colors
    enum Color {
        static let background = SwiftUI.Color(hex: "#1C1C1E")
        static let surface = SwiftUI.Color(hex: "#FAF8F5")
        static let primary = SwiftUI.Color(hex: "#F5A623")
        static let accent = SwiftUI.Color(hex: "#34C759")
        static let text = SwiftUI.Color(hex: "#2C2C2E")
        static let textLight = SwiftUI.Color(hex: "#8E8E93")
        static let danger = SwiftUI.Color(hex: "#FF3B30")
        static let textOnDark = SwiftUI.Color.white
    }

    // MARK: - Typography
    enum Font {
        // Primary: Space Mono
        static func heading() -> SwiftUI.Font { .custom("SpaceMono-Bold", size: 28) }
        static func subheading() -> SwiftUI.Font { .custom("SpaceMono-Bold", size: 20) }
        static func body() -> SwiftUI.Font { .custom("SpaceMono-Regular", size: 15) }
        static func caption() -> SwiftUI.Font { .custom("SpaceMono-Regular", size: 12) }
        static func label() -> SwiftUI.Font { .custom("SpaceMono-Regular", size: 14) }
        static func price() -> SwiftUI.Font { .custom("SpaceMono-Bold", size: 16) }

        // Secondary: DM Sans (using system rounded as fallback since we can't bundle Google Fonts without files)
        static func friendName() -> SwiftUI.Font { .system(size: 16, weight: .medium, design: .rounded) }
        static func marketing() -> SwiftUI.Font { .system(size: 16, weight: .regular, design: .rounded) }
        static func marketingBold() -> SwiftUI.Font { .system(size: 18, weight: .bold, design: .rounded) }
        static func smallLabel() -> SwiftUI.Font { .system(size: 12, weight: .medium, design: .rounded) }
    }

    // MARK: - Spacing
    enum Spacing {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 16
        static let lg: CGFloat = 24
        static let xl: CGFloat = 40
    }

    // MARK: - Corner Radius
    enum Radius {
        static let small: CGFloat = 6
        static let medium: CGFloat = 12
        static let large: CGFloat = 20
        static let pill: CGFloat = 999
    }

    // MARK: - Animation
    enum Anim {
        static let `default` = SwiftUI.Animation.easeInOut(duration: 0.25)
        static let spring = SwiftUI.Animation.spring(response: 0.4, dampingFraction: 0.7)
        static let itemStagger: Double = 0.05
    }

    // MARK: - Haptics
    enum Haptic {
        static func tap() { UIImpactFeedbackGenerator(style: .light).impactOccurred() }
        static func medium() { UIImpactFeedbackGenerator(style: .medium).impactOccurred() }
        static func success() { UINotificationFeedbackGenerator().notificationOccurred(.success) }
        static func heavy() { UIImpactFeedbackGenerator(style: .heavy).impactOccurred() }
        static func warning() { UINotificationFeedbackGenerator().notificationOccurred(.warning) }
    }

    // MARK: - Friend Colors (for assignment highlights)
    static let friendColors: [SwiftUI.Color] = [
        SwiftUI.Color(hex: "#FF6B6B"), // coral
        SwiftUI.Color(hex: "#4ECDC4"), // teal
        SwiftUI.Color(hex: "#FFD93D"), // yellow
        SwiftUI.Color(hex: "#6C5CE7"), // purple
        SwiftUI.Color(hex: "#A8E6CF"), // mint
        SwiftUI.Color(hex: "#FF8A5C"), // orange
        SwiftUI.Color(hex: "#81ECEC"), // cyan
        SwiftUI.Color(hex: "#FD79A8"), // pink
    ]
}

// MARK: - Color Hex Extension
extension SwiftUI.Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
