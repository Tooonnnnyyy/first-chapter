#!/usr/bin/env python3
"""Parse local HTML and syntax-check its scripts without executing them."""
from html.parser import HTMLParser
from pathlib import Path
import subprocess
import tempfile

class Page(HTMLParser):
    def __init__(self):
        super().__init__(convert_charrefs=False)
        self.scripts = []
        self.images = []
        self.current = None

    def handle_starttag(self, tag, attrs):
        attrs = dict(attrs)
        if tag == 'img':
            self.images.append(attrs)
        if tag == 'script' and 'src' not in attrs and attrs.get('type', '') in ('', 'text/javascript', 'module'):
            self.current = []

    def handle_data(self, data):
        if self.current is not None:
            self.current.append(data)

    def handle_endtag(self, tag):
        if tag == 'script' and self.current is not None:
            self.scripts.append(''.join(self.current))
            self.current = None

checked = 0
with tempfile.TemporaryDirectory(prefix='first-chapter-syntax-') as scratch:
    for filename in ['web/index.html', 'landing/index.html']:
        page = Page()
        page.feed(Path(filename).read_text())
        page.close()
        for script in page.scripts:
            target = Path(scratch) / f'{checked}.mjs'
            target.write_text(script)
            subprocess.run(['node', '--check', str(target)], check=True)
            checked += 1
        if filename.startswith('landing/'):
            assert page.images, 'Landing must have product images'
            assert all(i.get('src', '').startswith('data:image/') and i.get('alt', '').strip() for i in page.images), 'Landing images must be embedded with alt text'
            images = len(page.images)
    for folder in ['web/api', 'server/src', 'server/test', 'scripts']:
        for path in Path(folder).iterdir():
            if path.suffix in {'.js', '.mjs'}:
                subprocess.run(['node', '--check', str(path)], check=True)
                checked += 1
print(f'Syntax passed: {checked} scripts; {images} embedded landing images with alt text.')
