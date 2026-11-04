import Foundation

/// Public Library information, read from uottawa.ca/library on 2026-11-04.
/// Sources are in docs/LIBRARY-FACTS.md. Holds no user data.
struct Service: Identifiable, Hashable {
    let id: String
    let icon: String
    let title: String
    let oneLiner: String
    let steps: [String]
    let whereAt: String
    let cta: String
    let url: String
    let webClicks: Int
    let keywords: [String]
}

enum Catalog {
    static let services: [Service] = [
        Service(id: "camera", icon: "camera.fill", title: "Borrow a camera or gear",
                oneLiner: "The Library lends multimedia equipment for school projects. 7-day loan, 2 renewals.",
                steps: ["Check what's available on the equipment page", "Bring your library card to the Morisset main service desk", "Return or renew within 7 days"],
                whereAt: "Morisset Library, main service desk", cta: "See equipment",
                url: "https://www.uottawa.ca/library/services/computers-technology", webClicks: 5,
                keywords: ["camera", "gear", "equipment", "tripod", "mic", "microphone", "video", "film", "photo", "shoot", "record", "loan", "lend", "multimedia", "technology"]),
        Service(id: "room", icon: "person.3.fill", title: "Book a study room",
                oneLiner: "Reserve a room online at Morisset, Law, Learning Crossroads (5th floor) or Health Sciences.",
                steps: ["Choose a library", "Reserve online", "Show up with your group"],
                whereAt: "Morisset, Brian Dickson Law, CRX 5th floor, Health Sciences", cta: "Book a room",
                url: "https://www.uottawa.ca/library/services/reserve-study-space", webClicks: 2,
                keywords: ["room", "study", "group", "quiet", "space", "book", "reserve", "team", "meeting"]),
        Service(id: "podcast", icon: "mic.fill", title: "Record a podcast",
                oneLiner: "The Digital Skills Hub supports podcasting, virtual reality and other technology.",
                steps: ["Open Library services", "Choose Digital Skills Hub", "Pick podcasting"],
                whereAt: "Digital Skills Hub", cta: "Open Digital Skills Hub",
                url: "https://www.uottawa.ca/library/services", webClicks: 3,
                keywords: ["podcast", "studio", "audio", "record", "vr", "virtual", "reality", "sound", "digital"]),
        Service(id: "cite", icon: "quote.opening", title: "Cite your sources",
                oneLiner: "Tutorials and workshops on citation styles, citation software and avoiding plagiarism.",
                steps: ["Open Writing and citing", "Choose Citation styles", "Stuck? Ask a librarian"],
                whereAt: "Online, and hands-on workshops", cta: "Open citation help",
                url: "https://www.uottawa.ca/library/writing-citing", webClicks: 3,
                keywords: ["cite", "citation", "apa", "mla", "chicago", "plagiarism", "reference", "paper", "essay", "bibliography", "writing"]),
        Service(id: "librarian", icon: "person.fill.questionmark", title: "Talk to a librarian",
                oneLiner: "A librarian who knows your subject can help with research. Text 613-801-5603.",
                steps: ["Find your subject", "Contact your librarian", "Or text 613-801-5603"],
                whereAt: "Online, by text, or in person", cta: "Find my librarian",
                url: "https://www.uottawa.ca/library/research-guides-librarians", webClicks: 2,
                keywords: ["librarian", "help", "research", "ask", "question", "subject", "sources", "assignment", "stuck"]),
        Service(id: "print", icon: "printer.fill", title: "Print, copy, scan",
                oneLiner: "From $0.09 a page in black and white, $0.25 in colour. Scanning is free.",
                steps: ["Add funds to your student card", "Print at any library", "Scan to email or USB for free"],
                whereAt: "Every library", cta: "Printing details",
                url: "https://www.uottawa.ca/library/services/print-copy-scan", webClicks: 3,
                keywords: ["print", "printer", "copy", "scan", "photocopy", "price", "cost", "colour", "color"]),
        Service(id: "books", icon: "book.fill", title: "Borrow a book",
                oneLiner: "Undergrads get 120 days, up to 500 items, unlimited renewals. You can place a hold too.",
                steps: ["Search the catalogue", "Place a hold or grab it", "Show your library card"],
                whereAt: "Any library location", cta: "Borrowing rules",
                url: "https://www.uottawa.ca/library/services/borrow", webClicks: 2,
                keywords: ["book", "borrow", "hold", "renew", "textbook", "reserve", "loan", "card", "interlibrary"]),
        Service(id: "workshop", icon: "graduationcap.fill", title: "Join a workshop",
                oneLiner: "Workshops, orientations and tours built for new students.",
                steps: ["See what's on", "Pick a session", "Go"],
                whereAt: "On campus and online", cta: "See workshops",
                url: "https://www.uottawa.ca/library/workshops-orientations-tours", webClicks: 2,
                keywords: ["workshop", "tour", "orientation", "learn", "class", "training", "session"]),
        Service(id: "software", icon: "desktopcomputer", title: "Use a computer or software",
                oneLiner: "Public computers, plus uOLabsPlus for SPSS, Stata, ArcGIS and more on your own laptop.",
                steps: ["Sign in with uoAccess", "Or open uOLabsPlus on your device", "Note: uOLabsPlus is down midnight to 3 a.m."],
                whereAt: "Morisset, Health Sciences, Brian Dickson", cta: "Computers and technology",
                url: "https://www.uottawa.ca/library/services/computers-technology", webClicks: 2,
                keywords: ["computer", "software", "spss", "stata", "arcgis", "excel", "laptop", "pc", "adobe", "wifi"]),
    ]

    static let quick = ["camera", "room", "podcast", "cite", "librarian", "print"]

    static func service(_ id: String) -> Service? { services.first { $0.id == id } }

    /// Local ranking. No query ever leaves the phone.
    static func search(_ query: String) -> [Service] {
        let words = query.lowercased().split { !$0.isLetter && !$0.isNumber }.map(String.init).filter { $0.count > 1 }
        guard !words.isEmpty else { return [] }
        return services
            .map { s -> (Service, Int) in
                let hay = (s.title + " " + s.oneLiner).lowercased()
                var score = 0
                for w in words {
                    if s.keywords.contains(where: { $0 == w }) { score += 5 }
                    else if s.keywords.contains(where: { $0.hasPrefix(w) || w.hasPrefix($0) }) { score += 3 }
                    else if hay.contains(w) { score += 1 }
                }
                return (s, score)
            }
            .filter { $0.1 > 0 }
            .sorted { $0.1 > $1.1 }
            .map(\.0)
    }
}
