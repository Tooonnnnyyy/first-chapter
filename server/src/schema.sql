-- First Chapter server schema (SQLite, WAL mode).
-- Design rules: no passwords anywhere (OAuth only); session/refresh tokens are
-- stored SHA-256 hashed; XP is an append-only ledger, never a mutable counter;
-- every write path in the API maps to exactly one of these tables.

PRAGMA journal_mode = WAL;
PRAGMA foreign_keys = ON;

CREATE TABLE IF NOT EXISTS users (
  id            INTEGER PRIMARY KEY,
  kind          TEXT NOT NULL DEFAULT 'anon' CHECK (kind IN ('anon','oauth')),
  display_name  TEXT NOT NULL DEFAULT 'Explorer',
  avatar_url    TEXT,
  faculty       TEXT,
  year          INTEGER,
  timezone      TEXT NOT NULL DEFAULT 'America/Toronto',
  created_at    TEXT NOT NULL DEFAULT (datetime('now'))
);

-- One row per linked sign-in provider (google | microsoft). provider_user_id
-- is the provider's stable subject id. Email is kept only as the account key
-- the owner signed in with; it is never displayed publicly.
CREATE TABLE IF NOT EXISTS oauth_accounts (
  id               INTEGER PRIMARY KEY,
  user_id          INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  provider         TEXT NOT NULL CHECK (provider IN ('google','microsoft')),
  provider_user_id TEXT NOT NULL,
  email            TEXT,
  created_at       TEXT NOT NULL DEFAULT (datetime('now')),
  UNIQUE (provider, provider_user_id)
);

-- Anonymous device tokens and (later) OAuth refresh tokens. Only the SHA-256
-- hash is stored; the raw token exists only on the client.
CREATE TABLE IF NOT EXISTS sessions (
  id           INTEGER PRIMARY KEY,
  user_id      INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  token_hash   TEXT NOT NULL UNIQUE,
  kind         TEXT NOT NULL DEFAULT 'anon' CHECK (kind IN ('anon','refresh')),
  created_at   TEXT NOT NULL DEFAULT (datetime('now')),
  last_seen_at TEXT NOT NULL DEFAULT (datetime('now')),
  revoked_at   TEXT
);

-- Public Library catalog, seeded from catalog.json (compiled from the same
-- facts as the apps). Holds no user data.
CREATE TABLE IF NOT EXISTS services (
  id         TEXT PRIMARY KEY,
  icon       TEXT NOT NULL,
  color      TEXT NOT NULL,
  title      TEXT NOT NULL,
  answer     TEXT NOT NULL,
  facts      TEXT NOT NULL DEFAULT '[]',   -- JSON [{label, value}]
  steps      TEXT NOT NULL DEFAULT '[]',   -- JSON [string]
  cta        TEXT NOT NULL,
  url        TEXT NOT NULL,
  web_clicks INTEGER NOT NULL DEFAULT 0,
  keywords   TEXT NOT NULL DEFAULT '[]'    -- JSON [string]
);

-- The v1 PlanItem, now per-user and synced. Unique per (user, service).
CREATE TABLE IF NOT EXISTS plan_items (
  id         INTEGER PRIMARY KEY,
  user_id    INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  service_id TEXT NOT NULL REFERENCES services(id),
  source     TEXT NOT NULL DEFAULT 'find',  -- swipe | find | ask | borrow | feed
  added_at   TEXT NOT NULL DEFAULT (datetime('now')),
  done_at    TEXT,
  UNIQUE (user_id, service_id)
);

-- Behavior events: the raw material for feed ranking and XP anti-cheese.
CREATE TABLE IF NOT EXISTS events (
  id         INTEGER PRIMARY KEY,
  user_id    INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  service_id TEXT REFERENCES services(id),
  type       TEXT NOT NULL CHECK (type IN ('view','save','complete','open','ask','skip')),
  created_at TEXT NOT NULL DEFAULT (datetime('now'))
);
CREATE INDEX IF NOT EXISTS idx_events_user ON events(user_id, created_at);

