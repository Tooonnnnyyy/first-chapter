import SwiftUI
import SwiftData

struct FindView: View {
    @Binding var showDeck: Bool
    @State private var query = ""
    @Environment(ApmDialogs.self) private var dialogs: ApmDialogs?
    @Query private var plan: [PlanItem]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    header
                    if query.isEmpty {
                        home
                    } else {
                        results
                    }
                }
                .background(Color.apmPage)
            }
            .scrollDismissesKeyboard(.interactively)
            .apmRootChrome(.lime)
            .navigationDestination(for: Service.self) { ServiceDetail(service: $0) }
            .fullScreenCover(isPresented: $showDeck) {
                SwipeDeck { showDeck = false }
            }
        }
    }

    private var header: some View {
        ApmBand(tint: .lime, top: 6, bottom: 20) {
            ApmHeaderTitle(text: "Library")
            ApmSearchField(text: $query, prompt: "Camera, citing, study room…")
                .padding(.top, 18)
            XPBar(progress: PlanScore.progress(plan))
                .padding(.top, 20)
        }
    }

    @ViewBuilder
    private var home: some View {
        Button { showDeck = true } label: {
            ApmCard(fill: .apmInk, ink: .apmBone, shadow: .apmFlame, shadowOffset: 6) {
                HStack(alignment: .center, spacing: 12) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Discover What's Here").apmText(.h4)
                        Text("\(Catalog.discover.count) quick cards, under a minute").apmText(.label)
                        ApmTag(text: "+\(Game.saveXP) XP a card", fill: .apmLime)
                            .padding(.top, 4)
                    }
                    Spacer(minLength: 0)
                    Text(ApmGlyph.right).apmText(.h3).accessibilityHidden(true)
                }
            }
        }
        .buttonStyle(ApmCardPress())
        .accessibilityLabel("Discover What's Here, \(Catalog.discover.count) quick cards, under a minute")
        .padding(.horizontal, ApmLayout.gutter)
        .padding(.top, 22)
        .padding(.bottom, 28)

        Button {
            dialogs?.show(ApmDialogModel(title: "Coming Soon",
                                         message: "Importing your own files isn't in this prototype yet.",
                                         actions: [ApmDialogAction(title: "OK", role: .cancel)]))
        } label: {
            HStack(alignment: .top, spacing: 12) {
                ApmIcon(symbol: "square.and.arrow.down", size: 18)
                    .padding(.top, 2)
                VStack(alignment: .leading, spacing: 3) {
                    Text("Import Your Files").apmText(.title)
                    Text("Add notes and course outlines as personal context").apmText(.small)
                        .foregroundStyle(Color.apmInk.opacity(0.78))
                        .fixedSize(horizontal: false, vertical: true)
                }
                Spacer(minLength: 8)
                ApmTag(text: "Soon", fill: .apmMute)
            }
            .foregroundStyle(Color.apmInk)
            .padding(.horizontal, ApmLayout.gutter)
            .padding(.vertical, 14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .overlay(alignment: .top) { ApmRule() }
            .overlay(alignment: .bottom) { ApmRule() }
        }
        .buttonStyle(ApmRowPress())

        ApmSectionHead(title: "Most Needed", trailing: String(format: "%02d", Catalog.quick.count))
        ForEach(Catalog.quick) { ServiceLink(service: $0) }

        VStack(alignment: .leading, spacing: 0) {
            ApmSectionHead(title: "More Services", trailing: String(format: "%02d", Catalog.more.count))
            ForEach(Catalog.more) { ServiceLink(service: $0) }
        }
        .padding(.bottom, 28)
        .background(Color.apmPaper)
        .padding(.top, 28)
        .overlay(alignment: .top) { ApmRule().padding(.top, 28) }
    }

    @ViewBuilder
    private var results: some View {
        let found = Catalog.search(query)
        if found.isEmpty {
            VStack(alignment: .leading, spacing: 10) {
                Text("No Results for “\(query)”").apmText(.h4)
                    .fixedSize(horizontal: false, vertical: true)
                Text("Check the spelling or try a new search.").apmText(.body)
                if let text = URL(string: "sms:6138015603") {
                    Link(destination: text) {
                        Label("Text a librarian: 613-801-5603", systemImage: "message")
                    }
                    .buttonStyle(ApmPillStyle())
                    .padding(.top, 12)
                }
            }
            .foregroundStyle(Color.apmInk)
            .padding(ApmLayout.gutter)
            .padding(.top, 12)
        } else {
            ForEach(found) { ServiceLink(service: $0) }
        }
    }
}

