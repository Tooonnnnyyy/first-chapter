# Source consolidation and storage cleanup

Requested by the owner on November 4, 2026: preserve necessary local project files in GitHub, remove wireframe images, and recover local storage.

## Canonical project

- Native iOS: `FirstChapter/` and `FirstChapter.xcodeproj/`.
- Current interactive web app: `web/`.
- Standalone landing page: `landing/index.html`, with embedded **real** Simulator captures replacing all illustrated phone wireframes.
- Pitch: `docs/pitch/index.html`, its generator, and the five compressed JPEG screenshot inputs it uses.
- Older unique prototype: `archive/geeguide-web/`, source and dependency lockfile only. It is retained as an archive, not another production app.
- Requirements, catalog source links, architecture, design guidance, project memory, and task records remain in `docs/` and the root Markdown files.

## Removed from the current tree

- All 18 SVG/PNG wireframe exports in `docs/wireframes/`.
- Five full-size pitch PNGs that duplicate the compressed JPEG inputs. The pitch generator uses only the retained JPEGs.
- No source for the current native app or deployed web app was deleted.

## Local cleanup policy

Verify the GitHub commit contains the archived source before deleting local duplicates. Delete only named First Chapter build products, dependency installs, duplicate source exports, redundant ZIPs, and temporary image conversions. Keep original requirement HEIC photos in Downloads. Exclude credentials, local app data and deployment settings from Git.

The active repository in `Projects/first-chapter` remains the canonical checkout so other agents can continue using it. Downloads can contain links to that checkout and its standalone landing page instead of full duplicate copies.

Generated `node_modules`, Vite output, Xcode build products and SQLite catalog files can be recreated from source. Simulator runtimes, unrelated project caches and user data are outside this cleanup.

## Verification

- Earlier prototype: five tests and TypeScript/Vite production build passed immediately before source archival.
- Source preservation: SHA-256 matches checked for all 21 archived source/configuration files.
- Landing page: four valid embedded JPEG placements with alt text; zero SVG wireframe images or external image dependencies.
- Pitch generator still produces its five-slide deck using retained JPEGs.
- No new native implementation changes; no new native-build claim is made by this cleanup.
- Previous wireframes remain in existing Git history. History is not rewritten, preserving other agents' branches and commits.
