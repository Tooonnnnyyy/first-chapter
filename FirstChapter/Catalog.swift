import SwiftUI

/// Public Library information, read from uottawa.ca/library on 2026-11-04.
/// Sources are in docs/reference/library-services.md. Holds no user data.
struct Fact: Hashable {
    let label: String
    let value: String
}

struct Service: Identifiable, Hashable {
    let id: String
    let icon: String
    let color: Color
    let title: String
    /// The answer itself, shown on the row, so most students never need another tap.
    let answer: String
    let facts: [Fact]
    let steps: [String]
    let cta: String
    let url: String
    let webClicks: Int
    let keywords: [String]
}

enum Catalog {
    static let gearURL = "https://ocul-uo.primo.exlibrisgroup.com/discovery/collectionDiscovery?vid=01OCUL_UO:UO_DEFAULT&collectionId=81966870270005161&lang=en"

    static let gear: [(icon: String, name: String, color: Color)] = [
        ("camera.fill", "Cameras", .orange),
        ("mic.fill", "Microphones", .red),
        ("camera.on.rectangle.fill", "Tripods and Holders", .blue),
        ("lightbulb.fill", "Screens and Lights", .yellow),
        ("cable.connector", "Cables and Adaptors", .gray),
        ("tv.fill", "TV Equipment and Others", .indigo),
        ("clock.fill", "Reserved Items (4-Hour Loan)", .teal),
    ]

