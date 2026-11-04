# Code review — full source pass, 2026-11-04

Reviewer: cutie (Muse), at Tony's request after the Buildathon. Scope: every source file in the repo — `FirstChapter/*.swift` (10 files), `web/index.html`, `web/api/ask.js`, `scripts/run.sh`, `project.pbxproj` — traced against `docs/CRITERIA.md`, `docs/DATA-MODEL.md` and `docs/LIBRARY-FACTS.md`. The app could not be compiled in the review environment (no Xcode), so Swift findings are from close reading; anything marked FIXED is either web code (syntax-checked) or new files written conservatively.

## How the app works (trace)

**Question flow (Ask):** `AskView.send` → `Guide.answer(question, online:)` → local `Catalog.search` runs first → if Online AI is on and a key exists, `askDeepSeek` (question redacted by `Guide.redact`, facts + rules as system prompt, model must end with `SERVICE=<id>`) → else `askApple` (on-device model, only if local search found a match) → else the local match's own answer. Every reply carries its `Guide.Source`, and the UI prints it ("Answered by …"). Fallbacks are honest and labelled, as AGENTS.md requires.

**Data flow:** `Catalog` is a compile-time, read-only list of 13 services + 7 gear groups. Views read it directly. The only writes in the app are `PlanItem` rows in SwiftData (`Store.swift`): serviceID, source, addedAt, doneAt. Plan tab derives progress and "clicks saved" from those rows. Erase = delete all rows + reset onboarding.

**Web parity:** `web/index.html` re-implements the same four tabs in one file with the same data copied into a JS array; `web/api/ask.js` is a small DeepSeek proxy holding a third, condensed copy of the facts as a prompt string.

**Criteria traceability:** UI/UX 25% → native HIG lists/search/tabs in `FindView`, `Theme` (answer on the row: `ServiceRow`). Innovation 25% → `SwipeDeck` in `OnboardingView.swift`, the grounded assistant in `Guide.swift`, click comparison in `ServiceDetail` + `PlanView`. Privacy/feasibility 25% → `Store.swift` (local-only, `.complete` protection, backup-excluded), `Guide.redact`, `DataView`. Prototype quality 15% → all four tabs functional, official links via in-app Safari (`WebLink`). Pitch 10% → `docs/PITCH.md`, `docs/pitch/`.

## Findings

Severity: **P1** fix soon · **P2** worth doing · **P3** note.

### Correctness and robustness

- **R1 · P2 · `Guide.swift` (T8 lead).** `askApple` builds a fresh `LanguageModelSession` per question, and only runs when local search already matched — so the on-device model can never rescue a search miss. On the reported simulator failure: `SystemLanguageModel.default.availability` can report `.available` while `respond(to:)` still throws (model assets not downloaded / Apple Intelligence not enabled in the simulator). The code logs and falls back, so users see no error — but "on-device AI" will rarely be the named source until tested on a real, enabled device. Fix: cache availability once, prewarm a session, and log the concrete error (domain/code) instead of only `String(describing:)`.
- **R2 · P2 · `Guide.swift`.** The DeepSeek reply parser takes the *first* `SERVICE=` in the text. If the model echoes the instruction or repeats it, the visible answer is cut at the wrong place and the trailing id may carry punctuation, so `Catalog.service(id)` misses and silently uses the fallback. Fix: parse the *last* line matching `^SERVICE=([a-z]+)$` and strip everything after it.
- **R3 · P2 · `Store.swift`.** Two issues. (a) The last-resort in-memory container is built with `try!` — if that ever throws, the app crashes at launch rather than degrading. (b) Every mutation does its own fetch + save; `markDone` fetches twice and can save twice. Fix: one private `item(_:)` fetch helper used by all mutations, one save per operation, and remove the `try!` path (a plain default configuration as the final fallback).
- **R4 · P3 · `BorrowView.swift`.** `Catalog.service("camera")!` and `("books")!` force-unwrap. Safe today; one catalog rename away from a crash. Fix: typed accessors (`Catalog.camera`, `Catalog.books`) or a `preconditionFailure`-free fallback row.
- **R5 · P3 · `OnboardingView.swift` (SwipeDeck).** `decide(_:)` animates with `DispatchQueue.main.asyncAfter`; if the student taps **Done** mid-animation, `onDone` can fire twice (deck end + button), and the delayed closure mutates state after dismissal. Fix: one guarded `finish()` plus `Task.sleep` so dismissal cancels the pending step.
- **R6 · P2 · `App.swift` (T12).** Onboarding is an `.overlay` above the `TabView`. The background is opaque now, but the tab interface still exists behind it: VoiceOver focus can reach the tabs, and all four tabs build state before onboarding finishes. Fix: switch the root on `onboarded` (`if onboarded { TabView } else { OnboardingView }`) instead of overlaying; keep the `DEMO_TAB` path working.
- **R7 · P3 · `AskView.swift`.** Scrolling follows `lines.count` only. When `thinking` turns on, the spinner (id `"thinking"`) is never scrolled into view, so on a long chat it can sit off-screen. Fix: also scroll on `thinking` change.
- **R8 · P3 · `App.swift`.** The `DEMO_TAB` environment backdoor ships in release builds. Harmless, but gate it with `#if DEBUG` before any real release.

### Privacy and security

