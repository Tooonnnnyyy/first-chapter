# 5-minute pitch

Target: 3 minutes of demo-led pitch, 2 minutes of questions.

## Script

**0:00 Problem (30s).** "Most first-years don't know the Library lends cameras or has a podcast studio. To find a camera today, it's 5 clicks across 2 websites. And you can't search for something you don't know exists."

**0:30 Answer (15s).** "First Chapter gets you to any Library service in one tap, and shows you what you didn't know to look for."

**0:45 Demo (1m45s).**
1. Swipe deck: "30 seconds on day one. Right for need it. That's your plan."
2. Find: type "camera". "One tap. Loan rule, where to go, what to bring. Website: 5 clicks. Here: 1."
3. Ask: "My paper's due Friday and I don't know APA." "AI on the phone answers from Library facts and links to the real page."
4. Me: stamps, clicks saved. "And here's every byte we store. One table. Tap erase and it's gone."

**2:30 Why it wins (30s).** "No login, no student number, no server. The AI runs on the phone. And the Library keeps its own systems, because we link to them."

## Likely questions

| Question | Answer |
| --- | --- |
| Is the data real? | Library facts come from uottawa.ca/library, with sources in the repo. Each card links to the official page. |
| Where's the database? | One local SwiftData table of saved service IDs and dates, plus a read-only public catalog. No server. |
| How is it secured? | No personal identifiers to steal. iOS encrypts the file when the phone is locked. It's excluded from backups. One-tap erase. |
| What about AI mistakes? | It answers only from the catalog and always links the official page. Without Apple's model it uses local search and says so. |
| Does booking work in the app? | It opens the Library's real page. Sign-in happens there, so we never see credentials. With an API, it could go deeper. |
| Why not just improve the website? | A site waits for you to know what to look for. The swipe deck reaches you first. |
| French? | Next on the plan. uOttawa is bilingual, so it's required before launch. |
| How does it stay up to date? | Today it's bundled. Next, a Library-owned file the app downloads, with no student data sent. |
| How would you know it works? | Compare clicks and time with the website, plus an opt-in survey on services used by Reading Week. |
