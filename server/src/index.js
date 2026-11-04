// First Chapter API — skeleton for issue #2 (data layer).
// Zero dependencies: Node >= 24 (built-in node:sqlite + node:http).
// Auth here is anonymous device tokens; OAuth (issue #3) plugs into the same
// sessions table. Every query is parameterized; tokens are stored hashed.
import { createServer } from 'node:http';
import { createHash, randomBytes } from 'node:crypto';
import { db, seed } from './db.js';

const PORT = Number(process.env.PORT ?? 8787);
const HOST = process.env.HOST || '127.0.0.1';
const XP_PER_COMPLETION = 10;
const CHEST_XP = 25;

const hash = (t) => createHash('sha256').update(t).digest('hex');
const newToken = () => randomBytes(32).toString('hex');

function send(res, status, obj) {
  const body = JSON.stringify(obj);
  res.writeHead(status, { 'Content-Type': 'application/json', 'Content-Length': Buffer.byteLength(body) });
  res.end(body);
}

function readBody(req) {
  return new Promise((resolve, reject) => {
    let size = 0; const chunks = [];
    req.on('data', (c) => { size += c.length; if (size > 16384) { reject(new Error('too large')); req.destroy(); } else chunks.push(c); });
    req.on('end', () => { try { resolve(chunks.length ? JSON.parse(Buffer.concat(chunks).toString('utf8')) : {}); } catch { reject(new Error('bad json')); } });
    req.on('error', reject);
  });
}

function authUser(req) {
  // Tokens are exactly 32 random bytes encoded as hexadecimal. Disjoint
  // whitespace/token classes avoid backtracking on malformed headers.
  const m = /^Bearer[ \t]+([a-f0-9]{64})[ \t]*$/i.exec(req.headers.authorization || '');
  if (!m) return null;
  const row = db.prepare(`
    SELECT u.* FROM sessions s JOIN users u ON u.id = s.user_id
    WHERE s.token_hash = ? AND s.revoked_at IS NULL`).get(hash(m[1].trim()));
  if (row) db.prepare(`UPDATE sessions SET last_seen_at = datetime('now') WHERE token_hash = ?`).run(hash(m[1].trim()));
  return row || null;
}

const serviceOut = (s) => ({ ...s, facts: JSON.parse(s.facts), steps: JSON.parse(s.steps), keywords: JSON.parse(s.keywords), webClicks: s.web_clicks });
const allServices = () => db.prepare('SELECT * FROM services').all().map(serviceOut);
const xpOf = (uid) => db.prepare('SELECT COALESCE(SUM(amount),0) AS xp FROM xp_ledger WHERE user_id = ?').get(uid).xp;
const levelOf = (xp) => Math.floor(xp / 100) + 1;

function completedIds(uid) {
  return new Set(db.prepare('SELECT service_id FROM plan_items WHERE user_id = ? AND done_at IS NOT NULL').all(uid).map(r => r.service_id));
}

// After a completion: advance quests whose service set is now fully done.
// Grants quest XP + stamp + one chest, exactly once per quest per user.
function settleQuests(uid) {
  const done = completedIds(uid);
  const granted = [];
  for (const q of db.prepare('SELECT * FROM quests').all()) {
    const needs = JSON.parse(q.service_ids);
    if (!needs.length || !needs.every((id) => done.has(id))) continue;
    const existing = db.prepare('SELECT * FROM user_quests WHERE user_id = ? AND quest_id = ?').get(uid, q.id);
    if (existing?.completed_at) continue;
    db.prepare(`INSERT INTO user_quests (user_id, quest_id, progress, completed_at) VALUES (?, ?, ?, datetime('now'))
                ON CONFLICT(user_id, quest_id) DO UPDATE SET progress = excluded.progress, completed_at = excluded.completed_at`)
      .run(uid, q.id, needs.length);
    db.prepare('INSERT INTO xp_ledger (user_id, amount, reason) VALUES (?, ?, ?)').run(uid, q.xp_reward, `quest:${q.id}`);
    if (q.stamp_id) db.prepare('INSERT OR IGNORE INTO stamps (user_id, stamp_id) VALUES (?, ?)').run(uid, q.stamp_id);
    db.prepare('INSERT INTO chests (user_id, source, reward) VALUES (?, ?, ?)').run(uid, `quest:${q.id}`, JSON.stringify({ xp: CHEST_XP }));
    granted.push(q.id);
  }
  return granted;
}

