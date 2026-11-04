# Database structure and data security

## Principle

Keep public data and personal data apart, and collect as little personal data as possible.

## Structure

```
Catalog (bundled, read-only, public)        PlanItem (SwiftData, on the phone only)
----------------------------------          ---------------------------------------
Service                                     serviceID  String  unique  -> Service.id
  id, title, answer, facts[], steps[]       source     String  swipe|find|ask|borrow
  cta, url, webClicks, keywords[]           addedAt    Date
Gear                                        doneAt     Date?
  name, icon
```

- **Catalog** is public Library information compiled into the app, with no user data. Planned update path: a signed JSON file served by the Library.
- **PlanItem** is the only stored personal data: which public services a student saved and finished.
- `serviceID` is unique, so a service can't be saved twice.
- **Chats are not stored.** They live in memory and disappear when the app closes.

## Security

| Control | How | Code |
| --- | --- | --- |
| No account, name, student number or email | Nothing to breach | No such fields exist |
| Encrypted at rest | iOS Data Protection `.complete` on the store folder | `Store.swift` |
| Plan stays on the device | CloudKit off, excluded from backups | `Store.swift` |
| No third-party SDKs or analytics | No dependencies | `project.pbxproj` |
| Student control | Erase Everything, swipe to remove | `PlanView.swift` |
| Official systems only | Bookings and sign-in happen on the Library's own pages | `Catalog.swift` |
| Key not in source | Gitignored `Secrets.plist` | `.gitignore`, `Guide.swift` |
| Data minimization for AI | Emails and phone or ID numbers removed before a question is sent | `Guide.redact` |

## What leaves the phone

When Online AI is on and a key is set, Ask sends the typed question (after redaction) and the public catalog to DeepSeek. Nothing else. The student can switch this off with the cloud button, and the app then answers on the phone.

## Web version

The web version keeps the same small list in the browser's local storage. Its DeepSeek key stays on the server (`web/api/ask.js`), which stores nothing. The page removes emails and phone or ID numbers before sending a question. Vercel may keep standard request logs.

## Limits to say out loud

- **DeepSeek is a third party outside Canada.** The app says so in Ask and in Your Data, and strips identifiers first, but a student could still type something personal. For a real launch, use a provider the university approves, through a proxy that doesn't log.
- A key inside an app can be extracted. Acceptable for a local demo only.
- `.complete` protection takes effect on a real locked device, not in the simulator.
- Redaction is pattern-based and won't catch everything, such as a name.
- Not reviewed by uOttawa privacy or security staff. A real launch would need a privacy review under Ontario's FIPPA, which covers universities.
