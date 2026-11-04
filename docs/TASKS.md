# Tasks

Claim by replacing `open` with your name, commit, push, then work. Stay in the files listed. Keep `main` compiling.

| ID | Task | Files | Status |
| --- | --- | --- | --- |
| T1 | Native screens on Apple HIG | `FirstChapter/*View.swift`, `Theme.swift`, `App.swift` | Built; full native test pass still open |
| T2 | Real equipment categories and direct links | `Catalog.swift`, `docs/LIBRARY-FACTS.md` | Done |
| T3 | Verify click counts by hand in a browser, correct `webClicks` and `LIBRARY-FACTS.md` | `docs/LIBRARY-FACTS.md`, `webClicks` in `Catalog.swift` | open |
| T4 | Slides for the 5-minute pitch from `docs/PITCH.md` (5 max), with simulator screenshots | `docs/pitch/` | Done: `docs/pitch/index.html`, open in a browser, arrow keys |
| T5 | App icon | `FirstChapter/Assets.xcassets/` | open |
| T6 | French strings for the catalog | new `FirstChapter/CatalogFR.swift` | open |
| T7 | Accessibility check: VoiceOver, largest Dynamic Type, dark mode | any view, after T1 | open |
| T8 | Find out why Apple's on-device model call fails in the simulator | `FirstChapter/Guide.swift` | open |
| T9 | Test DeepSeek end to end once Tony has entered a key | `FirstChapter/Guide.swift` | open, needs Tony |
| T12 | Onboarding overlay is layered on top of the tabs | `FirstChapter/App.swift` | Welcome now has an opaque background; layering unchanged |
| T10 | P0 isolated build, simulator smoke verification, accurate demo handoff | `docs/CODEX-P0-HANDOFF.md`, isolated Downloads snapshot only | Codex: build passed; partial live smoke verified; handoff saved |
| T10 | Web version and Vercel deploy | `web/` | Done, live at https://first-chapter-nine.vercel.app |
| T11 | Finish testing every function on the final native build | any view | open |
| T13 | Bring the colorful style to the web version | `web/index.html` | open |
| T14 | Make Import Your Files work (currently UI only) | `FirstChapter/FindView.swift` | open, needs Tony |
