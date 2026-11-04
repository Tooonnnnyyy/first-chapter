import Foundation
#if canImport(FoundationModels)
import FoundationModels
#endif

struct GuideReply {
    let text: String
    let service: Service?
    let source: Guide.Source
}

/// A small assistant: DeepSeek when a key is set and the student allows it,
/// then Apple's on-device model, then local search. Each reply names its source.
enum Guide {
    enum Source: String {
        case deepseek = "DeepSeek"
        case apple = "on-device AI"
        case search = "Library search"
    }

    /// Never in the repo. Comes from the environment or a gitignored Secrets.plist.
    static var apiKey: String? {
        if let key = ProcessInfo.processInfo.environment["DEEPSEEK_API_KEY"], !key.isEmpty { return key }
        guard let url = Bundle.main.url(forResource: "Secrets", withExtension: "plist"),
              let dict = NSDictionary(contentsOf: url),
              let key = dict["DEEPSEEK_API_KEY"] as? String, !key.isEmpty else { return nil }
        return key
    }

    static var onlineConfigured: Bool { apiKey != nil }

    /// Data minimization: strip identifiers before a question can leave the phone.
    static func redact(_ text: String) -> String {
        var out = text
        for pattern in ["[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}", "\\+?\\d[\\d\\s().-]{5,}\\d"] {
            out = out.replacingOccurrences(of: pattern, with: "[removed]", options: .regularExpression)
        }
        return out
    }

    private static var facts: String {
        Catalog.services.map { s in
            let extra = s.facts.map { "\($0.label): \($0.value)" }.joined(separator: "; ")
            return "- id=\(s.id) | \(s.title) | \(s.answer) \(extra)"
        }.joined(separator: "\n")
    }

    private static let rules = "You help first-year University of Ottawa students find Library services. Reply in at most 2 short, plain sentences using ONLY the facts given. Never invent hours, prices, models or availability. If the facts don't cover it, say a librarian can help (text 613-801-5603)."

    static func answer(_ question: String, online: Bool) async -> GuideReply {
        let local = Catalog.search(question).first
        if online, let key = apiKey, let reply = await askDeepSeek(question, key: key, fallback: local) {
            return reply
        }
        if let reply = await askApple(question, top: local) { return reply }
        if let local {
            return GuideReply(text: local.answer, service: local, source: .search)
        }
        return GuideReply(text: "I couldn't match that to a Library service. A librarian can help: text 613-801-5603.",
                          service: Catalog.service("librarian"), source: .search)
    }

    private static func askDeepSeek(_ question: String, key: String, fallback: Service?) async -> GuideReply? {
        guard let url = URL(string: "https://api.deepseek.com/chat/completions") else { return nil }
        var request = URLRequest(url: url, timeoutInterval: 15)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(key)", forHTTPHeaderField: "Authorization")
        let body: [String: Any] = [
            "model": "deepseek-chat",
            "temperature": 0.2,
            "max_tokens": 160,
            "messages": [
                ["role": "system", "content": "\(rules)\nEnd with a new line: SERVICE=<id of the best match>.\n\nFacts:\n\(facts)"],
                ["role": "user", "content": redact(question)],
            ],
        ]
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
            let (data, response) = try await URLSession.shared.data(for: request)
            guard (response as? HTTPURLResponse)?.statusCode == 200,
                  let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let choices = json["choices"] as? [[String: Any]],
                  let message = choices.first?["message"] as? [String: Any],
                  let content = message["content"] as? String else {
                NSLog("FirstChapterAI DeepSeek bad response: %d", (response as? HTTPURLResponse)?.statusCode ?? -1)
                return nil
            }
            var text = content
            var service = fallback
            if let range = content.range(of: "SERVICE=") {
                let id = content[range.upperBound...].trimmingCharacters(in: .whitespacesAndNewlines)
                service = Catalog.service(id) ?? fallback
                text = String(content[..<range.lowerBound])
            }
            return GuideReply(text: text.trimmingCharacters(in: .whitespacesAndNewlines), service: service, source: .deepseek)
        } catch {
            NSLog("FirstChapterAI DeepSeek error: %@", String(describing: error))
            return nil
        }
    }

    private static func askApple(_ question: String, top: Service?) async -> GuideReply? {
        #if canImport(FoundationModels)
        guard let top, case .available = SystemLanguageModel.default.availability else { return nil }
        do {
            let session = LanguageModelSession(instructions: rules)
            let detail = top.facts.map { "\($0.label): \($0.value)" }.joined(separator: "; ")
            let reply = try await session.respond(to: "Facts: \(top.title). \(top.answer) \(detail)\nStudent asks: \(question)")
            return GuideReply(text: reply.content, service: top, source: .apple)
        } catch {
            NSLog("FirstChapterAI Apple model error: %@", String(describing: error))
            return nil
        }
        #else
        return nil
        #endif
    }
}
