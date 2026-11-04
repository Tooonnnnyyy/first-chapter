#!/usr/bin/env python3
"""Check repository-local Markdown links and accidental sensitive/generated files."""
from pathlib import Path
import re
import subprocess
import sys
from urllib.parse import unquote, urlsplit

root = Path(__file__).resolve().parents[1]
paths = subprocess.check_output(['git', 'ls-files', '--cached', '--others', '--exclude-standard', '-z'], cwd=root).decode().split('\0')
errors = []
checked = 0
for name in sorted(set(paths)):
    path = root / name
    if not name or not path.is_file():
        continue
    if re.search(r'(^|/)(node_modules|DerivedData|data/firstchapter\.db)(/|$)|Secrets\.plist$|\.env($|\.(?!example$))|\.(db|sqlite|sqlite-wal|sqlite-shm)$', name):
        errors.append(f'{name}: sensitive/generated file must not be tracked')
    if path.suffix not in {'.md', '.swift', '.js', '.mjs', '.json', '.yml', '.yaml', '.html', '.sh', '.py'}:
        continue
    content = path.read_text()
    for pattern in [r'-----BEGIN (?:RSA |EC |OPENSSH )?PRIVATE KEY-----', r'gh[pousr]_[A-Za-z0-9]{30,}', r'sk-[A-Za-z0-9]{32,}']:
        if re.search(pattern, content):
            errors.append(f'{name}: possible credential (value withheld)')
    if path.suffix != '.md':
        continue
    checked += 1
    for link in re.findall(r'(?<!!)\[[^\]]*\]\(([^\s)]+)(?:\s+[^)]*)?\)', content):
        link = link.strip('<>')
        parsed = urlsplit(link)
        if parsed.scheme or link.startswith('#') or not parsed.path:
            continue
        target = (path.parent / unquote(parsed.path)).resolve()
        if not target.is_relative_to(root) or not target.exists():
            errors.append(f'{name}: broken local link: {link}')
if errors:
    print('\n'.join(errors), file=sys.stderr)
    sys.exit(1)
print(f'Repository checks passed: {checked} Markdown files; local links and basic source hygiene.')
