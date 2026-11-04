import Foundation
#if canImport(FoundationModels)
import FoundationModels
#endif

struct GuideReply {
    let text: String
    let service: Service?
    let usedModel: Bool
}

/// Runs entirely on the phone. Uses Apple's on-device model when available,
/// otherwise local search. The UI states which mode is running.
enum Guide {
    static var modelAvailable: Bool {
        #if canImport(FoundationModels)
        if case .available = SystemLanguageModel.default.availability { return true }
        #endif
        return false
    }

    static func answer(_ question: String) async -> GuideReply {
        guard let top = Catalog.search(question).first else {
            return GuideReply(text: "I couldn't match that to a Library service. A librarian can help: text 613-801-5603 or email bibliolibrary@uOttawa.ca.",
                              service: Catalog.service("librarian"), usedModel: false)
        }
        #if canImport(FoundationModels)
        if modelAvailable {
            do {
                let session = LanguageModelSession(instructions: "You help first-year uOttawa students find Library services. Reply in at most 2 short sentences using ONLY the facts given. Never invent hours, prices or equipment.")
                let facts = "\(top.title). \(top.oneLiner) Steps: \(top.steps.joined(separator: "; ")). Where: \(top.whereAt)."
                let reply = try await session.respond(to: "Facts: \(facts)\nStudent asks: \(question)")
                return GuideReply(text: reply.content, service: top, usedModel: true)
            } catch {
                NSLog("FirstChapterAI error: %@", String(describing: error))
            }
        }
        #endif
        return GuideReply(text: "\(top.oneLiner) First step: \(top.steps.first ?? top.cta).", service: top, usedModel: false)
    }
}
