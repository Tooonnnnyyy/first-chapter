# Source consolidation and storage cleanup

> Historical record. Current setup is in the root README. Pitch/demo assets referenced below were subsequently removed; v2 proposals may supersede these decisions.
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

## Completed local cleanup

After verifying the consolidated source on GitHub main (`e5260fa`), 27 named local paths were removed: 15,313 files totaling approximately **427.2 MiB of allocated filesystem blocks**. This is the sum of `du` measurements for deleted paths; APFS snapshots and concurrent activity can affect the change shown in system free space.

Removed: the old Downloads React app with `node_modules`, both isolated iOS build trees, the duplicate iOS source export (older source already retained in Git history), the redundant ZIP, the old standalone landing-page generator and copies, and temporary HEIC conversions/site-download copies. The canonical repository's reproducible `build/` folder was also removed.

Preserved: current source, the 21-file earlier prototype source archive plus README, five compressed real Simulator screenshots used by the pitch, the landing page with real screenshots, and the two original requirement photos in Downloads. The obsolete local preview server was stopped before removing its folder. Simulator runtimes and other applications/projects were untouched.

Downloads now has a `first-chapter` directory link to the canonical checkout and a `First-Chapter-Landing.html` link to `landing/index.html`, keeping the existing entry points without duplicate content. A local JSON deletion inventory is saved alongside those links.