- **S1 · P1 · `web/api/ask.js`. FIXED in this commit.** Redaction existed only in the browser; anyone could POST an unredacted question straight to `/api/ask` and bypass it. The same `redact()` now runs server-side before the DeepSeek call. The native app already redacts on-device (`Guide.redact`) before anything leaves the phone.
- **S2 · P3 · `Guide.swift` / web `redact`.** The phone-number pattern also redacts long benign digit strings (e.g. the date `2026-11-04`). It fails in the privacy-safe direction; noted, not changed.
- **S3 · P3 · docs.** `DATA-MODEL.md` matches the code (no accounts, local store, key handling, DeepSeek caveats). One wording nit: chat lines live in `AskView` state for the whole app session, not only while the Ask tab is open — "never saved, gone when the app closes" is accurate as written.

### Data consistency

- **D1 · P2 · process.** The catalog exists in three hand-copied places: `Catalog.swift`, the `S` array in `web/index.html`, and the `FACTS` string in `web/api/ask.js`. This review compared them field by field: **they agree today** (ids, titles, answers, facts, steps, CTAs, URLs, click counts, gear list). Nothing keeps them in step tomorrow. Fix path: one `catalog.json` as the source, generated into both, plus a tiny parity check; longer term this becomes the "signed JSON served by the Library" already planned in `DATA-MODEL.md`.
- **D2 · P2 · facts.** `docs/CODEX-P0-HANDOFF.md` verified from the official page that the podcast studios are on **CRX floor 2** and that booking is **a request through Library staff**, not a confirmed reservation. `Catalog`'s podcast entry says neither. Add both (source already captured in the handoff; also add to `LIBRARY-FACTS.md`).
- **D3 · P3 · click counts (T3).** The five counts documented in `LIBRARY-FACTS.md` match `Catalog.swift` exactly (camera 5, print 3, cite 3, podcast 3, room 2). The other eight services carry counts in code with no documented path. They are labelled as structure counts, not timed tests, in both places — keep that honesty; T3 stays open for the remaining eight.

### Missing pieces

- **M1 · P1 · app icon. FIXED in this commit.** `project.pbxproj` names `AppIcon` and `AccentColor`, but the repo had **no `Assets.xcassets` at all**, so builds used the placeholder icon and a default accent. Added `FirstChapter/Assets.xcassets` with a 1024×1024 icon (garnet, open book) and the brand accent color (garnet in light mode, the lighter dark-mode brand from `Theme.swift`). Confirm in Xcode that it is picked up (synchronized folder should include it automatically).
- **M2 · P2 · French (T6). Progress in this commit.** `FirstChapter/CatalogFR.swift` added: all 13 services translated (titles, answers, facts, steps, CTAs) with French keywords added to search, same ids/icons/colors/URLs. Nothing references it yet — wiring a language toggle is the follow-up (T15). UI chrome strings are still English-only.
- **M3 · P2 · web style (T13). FIXED in this commit.** The native demo style (colorful: mesh-gradient welcome, full-color deck cards) is now mirrored on the web: welcome screen sits on the same garnet-to-violet mesh, and deck cards are full service colour with white text, matching `DeckCard`. Layout and HIG structure unchanged.
- **M4 · P2 · still needs a Mac.** T7 (VoiceOver / largest Dynamic Type / dark mode pass) and T11 (full test pass on the final native build) cannot be done from the review environment. Checklist for whoever runs it: every control reachable by VoiceOver in order; deck usable by buttons alone; no clipped text at AX5 on Find, Detail, Plan; dark-mode contrast on the mesh-gradient rows (white on the lightest gradient stop is the risk spot); erase flow end-to-end.
- **M5 · blocked on Tony.** T9 (DeepSeek end-to-end) needs the key entered via `scripts/run.sh`; T14 (Import Your Files) is marked needs-Tony in TASKS.md.

### Performance

Everything is small-scale today (13 services), so these are growth notes, not problems: `Catalog.search` runs inside `FindView`'s body per render — fine now, memoize if the catalog grows past a few hundred entries (the web version already re-renders only the results node). `FancyBackground` is a static mesh — negligible. SwiftData fetches are per-tap and tiny (see R3 for the consolidation).

## Optimization roadmap (in order)

1. **Root-switch onboarding (R6)** and **Ask scroll fix (R7)** — small diffs, directly serve the 25% UI/UX criterion.
2. **Podcast fact (D2)** — one fact + steps edit in `Catalog.swift`, mirrored to web + `ask.js`, source added to `LIBRARY-FACTS.md`.
3. **Guide hardening (R1, R2)** — last-line SERVICE parse; cached availability + prewarmed session; test on a real device for T8.
4. **Store consolidation (R3)** and **Borrow accessors (R4)** — crash-proofing before any wider release.
5. **Single-source catalog (D1)** — `catalog.json` + generator + parity check; kills the drift class entirely.
6. **French toggle (T15)** — uOttawa is bilingual; required before a real launch (already in MEMORY.md known issues).
7. **Mac pass (M4)** — T7 + T11 checklists, then T9 once Tony enters the key.

## What changed with this review

- `docs/CODE-REVIEW.md` — this file.
- `web/api/ask.js` — server-side redaction (S1).
- `FirstChapter/Assets.xcassets/` — app icon + accent color (M1).
- `FirstChapter/CatalogFR.swift` — French catalog (M2).
- `web/index.html` — colorful welcome + deck cards (M3).
- `docs/TASKS.md`, `MEMORY.md` — status and log updates.