-- Append-only XP ledger. Balance = SUM(amount). reason is machine-readable
-- ('complete:camera') so every point can be audited.
CREATE TABLE IF NOT EXISTS xp_ledger (
  id         INTEGER PRIMARY KEY,
  user_id    INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  amount     INTEGER NOT NULL,
  reason     TEXT NOT NULL,
  created_at TEXT NOT NULL DEFAULT (datetime('now'))
);
CREATE INDEX IF NOT EXISTS idx_xp_user ON xp_ledger(user_id);

CREATE TABLE IF NOT EXISTS quests (
  id          TEXT PRIMARY KEY,
  title       TEXT NOT NULL,
  description TEXT NOT NULL,
  xp_reward   INTEGER NOT NULL DEFAULT 0,
  stamp_id    TEXT,
  service_ids TEXT NOT NULL DEFAULT '[]'   -- JSON [service id]: complete all to finish
);

CREATE TABLE IF NOT EXISTS user_quests (
  id          INTEGER PRIMARY KEY,
  user_id     INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  quest_id    TEXT NOT NULL REFERENCES quests(id),
  progress    INTEGER NOT NULL DEFAULT 0,
  completed_at TEXT,
  UNIQUE (user_id, quest_id)
);

-- Passport stamps earned (one per user per stamp).
CREATE TABLE IF NOT EXISTS stamps (
  id       INTEGER PRIMARY KEY,
  user_id  INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  stamp_id TEXT NOT NULL,
  earned_at TEXT NOT NULL DEFAULT (datetime('now')),
  UNIQUE (user_id, stamp_id)
);

-- Treasure chests: granted by quests/events, opened once.
CREATE TABLE IF NOT EXISTS chests (
  id        INTEGER PRIMARY KEY,
  user_id   INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  source    TEXT NOT NULL,               -- 'quest:<id>' | 'streak:7' | ...
  reward    TEXT NOT NULL DEFAULT '{}',  -- JSON {xp?, badge?}
  granted_at TEXT NOT NULL DEFAULT (datetime('now')),
  opened_at TEXT
);

-- UGC (issue #6 builds the API; tables land with the data layer).
CREATE TABLE IF NOT EXISTS posts (
  id         INTEGER PRIMARY KEY,
  user_id    INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  service_id TEXT REFERENCES services(id),
  body       TEXT NOT NULL CHECK (length(body) <= 2000),
  status     TEXT NOT NULL DEFAULT 'visible' CHECK (status IN ('visible','hidden','removed')),
  created_at TEXT NOT NULL DEFAULT (datetime('now'))
);

CREATE TABLE IF NOT EXISTS comments (
  id         INTEGER PRIMARY KEY,
  post_id    INTEGER NOT NULL REFERENCES posts(id) ON DELETE CASCADE,
  user_id    INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  body       TEXT NOT NULL CHECK (length(body) <= 1000),
  status     TEXT NOT NULL DEFAULT 'visible' CHECK (status IN ('visible','hidden','removed')),
  created_at TEXT NOT NULL DEFAULT (datetime('now'))
);

CREATE TABLE IF NOT EXISTS likes (
  user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  post_id INTEGER NOT NULL REFERENCES posts(id) ON DELETE CASCADE,
  created_at TEXT NOT NULL DEFAULT (datetime('now')),
  PRIMARY KEY (user_id, post_id)
);

CREATE TABLE IF NOT EXISTS reports (
  id         INTEGER PRIMARY KEY,
  reporter_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  target_type TEXT NOT NULL CHECK (target_type IN ('post','comment')),
  target_id  INTEGER NOT NULL,
  reason     TEXT NOT NULL DEFAULT '',
  status     TEXT NOT NULL DEFAULT 'open' CHECK (status IN ('open','actioned','dismissed')),
  created_at TEXT NOT NULL DEFAULT (datetime('now'))
);
