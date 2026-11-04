# Judging criteria and how we meet them

Transcribed from Tony's photos of the printed table and the event slide. Weights total 100%.

| Criterion | Focus area | Weight | What we do | Where to show it |
| --- | --- | --- | --- | --- |
| UI/UX Design | Visual clarity, navigation, user flow | 25% | Search-first home, one-tap tiles, 4 tabs, one primary action per screen, shared design tokens, 44pt targets | Find tab |
| Innovation | Originality and creative approach | 25% | Swipe deck that surfaces services students don't know exist; on-device AI guide; click counter against the real website; passport stamps | Onboarding, Ask, Me |
| Technical feasibility & data privacy | Database structure & data security | 25% | One small SwiftData table, read-only public catalog, no accounts, encrypted at rest, one-tap erase, schema shown in the app | Me tab, `DATA-MODEL.md` |
| Prototype quality | Interactivity and feature coverage | 15% | Real running app: search, swipe, chat, plan, stamps, gear, links to the real systems | Whole demo |
| Pitch and demo | Concise pitch & response to questions | 10% | 5-minute script and prepared answers | `PITCH.md` |

## The problem, as given

> Each academic year, many first-year students are unaware of the services offered by the Library (e.g., research assistance, technology loans, booking of podcast studios and study rooms, workshops on citation styles).

> Challenge: Design an app prototype (code or mock-up) that will guide new students through services offered by the Library (uottawa.ca/library).

## Originality: what makes this different

A directory repeats the website. This app does three things a website can't:

1. **It starts from the student's situation.** "I need a camera", not "Services → Computers and technology → Multimedia equipment".
2. **It shows services nobody searches for.** A student can't search for a podcast studio they don't know exists, so the swipe deck brings it to them.
3. **It proves the saving.** Each card shows website clicks against app taps, and the Me tab totals the clicks saved.