/// Square search field: 2pt ink outline, bone fill, 3pt outline while typing.
struct ApmSearchField: View {
    @Binding var text: String
    let prompt: String
    @FocusState private var focused: Bool

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 17, weight: .medium))
                .accessibilityHidden(true)
            TextField("Search", text: $text, prompt: Text(prompt).foregroundStyle(Color.apmInk.opacity(0.55)))
                .apmText(.body)
                .focused($focused)
                .submitLabel(.search)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
            if !text.isEmpty {
                Button { text = "" } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 13, weight: .semibold))
                        .frame(width: 28, height: 28)
                        .overlay(Circle().strokeBorder(Color.apmInk, lineWidth: 2))
                        .frame(width: 44, height: 44)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Clear search")
            }
        }
        .foregroundStyle(Color.apmInk)
        .padding(.leading, 14)
        .padding(.trailing, text.isEmpty ? 14 : 2)
        .frame(minHeight: 50)
        .background(Color.apmBone)
        .overlay(Rectangle().strokeBorder(Color.apmInk, lineWidth: focused ? 3 : 2))
        .contentShape(Rectangle())
        .onTapGesture { focused = true }
    }
}

struct ServiceDetail: View {
    let service: Service
    @Environment(\.modelContext) private var ctx
    @Environment(\.apmTint) private var tint
    @Query private var plan: [PlanItem]
    private var item: PlanItem? { plan.first { $0.serviceID == service.id } }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                ApmBand(tint: tint, top: 4, bottom: 24) {
                    Image(systemName: service.icon)
                        .font(.system(size: 28, weight: .regular))
                        .padding(.bottom, 14)
                        .accessibilityHidden(true)
                    ApmHeaderTitle(text: service.title, style: .h2)
                    Text(service.answer).apmText(.lede)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.top, 12)
                    WebLink(url: service.url) {
                        Text("\(service.cta) \(ApmGlyph.out)")
                    }
                    .buttonStyle(ApmPillStyle(shadow: tint == .flame ? .apmLime : .apmFlame))
                    .padding(.top, 20)
                }

                if !service.facts.isEmpty {
                    ApmSectionHead(title: "Good to Know")
                    ForEach(service.facts, id: \.label) { ApmFactRow(label: $0.label, value: $0.value) }
                }

                ApmSectionHead(title: "How It Works")
                ForEach(Array(service.steps.enumerated()), id: \.offset) { index, step in
                    HStack(alignment: .top, spacing: 14) {
                        Text("\(index + 1)")
                            .apmText(.label)
                            .frame(width: 28, height: 28)
                            .overlay(Circle().strokeBorder(Color.apmInk, lineWidth: 2))
                        Text(step).apmText(.body).fixedSize(horizontal: false, vertical: true)
                            .padding(.top, 3)
                        Spacer(minLength: 0)
                    }
                    .foregroundStyle(Color.apmInk)
                    .padding(.horizontal, ApmLayout.gutter)
                    .padding(.vertical, 12)
                    .overlay(alignment: .bottom) { ApmHairline().padding(.horizontal, ApmLayout.gutter) }
                    .accessibilityElement(children: .combine)
                }

                planActions
                    .padding(.top, 28)
            }
            .background(Color.apmPage)
        }
        // The plan block is paper, so paper fills any space under it.
        .apmPushedChrome(tint, bottom: .apmPaper)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if let target = URL(string: service.url) {
                ToolbarItem(placement: .topBarTrailing) {
                    ShareLink(item: target) { ApmBarGlyph(symbol: "square.and.arrow.up") }
                        .buttonStyle(.plain)
                        .accessibilityLabel("Share")
                }
                .sharedBackgroundVisibility(.hidden)
            }
        }
    }

    private var planActions: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .center, spacing: 10) {
                Text(item == nil ? "Quest" : item?.doneAt == nil ? "In My Plan · +\(Game.doneXP) XP to finish" : "Done · Stamp collected")
                    .apmText(.eyebrow)
                    .fixedSize(horizontal: false, vertical: true)
                Spacer(minLength: 6)
                RewardPill(done: item?.doneAt != nil)
            }
            if let item {
                Button { ctx.toggleDone(service.id) } label: {
                    HStack(spacing: 10) {
                        Text(item.doneAt == nil ? "Mark as Done" : "Mark as Not Done")
                        if item.doneAt == nil { ApmTag(text: "+\(Game.doneXP) XP") }
                    }
                }
                .buttonStyle(ApmPillStyle(fullWidth: true))
                Button("Remove from My Plan", role: .destructive) { ctx.removeFromPlan(service.id) }
                    .buttonStyle(ApmPillStyle(kind: .ghost, fullWidth: true))
            } else {
                Button { ctx.addToPlan(service.id, source: "find") } label: {
                    HStack(spacing: 10) {
                        Text("Add to My Plan")
                        ApmTag(text: "+\(Game.saveXP) XP")
                    }
                }
                .buttonStyle(ApmPillStyle(fullWidth: true))
            }
            Text("On the website: \(service.webClicks) \(service.webClicks == 1 ? "click" : "clicks") from the Library home page. Here: the answer is on the first screen.")
                .apmText(.small)
                .foregroundStyle(Color.apmInk.opacity(0.72))
                .fixedSize(horizontal: false, vertical: true)
                .padding(.top, 4)
        }
        .foregroundStyle(Color.apmInk)
        .padding(ApmLayout.gutter)
        .padding(.top, 6)
        .padding(.bottom, 24)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.apmPaper)
        .overlay(alignment: .top) { ApmRule() }
    }
}
