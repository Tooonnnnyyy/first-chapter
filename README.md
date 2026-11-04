# First Chapter

[English](README.md) · [Français](docs/fr/README.md) · [简体中文](docs/zh-CN/README.md)

An open-source guide to University of Ottawa Library services for first-year students. Find research help, study spaces and equipment, follow official service links, and save a personal plan.

**P0: make essential information easy to find, and keep every advertised function working.** Started at the 2026 Library AI Buildathon; now maintained as an independent project under the [MIT license](LICENSE).

[Try the web app](https://first-chapter-nine.vercel.app) · [Report an issue](https://github.com/Tooonnnnyyy/first-chapter/issues) · [Wiki](https://github.com/Tooonnnnyyy/first-chapter/wiki)

## What works today

- Native iOS: onboarding, service search, equipment links, optional assistant and a local saved plan.
- Static web app: search, discovery, equipment links and a browser-local plan. On Vercel, an optional server-side DeepSeek proxy supports Ask.
- Experimental Node/SQLite API: catalog, anonymous sessions, plans, explainable feed ranking and initial quest/XP endpoints. **The current apps are not connected to this API.**

OAuth accounts, the new Reels interface and community features are planned. French catalog data exists, but the app's French language selection is not wired yet. Documentation translations do not imply translated app interfaces. “Import Your Files” is a placeholder. Click-saving figures are estimates, not measured user-study results.

## Use and run

### iOS

Requires macOS, Xcode 26+ and an iOS 26+ simulator. Open `FirstChapter.xcodeproj`, select the FirstChapter scheme and an available iPhone simulator, then press Run. No API key is required. Local search is the final assistant fallback and is labelled accordingly.

For command-line builds:

```sh
xcodebuild -project FirstChapter.xcodeproj -scheme FirstChapter \
  -destination 'generic/platform=iOS Simulator' CODE_SIGNING_ALLOWED=NO build
```

With an iPhone simulator already booted, `./scripts/run.sh` builds, installs and launches the app. It no longer asks for or stores an API key. The legacy native direct-key path is for private development only; never distribute an app containing a provider key. Live DeepSeek and full native accessibility/end-to-end checks are still outstanding.

### Web and landing page

Requires Python 3; Node 24 is required for checks and the API.

```sh
npm run serve:web
```

Open <http://127.0.0.1:8080>. This serves static files only: `/api/ask` is unavailable locally, so Ask uses the labelled local fallback. To run the optional proxy, deploy `web/` to Vercel and set `DEEPSEEK_API_KEY` in the hosting environment. Never place it in browser code. This repository does not automatically deploy to Vercel through GitHub Actions.

For the self-contained product page, open `landing/index.html`. Its product screenshots are embedded in the HTML; no image folder is needed. They show the November 2026 prototype and may differ from later builds.

### Experimental API

Use Node 24 (`.node-version`). No npm install is needed for the root commands or server.

```sh
npm run start:server
# In another terminal:
curl http://127.0.0.1:8787/health
```

SQLite data is created in `server/data/` (gitignored). Configure `HOST`, `PORT` and `FC_DATA_DIR` if needed. The default host is loopback. This API lacks production account lifecycle, rate limiting and complete input validation; keep it local until these are addressed. See [security](SECURITY.md) and [architecture](docs/architecture/overview.md).

### Checks

```sh
npm run check
npm test
```

These check documentation links, source hygiene, JavaScript syntax, the experimental API and archived catalog/state behavior. They do not prove browser or native UI behavior. The archived React app is retained in `archive/geeguide-web/`; if needed, run `npm ci`, `npm test`, `npm run build` and `npm start` there (preview on port 4173).

## Repository map

| Folder or file | Purpose |
| --- | --- |
| `FirstChapter/` | SwiftUI screens, public catalog and local SwiftData storage |
| `FirstChapter.xcodeproj/` | Native app build configuration |
| `web/` | Maintained interactive web app and optional Vercel Ask endpoint |
| `server/` | Experimental Node 24/SQLite API, tests and container definition |
| `landing/` | Standalone product page with embedded screenshots |
| `docs/en/`, `docs/fr/`, `docs/zh-CN/` | Language-specific documentation |
| `docs/architecture/` | Current architecture and decision records |
| `docs/reference/` | Library sources and UI design reference |
| `docs/planning/` | Roadmap and work ownership |
| `docs/reviews/`, `docs/history/` | Dated reviews and historical records |
| `scripts/` | Build, verification and repository maintenance tools |
| `.github/` | CI, release/package automation and community templates |
| `archive/geeguide-web/` | Earlier React prototype source; not the current deployment |

[Contribute](CONTRIBUTING.md) · [How GitHub automation works](docs/en/maintenance.md) · [Architecture](docs/architecture/overview.md) · [Roadmap](docs/planning/v2-roadmap.md) · [Library sources](docs/reference/library-services.md)

Library bookings, eligibility, hours and equipment availability are controlled by official systems; always check the linked source. Not affiliated with or endorsed by the University of Ottawa. MIT covers project code; university names, trademarks and linked content retain their owners' rights.
