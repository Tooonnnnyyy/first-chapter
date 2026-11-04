// Database open + schema + seed. Uses Node's built-in SQLite (Node >= 22),
// so the server has zero npm dependencies: `node src/index.js` just runs.
import { DatabaseSync } from 'node:sqlite';
import { readFileSync, mkdirSync } from 'node:fs';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';

const here = dirname(fileURLToPath(import.meta.url));
const dataDir = process.env.FC_DATA_DIR || join(here, '..', 'data');
mkdirSync(dataDir, { recursive: true });

export const db = new DatabaseSync(join(dataDir, 'firstchapter.db'));
db.exec(readFileSync(join(here, 'schema.sql'), 'utf8'));

// Seed the public catalog and starter quests. Idempotent: INSERT OR IGNORE /
// REPLACE keyed by id, so restarts never duplicate or clobber user data.
export function seed() {
  const catalog = JSON.parse(readFileSync(join(here, 'catalog.json'), 'utf8'));
  const upsertService = db.prepare(`
    INSERT INTO services (id, icon, color, title, answer, facts, steps, cta, url, web_clicks, keywords)
    VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    ON CONFLICT(id) DO UPDATE SET icon=excluded.icon, color=excluded.color, title=excluded.title,
      answer=excluded.answer, facts=excluded.facts, steps=excluded.steps, cta=excluded.cta,
      url=excluded.url, web_clicks=excluded.web_clicks, keywords=excluded.keywords`);
  for (const s of catalog) {
    upsertService.run(s.id, s.icon, s.color, s.title, s.answer,
      JSON.stringify(s.facts), JSON.stringify(s.steps), s.cta, s.url, s.webClicks,
      JSON.stringify(s.keywords));
  }

  const quests = [
    { id: 'first-steps', title: 'First Steps', description: 'Save your first service and finish it.', xp: 50, stamp: 'first-steps', services: [] },
    { id: 'gear-up', title: 'Gear Up', description: 'Complete Borrow a Camera or Gear.', xp: 100, stamp: 'gear-up', services: ['camera'] },
    { id: 'cite-right', title: 'Cite Right', description: 'Complete Cite Your Sources.', xp: 100, stamp: 'cite-right', services: ['cite'] },
    { id: 'base-camp', title: 'Base Camp', description: 'Complete Book a Study Room and Locations and Hours.', xp: 120, stamp: 'base-camp', services: ['room', 'hours'] },
  ];
  const upsertQuest = db.prepare(`
    INSERT INTO quests (id, title, description, xp_reward, stamp_id, service_ids)
    VALUES (?, ?, ?, ?, ?, ?)
    ON CONFLICT(id) DO UPDATE SET title=excluded.title, description=excluded.description,
      xp_reward=excluded.xp_reward, stamp_id=excluded.stamp_id, service_ids=excluded.service_ids`);
  for (const q of quests) upsertQuest.run(q.id, q.title, q.description, q.xp, q.stamp, JSON.stringify(q.services));
  return { services: catalog.length, quests: quests.length };
}
