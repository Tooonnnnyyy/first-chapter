# First Chapter server

The v2 data layer (issue #2): a small API backed by one SQLite file. Zero npm dependencies — it runs on Node's built-in SQLite and HTTP server.

## Run

```bash
node --version   # needs >= 22
node src/index.js          # http://localhost:8787 (PORT env to change)
npm run smoke              # boots a scratch instance and walks the demo loop
```

The database is created and seeded on first start at `data/firstchapter.db` (override with `FC_DATA_DIR`). Seeding is idempotent and never touches user rows. `data/` is gitignored — the database is never committed.

## API (skeleton)

| Route | Auth | What |
| --- | --- | --- |
| `GET /health` | – | liveness |
| `GET /api/services`, `GET /api/services/:id` | – | public catalog |
| `POST /api/session/anon` | – | create an anonymous user + device token |
| `GET /api/me` | Bearer | profile, XP, level, stamps, chests |
| `GET /api/feed` | Bearer | ranked Reels cards, each with a `why` |
| `GET /api/plan` | Bearer | the user's plan |
| `POST /api/plan` | Bearer | save a service (`{serviceId, source}`) |
| `POST /api/plan/:id/complete` | Bearer | mark done: +10 XP once, settles quests |
| `DELETE /api/plan/:id` | Bearer | remove from plan |
| `POST /api/events` | Bearer | behavior events (view/save/complete/open/ask/skip) |

## Design notes

- **Schema**: `src/schema.sql` — users, OAuth accounts, sessions, catalog, plan, events, append-only `xp_ledger`, quests, stamps, chests, and the UGC tables (posts/comments/likes/reports) ahead of issue #6.
- **Security**: every query is parameterized; session tokens are stored SHA-256 hashed (the raw token exists only on the client); request bodies are size-capped and validated; no passwords exist anywhere — accounts arrive via Google/Microsoft OAuth in issue #3 and plug into the same `sessions` table.
- **XP integrity**: XP is a ledger, never a counter. Completing the same service twice grants 0 the second time; quest rewards settle exactly once.
- **Feed ranking v1** is rules-based (unexplored bonus + keyword affinity + active-quest relevance) and every card says why it was shown. See ADR-0003 when it lands.
- **Quests** are seeded in `src/db.js` (First Steps, Gear Up, Cite Right, Base Camp) and grant XP + a passport stamp + a chest on completion.

## What's next

OAuth sign-in (#3), feed client (#4), chest opening + reward spend (#5), UGC endpoints (#6), rate limiting before any public deploy.
