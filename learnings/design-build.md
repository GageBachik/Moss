# Design-Build Learnings

## Design Principles
- Theme-first: every app should feel like a physical object turned digital
- Bold, distinctive aesthetics outperform generic minimalism in the App Store
- Custom fonts and colors are worth the effort -- they make screenshots pop

## SwiftUI Patterns
- Use a Theme.swift file with all design constants (colors, fonts, spacing)
- Custom ViewModifiers for consistent button/card/input styling
- Environment-based theme injection for easy global access
- NavigationStack over NavigationView (iOS 17+)

## Common Eval Failures (avoid these)
- Default SF Pro font leaking through (always set custom font)
- System toggle/switch style (always use custom toggle)
- Plain white/black backgrounds (always use themed backgrounds)
- Missing haptic feedback on interactive elements

## Build Notes
- Always target iOS 17+ for latest SwiftUI features
- RevenueCat SDK via SPM (Swift Package Manager)
- Test on iPhone 16 Pro simulator (primary eval device)