// Feed ranking v1 (rules-based; ADR-0003): unexplored bonus + keyword affinity
// with what the student saved/finished + active-quest relevance. Completed
// services leave the feed. Every card explains itself.
function feedFor(user) {
  const saved = new Set(db.prepare('SELECT service_id FROM plan_items WHERE user_id = ?').all(user.id).map(r => r.service_id));
  const done = completedIds(user.id);
  const affinityWords = new Set();
  for (const s of allServices()) if (saved.has(s.id) || done.has(s.id)) s.keywords.forEach((k) => affinityWords.add(k));
  const questServices = new Map();
  for (const q of db.prepare('SELECT * FROM quests').all()) {
    const uq = db.prepare('SELECT completed_at FROM user_quests WHERE user_id = ? AND quest_id = ?').get(user.id, q.id);
    if (!uq?.completed_at) for (const id of JSON.parse(q.service_ids)) questServices.set(id, q.title);
  }
  return allServices()
    .filter((s) => !done.has(s.id))
    .map((s) => {
      let score = 0; const why = [];
      if (!saved.has(s.id)) { score += 3; why.push('New to you'); }
      const shared = s.keywords.filter((k) => affinityWords.has(k)).length;
      if (shared) { score += Math.min(shared, 4); why.push('Matches what you have explored'); }
      if (questServices.has(s.id)) { score += 4; why.push(`Part of your quest: ${questServices.get(s.id)}`); }
      if (!why.length) why.push('Worth discovering');
      return { service: s, score, why: why[0] };
    })
    .sort((a, b) => b.score - a.score)
    .slice(0, 10);
}

