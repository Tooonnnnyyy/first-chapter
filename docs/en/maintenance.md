# Contributing and maintaining First Chapter

[Usage README](../../README.md) · [Français](../fr/maintenance.md) · [简体中文](../zh-CN/maintenance.md)

## Contribution flow

1. Choose or open an issue describing a student need and observable acceptance criteria. P0 means essential discovery is broken or a release-blocking privacy/data issue; P1 means the next useful improvement; P2 means later work. Existing v2 priorities also remain in the roadmap.
2. Branch from current `main` (or fork for external contributors). Check active workstreams in the task ledger. Do not push directly to `main`.
3. Make a focused change, update official-source evidence and affected translations, and run the README checks. Swift changes also need the simulator build; UI changes need real interaction/accessibility evidence.
4. Open a PR linked to the issue. Explain what changes for the student and what you verified. Resolve review conversations and wait for required checks before merging. Owners can review their own maintenance PRs, but do not invent an independent approval.

English, French and Chinese contributions are welcome. Keep code identifiers stable; translate user-facing text and docs. Mark untranslated new material instead of suggesting all UI is localized. Use official Library sources, and record the check date for time-sensitive facts. See [community conduct](../../CODE_OF_CONDUCT.md).

## Automation: what each workflow does

| Workflow | When | Result |
| --- | --- | --- |
| CI | PR, push to main, manual | Repository/link checks, API/archive tests, unsigned iOS simulator build, container health smoke |
| Security | PR, main, weekly | Dependency review for PRs and JavaScript/TypeScript CodeQL analysis |
| Source release | A pushed `v*` tag | Validates version/main ancestry, runs checks, creates a **draft** release with source archive and SHA-256 checksum |
| Publish experimental API container | Manual, main only | Runs checks and uploads a commit-tagged image to GHCR; no server is deployed |
| Wiki navigation | Docs changes on main or manual | Generates three-language Wiki navigation as an artifact; syncs only if `WIKI_TOKEN` exists |
| Dependabot | Weekly actions; monthly archived npm dependencies | Opens update PRs; nothing is automatically merged |

Find runs under **Actions**, open a run, then select a job for logs. Green means those specific checks passed. It does not certify full UI behavior, factual freshness, security or a live deployment. Red means inspect the first failing step, fix it on the same branch and push again. Workflow tokens have narrow permissions; no cloud billing credentials are configured.

## Tags and releases

A Git tag names a specific commit. A GitHub Release adds notes and downloadable files to that tag. For an approved, tested commit on main, create an annotated version tag such as `v0.1.0-alpha.1` and push that exact tag. The release workflow creates a draft, which a maintainer reviews and publishes. Use prereleases until native/UI/provider checks and the published feature set are ready; update CHANGELOG first. A source release is not a signed iOS app, TestFlight upload or deployment. Never overwrite a released tag; create a new patch version. Revert code through a PR for rollback.

## Packages and containers

The root package is private and only defines developer commands. The experimental server has no npm dependencies. Neither is published to npm. The archived React project has its own lockfile; use `npm ci` there.

The server Dockerfile runs as a non-root user. CI builds it and checks `/health`. To build locally when Docker is installed:

```sh
docker build -t first-chapter-api:local server
docker run --rm -p 127.0.0.1:8787:8787 -v first-chapter-data:/data first-chapter-api:local
```

The named volume persists data after the container exits. Deleting it deletes the database. The manual publishing workflow uses `ghcr.io/tooonnnnyyy/first-chapter/api:sha-<full-commit>`; no mutable `latest` tag is created. GitHub's package visibility is separate from repository visibility: check package access before expecting anonymous pulls. Publishing is optional and does not make this experimental API production ready. No package is needed to run the native/static app.

## Wiki

Versioned Markdown in this repository is the source of truth; Wiki is navigation to it. GitHub requires creating its first Wiki page through the UI before the separate `.wiki.git` repository exists. The workflow always creates a downloadable artifact. Automatic sync needs a dedicated, least-privilege token that can write this repository's Wiki, stored as the Actions secret `WIKI_TOKEN`. Do not paste a token into a file or issue. The normal `GITHUB_TOKEN` is not assumed to have Wiki write access. Without that secret, generated pages can be copied into the initialized Wiki manually.

## Privacy and maintenance

Current plans stay in device/browser storage. Ask may send the question to an optional provider; avoid sensitive information. Review [SECURITY](../../SECURITY.md) and the [API limitations](../architecture/overview.md) before hosting any server. Never attach student records, tokens, database files or personal screenshots to issues.

Keep app directories stable while feature branches are active. Read [the roadmap](../planning/v2-roadmap.md), [architecture](../architecture/overview.md) and [task ownership](../planning/task-ledger.md). Architecture/reference/history documents use English as the canonical source; translated maintenance and usage documents summarize them. Additional language coverage is welcome.

## Repository configuration record

The foundation setup enables Discussions, private vulnerability reports, dependency alerts/security updates, secret scanning and push protection. P0 labels are red; area/status/language labels are defined in `.github/labels.json` and can be reapplied with `python3 scripts/maintenance/sync_labels.py` by an authenticated maintainer. Topics describe the actual stack. Branch protection is configured after CI check names are available, with PRs and resolved conversations required; a solo maintainer is not required to obtain an impossible self-approval.

Wiki initialization is currently blocked by the browser permission gate. Generated navigation and the workflow are ready; no Wiki publication or automatic sync is claimed. `WIKI_TOKEN` is not configured. No container package or version release has been published by this setup.
