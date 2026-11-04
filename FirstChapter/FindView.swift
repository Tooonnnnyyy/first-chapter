import SwiftUI
import SwiftData

struct FindView: View {
    @State private var query = ""
    @State private var showDeck = false

    var body: some View {
        NavigationStack {
            List {
                if query.isEmpty {
                    Section {
                        Button { showDeck = true } label: {
                            HStack(spacing: 12) {
                                IconTile(symbol: "sparkles", color: .brand)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Discover What's Here").foregroundStyle(.primary)
                                    Text("\(Catalog.discover.count) quick cards, under a minute").font(.subheadline).foregroundStyle(.secondary)
                                }
                            }
                        }
                    }
                    Section("Most Needed") {
                        ForEach(Catalog.quick) { service in
                            NavigationLink(value: service) { ServiceRow(service: service) }
                        }
                    }
                    Section("More Services") {
                        ForEach(Catalog.more) { service in
                            NavigationLink(value: service) { ServiceRow(service: service) }
                        }
                    }
                } else {
                    let results = Catalog.search(query)
                    if results.isEmpty {
                        ContentUnavailableView.search(text: query)
                        if let text = URL(string: "sms:6138015603") {
                            Link(destination: text) { Label("Text a librarian: 613-801-5603", systemImage: "message") }
                        }
                    } else {
                        ForEach(results) { service in
                            NavigationLink(value: service) { ServiceRow(service: service) }
                        }
                    }
                }
            }
            .navigationTitle("Library")
            .searchable(text: $query, placement: .navigationBarDrawer(displayMode: .always), prompt: "Camera, citing, study room…")
            .autocorrectionDisabled()
            .navigationDestination(for: Service.self) { ServiceDetail(service: $0) }
            .fullScreenCover(isPresented: $showDeck) {
                SwipeDeck { showDeck = false }
            }
        }
    }
}

struct ServiceDetail: View {
    let service: Service
    @Environment(\.modelContext) private var ctx
    @Query private var plan: [PlanItem]
    private var item: PlanItem? { plan.first { $0.serviceID == service.id } }

    var body: some View {
        List {
            Section {
                HStack(alignment: .top, spacing: 14) {
                    IconTile(symbol: service.icon, color: service.color, size: 52)
                    VStack(alignment: .leading, spacing: 4) {
                        Text(service.title).font(.title3.bold())
                        Text(service.answer).font(.subheadline).foregroundStyle(.secondary)
                    }
                }
                .padding(.vertical, 4)
                WebLink(url: service.url) {
                    HStack {
                        Text(service.cta)
                        Spacer()
                        Image(systemName: "arrow.up.forward").font(.footnote.weight(.semibold))
                    }
                }
            }
            if !service.facts.isEmpty {
                Section("Good to Know") {
                    ForEach(service.facts, id: \.label) { fact in
                        LabeledContent(fact.label, value: fact.value)
                    }
                }
            }
            Section("How It Works") {
                ForEach(Array(service.steps.enumerated()), id: \.offset) { index, step in
                    Label(step, systemImage: "\(index + 1).circle")
                }
            }
            Section {
                if let item {
                    Button(item.doneAt == nil ? "Mark as Done" : "Mark as Not Done") {
                        ctx.toggleDone(service.id)
                    }
                    Button("Remove from My Plan", role: .destructive) { ctx.removeFromPlan(service.id) }
                } else {
                    Button("Add to My Plan") { ctx.addToPlan(service.id, source: "find") }
                }
            } footer: {
                Text("On the website: \(service.webClicks) \(service.webClicks == 1 ? "click" : "clicks") from the Library home page. Here: the answer is on the first screen.")
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if let target = URL(string: service.url) {
                ToolbarItem(placement: .topBarTrailing) { ShareLink(item: target) }
            }
        }
    }
}
