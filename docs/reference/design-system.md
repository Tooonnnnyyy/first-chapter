# First Chapter — design system

Current as of 2026-11-08. The owner chose this style ("apply it to current app … make overall UX more gamified") and kept monospace labels. It replaces the Apple HIG guide in `ios-style-guide.md` and the gold/rounded values proposed in `docs/planning/v2-roadmap.md`.

Code: `FirstChapter/ApmStyle.swift` (native tokens and primitives) and the `:root` block in `web/index.html`. The two must stay in step.

## Look

A loud print-shop poster: full-bleed colour bands, 2px ink rules, square corners, solid offset shadows, huge tight headlines. No blur, glass, gradients, rounded cards or icon tiles.

| Token | Hex | Use |
| --- | --- | --- |
| ink | `#11120f` | Text, rules, primary buttons, Your Data band |
| paper | `#f3efe3` | Quest blocks, stamp board |
| bone | `#fffdf7` | Text on cobalt, page and field fill |
| lime | `#d9ff43` | Find band, XP pills, progress fill on flame |
| flame | `#ff5a36` | My Plan band, button shadow, progress fill |
| violet | `#b7a7ff` | Ask band |
| mint | `#75ded1` | Notes and blobs |
| cobalt | `#2864ff` | Borrow band, with bone text |

Contrast rules: ink on any band; bone (never ink) for small text on cobalt; ink (never bone) on flame; never lime on paper, including focus rings and progress cells.

Type: Manrope 400/500 for text and display, DM Mono 400/500 only for labels, buttons, pills, eyebrows and tab labels. Never weight 700. Fonts are bundled in `FirstChapter/Fonts/` (SIL OFL, `OFL.txt`) and loaded from Google Fonts on the web. Native text keeps Dynamic Type through relative sizing.

Shape and motion: radius 0, pills or circles only. Button shadow `4 4 0 flame` (lime on a flame band), card shadow `7 7 0 ink`. Easing `cubic-bezier(.16,1,.3,1)`. Reduce Motion turns every toast, banner, deck and bar animation static.

## Game layer

Everything is derived from the existing plan table (native `PlanItem`, web `localStorage`). No new storage, no network, nothing sent anywhere. XP is "just for fun and stays on this device"; the app says so on My Plan.

- Save a service: +10 XP. Mark it done: +40 XP. A finished quest is worth 50.
- Only services in the catalog count, each once.
- Chapters: 1 New Reader (0), 2 Explorer (100), 3 Regular (200), 4 Library Pro (350), 5 Library Legend (500).
- Stamps: one per finished service, 13 in all.
- Discover deck: "Quest k of 6", +10 XP per card added, ends on an XP summary.
- Feedback: "+N XP" pop-up above the tab bar and a level-up banner; nothing shows when XP goes down. Erase Everything resets XP to 0.

Rules live in `FirstChapter/Game.swift` and the game block of `web/index.html`; change both together.

## Known limits

- System share sheet, Safari view, keyboard and AutoFill stay system glass.
- Borrow switches the app to a dark colour scheme so the status bar reads bone on cobalt; a share sheet opened there is dark.
- Not yet checked: VoiceOver, largest Dynamic Type, live AI path, haptics on a device.
