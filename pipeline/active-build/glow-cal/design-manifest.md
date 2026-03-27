# Design Manifest: Glow Cal

## Theme
This app is a rose-gold compact mirror, specifically a luxe hinged vanity compact with a matte velvet interior and gold trim.

The visual world draws from the tactile warmth of a high-end beauty compact. Think matte blush-pink surfaces with subtle rose-gold metallic accents, soft shadows that suggest depth and luxury. The light quality is warm and diffused, like vanity mirror lighting. Every card and surface feels like the velvet-lined interior of a jewelry box, with gold-edged borders providing structure and sparkle. The era is contemporary luxury -- clean lines but with warmth and softness, never cold or clinical.

The color palette is rooted in warm neutrals and rose tones. Backgrounds are deep enough to let content float but never dark or moody -- this is a beauty app, not a finance app. Accent colors are deliberately limited to rose-gold and a fresh coral for alerts, keeping the palette cohesive and feminine without being saccharine.

## Color Palette
| Role       | Name           | Hex     | Usage                              |
|------------|----------------|---------|------------------------------------|
| background | Velvet Night   | #1C1520 | App background, all screens        |
| surface    | Compact Shell  | #2A2030 | Cards, sheets, modals              |
| primary    | Rose Gold      | #E8A87C | Primary actions, active states     |
| accent     | Soft Coral     | #F4726C | Overdue alerts, attention states   |
| muted      | Mauve Mist     | #8B7B8B | Secondary text, inactive elements  |
| border     | Gold Trim      | #D4A574 | Card borders, dividers, highlights |
| text       | Pearl White    | #F5F0EB | Primary text                       |

## Typography
### Primary: Playfair Display
- Heading: Playfair Display Bold 28pt
- Subheading: Playfair Display SemiBold 20pt
- Body: Playfair Display Regular 16pt
- Caption: Playfair Display Regular 12pt
- Label: Playfair Display Medium 14pt

### Secondary: Avenir Next
- Usage: Category labels, countdown timers, numerical data, tab bar labels

## Spacing & Shape
- Base unit: 8pt
- xs: 4pt | sm: 8pt | md: 16pt | lg: 24pt | xl: 40pt
- Corner radius -- small: 6pt | medium: 12pt | large: 20pt | pill: 999pt

## Animations
- Default duration: 0.3s, easeInOut
- Signature animation: Cards appear with a gentle scale-up (0.95 to 1.0) combined with opacity fade, like a compact mirror opening to reveal its contents

## Haptics
- Tap: light impact
- Success: success notification
- Destructive: heavy impact
- Navigation: light impact

## Screens

### 1. Home (Maintenance Timeline)
**Purpose:** Show all beauty maintenance categories with their next-due dates and status at a glance.
**Layout:** Vertical scroll with a greeting header and category cards stacked below.
**Key elements:**
- Greeting header: "Your Glow" with current date, styled like engraving on a compact
- Category cards: Each shows icon, category name, days until due (or "overdue" in coral), last completed date
- Floating "+" button: Rose-gold circle to add new maintenance category
- Status ring: Small circular progress indicator on each card showing cycle progress
**Navigation:** Tab bar item (first tab). Tap card to see category detail.
**Empty state:** Illustration of an open compact mirror with text "Add your first beauty routine" and a prominent add button.

### 2. Category Detail
**Purpose:** View history and manage a single maintenance category (e.g., Nails, Hair).
**Layout:** Vertical scroll with category header, next-due countdown, and history list.
**Key elements:**
- Category header: Large icon, name, and frequency (e.g., "Every 3 weeks")
- Countdown display: Large number showing days until next appointment, with a circular progress ring
- "Mark as Done" button: Primary rose-gold button to log a completion
- History list: Past completions with dates, styled as timeline entries
- Edit frequency: Tap to adjust the recurrence interval
**Navigation:** Push from Home card tap. Back button returns to Home.
**Empty state:** "No history yet. Tap 'Done' after your next appointment."

### 3. Add/Edit Category
**Purpose:** Create or edit a maintenance category with name, icon, frequency, and optional cost.
**Layout:** Form-style vertical layout with themed input fields.
**Key elements:**
- Icon picker: Grid of beauty-related SF Symbols (sparkles, scissors, drop, flame, etc.)
- Name field: Text input with gold-trim border
- Frequency picker: Segmented control or wheel for weeks (1-12) or days
- Cost per visit: Optional currency input for spend tracking
- Color accent picker: Choose from 6 preset accent colors for the category card
**Navigation:** Modal sheet presented from Home "+" button or Detail edit button.
**Empty state:** N/A (this is a form)

### 4. Paywall
**Purpose:** Convert free users to premium subscribers.
**Layout:** Full-screen vertical scroll with value prop and pricing options.
**Key elements:**
- Hero section: "Unlock Your Full Glow" heading with compact mirror illustration concept
- Benefits list: 5 benefits with checkmark icons (unlimited categories, spend analytics, widgets, reminders, export)
- Pricing cards: Weekly ($2.99/wk), Annual ($49.99/yr), Lifetime ($79.99) with gold-bordered cards
- Restore purchases: Subtle text button below pricing
- Close button: Top-right "X" to dismiss
**Navigation:** Presented modally when user hits free tier limit or taps premium badge.
**Empty state:** Loading state while fetching RevenueCat offerings shows skeleton cards with shimmer.
