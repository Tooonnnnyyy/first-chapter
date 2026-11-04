import Foundation
import SwiftData

/// The ONLY personal data the app ever stores: which public services a student
/// saved and which they tried. No name, no student number, no email, no account.
@Model
final class PlanItem {
    @Attribute(.unique) var serviceID: String
    var source: String   // "swipe" | "find" | "ask" | "borrow"
    var addedAt: Date
    var doneAt: Date?

    init(serviceID: String, source: String) {
        self.serviceID = serviceID
        self.source = source
        self.addedAt = .now
    }
}

enum Store {
    /// Local-only SwiftData store: no CloudKit, encrypted by iOS while the
    /// phone is locked, and excluded from device backups.
    static func makeContainer() -> ModelContainer {
        let schema = Schema([PlanItem.self])
        let fm = FileManager.default
        var dir = fm.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("LocalOnly", isDirectory: true)
        try? fm.createDirectory(at: dir, withIntermediateDirectories: true)
        try? fm.setAttributes([.protectionKey: FileProtectionType.complete], ofItemAtPath: dir.path)
        var values = URLResourceValues()
        values.isExcludedFromBackup = true
        try? dir.setResourceValues(values)

        let config = ModelConfiguration(
            schema: schema,
            url: dir.appendingPathComponent("plan.store"),
            cloudKitDatabase: .none
        )
        do {
            return try ModelContainer(for: schema, configurations: [config])
        } catch {
            // Never lose the demo to a store error: fall back to memory only.
            let memory = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
            return try! ModelContainer(for: schema, configurations: [memory])
        }
    }
}

extension ModelContext {
    func addToPlan(_ id: String, source: String) {
        let found = (try? fetch(FetchDescriptor<PlanItem>(predicate: #Predicate<PlanItem> { $0.serviceID == id }))) ?? []
        if found.isEmpty {
            insert(PlanItem(serviceID: id, source: source))
            try? save()
        }
    }

    func markDone(_ id: String, source: String = "find") {
        addToPlan(id, source: source)
        let found = (try? fetch(FetchDescriptor<PlanItem>(predicate: #Predicate<PlanItem> { $0.serviceID == id }))) ?? []
        found.first?.doneAt = found.first?.doneAt ?? .now
        try? save()
    }

    func eraseEverything() {
        try? delete(model: PlanItem.self)
        try? save()
    }
}

extension ModelContext {
    func toggleDone(_ id: String) {
        let found = (try? fetch(FetchDescriptor<PlanItem>(predicate: #Predicate<PlanItem> { $0.serviceID == id }))) ?? []
        if let item = found.first {
            item.doneAt = item.doneAt == nil ? .now : nil
            try? save()
        }
    }

    func removeFromPlan(_ id: String) {
        let found = (try? fetch(FetchDescriptor<PlanItem>(predicate: #Predicate<PlanItem> { $0.serviceID == id }))) ?? []
        found.forEach { delete($0) }
        try? save()
    }
}
