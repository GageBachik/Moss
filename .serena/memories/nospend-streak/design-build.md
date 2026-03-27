# NoSpend Streak - Design-Build Notes

## Theme
Gold-star sticker chart — elevated modern take on classroom reward charts. Matte obsidian (#121218) background with metallic gold foil (#F5C542) stars and rose gold (#E8A0BF) accents.

## Key Decisions
- **Font**: Nunito (bundled from Google Fonts, 5 weights: Regular/Medium/SemiBold/Bold/ExtraBold). SF Mono for stat numbers.
- **Persistence**: SwiftData with `SpendDay` model (date, didSpend, amountSpent, note)
- **Architecture**: @Observable UserSettings with UserDefaults backing. @Query for SwiftData fetches.
- **RevenueCat**: Weekly $1.99 highlighted as "Most Popular". Fallback static pricing if offerings fail to load.
- **Project generation**: Used xcodegen with project.yml spec. Much easier than manual pbxproj.

## Tricky Bits
- `@Observable` + `didSet` requires default values on all stored properties. Can't use `self.prop = defaults.value` pattern directly in init without defaults first.
- iPhone 16 Pro simulator not available on this Xcode (26.3.1 SDK). Used iPhone 17 Pro instead.
- Deep link URLs don't work for tab switching without explicit URL scheme registration — screenshots only captured Home tab.

## Build Info
- Bundle ID: com.moss.nospend.streak
- Deployment target: iOS 17.0
- RevenueCat SDK: 5.67.0 via SPM
- 4 screens: Home (calendar+streak), Stats (analytics+milestones), Paywall, Settings
- Build path: pipeline/active-build/nospend-streak/