    static let services: [Service] = [
        Service(id: "camera", icon: "camera.fill", color: .orange, title: "Borrow a Camera or Gear",
                answer: "Cameras, mics, tripods and lights. 7-day loan from the Morisset service desk.",
                facts: [Fact(label: "Loan", value: "7 days, 2 renewals"),
                        Fact(label: "Pick up", value: "Morisset service desk"),
                        Fact(label: "Who", value: "Current students"),
                        Fact(label: "Bring", value: "Valid library card"),
                        Fact(label: "Return", value: "With all accessories")],
                steps: ["Pick your gear from the equipment list", "Bring your library card to the Morisset service desk", "Return it with all accessories, or renew, within 7 days"],
                cta: "See Equipment List", url: gearURL, webClicks: 5,
                keywords: ["camera", "cameras", "gear", "equipment", "tripod", "mic", "microphone", "video", "film", "photo", "shoot", "record", "loan", "lend", "multimedia", "technology", "light", "lights", "borrow", "cable", "adaptor"]),
        Service(id: "room", icon: "person.3.fill", color: .blue, title: "Book a Study Room",
                answer: "Reserve online at Morisset, Law, Learning Crossroads or Health Sciences.",
                facts: [Fact(label: "Where", value: "Morisset, Law, CRX 5th floor, Health Sciences"),
                        Fact(label: "Size", value: "Up to about 6, varies")],
                steps: ["Open the booking page", "Choose a library and time", "Reserve and show up with your group"],
                cta: "Book a Room", url: "https://bibliorooms.uottawa.ca/", webClicks: 2,
                keywords: ["room", "rooms", "study", "group", "quiet", "space", "book", "booking", "reserve", "team", "meeting"]),
        Service(id: "podcast", icon: "mic.fill", color: .purple, title: "Record a Podcast",
                answer: "The Digital Skills Hub at Learning Crossroads supports podcasting and VR.",
                facts: [Fact(label: "Where", value: "Learning Crossroads (CRX)")],
                steps: ["Open the Digital Skills Hub page", "Choose podcasting", "Follow its booking steps"],
                cta: "Open Digital Skills Hub", url: "https://www.uottawa.ca/library/learning-crossroads/digital-skills-hub", webClicks: 3,
                keywords: ["podcast", "studio", "audio", "record", "vr", "virtual", "reality", "sound", "digital", "skills"]),
        Service(id: "cite", icon: "quote.opening", color: .green, title: "Cite Your Sources",
                answer: "Library guides to citation styles, citation software and avoiding plagiarism.",
                facts: [],
                steps: ["Open Citation Styles", "Choose the style your course uses", "Stuck? Ask a librarian"],
                cta: "Open Citation Styles", url: "https://www.uottawa.ca/library/writing-citing/citation-styles", webClicks: 3,
                keywords: ["cite", "citing", "citation", "citations", "apa", "mla", "chicago", "plagiarism", "reference", "references", "paper", "essay", "bibliography", "writing", "sources"]),
        Service(id: "librarian", icon: "person.fill.questionmark", color: .pink, title: "Talk to a Librarian",
                answer: "Text 613-801-5603, or find the librarian for your subject.",
                facts: [Fact(label: "Text", value: "613-801-5603"),
                        Fact(label: "Phone", value: "613-562-5213"),
                        Fact(label: "Email", value: "bibliolibrary@uOttawa.ca")],
                steps: ["Find your subject", "Contact your librarian", "Or text the Library"],
                cta: "Find My Librarian", url: "https://www.uottawa.ca/library/research-guides-librarians", webClicks: 2,
                keywords: ["librarian", "help", "research", "ask", "question", "subject", "assignment", "stuck", "contact"]),
        Service(id: "print", icon: "printer.fill", color: .gray, title: "Print, Copy, Scan",
                answer: "$0.09 a page in black and white, $0.25 in colour. Scanning is free.",
                facts: [Fact(label: "B&W", value: "$0.09, 2-sided $0.16"),
                        Fact(label: "Colour", value: "$0.25, 2-sided $0.48"),
                        Fact(label: "Scan", value: "Free"),
                        Fact(label: "Pay with", value: "Funds on student card")],
                steps: ["Add funds to your student card", "Print at any library", "Scan to email or USB for free"],
                cta: "Printing Details", url: "https://www.uottawa.ca/library/services/print-copy-scan", webClicks: 3,
                keywords: ["print", "printing", "printer", "copy", "scan", "scanner", "photocopy", "price", "cost", "colour", "color", "money"]),
        Service(id: "hours", icon: "clock.fill", color: .teal, title: "Locations and Hours",
                answer: "Morisset, Law, Health Sciences, Learning Crossroads and more.",
                facts: [],
                steps: ["Open Locations and hours", "Choose your library"],
                cta: "See Today's Hours", url: "https://www.uottawa.ca/library/locations-hours", webClicks: 1,
                keywords: ["hours", "open", "close", "closing", "location", "locations", "where", "morisset", "crx", "address", "map"]),
        Service(id: "books", icon: "book.fill", color: .brown, title: "Borrow a Book",
                answer: "Undergrads get 120 days, up to 500 items, unlimited renewals.",
                facts: [Fact(label: "Loan", value: "120 days"),
                        Fact(label: "Limit", value: "500 items"),
                        Fact(label: "Renewals", value: "Unlimited")],
                steps: ["Search the catalogue", "Place a hold or take it from the shelf", "Show your library card"],
                cta: "Borrowing Rules", url: "https://www.uottawa.ca/library/services/borrow", webClicks: 2,
                keywords: ["book", "books", "borrow", "hold", "renew", "textbook", "card", "interlibrary", "due"]),
        Service(id: "card", icon: "creditcard.fill", color: .indigo, title: "Get a Library Card",
                answer: "You need a valid library card to borrow anything.",
                facts: [],
                steps: ["Open Library account", "Follow the steps for students"],
                cta: "Library Account", url: "https://www.uottawa.ca/library/services/library-account", webClicks: 2,
                keywords: ["card", "account", "library", "login", "sign", "id"]),
        Service(id: "reserves", icon: "bookmark.fill", color: .orange, title: "Course Reserves",
                answer: "Course materials your instructor set aside for short-term use.",
                facts: [],
                steps: ["Open Course reserves", "Search your course"],
                cta: "Open Course Reserves", url: "https://www.uottawa.ca/library/services/course-reserves", webClicks: 1,
                keywords: ["course", "reserve", "reserves", "textbook", "instructor", "professor", "readings"]),
        Service(id: "workshop", icon: "graduationcap.fill", color: .mint, title: "Join a Workshop",
                answer: "Workshops, orientations and tours at the Library.",
                facts: [],
                steps: ["See what's on", "Pick a session"],
                cta: "See Workshops", url: "https://www.uottawa.ca/library/workshops-orientations-tours", webClicks: 2,
                keywords: ["workshop", "workshops", "tour", "orientation", "learn", "class", "training", "session"]),
        Service(id: "software", icon: "desktopcomputer", color: .cyan, title: "Computers and Software",
                answer: "Public computers, plus SPSS, Stata and ArcGIS on your laptop through uOLabsPlus.",
                facts: [Fact(label: "Sign in", value: "uoAccess"),
                        Fact(label: "uOLabsPlus down", value: "Midnight to 3 a.m.")],
                steps: ["Sign in with uoAccess", "Or open uOLabsPlus on your own device"],
                cta: "Computers and Technology", url: "https://www.uottawa.ca/library/services/computers-technology", webClicks: 2,
                keywords: ["computer", "computers", "software", "spss", "stata", "arcgis", "excel", "laptop", "pc", "adobe", "wifi"]),
        Service(id: "access", icon: "accessibility", color: .blue, title: "Accessibility Services",
                answer: "Inclusive spaces, services and assistive technology at the Library.",
                facts: [],
                steps: ["Open Accessibility", "Contact the Library if you need support"],
                cta: "Open Accessibility", url: "https://www.uottawa.ca/library/services/accessibility", webClicks: 2,
                keywords: ["accessibility", "accessible", "disability", "assistive", "accommodation"]),
    ]

    static func service(_ id: String) -> Service? { services.first { $0.id == id } }

    private static func list(_ ids: [String]) -> [Service] { ids.compactMap(service) }
    static var quick: [Service] { list(["camera", "room", "cite", "librarian", "print", "hours"]) }
    static var more: [Service] { services.filter { s in !quick.contains(s) } }
    static var discover: [Service] { list(["camera", "podcast", "librarian", "room", "workshop", "software"]) }

    /// Local ranking. Search never leaves the phone.
    static func search(_ query: String) -> [Service] {
        let words = query.lowercased().split { !$0.isLetter && !$0.isNumber }.map(String.init).filter { $0.count > 1 }
        guard !words.isEmpty else { return [] }
        return services
            .map { s -> (Service, Int) in
                let hay = (s.title + " " + s.answer).lowercased()
                var score = 0
                for w in words {
                    if s.keywords.contains(w) { score += 5 }
                    else if s.keywords.contains(where: { $0.hasPrefix(w) }) { score += 3 }
                    else if hay.contains(w) { score += 1 }
                }
                return (s, score)
            }
            .filter { $0.1 > 0 }
            .sorted { $0.1 > $1.1 }
            .map(\.0)
    }
}
