import SwiftUI
import CoreText

enum Theme {

    // MARK: - Colors
    enum Color {
        static let background = SwiftUI.Color(hex: "#1C1520")
        static let surface = SwiftUI.Color(hex: "#2A2030")
        static let primary = SwiftUI.Color(hex: "#E8A87C")
        static let accent = SwiftUI.Color(hex: "#F4726C")
        static let muted = SwiftUI.Color(hex: "#8B7B8B")
        static let border = SwiftUI.Color(hex: "#D4A574")
        static let text = SwiftUI.Color(hex: "#F5F0EB")
    }

    // MARK: - Typography
    enum Font {
        private static let playfair = "PlayfairDisplayRoman-Regular"
        static func heading() -> SwiftUI.Font { .custom(playfair, size: 28).weight(.bold) }
        static func subheading() -> SwiftUI.Font { .custom(playfair, size: 20).weight(.semibold) }
        static func body() -> SwiftUI.Font { .custom(playfair, size: 16) }
        static func caption() -> SwiftUI.Font { .custom(playfair, size: 12) }
        static func label() -> SwiftUI.Font { .custom(playfair, size: 14).weight(.medium) }

        /// Registers fonts on first use. Call from App.init().
        static func registerFonts() {
            guard let fontURL = Bundle.main.url(forResource: "PlayfairDisplay-VariableFont_wght", withExtension: "ttf") else { return }
            CTFontManagerRegisterFontsForURL(fontURL as CFURL, .process, nil)
        }
        static func data() -> SwiftUI.Font { .custom("AvenirNext-Medium", size: 16) }
        static func dataLarge() -> SwiftUI.Font { .custom("AvenirNext-Bold", size: 42) }
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
        static let spring = SwiftUI.Animation.spring(response: 0.4, dampingFraction: 0.7)
        static let cardAppear = SwiftUI.Animation.easeOut(duration: 0.35)
    }

    // MARK: - Haptics
    enum Haptic {
        static func tap() { UIImpactFeedbackGenerator(style: .light).impactOccurred() }
        static func success() { UINotificationFeedbackGenerator().notificationOccurred(.success) }
        static func heavy() { UIImpactFeedbackGenerator(style: .heavy).impactOccurred() }
        static func warning() { UINotificationFeedbackGenerator().notificationOccurred(.warning) }
    }
}

// MARK: - Color Hex Extension
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 6:
            (a, r, g, b) = (255, (int >> 16) & 0xFF, (int >> 8) & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = ((int >> 24) & 0xFF, (int >> 16) & 0xFF, (int >> 8) & 0xFF, int & 0xFF)
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
