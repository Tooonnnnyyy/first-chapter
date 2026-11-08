# Project memory

Updated 2026-11-08. This file records current state; README owns usage instructions.

## Purpose and priority

First Chapter helps first-year uOttawa students discover Library services and borrow equipment. **P0: accurate, accessible information and working essential functions.** Public repository: https://github.com/Tooonnnnyyy/first-chapter. Owner: @Tooonnnnyyy. License: MIT, selected by the owner.

## Current implementation

- `FirstChapter/`: SwiftUI/SwiftData, iOS 26+. Plans stay on the device.
- `web/`: static interactive client with browser-local plans; optional Vercel DeepSeek proxy. Published URL: https://first-chapter-nine.vercel.app.
- Both clients: apm-style design and a local game layer (XP, chapters, quests, stamps) derived only from saved plans; no schema change. See `docs/reference/design-system.md`.
- `server/`: separate experimental Node 24/SQLite API from PR #10. No current client connection; OAuth and account lifecycle are not implemented.
- `landing/index.html`: standalone page with embedded real prototype screenshots.
- `archive/geeguide-web/`: earlier prototype source only.
- Optional native DeepSeek direct-key support is private-development legacy. No key is committed; live provider behavior remains unverified. Core local search needs no key.

## Decisions

- Workstream branch + tracking issue + PR; never edit `main` directly.
- The 2026-11-04 post-hackathon v2 plan supersedes the original no-account/HIG-only constraints. Gamified design, accounts, feed and community are planned work: see `docs/planning/v2-roadmap.md`.
- 2026-11-08: owner chose the apm-style design system for the current apps and kept DM Mono labels. It supersedes the HIG guide and the v2 roadmap's gold/rounded values.
- Official links own reservations and availability. A request is not a confirmed booking.
- Documentation in English, French and Simplified Chinese; current app localization remains incomplete.
- Owner requested removal of pitch/demo material and consolidation of usage instructions into README. Build/test/maintenance scripts remain.
- App and deployment source paths stay stable while other branches are active.

## Evidence and gaps

- Earlier native build and partial Simulator checks were recorded in the dated review. Full native accessibility/end-to-end validation remains open.
- Apple's on-device model can report available and fail during inference; local fallback is labelled.
- Import Your Files is a placeholder. French catalog exists but language selection is not connected.
- Click-saving figures are estimates. Library facts require periodic official-source review.
- Experimental server lacks production auth lifecycle/rate limiting and has known quest/reward edge cases; see `docs/architecture/overview.md`.
- This foundation adds repeatable CI checks; CI build success does not certify UI behavior or production readiness.

## Log

- 2026-11-04: Library Buildathon prototype created; native and web implementations, catalog and source links preserved.
- 2026-11-04: Owner moved the project to long-term open source; v2 plan and experimental SQLite API merged.
- 2026-11-04: Source consolidation removed duplicate/generated local artifacts after remote backup. See `docs/history/2026-11-04-storage-cleanup.md`.
- 2026-11-04: Open-source foundation on `chore/open-source-foundation`, issue #7: MIT, multilingual docs, CI/community/release/package configuration, demo removal and safer build helper. Integration status is tracked by its PR.
- 2026-11-08: apm-style restyle and local game layer on both clients (issue/PR on `feature/apm-style-game`). Native: real-tap Simulator review; web: 90 browser checks at 390 and 1440 wide.
