# Agent and contributor instructions

## Start here

1. Read `README.md`, `MEMORY.md` and `docs/planning/task-ledger.md`.
2. Check the tracking issue, remote branches and open PRs before editing shared files.
3. Work in an isolated branch/worktree based on current `main`. Never edit or push `main` directly. Record ownership on your branch; use a PR for integration.

## P0

Help first-year students find accurate Library information with fewer steps. Every advertised function must work; show incomplete features as planned. Click-saving figures remain estimates until measured.

## Rules

- Library facts need official sources in `docs/reference/library-services.md`; do not invent hours, prices, stock or confirmed bookings.
- Preserve other workstreams. Keep app paths stable unless a coordinated migration updates every consumer.
- The owner approved v2 accounts, gamification and community as a roadmap, not as shipped features. Current clients still use local storage; the experimental API is separate.
- Follow the design system in `docs/reference/design-system.md` (owner's choice, 2026-11-08; keep native and web tokens and game rules in step); preserve native accessibility, Dynamic Type and reduced-motion behavior.
- Never present local fallback results as AI. AI must remain optional for core discovery.
- No credentials, student records, databases, derived builds or personal media in commits. Do not distribute a native app with a provider API key.
- README is the usage guide, translated in `docs/fr/README.md` and `docs/zh-CN/README.md`. Do not reintroduce pitch decks, demo scripts or duplicate quickstarts.
- Keep current behavior separate from proposals and historical evidence. Repository settings/release changes need owner scope; the open-source foundation is authorized.

## Validate and hand off

Run `npm run check` and `npm test`. For Swift changes, build for an iOS simulator as documented in README. State separately what was source-checked, tested, built and exercised in a real UI. Update the task ledger and project memory when state changes. Open a PR linked to the issue and wait for required checks; no history rewrites or force-pushes to shared branches.
