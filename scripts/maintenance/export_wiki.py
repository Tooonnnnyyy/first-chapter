#!/usr/bin/env python3
"""Generate Wiki navigation backed by versioned repository docs. No credentials."""
import argparse
from pathlib import Path
parser = argparse.ArgumentParser()
parser.add_argument('output', type=Path)
args = parser.parse_args()
args.output.mkdir(parents=True, exist_ok=True)
base = 'https://github.com/Tooonnnnyyy/first-chapter/blob/main/'
pages = {
    'Home': '# First Chapter Wiki\n\n[English](English) · [Français](Français) · [简体中文](简体中文)\n\nDocumentation lives in the repository and is reviewed in pull requests. These pages link to its current version; README is the usage guide.\n',
    'English': f'# English\n\n- [Use First Chapter]({base}README.md)\n- [Contribute and maintain]({base}docs/en/maintenance.md)\n- [Architecture]({base}docs/architecture/overview.md)\n- [Roadmap]({base}docs/planning/v2-roadmap.md)\n',
    'Français': f'# Français\n\n- [Utiliser First Chapter]({base}docs/fr/README.md)\n- [Contribuer et maintenir]({base}docs/fr/maintenance.md)\n- [Architecture de référence (anglais)]({base}docs/architecture/overview.md)\n',
    '简体中文': f'# 简体中文\n\n- [使用 First Chapter]({base}docs/zh-CN/README.md)\n- [贡献与维护]({base}docs/zh-CN/maintenance.md)\n- [架构参考（英文）]({base}docs/architecture/overview.md)\n',
    '_Sidebar': '[Home](Home)\n\n[English](English) · [Français](Français) · [简体中文](简体中文)\n',
}
for name, body in pages.items():
    (args.output / f'{name}.md').write_text(body)
print(f'Generated {len(pages)} Wiki pages in {args.output}')
