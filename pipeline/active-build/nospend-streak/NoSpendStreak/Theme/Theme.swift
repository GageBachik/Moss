import SwiftUI
import UIKit

enum Theme {

    // MARK: - Colors
    enum Color {
        static let background = SwiftUI.Color(hex: "#121218")
        static let surface = SwiftUI.Color(hex: "#1E1E2A")
        static let primary = SwiftUI.Color(hex: "#F5C542")
        static let accent = SwiftUI.Color(hex: "#E8A0BF")
        static let muted = SwiftUI.Color(hex: "#7B7B8E")
        static let border = SwiftUI.Color(hex: "#2E2E3E")
        static let success = SwiftUI.Color(hex: "#4ECDC4")
        static let danger = SwiftUI.Color(hex: "#FF6B6B")
    }

    // MARK: - Typography
    enum Font {
        static func heading() -> SwiftUI.Font {
            .custom("Nunito-ExtraBold", size: 28)
        }
        static func subheading() -> SwiftUI.Font {
            .custom("Nunito-Bold", size: 20)
        }
        static func body() -> SwiftUI.Font {
            .custom("Nunito-SemiBold", size: 16)
        }
        static func caption() -> SwiftUI.Font {
            .custom("Nunito-Regular", size: 13)
        }
        static func label() -> SwiftUI.Font {
            .custom("Nunito-Medium", size: 14)
        }

        // Monospace for numbers/stats
        static func statLarge() -> SwiftUI.Font {
            .system(size: 36, design: .monospaced).bold()
        }
        static func statMedium() -> SwiftUI.Font {
            .system(size: 24, design: .monospaced).weight(.semibold)
        }
        static func statSmall() -> SwiftUI.Font {
            .system(size: 16, design: .monospaced).weight(.medium)
        }
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
        static let `default` = SwiftUI.Animation.easeInOut(duration: 0.3)
        static let spring = SwiftUI.Animation.spring(response: 0.5, dampingFraction: 0.7)
        static let stamp = SwiftUI.Animation.spring(response: 0.4, dampingFraction: 0.5)
    }

    // MARK: - Haptics
    enum Haptic {
        static func tap() {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
        }
        static func stamp() {
            UINotificationFeedbackGenerator().notificationOccurred(.success)
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        }
        static func milestone() {
            UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
        }
        static func warning() {
            UINotificationFeedbackGenerator().notificationOccurred(.warning)
        }
        static func selection() {
            UISelectionFeedbackGenerator().selectionChanged()
        }
    }
}

// MARK: - Color Hex Initializer
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet(charactersIn: "#"))
        let scanner = Scanner(string: hex)
        var rgbValue: UInt64 = 0
        scanner.scanHexInt64(&rgbValue)

        let r = Double((rgbValue & 0xFF0000) >> 16) / 255.0
        let g = Double((rgbValue & 0x00FF00) >> 8) / 255.0
        let b = Double(rgbValue & 0x0000FF) / 255.0

        self.init(red: r, green: g, blue: b)
    }
}
