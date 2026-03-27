# Design Manifest: NoSpend Streak

## Theme
This app is a gold-star sticker chart, specifically an elevated, modern take on the classroom reward charts — matte black backing with metallic gold foil stars and a satisfying stamp animation when you mark a no-spend day.

The visual world is a night-mode sticker chart: deep obsidian backgrounds like black card stock, with gold foil star stickers that catch the light. Each no-spend day earns a gold star stamped onto the calendar grid. The texture is premium and tactile — think matte paper with embossed metallic accents, not flat digital UI. Shadows are soft and warm, edges are slightly rounded like sticker corners.

The mood is celebratory and rewarding. Every interaction should feel like you're earning something. The gold is warm and rich, not garish — think brass hardware, not glitter. Rose gold accents add warmth for secondary highlights. The overall feeling is "I'm winning" — a personal scoreboard that makes not spending feel like an achievement, not deprivation.

The era is modern-retro: the concept of a sticker chart is nostalgic, but the execution is sleek and contemporary. Think Apple's design language applied to a childhood reward system.

## Color Palette
| Role       | Name         | Hex     | Usage                                    |
|------------|-------------|---------|------------------------------------------|
| background | Obsidian    | #121218 | App background, all screens              |
| surface    | Graphite    | #1E1E2A | Cards, sheets, modals, calendar cells    |
| primary    | Gold Foil   | #F5C542 | Gold stars, primary actions, streaks      |
| accent     | Rose Gold   | #E8A0BF | Secondary highlights, savings amounts    |
| muted      | Pewter      | #7B7B8E | Inactive states, secondary text, labels  |
| border     | Slate Edge  | #2E2E3E | Dividers, card borders, grid lines       |
| success    | Mint Stamp  | #4ECDC4 | Success states, positive savings delta   |
| danger     | Red Ink     | #FF6B6B | Broken streaks, spent days, warnings     |

## Typography
### Primary: Nunito
A rounded, friendly sans-serif that feels approachable and modern — like handwriting on a sticker chart, but grown up. Bundled via Google Fonts.

- Heading: Nunito ExtraBold 28pt
- Subheading: Nunito Bold 20pt
- Body: Nunito SemiBold 16pt
- Caption: Nunito Regular 13pt
- Label: Nunito Medium 14pt

### Secondary: SF Mono (system monospace)
Used exclusively for numerical displays — streak counts, savings amounts, dates.

- Stat Large: SF Mono Bold 36pt
- Stat Medium: SF Mono Semibold 24pt
- Stat Small: SF Mono Medium 16pt

## Spacing & Shape
- Base unit: 8pt
- xs: 4pt | sm: 8pt | md: 16pt | lg: 24pt | xl: 40pt
- Corner radius — small: 6pt | medium: 12pt | large: 20pt | pill: 999pt

## Animations
- Default duration: 0.3s, easeInOut
- Spring: response 0.5, damping 0.7
- Signature animation: When marking a no-spend day, a gold star scales up from 0 with a spring bounce and a subtle rotation (like stamping a sticker), accompanied by a particle burst of tiny gold dots

## Haptics
- Tap: light impact
- Star stamp (mark no-spend): success notification + medium impact
- Streak milestone: heavy impact
- Destructive (break streak): warning notification
- Navigation: selection changed

## Screens

### 1. Home (Calendar)
**Purpose:** The main screen — a monthly calendar grid where each no-spend day is marked with a gold star
**Layout:** Vertical scroll with sticky month/year header. Top section shows current streak count prominently. Below is the calendar grid (7-column). Below calendar: savings summary card.
**Key elements:**
- Streak counter: large gold number with "day streak" label, centered at top with a subtle glow
- Month navigation: left/right arrows flanking "March 2026" header
- Calendar grid: 7x5 grid of day cells. No-spend days show gold star. Spent days show red dot. Future days are dimmed. Today pulses gently.
- Quick-log FAB: floating action button at bottom to mark today
- Savings card: compact card showing "Estimated saved this month: $X"
**Navigation:** Tab bar item 1 (star icon). Tap FAB opens day-log sheet.
**Empty state:** Fresh calendar with no stars, motivational text: "Your first gold star is waiting. Tap + to log today."

### 2. Stats
**Purpose:** Analytics and achievements — longest streak, total saved, monthly success rate
**Layout:** Vertical scroll with stat cards stacked
**Key elements:**
- Hero stat: Current streak in large gold type
- Stat grid (2x2): Longest streak, Total no-spend days, Monthly success rate (%), Estimated total saved
- Monthly bar chart: Visual showing no-spend vs spent days per month (last 3 months)
- Milestones section: Achievement badges for streak milestones (7 days, 30 days, 100 days)
**Navigation:** Tab bar item 2 (chart icon)
**Empty state:** Stats at zero with encouraging message: "Start logging to see your stats grow"

### 3. Paywall
**Purpose:** Premium upgrade screen with RevenueCat offerings
**Layout:** Full-screen modal with vertical scroll
**Key elements:**
- Hero section: animated gold star with "Go Premium" heading
- Benefits list: 4-5 premium features with gold star bullet points
  - Custom challenge durations (7, 14, 30, 100 days)
  - Savings goal tracker
  - Home screen widgets
  - Shareable streak cards
  - Detailed analytics
- Pricing options: Weekly ($1.99/wk) highlighted as "Most Popular", Monthly, Annual
- Restore Purchases button (caption text)
- Close/dismiss X button top-right
**Navigation:** Presented as sheet from Settings or triggered by tapping locked features
**Empty state:** Loading skeleton while RevenueCat offerings fetch

### 4. Settings
**Purpose:** App preferences and account management
**Layout:** Grouped list style with themed section headers
**Key elements:**
- Daily reminder toggle + time picker
- Default daily budget input (for savings calculation)
- Challenge mode selector (ongoing, 7-day, 30-day, 100-day)
- Share streak card button
- Rate app / send feedback links
- Restore purchases
- App version footer
**Navigation:** Tab bar item 3 (gear icon)
**Empty state:** N/A — always has content
