# AGENTS.md: start here

For every AI agent (Claude Code, Codex, Cursor, Gemini, Copilot) and every human on the team. **The repo carries all context.** Nothing important may live only in a chat.

## Before you start

1. Read `MEMORY.md` (state, decisions, deadlines).
2. Read `docs/TASKS.md` and claim one task by putting your name on it. Commit and push that claim first.
3. `git pull --rebase origin main`.

## The P0

**All functions work, and first-years find information in fewer steps than the website,** including how to borrow gear like a camera. If a change does not reduce steps or raise a judging score (`docs/CRITERIA.md`), skip it.

## Rules

- **Time box.** This is a live hackathon. Small commits, pushed often. A working demo beats a better unfinished one. Never leave `main` not compiling.
- **Stay in your files.** `docs/TASKS.md` lists file owners. Do not edit a file another open task owns.
- **Facts must be real.** Library facts go in `docs/LIBRARY-FACTS.md` with a source URL. Do not invent hours, loan periods, prices or equipment. If it is unverified, link to the official page instead.
- **Privacy is a feature.** Do not add accounts, analytics, third-party SDKs, or anything new that sends student data off the phone without asking the owner. See `docs/DATA-MODEL.md`. Never commit an API key.
- **Design system: Apple Human Interface Guidelines.** Use native components (`List`, `.searchable`, `LabeledContent`, `Toggle`, standard button styles), system colors, and text styles for Dynamic Type. No custom cards, monospace labels, or hard-coded font sizes: Tony rejected that look.
- **Honest labels.** Never present a fallback as AI, or a mock as real. Each Ask reply names its source.
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
| `FirstChapter/Theme.swift` | App tint and small shared views |
| `FirstChapter/Catalog.swift` | Public Library data: services and gear (read-only) |
| `FirstChapter/Store.swift` | SwiftData: the only personal data |
| `FirstChapter/Guide.swift` | Assistant: DeepSeek, then on-device AI, then local search |
| `web/` | Web version on Vercel; keep its data in step with `Catalog.swift` |
| `scripts/run.sh` | Build and launch; asks once for the DeepSeek key |
| `FirstChapter/*View.swift` | Screens |