const server = createServer(async (req, res) => {
  const url = new URL(req.url, 'http://localhost');
  const path = url.pathname;
  try {
    if (req.method === 'GET' && path === '/health') return send(res, 200, { ok: true });

    if (req.method === 'GET' && path === '/api/services') return send(res, 200, { services: allServices() });
    const svcMatch = /^\/api\/services\/([a-z]+)$/.exec(path);
    if (req.method === 'GET' && svcMatch) {
      const s = db.prepare('SELECT * FROM services WHERE id = ?').get(svcMatch[1]);
      return s ? send(res, 200, { service: serviceOut(s) }) : send(res, 404, { error: 'unknown service' });
    }

    if (req.method === 'POST' && path === '/api/session/anon') {
      const body = await readBody(req).catch(() => ({}));
      const name = String(body.displayName || 'Explorer').slice(0, 40).trim() || 'Explorer';
      const info = db.prepare('INSERT INTO users (kind, display_name) VALUES (?, ?)').run('anon', name);
      const token = newToken();
      db.prepare('INSERT INTO sessions (user_id, token_hash, kind) VALUES (?, ?, ?)').run(info.lastInsertRowid, hash(token), 'anon');
      return send(res, 201, { token, user: { id: Number(info.lastInsertRowid), displayName: name } });
    }

    // Everything below requires a session token.
    const user = authUser(req);
    if (!user) return send(res, 401, { error: 'missing or invalid token' });

    if (req.method === 'GET' && path === '/api/me') {
      const xp = xpOf(user.id);
      return send(res, 200, {
        user: { id: user.id, displayName: user.display_name, kind: user.kind },
        xp, level: levelOf(xp),
        stamps: db.prepare('SELECT stamp_id, earned_at FROM stamps WHERE user_id = ?').all(user.id),
        chests: db.prepare('SELECT id, source, reward, opened_at FROM chests WHERE user_id = ?').all(user.id)
          .map((c) => ({ ...c, reward: JSON.parse(c.reward) })),
      });
    }

    if (req.method === 'GET' && path === '/api/feed') return send(res, 200, { cards: feedFor(user) });

    if (req.method === 'GET' && path === '/api/plan') {
      const items = db.prepare('SELECT * FROM plan_items WHERE user_id = ? ORDER BY added_at').all(user.id);
      return send(res, 200, { items });
    }

    if (req.method === 'POST' && path === '/api/plan') {
      const body = await readBody(req);
      const serviceId = String(body.serviceId || '');
      if (!db.prepare('SELECT 1 FROM services WHERE id = ?').get(serviceId)) return send(res, 400, { error: 'unknown serviceId' });
      const source = ['swipe', 'find', 'ask', 'borrow', 'feed'].includes(body.source) ? body.source : 'find';
      db.prepare('INSERT OR IGNORE INTO plan_items (user_id, service_id, source) VALUES (?, ?, ?)').run(user.id, serviceId, source);
      db.prepare('INSERT INTO events (user_id, service_id, type) VALUES (?, ?, ?)').run(user.id, serviceId, 'save');
      return send(res, 201, { ok: true });
    }

    const completeMatch = /^\/api\/plan\/([a-z]+)\/complete$/.exec(path);
    if (req.method === 'POST' && completeMatch) {
      const serviceId = completeMatch[1];
      if (!db.prepare('SELECT 1 FROM services WHERE id = ?').get(serviceId)) return send(res, 400, { error: 'unknown serviceId' });
      db.prepare('INSERT OR IGNORE INTO plan_items (user_id, service_id, source) VALUES (?, ?, ?)').run(user.id, serviceId, 'find');
      const before = db.prepare('SELECT done_at FROM plan_items WHERE user_id = ? AND service_id = ?').get(user.id, serviceId);
      let xpGranted = 0;
      if (!before.done_at) {
        db.prepare('UPDATE plan_items SET done_at = datetime(\'now\') WHERE user_id = ? AND service_id = ?').run(user.id, serviceId);
        db.prepare('INSERT INTO xp_ledger (user_id, amount, reason) VALUES (?, ?, ?)').run(user.id, XP_PER_COMPLETION, `complete:${serviceId}`);
        xpGranted = XP_PER_COMPLETION;
      }
      db.prepare('INSERT INTO events (user_id, service_id, type) VALUES (?, ?, ?)').run(user.id, serviceId, 'complete');
      const quests = settleQuests(user.id);
      return send(res, 200, { ok: true, xpGranted, questsCompleted: quests, xp: xpOf(user.id) });
    }

    const planMatch = /^\/api\/plan\/([a-z]+)$/.exec(path);
    if (req.method === 'DELETE' && planMatch) {
      db.prepare('DELETE FROM plan_items WHERE user_id = ? AND service_id = ?').run(user.id, planMatch[1]);
      return send(res, 200, { ok: true });
    }

    if (req.method === 'POST' && path === '/api/events') {
      const body = await readBody(req);
      const type = String(body.type || '');
      if (!['view', 'save', 'complete', 'open', 'ask', 'skip'].includes(type)) return send(res, 400, { error: 'unknown event type' });
      const serviceId = body.serviceId ? String(body.serviceId) : null;
      if (serviceId && !db.prepare('SELECT 1 FROM services WHERE id = ?').get(serviceId)) return send(res, 400, { error: 'unknown serviceId' });
      db.prepare('INSERT INTO events (user_id, service_id, type) VALUES (?, ?, ?)').run(user.id, serviceId, type);
      return send(res, 201, { ok: true });
    }

    return send(res, 404, { error: 'not found' });
  } catch (e) {
    return send(res, 500, { error: 'server error' });
  }
});

seed();
server.listen(PORT, HOST, () => console.log(`First Chapter API on http://${HOST}:${server.address().port}`));
