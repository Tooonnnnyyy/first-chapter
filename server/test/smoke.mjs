// Smoke test: boots the server on a scratch port with a scratch DB and walks
// the API lifecycle — anon session -> save -> complete -> quest settles -> feed.
// Run: npm run smoke (from server/). Uses a temp data dir via FC_DATA_DIR.
import { spawn } from 'node:child_process';
import { mkdtempSync, rmSync } from 'node:fs';
import { once } from 'node:events';
import { tmpdir } from 'node:os';
import { join, dirname } from 'node:path';
import { fileURLToPath } from 'node:url';

const root = join(dirname(fileURLToPath(import.meta.url)), '..');
const dataDir = mkdtempSync(join(tmpdir(), 'fc-smoke-'));
const child = spawn(process.execPath, ['src/index.js'], {
  cwd: root,
  env: { ...process.env, PORT: '0', HOST: '127.0.0.1', FC_DATA_DIR: dataDir },
  stdio: ['ignore', 'pipe', 'pipe'],
});
const exited = once(child, 'exit');
const ready = new Promise((resolve, reject) => {
  let output = '';
  const timer = setTimeout(() => reject(new Error('API startup timed out')), 10000);
  child.stdout.on('data', chunk => {
    output += chunk;
    const match = output.match(/http:\/\/127\.0\.0\.1:\d+/);
    if (match) { clearTimeout(timer); resolve(match[0]); }
  });
  child.once('error', error => { clearTimeout(timer); reject(error); });
  child.once('exit', code => { clearTimeout(timer); reject(new Error(`API exited early: ${code}`)); });
  child.stderr.on('data', chunk => process.stderr.write(chunk));
});
let passed = 0;
const check = (name, cond) => { if (!cond) { console.error(`FAIL: ${name}`); process.exitCode = 1; } else { passed++; console.log(`ok: ${name}`); } };

try {
  const base = await ready;
  const j = async (method, path, token, body) => {
    const r = await fetch(base + path, { method, signal: AbortSignal.timeout(5000), headers: { 'Content-Type': 'application/json', ...(token ? { Authorization: `Bearer ${token}` } : {}) }, body: body ? JSON.stringify(body) : undefined });
    return { status: r.status, data: await r.json().catch(() => ({})) };
  };

  let r = await j('GET', '/api/services');
  check('catalog has 13 services', r.data.services?.length === 13);

  r = await j('POST', '/api/session/anon', null, { displayName: 'Smoke' });
  const token = r.data.token;
  check('anon session issued', r.status === 201 && !!token);

  r = await j('GET', '/api/me', null);
  check('me requires auth', r.status === 401);

  r = await j('POST', '/api/plan', token, { serviceId: 'camera', source: 'feed' });
  check('save camera', r.status === 201);

  r = await j('POST', '/api/plan/camera/complete', token);
  check('complete grants 10 XP', r.data.xpGranted === 10);
  check('gear-up quest settled', (r.data.questsCompleted || []).includes('gear-up'));

  r = await j('POST', '/api/plan/camera/complete', token);
  check('re-complete grants 0 XP (anti-cheese)', r.data.xpGranted === 0);

  r = await j('GET', '/api/me', token);
  check('me shows quest XP (10 + 100)', r.data.xp === 110 && r.data.level === 2);
  check('stamp + chest granted', r.data.stamps?.length === 1 && r.data.chests?.length === 1);

  r = await j('GET', '/api/feed', token);
  check('feed excludes completed camera', !r.data.cards?.some((c) => c.service.id === 'camera'));
  check('feed cards explain themselves', r.data.cards?.every((c) => typeof c.why === 'string' && c.why.length > 0));

  r = await j('POST', '/api/plan', token, { serviceId: 'nope' });
  check('unknown service rejected', r.status === 400);

  const other = await j('POST', '/api/session/anon', null, { displayName: 'Another student' });
  r = await j('GET', '/api/plan', other.data.token);
  check('plans isolated between sessions', r.status === 200 && r.data.items.length === 0);
  r = await j('GET', '/api/me', 'invalid-token');
  check('invalid bearer rejected', r.status === 401);
  r = await j('DELETE', '/api/plan/camera', token);
  check('remove plan item', r.status === 200);
  r = await j('GET', '/api/plan', token);
  check('removed plan is empty', r.data.items.length === 0);
  console.log(`\n${passed} checks passed`);
} finally {
  child.kill();
  await exited;
  rmSync(dataDir, { recursive: true, force: true });
}
