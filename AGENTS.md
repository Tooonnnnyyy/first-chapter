# AGENTS.md: start here

For every AI agent (Claude Code, Codex, Cursor, Gemini, Copilot) and every human on the team. **The repo carries all context.** Nothing important may live only in a chat.

## Before you start

1. Read `MEMORY.md` (state, decisions, deadlines).
2. Read `docs/TASKS.md` and claim one task by putting your name on it. Commit and push that claim first.
3. `git pull --rebase origin main`.

## The P0

**Fewer steps than the website.** A first-year finds any Library service in one tap, and can find and borrow gear like a camera. If a change does not reduce steps or raise a judging score (`docs/CRITERIA.md`), skip it.

## Rules

- **Time box.** This is a live hackathon. Small commits, pushed often. A working demo beats a better unfinished one. Never leave `main` not compiling.
- **Stay in your files.** `docs/TASKS.md` lists file owners. Do not edit a file another open task owns.
- **Facts must be real.** Library facts go in `docs/LIBRARY-FACTS.md` with a source URL. Do not invent hours, loan periods, prices or equipment. If it is unverified, link to the official page instead.
- **Privacy is a feature.** Do not add accounts, analytics, third-party SDKs, or anything that sends student data off the phone without asking the owner. See `docs/DATA-MODEL.md`.
- **Design.** Use `FirstChapter/Theme.swift` tokens (ported from ideamap's design system): zinc surfaces, one amber accent, borders not shadows, 4px spacing, 44pt touch targets. No new colors.
- **Honest labels.** Never present a fallback as AI, or a mock as real. The Ask screen says which mode is running.
- **No secrets** in the repo. Never edit this repo's visibility or settings without the owner.

## After every task

Update, in the same commit: `docs/TASKS.md` (status), `MEMORY.md` (only if a fact or decision changed, plus a line in its log).

## Build check

```bash
xcodebuild -project FirstChapter.xcodeproj -scheme FirstChapter -destination 'platform=iOS Simulator,name=iPhone 17 Pro' build -quiet
```

New `.swift` files inside `FirstChapter/` are picked up automatically (synchronized folder). No project file edits needed.

## Layout

| Path | What |
| --- | --- |
| `FirstChapter/Theme.swift` | Design tokens and shared components |
| `FirstChapter/Catalog.swift` | Public Library data: services and gear (read-only) |
| `FirstChapter/Store.swift` | SwiftData: the only personal data |
| `FirstChapter/Guide.swift` | On-device AI and search |
| `FirstChapter/*View.swift` | Screens |
