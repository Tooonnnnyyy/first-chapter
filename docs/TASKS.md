# Tasks

Claim by replacing `open` with your name, commit, push, then work. Stay in the files listed. Keep `main` compiling.

## V2 (from 2026-11-04 — post-hackathon rebuild)

Owner's rule: **never edit `main` directly; one branch + one issue per workstream.** Full plan: `docs/V2-PLAN.md`.

| ID | Task | Branch |
| --- | --- | --- |
| V2-1 | Design system v2 (gamified tokens + components) | `design/gamified-v2` |
| V2-2 | Server + SQLite data layer, REST API, security model | `feature/sqlite-data-layer` |
| V2-3 | Accounts: Google + Microsoft OAuth, profile, sign in/out | `feature/accounts-auth` |
| V2-4 | Reels feed with behavior-based ranking v1 | `feature/reels-feed` |
| V2-5 | Gamification engine: XP, levels, streaks, quests, stamps, chests | `design/gamified-v2` |
| V2-6 | UGC + community: posts, comments, likes, reports | `feature/community-ugc` |
| V2-7 | Public polish: README, ARCHITECTURE.md, ADRs, license | `docs/v2-architecture` |

| ID | Task | Files | Status |
| --- | --- | --- | --- |
| T1 | Native screens on Apple HIG | `FirstChapter/*View.swift`, `Theme.swift`, `App.swift` | Built; full native test pass still open |
| T2 | Real equipment categories and direct links | `Catalog.swift`, `docs/LIBRARY-FACTS.md` | Done |
| T3 | Verify click counts by hand in a browser, correct `webClicks` and `LIBRARY-FACTS.md` | `docs/LIBRARY-FACTS.md`, `webClicks` in `Catalog.swift` | open |
| T4 | Slides for the 5-minute pitch from `docs/PITCH.md` (5 max), with simulator screenshots | `docs/pitch/` | Done: `docs/pitch/index.html`, open in a browser, arrow keys |
| T5 | App icon | `FirstChapter/Assets.xcassets/` | Asset catalog + AccentColor committed (cutie, 2026-11-04); icon PNG handed to Tony in chat — drop it into `AppIcon.appiconset/`, then confirm in Xcode |
| T6 | French strings for the catalog | new `FirstChapter/CatalogFR.swift` | Built (cutie, 2026-11-04): all 13 services translated, FR keywords added; wiring is T15 |
| T7 | Accessibility check: VoiceOver, largest Dynamic Type, dark mode | any view, after T1 | open |
| T8 | Find out why Apple's on-device model call fails in the simulator | `FirstChapter/Guide.swift` | open |
| T9 | Test DeepSeek end to end once Tony has entered a key | `FirstChapter/Guide.swift` | open, needs Tony |
| T12 | Onboarding overlay is layered on top of the tabs | `FirstChapter/App.swift` | Welcome now has an opaque background; layering unchanged |
| T10 | P0 isolated build, simulator smoke verification, accurate demo handoff | `docs/CODEX-P0-HANDOFF.md`, isolated Downloads snapshot only | Codex: build passed; partial live smoke verified; handoff saved |
| T10 | Web version and Vercel deploy | `web/` | Done, live at https://first-chapter-nine.vercel.app |
| T11 | Finish testing every function on the final native build | any view | open |
| T13 | Bring the colorful style to the web version | `web/index.html` | Done (cutie, 2026-11-04): mesh welcome, gradient Discover/CTA rows, full-color deck cards; live on next Vercel deploy |
| T15 | Wire the French catalog to a language toggle | `FirstChapter/App.swift`, views, `CatalogFR.swift` | open |
| T16 | Code-review fixes R1–R8 (see `docs/CODE-REVIEW.md`) | `Guide.swift`, `Store.swift`, `App.swift`, `AskView.swift`, `BorrowView.swift`, `OnboardingView.swift` | open |
| T14 | Make Import Your Files work (currently UI only) | `FirstChapter/FindView.swift` | open, needs Tony |
