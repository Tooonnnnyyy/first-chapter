# V2 Plan — First Chapter as a long-term open-source project

Decided by the owner (Tony) on 2026-11-04, after the Library AI Buildathon (no prize; retrospective in Tony's knowledge base, `BUILDATHON-RETRO.md`). The 40-minute prototype becomes a real project with no deadline pressure. **Working rule from the owner: never edit `main` directly — every workstream lives on its branch with a tracking issue.**

## What changes, and why

V1 proved the content: real Library facts, answer-on-the-row, fewer steps than the website. What it did not have — and what the strongest demo at the event did have — is a reason to come back: a game. V2 keeps V1's content and honesty rules, and rebuilds three layers around it:

1. **Discovery becomes a game** (Duolingo-inspired, not copied): XP, levels, streaks, quests, passport stamps, treasure chests, and a **Reels-style vertical feed** that recommends services from the student's own behavior.
2. **Data becomes a real system**: a server with a SQLite database, personal accounts, and a documented security model — replacing v1's local-only store as the source of truth (local cache stays for offline).
3. **It becomes a platform**: profiles, UGC and community features so students interact with each other (university-email identity), not just with a catalog.

## P0 — decided 2026-11-04, in this order

| # | Priority | Branch | Issue |
| --- | --- | --- | --- |
| P0-1 | Design system v2: gamified tokens (one primary color, defined accents), components, motion | `design/gamified-v2` | #1 |
| P0-2 | Data layer: `server/` (Node + SQLite), schema, seed from the catalog, REST API, security model | `feature/sqlite-data-layer` | #2 |
| P0-3 | Accounts: Google + Microsoft OAuth, sign up / in / out, personal profile | `feature/accounts-auth` | #3 |
| P0-4 | Reels feed: full-screen vertical service cards, behavior-based ranking v1 | `feature/reels-feed` | #4 |

## P1

| # | Priority | Branch |
| --- | --- | --- |
| P1-1 | Gamification engine: XP ledger, levels, streaks, quests, stamps/passport, chest drops | `design/gamified-v2` (with P0-1) |
| P1-2 | UGC + community: posts, comments, likes, report/moderation basics | `feature/community-ugc` |
| P1-3 | Code-review fixes R1–R8 from `docs/reviews/2026-11-04-code-review.md` | (per-file branches) |
| P1-4 | Public polish: README rewrite, `docs/architecture/overview.md`, ADRs, license choice | `docs/v2-architecture` |

## P2

French UI wiring (catalog FR exists, T15), photo-proof stamps, push notifications, TestFlight, accessibility pass (T7), full native test pass (T11).

## Design system v2 (P0-1, decided values)

> Superseded on 2026-11-08: the owner chose the apm-style poster look with DM Mono labels instead. Current values: [design-system.md](../reference/design-system.md). The proposal below is kept for history.

Fancy without garish: saturation stays moderate; the game feel comes from shape, motion and reward timing, not neon.

- **Primary: Garnet `#8F001A`** (uOttawa identity; already the v1 brand). Primary dark `#6E0013`.
- **XP / reward: Gold `#D97706`** (chests, XP, stamps).
- **Go / success: Leaf `#3E9B4F`** (complete states, primary progress).
- **Quest accent: Royal `#5B4B9E`** (quests, rare/epic items).
- **Info: Slate Blue `#2F6FED`** (links, info states) — used sparingly.
- Surfaces: warm paper background `#FAF7F2`, card `#FFFFFF`, ink `#1C1B1A`, muted `#6F6A66`. Dark mode: bg `#141210`, card `#1F1C1A`, primary lifts to `#F57379` (v1 dark brand).
- Shape: chunky radii (16 cards, 24 sheets), soft shadows, thick bottom-edge primary buttons (the Duolingo "pressable" feel, muted).
- Type: rounded display for headings (SF Rounded on iOS / "Baloo 2" on web), system body. No pixel/voxel styling (owner's call).
- Motion: reward moments are the product — stamp slam, chest open, XP count-up; everything else stays quiet. `prefers-reduced-motion` respected.

## Proposed architecture v2 (not yet connected; full doc: `docs/architecture/overview.md` on `docs/v2-architecture`)

```
iOS app (SwiftUI) ──┐
                    ├── HTTPS JSON ──► server/ (Node 24, no framework deps beyond SQLite)
Web app (static) ───┘                     │
                                          ├─ SQLite (one file, WAL mode)
                                          ├─ OAuth: Google + Microsoft (uOttawa = Microsoft 365)
                                          ├─ Own session tokens (hashed at rest)
                                          └─ DeepSeek proxy (existing web/api/ask.js pattern)
```

- **Identity**: OAuth only — no passwords stored, ever. The server issues its own short-lived access token + rotating refresh token (SHA-256 hashed in DB). Sign out revokes the refresh token; account deletion hard-deletes the user row and cascades.
- **Feed ranking v1** (rules-based, documented, no black box): score = unexplored bonus + category affinity from the student's events + active-quest relevance + small recency term. Every card can say *why* it is shown ("Because you saved printing").
- **Gamification**: XP is an append-only ledger (`xp_ledger`), never a mutable counter — levels/streaks/stamps are derived. Chests drop on quest completion with a seeded reward table. Streaks computed in the student's timezone.
- **Data model** (SQLite, see the data-layer issue for the full schema): `users`, `oauth_accounts`, `sessions`, `services`, `plan_items`, `events`, `xp_ledger`, `quests`, `user_quests`, `stamps`, `chests`, `posts`, `comments`, `likes`, `reports`.
- **Security**: parameterized SQL only; tokens hashed; rate limits on auth + write endpoints; input validation on every write; UGC ships with report + moderation queue from day one; uploaded images (future photo stamps) get EXIF/GPS stripped. Data minimization survives from v1: profile needs a display name and nothing else real.
- **This supersedes v1's "no accounts, local-only" stance by owner decision.** `docs/architecture/v1-local-data.md` stays as the v1 record; v2 gets its own data doc + ADR.

## References (style/pattern study — licenses checked 2026-11-04)

- `sanidhyy/duolingo-clone` ("Lingo", ~700★) and `bryanjenningz/react-duolingo` (~470★): useful to study quest/map UI structure. **Both have NO LICENSE file — all rights reserved: patterns and visual ideas only, no code copied.** Same rule for anything else without a license.
- The Gamified Explorer demo photographed at the event (passport/stamps/XP/Reels): concept reference only, per the owner.
- Duolingo's public design language (pressable buttons, XP, streaks) as the mechanic benchmark; Microsoft/Minecraft-style reward clarity without pixel styling.

## Process (the scaffolding lesson, made permanent)

- Branches per workstream (above); PRs into `main`; issues carry scope + acceptance criteria; ADRs in `docs/architecture/decisions/` record every real decision (the thinking process is a deliverable — this repo is public).
- Definition of runnable: `server/` starts with one command and seeds itself; the web app deploys on push; the iOS app builds in Xcode with no secrets required (DeepSeek stays optional).
- Small verified steps over big-bang rewrites: each P0 lands as its own PR with a smoke test noted in the issue.
