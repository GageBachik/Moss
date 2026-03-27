# Design Manifest: Snap Split

## Theme
This app is a fresh thermal receipt on a dark marble countertop, specifically the crisp white-on-dark contrast of a paper receipt just torn from the printer at a restaurant.

The visual world draws from the tactile experience of splitting a bill at a restaurant table. The dark background evokes the black marble or slate surface of an upscale restaurant table. Cards and surfaces are bright, warm white -- like thermal receipt paper with its slightly warm tone. Text uses a monospace aesthetic reminiscent of receipt printers, with prices right-aligned just like a real receipt. Accent colors come from the warm amber of restaurant lighting and the fresh green of a successful split. The overall feeling is premium but approachable -- a tool that feels at home in a nice restaurant, not a sterile finance app.

Interactive elements use subtle shadows to feel like paper sitting on a surface. Assigned items get colored tags that feel like highlighter marks on a receipt. The camera view has a receipt-shaped scanning frame to reinforce the metaphor.

## Color Palette
| Role       | Name           | Hex     | Usage                                    |
|------------|----------------|---------|------------------------------------------|
| background | Dark Marble    | #1C1C1E | App background, all screens              |
| surface    | Receipt White  | #FAF8F5 | Cards, receipt displays, modals          |
| primary    | Warm Amber     | #F5A623 | Primary actions, scan button, highlights |
| accent     | Split Green    | #34C759 | Success states, completed splits         |
| text       | Charcoal       | #2C2C2E | Primary text on light surfaces           |
| textLight  | Soft Gray      | #8E8E93 | Secondary text, captions, placeholders   |
| danger     | Alert Red      | #FF3B30 | Destructive actions, errors              |

## Typography
### Primary: Space Mono
- Heading: Space Mono Bold 28pt
- Subheading: Space Mono Bold 20pt
- Body: Space Mono Regular 15pt
- Caption: Space Mono Regular 12pt
- Label: Space Mono Medium 14pt

### Secondary: DM Sans
- Usage: Friend name tags, paywall marketing copy, and any text that needs warmth over the receipt aesthetic
- Body: DM Sans Regular 16pt
- Label: DM Sans Medium 14pt
- Caption: DM Sans Regular 12pt

## Spacing & Shape
- Base unit: 8pt
- xs: 4pt | sm: 8pt | md: 16pt | lg: 24pt | xl: 40pt
- Corner radius -- small: 6pt | medium: 12pt | large: 20pt | pill: 999pt

## Animations
- Default duration: 0.25s, easeInOut
- Signature animation: Items slide in from the right like a receipt printing line-by-line (staggered 0.05s delay per item). Assigned items get a highlight wash animation (left-to-right color fill over 0.3s).

## Haptics
- Tap: light impact
- Success (split calculated): success notification
- Destructive (remove friend, clear): heavy impact
- Navigation: light impact
- Item assigned to friend: medium impact

## Screens

### 1. Home / Recent Splits
**Purpose:** Landing screen showing recent splits and prominent scan button
**Layout:** Vertical scroll with large floating scan button at bottom center
**Key elements:**
- App title "Snap Split" in Space Mono Bold at top
- Large circular camera button (amber, 72pt diameter) with camera icon
- Recent splits list: each card shows receipt thumbnail, restaurant name, date, total, number of friends
- Each card is receipt-white on dark marble background with subtle shadow
- Free scans remaining badge (e.g., "3/5 free scans") near the scan button
**Navigation:** Tap scan button -> Camera. Tap recent split -> Split Detail.
**Empty state:** Illustration of a receipt with a dotted split line. Text: "No splits yet. Tap the camera to scan your first receipt."

### 2. Camera / Scan
**Purpose:** Live camera view for capturing a receipt
**Layout:** Full-screen camera with receipt-shaped overlay frame
**Key elements:**
- Live camera preview fills the screen
- Translucent dark overlay with a receipt-shaped cutout (tall rectangle with rounded corners)
- "Align receipt within frame" instruction text at top
- Auto-capture indicator: frame border turns amber then green when receipt detected
- Manual capture button at bottom (large amber circle)
- Flash toggle and close button in top bar
**Navigation:** Auto-navigates to Item Review after successful scan. Close returns to Home.
**Empty state:** N/A (always shows camera)

### 3. Item Review / Split
**Purpose:** Core experience -- shows OCR results, lets user assign items to friends
**Layout:** Two sections: scrollable item list (top 60%), friend bar (bottom 40%)
**Key elements:**
- Receipt-style item list on a receipt-white card: each row shows item name (left) and price (right-aligned) in Space Mono
- Subtotal, tax, and tip rows at bottom of receipt with dashed separator line
- Tip adjustment slider (custom themed)
- Friend chips at bottom: circular avatars with initials, each with an assigned color
- Tap an item, then tap a friend to assign. Assigned items show the friend's color as a left-border highlight
- "Split equally" shortcut button for remaining unassigned items
- Running total per friend shown below friend chips
**Navigation:** Back returns to Camera for re-scan. "Done" navigates to Summary.
**Empty state:** If OCR returns no items: "Couldn't read this receipt. Try again with better lighting." with re-scan button.

### 4. Summary / Share
**Purpose:** Final breakdown per person with share options
**Layout:** Vertical scroll, one card per friend
**Key elements:**
- Each friend card shows: name, list of their items, their subtotal, their share of tax, their share of tip, total owed
- All amounts in Space Mono, right-aligned, receipt-style
- "Send via Venmo" and "Send via PayPal" deep-link buttons per person (amber outlined)
- "Share as Text" button to copy a plain-text breakdown to clipboard
- Grand total at the top confirming the receipt total matches
**Navigation:** Done returns to Home. New split from here starts Camera.
**Empty state:** N/A (always has data when reaching this screen)

### 5. Paywall
**Purpose:** Premium upgrade screen
**Layout:** Vertical scroll with marketing copy and pricing cards
**Key elements:**
- Header: "Unlimited Splits" in Space Mono Bold
- Value props in DM Sans: unlimited scans, receipt history, group presets, Venmo/PayPal links
- Two pricing cards on receipt-white: Monthly ($2.99/mo), Annual ($19.99/yr with "Save 44%" badge in green)
- Each card has a prominent amber "Subscribe" button
- "Restore Purchases" text button at bottom
- Close/dismiss X button at top right for free tier users
**Navigation:** Triggered when user hits scan limit. Dismiss returns to Home. Success returns to Camera.
**Empty state:** Loading state: skeleton cards with pulsing receipt-white placeholders
