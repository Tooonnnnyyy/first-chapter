# 5-minute pitch

Target: 3 minutes of demo-led pitch, 2 minutes of questions.

## Script

**0:00 Problem (30s).** "Most first-years don't know the Library lends cameras or supports podcasting. To find a camera today, it's 5 clicks across 2 websites. And you can't search for something you don't know exists."

**0:30 Answer (15s).** "First Chapter puts the answer on the first screen, and shows you what you didn't know to look for."

**0:45 Demo (1m45s).**
1. Discover: "Under a minute on day one. Swipe right, it's in your plan."
2. Find: type "camera". "The answer's on the row: 7 days, Morisset desk."
3. Borrow: "Every category, every rule, one screen. One tap opens the Library's real list."
4. Ask: "How much does printing cost?" Answer plus a link to the service.
5. Your Data: "This is everything we store. One table, no names. One button erases your plan."

**2:30 Why it wins (30s).** "No login and no student number. It works with the Library's systems instead of replacing them, so it could ship without new infrastructure."

## Database criterion (25%)

"We designed the database around one rule: keep public data and personal data apart.

Public Library facts sit in a read-only catalog inside the app. The only personal data is one small table on the phone, with four fields: which service, where it was added, when it was added, and when it was finished. The service field is unique, so nothing saves twice.

For security, we start by not collecting anything sensitive. There's no login, no name, no student number and no server. We set iOS's strongest file protection, we leave the file out of backups, and students can erase their plan with one button.

And it's feasible today, because there's no new infrastructure to run. For bookings and loans, we link to the Library's existing systems."

If demoing the live site, say "no database on a server" and "stored only in this browser" instead of the phone and iOS lines.

## Likely questions

| Question | Answer |
| --- | --- |
| Is the data real? | Yes. Facts come from uottawa.ca/library, sources are in the repo, and each service links to its official page. |
| Where's the database? | One local SwiftData table of saved service IDs and dates, plus a read-only public catalog. |
| How is it secured? | No identifiers to steal. iOS encrypts the file when the phone is locked. It's left out of backups. One-tap erase. |
| Doesn't DeepSeek break your privacy claim? | Only typed questions go, with emails and numbers stripped, and students can turn it off. For a real launch we'd use a university-approved provider through a proxy. |
| What about AI mistakes? | It may only use Library facts, and always links the official page. It sends anything else to a librarian. |
| Does booking work in the app? | It opens the Library's real page, so sign-in stays there. With an API it could go deeper. |
| Why not improve the website? | A site waits for you to know what to look for. The swipe deck reaches you first. |
| French? | Next on the plan. uOttawa is bilingual, so it's required before launch. |
| How do you know it saves steps? | We counted from the site's structure. Next step is a timed test with real first-years. |
