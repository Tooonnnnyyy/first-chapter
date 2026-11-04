import { readFileSync, mkdtempSync, writeFileSync, rmSync, readdirSync } from 'node:fs';
import { join } from 'node:path';
import { tmpdir } from 'node:os';
import { execFileSync } from 'node:child_process';
const scratch = mkdtempSync(join(tmpdir(), 'first-chapter-syntax-'));
let checked = 0;
try {
  for (const file of ['web/index.html', 'landing/index.html']) {
    const html = readFileSync(file, 'utf8');
    for (const [index, match] of [...html.matchAll(/<script\b([^>]*)>([\s\S]*?)<\/script>/gi)].entries()) {
      if (/src=|application\/ld\+json/.test(match[1])) continue;
      const script = join(scratch, `${checked}-${index}.mjs`);
      writeFileSync(script, match[2]);
      execFileSync(process.execPath, ['--check', script], { stdio: 'inherit' });
      checked++;
    }
  }
  for (const folder of ['web/api', 'server/src', 'server/test', 'scripts']) {
    for (const file of readdirSync(folder).filter(f => /\.(mjs|js)$/.test(f))) {
      execFileSync(process.execPath, ['--check', join(folder, file)], { stdio: 'inherit' });
      checked++;
    }
  }
  const landing = readFileSync('landing/index.html', 'utf8');
  const images = [...landing.matchAll(/<img\b[^>]*src="([^"]+)"[^>]*>/gi)];
  if (!images.length || images.some(m => !m[1].startsWith('data:image/') || !/alt="[^"]+"/.test(m[0]))) {
    throw new Error('Landing images must be embedded and have descriptive alt text');
  }
  console.log(`Syntax passed: ${checked} scripts; ${images.length} embedded landing images with alt text.`);
} finally { rmSync(scratch, { recursive: true, force: true }); }
