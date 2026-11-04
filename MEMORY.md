# MEMORY.md: long-term project memory

Durable facts and decisions. Overwrite when stale. Add one log line per change. Details live in `docs/`: link, don't copy.

_Last updated: 2026-11-04._

## What this is

**First Chapter**: native iOS guide to uOttawa Library services for first-year students. Owner: Tony (GitHub `Tooonnnnyyy`). Repo is public (Tony, 2026-11-04). Never commit keys or personal data. Local path on Tony's Mac: `~/Projects/first-chapter`.

## Where it lives

- **Live web version:** https://first-chapter-nine.vercel.app (Vercel project `first-chapter`, team `tony-7d93`, source in `web/`). Redeploy: `cd web && vercel link --project first-chapter --yes && vercel deploy --prod`.
- **Native app:** `FirstChapter.xcodeproj`, runs in the simulator. An iPhone install needs Apple signing; a public release needs TestFlight.
- **Repo:** https://github.com/Tooonnnnyyy/first-chapter (public).

## The event

- Library AI Buildathon, **2026-11-04, 1:30 to 3:00 p.m.**, Learning Crossroads CRX 230. Prize $150 CAD.
- Build in under 40 minutes, then **5 minutes** per team for the judges. Teams of 3 to 5. Code or mock-up allowed, any AI tools allowed. The event asks for an AI-powered solution.
- Host contact: Paul.Tanase@uottawa.ca. Source: https://www.uottawa.ca/en/events-all/join-ai-buildathon-library
- The brief and scoring table are transcribed in `docs/CRITERIA.md`.

## Priorities from Tony

1. **All functions must work.**
2. **First-years find information more easily, in fewer steps than the website.**
3. Borrowing gear (cameras etc.) is a core feature.
4. Simple AI assistant only. Do not spend most of the time on it.

## Stack (final)

SwiftUI, SwiftData, iOS 26+, Xcode. No dependencies, no backend. Figma not used: a running app beat a mock-up on time.

## Decisions

| Decision | Why | Who, when |
| --- | --- | --- |
| P0 is fewer steps than the website | Owner's instruction | Tony, 2026-11-04 |
| Borrowing gear is core | Owner's instruction | Tony, 2026-11-04 |
| Native SwiftUI | Owner allowed Xcode; runs in the simulator | Tony, 2026-11-04 |
| **Design system: Apple Human Interface Guidelines** | Tony rejected the first custom zinc/amber look as "pretty AI, pretty odd" and asked for an existing design system | Tony, 2026-11-04 |
| Separate private repo | Owner's instruction; unrelated to ideamap | Tony, 2026-11-04 |
| DeepSeek for the assistant | Owner's instruction | Tony, 2026-11-04 |
| Answer shown on the row itself | Fewer taps: most students need no second screen | Agent, 2026-11-04 |
| No accounts; plan stored on the phone | Data privacy is 25% of the score | Agent, 2026-11-04 |
| Link to official booking and loan systems | No API access; never fake a booking or stock level | Agent, 2026-11-04 |

## Demo style (2026-11-04)

Tony asked for a more colorful, simple look for the demo: mesh gradient on Welcome, the Discover banner and each service's main button, plus full-color swipe cards. `web/` still has the earlier style. **Import Your Files** on Find is UI only, at Tony's request: it's marked Soon and shows a Coming Soon alert. Don't present it as working.

## Current state

- Local artifacts are consolidated: `landing/` contains the standalone page with real product screenshots; `archive/geeguide-web/` preserves the earlier React prototype source. Generated wireframes and redundant full-size pitch captures were removed. See `docs/STORAGE-CLEANUP.md`.

- `FirstChapter/` holds the app. Screens: onboarding and swipe deck, Find, Borrow, Ask, My Plan, Your Data.
- See `docs/TASKS.md` for what's open and what has been tested.

## DeepSeek key

- Not in the repo, and not found in Tony's environment or project `.env` files. Tony enters it by running `./scripts/run.sh`, which stores it in the gitignored `FirstChapter/Secrets.plist`.
- **Never commit a key.** Before committing: `git check-ignore FirstChapter/Secrets.plist`.
- Without a key, Ask tries Apple's on-device model, then local search. Each reply names its source.
- The `deepseek-chat` call has not been tested against the live API yet (no key).
- A key inside an app can be extracted. That is fine for a local demo only. A real release needs a small proxy server.

## Test status (2026-11-04)

- Web, live site: 38-check function run, 35 passed. The 3 failures all looked for "Most Needed", which the page shows in capitals, so the check was wrong.
- DeepSeek on the web: `/api/ask` answers 503 until `DEEPSEEK_API_KEY` is set in Vercel. The page then uses Library search and says so.
- Native: launch, swipe deck and Find screen seen in the simulator. The earlier style's four tabs were walked through. Full pass on the final native build is not finished.

## Known issues

- Apple's on-device model reported available in the simulator, but a call failed and the app fell back to local search. Cause not investigated. See T8.
- Click counts come from page structure, not a timed user test.
- English only. uOttawa is bilingual, so French is required before any real launch.

## Open questions for Tony

1. Team name and members for the pitch?
2. DeepSeek key: run `./scripts/run.sh`, or demo without it?
3. ~~Keep the repo private after the event?~~ Tony made it public, 2026-11-04. No license chosen yet.
4. Is the name "First Chapter" OK?

## Log

- 2026-11-04: repo created, docs and project skeleton pushed.
- 2026-11-04: first app version running in the simulator; real equipment categories added.
- 2026-11-04: colorful demo style and Import Your Files entry (UI only) added to the native app.
- 2026-11-04: wireframes of all eight screens added in `docs/wireframes/`.
- 2026-11-04: web version deployed to Vercel at Tony's request, with a small DeepSeek proxy.
- 2026-11-04: redesigned on Apple HIG at Tony's request; DeepSeek assistant added; direct links to official pages added.
- 2026-11-04: build verified with `-destination 'id=<sim UDID>'` (the name-only destination fails on Xcode 27); first paint takes about 10 seconds in the simulator before the UI appears. Pitch deck at `docs/pitch/index.html`.
- 2026-11-04: Codex isolated Downloads iOS build passed; partial Simulator smoke verified My Plan and Borrow. Full UI verification remains incomplete during concurrent simulator testing. See docs/CODEX-P0-HANDOFF.md. Self-contained landing page delivered in Downloads with labelled illustrated UI previews.
- 2026-11-04: full source code review by cutie at Tony's request (`docs/CODE-REVIEW.md`): all Swift + web code traced against the criteria; catalog copies in Swift/web/ask.js verified in agreement. Fixed in the same pass: server-side redaction in `web/api/ask.js`, the missing `Assets.xcassets` (catalog + accent color committed; the project file already named both — icon PNG handed to Tony to drop into `AppIcon.appiconset/`), web colorful style (T13). Added `CatalogFR.swift` (T6) — French toggle wiring is T15; review fixes R1–R8 are T16.

- 2026-11-04: Owner requested source consolidation and storage recovery. Codex archived unique prototype source, removed current-tree wireframes, and replaced landing wireframes with real Simulator captures; local duplicates are removed only after remote backup verification.

- 2026-11-04: Source backup verified on GitHub before cleanup. Removed 427.2 MiB of duplicate/generated local files (15,313 files); kept the canonical checkout, source archive and original requirement photos. Downloads entries now link to canonical files.
