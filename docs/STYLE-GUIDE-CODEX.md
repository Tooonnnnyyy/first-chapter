# First Chapter — native iOS style guide

Design system: Apple Human Interface Guidelines, native SwiftUI components and SF Symbols. This supersedes the initial ideamap/amber direction for this snapshot, following the user's request for native iOS conventions and red emphasis.

## Tokens
- Light-mode accent: garnet, RGB 0.56 / 0.00 / 0.10 (approximately #8F001A).
- Dark-mode accent: RGB 0.96 / 0.45 / 0.48, selected for visibility on dark backgrounds.
- Surfaces and primary/secondary text: semantic system colours. Do not hardcode white screens.
- Typography: SF system text styles with Dynamic Type, `.largeTitle`, `.title`, `.headline`, `.body`, `.subheadline`, `.footnote`, `.caption`.
- Spacing: 4 pt base; common 8 / 12 / 16 / 24 / 32 pt intervals.
- Touch controls: target 44 × 44 pt or larger. Native list rows and large buttons for primary navigation.

## Components and flows
- Native TabView: Find, Borrow, Ask, My Plan.
- Searchable List: answer-first service rows; Search empty state offers a librarian contact.
- NavigationStack: system back behavior and inline service-detail titles.
- In-app Safari sheet: official links, system Done dismissal, no replica login.
- Native confirmation dialog for clearing personal data.
- SF Symbols icon tiles; decorative symbols hidden from VoiceOver.

## Content rules
- Red emphasizes actions and important labels, never the entire reading surface.
- Colour never carries the only explanation of status.
- “Saved” means a personal plan, never a confirmed booking.
- A reply says DeepSeek, on-device AI, or Library search according to the executed path.
- Prefer “Check official availability” to invented inventory or times.

## Validation scope
Native controls provide established platform behavior. Dynamic Type, VoiceOver and contrast still require device testing; use source review as a starting point, not certification.
