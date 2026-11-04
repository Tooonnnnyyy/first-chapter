# First Chapter

A native iOS guide that helps first-year uOttawa students find Library services in fewer steps than the website, including borrowing cameras and other gear. Built at the Library AI Buildathon, 2026-11-04.

**The problem (from the organizers):** many first-year students don't know what the Library offers: research help, technology loans, podcast studios and study rooms, citation workshops.

**The challenge:** an app prototype, code or mock-up, that guides new students through the Library's services.

**Live web version:** https://first-chapter-nine.vercel.app

## Run it

Needs Xcode 26 or newer and an iOS 26+ simulator.

```bash
open FirstChapter.xcodeproj
```

Pick an iPhone simulator and press Run. No accounts or setup.

To turn on the DeepSeek assistant, boot a simulator and run this. It asks for your key once and keeps it in a gitignored file:

```bash
./scripts/run.sh
```

## Start here

| File | What |
| --- | --- |
| [AGENTS.md](AGENTS.md) | Rules for every AI agent and person joining |
| [MEMORY.md](MEMORY.md) | Long-term project memory: facts, decisions, state |
| [docs/TASKS.md](docs/TASKS.md) | Open work and who owns which files |
| [docs/VISION.md](docs/VISION.md) | Vision and plan beyond the hackathon |
| [docs/CRITERIA.md](docs/CRITERIA.md) | How each judging criterion is scored and met |
| [docs/DATA-MODEL.md](docs/DATA-MODEL.md) | Database structure and data security |
| [docs/LIBRARY-FACTS.md](docs/LIBRARY-FACTS.md) | Verified Library facts with source links |
| [docs/PITCH.md](docs/PITCH.md) | 5-minute pitch and Q&A |
| [docs/wireframes/](docs/wireframes/) | Wireframe of each screen, plus an overview with the user flow |

Not affiliated with or endorsed by the University of Ottawa.
