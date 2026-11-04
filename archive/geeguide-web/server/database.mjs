import { DatabaseSync } from 'node:sqlite';
import { readFileSync, mkdirSync } from 'node:fs';
import { dirname } from 'node:path';
export const seed = JSON.parse(readFileSync(new URL('../data/catalog.json', import.meta.url), 'utf8'));
export function openCatalog(path = ':memory:') {
 if (path !== ':memory:') mkdirSync(dirname(path), { recursive: true });
 const db = new DatabaseSync(path);
 db.exec(`PRAGMA foreign_keys=ON;
 CREATE TABLE IF NOT EXISTS sources(id TEXT PRIMARY KEY,title TEXT NOT NULL,url TEXT NOT NULL CHECK(url LIKE 'https://%'),checked_at TEXT NOT NULL);
 CREATE TABLE IF NOT EXISTS services(id TEXT PRIMARY KEY,source_id TEXT NOT NULL REFERENCES sources(id),title TEXT NOT NULL,category TEXT NOT NULL,payload TEXT NOT NULL CHECK(json_valid(payload)));
 CREATE TABLE IF NOT EXISTS service_steps(service_id TEXT REFERENCES services(id) ON DELETE CASCADE,position INTEGER NOT NULL,label TEXT NOT NULL,PRIMARY KEY(service_id,position));
 CREATE TABLE IF NOT EXISTS service_goals(service_id TEXT REFERENCES services(id) ON DELETE CASCADE,goal TEXT NOT NULL,PRIMARY KEY(service_id,goal));`);
 db.exec('BEGIN');
 try {
  db.exec('DELETE FROM service_steps; DELETE FROM service_goals; DELETE FROM services; DELETE FROM sources;');
  for (const s of seed.sources) db.prepare('INSERT INTO sources VALUES(?,?,?,?)').run(s.id,s.title,s.url,seed.checkedAt);
  for (const s of seed.services) {
   const {steps,goals,...payload}=s;
   db.prepare('INSERT INTO services VALUES(?,?,?,?,?)').run(s.id,s.sourceId,s.title,s.category,JSON.stringify(payload));
   steps.forEach((label,i)=>db.prepare('INSERT INTO service_steps VALUES(?,?,?)').run(s.id,i,label));
   goals.forEach(goal=>db.prepare('INSERT INTO service_goals VALUES(?,?)').run(s.id,goal));
  }
  db.exec('COMMIT');
 } catch(error) { db.exec('ROLLBACK');throw error; }
 return db;
}
export function readCatalog(db) {
 return {checkedAt:seed.checkedAt,sources:db.prepare('SELECT id,title,url FROM sources ORDER BY rowid').all().map(s=>({...s})),services:db.prepare('SELECT id,payload FROM services ORDER BY rowid').all().map(s=>({...JSON.parse(s.payload),steps:db.prepare('SELECT label FROM service_steps WHERE service_id=? ORDER BY position').all(s.id).map(r=>r.label),goals:db.prepare('SELECT goal FROM service_goals WHERE service_id=? ORDER BY rowid').all(s.id).map(r=>r.goal)}))};
}
