#!/usr/bin/env python3
"""Apply this repository's labels with an authenticated GitHub CLI."""
import json
from pathlib import Path
import subprocess
root = Path(__file__).resolve().parents[2]
for label in json.loads((root / '.github/labels.json').read_text()):
    subprocess.run(['gh', 'label', 'create', label['name'], '--repo', 'Tooonnnnyyy/first-chapter', '--color', label['color'], '--description', label['description'], '--force'], check=True)
print('Repository labels synchronized.')
