import Foundation

/// Game rules, worked out from the plan every time. Nothing here is stored or sent:
/// erase the plan and the XP, chapter and stamps reset with it.
/// Pure Foundation, so it can be compiled and tested on its own.
enum Game {
    /// Saving a service.
    static let saveXP = 10
    /// Marking a saved service done.
    static let doneXP = 40
    /// A finished quest: saved and done.
    static let questXP = saveXP + doneXP

    struct Chapter: Equatable {
        let number: Int
        let name: String
        let minXP: Int
        /// "Chapter 2 · Explorer"
        var title: String { "Chapter \(number) · \(name)" }
    }

    static let chapters: [Chapter] = [
        Chapter(number: 1, name: "New Reader", minXP: 0),
        Chapter(number: 2, name: "Explorer", minXP: 100),
        Chapter(number: 3, name: "Regular", minXP: 200),
        Chapter(number: 4, name: "Library Pro", minXP: 350),
        Chapter(number: 5, name: "Library Legend", minXP: 500),
    ]

    /// One plan entry as the rules see it.
    struct Entry: Equatable {
        let serviceID: String
        let done: Bool
    }

    /// XP for a plan. Only services in `catalog` count, so stale IDs earn nothing,
    /// and each service counts once.
    static func xp(_ entries: [Entry], catalog: Set<String>) -> Int {
        var seen = Set<String>()
        var total = 0
        for entry in entries where catalog.contains(entry.serviceID) && seen.insert(entry.serviceID).inserted {
            total += entry.done ? questXP : saveXP
        }
        return total
    }

    static func chapter(for xp: Int) -> Chapter {
        chapters.last { xp >= $0.minXP } ?? chapters[0]
    }

    static func nextChapter(after chapter: Chapter) -> Chapter? {
        chapters.first { $0.number == chapter.number + 1 }
    }

    /// The chapter reached by going from `old` to `new` XP, or nil if no new chapter opened.
    static func unlocked(from old: Int, to new: Int) -> Chapter? {
        let before = chapter(for: old)
        let after = chapter(for: new)
        return after.number > before.number ? after : nil
    }

    struct Progress: Equatable {
        let xp: Int
        let chapter: Chapter
        let next: Chapter?
        /// XP still needed for the next chapter; 0 at the last chapter.
        var toNext: Int { next.map { max($0.minXP - xp, 0) } ?? 0 }
        /// 0...1 through the current chapter; 1 at the last chapter.
        var fraction: Double {
            guard let next else { return 1 }
            let span = Double(next.minXP - chapter.minXP)
            return min(max(Double(xp - chapter.minXP) / span, 0), 1)
        }
    }

    static func progress(xp: Int) -> Progress {
        let current = chapter(for: xp)
        return Progress(xp: xp, chapter: current, next: nextChapter(after: current))
    }

    /// Stamps: one per catalog service, filled when that service is done.
    static func stamps(_ entries: [Entry], catalog: [String]) -> (filled: Set<String>, total: Int) {
        let known = Set(catalog)
        let filled = Set(entries.filter { $0.done && known.contains($0.serviceID) }.map(\.serviceID))
        return (filled, catalog.count)
    }
}
