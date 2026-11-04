# Database structure and data security

## Principle

Keep public data and personal data apart, and collect as little personal data as possible.

## Structure

```
Catalog (bundled, read-only, public)        PlanItem (SwiftData, on the phone only)
----------------------------------          ---------------------------------------
Service                                     serviceID  String  unique  -> Service.id
  id, title, category, summary, steps       source     String  swipe|find|ask|borrow
  location, url, webClicks, keywords        addedAt    Date
Gear                                        doneAt     Date?
  id, name, group, loan, url
```

- **Catalog** is public Library information compiled into the app. It holds no user data. Update path: a signed JSON file served by the Library.
- **PlanItem** is the only personal data: which public services a student saved and tried.
- `serviceID` is unique, so a service can't be saved twice.
- **Chat is not stored.** Questions live in memory and disappear when the app closes.

## Security

| Control | How | Code |
| --- | --- | --- |
| No account, name, student number or email | Nothing to breach | No such fields exist |
| Encrypted at rest | iOS Data Protection `.complete` on the store folder | `Store.swift` |
| Stays on the device | CloudKit off, excluded from backups | `Store.swift` |
| AI stays on the device | Apple Foundation Models; falls back to local search | `Guide.swift` |
| No third-party SDKs or analytics | No dependencies at all | `project.pbxproj` |
| Student control | Erase everything, one button | Me tab |
| Official systems only | Booking and loans open the Library's real pages, sign-in happens there | `Catalog.swift` |

## Limits to say out loud

- `.complete` protection takes effect on a real locked device, not in the simulator.
- Not reviewed by uOttawa privacy or security staff. A real launch would need a privacy review under Ontario's FIPPA, which covers universities.
- If the Library later wants usage numbers, they should be opt-in and aggregate only.
