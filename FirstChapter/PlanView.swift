import SwiftUI
import SwiftData

enum PlanRoute: Hashable {
    case service(Service)
    case data
}

struct PlanView: View {
    @Environment(\.modelContext) private var ctx
    @Query(sort: \PlanItem.addedAt) private var plan: [PlanItem]
    @State private var path: [PlanRoute] = []

    private var todo: [PlanItem] { plan.filter { $0.doneAt == nil } }
    private var done: [PlanItem] { plan.filter { $0.doneAt != nil } }
    private var clicksSaved: Int {
        done.compactMap { Catalog.service($0.serviceID) }.reduce(0) { $0 + max($1.webClicks - 1, 0) }
    }
    private var stamps: (filled: Set<String>, total: Int) {
        Game.stamps(PlanScore.entries(plan), catalog: PlanScore.catalogIDs)
    }

    var body: some View {
        NavigationStack(path: $path) {
            List {
                Group {
                    header
                    if plan.isEmpty {
                        empty
                    } else {
                        tally
                    }
                    if !todo.isEmpty {
                        ApmSectionHead(title: "To Do", trailing: quests(todo.count))
                        ForEach(todo) { row($0) }
                    }
                    if !done.isEmpty {
                        ApmSectionHead(title: "Done", trailing: quests(done.count))
                        ForEach(done) { row($0) }
                    }
                    stampBook
                    ApmSectionHead(title: "Contact the Library")
                    if let url = URL(string: "sms:6138015603") {
                        Link(destination: url) { ApmLineRow(symbol: "message", title: "Text 613-801-5603", trailing: .out) }
                            .buttonStyle(ApmRowPress())
                    }
                    if let url = URL(string: "tel:6135625213") {
                        Link(destination: url) { ApmLineRow(symbol: "phone", title: "Call 613-562-5213", trailing: .out) }
                            .buttonStyle(ApmRowPress())
                    }
                    if let url = URL(string: "mailto:bibliolibrary@uOttawa.ca") {
                        Link(destination: url) { ApmLineRow(symbol: "envelope", title: "bibliolibrary@uOttawa.ca", trailing: .out) }
                            .buttonStyle(ApmRowPress())
                    }
                    Button { path.append(.data) } label: {
                        ApmLineRow(symbol: "lock", title: "Your Data").overlay(alignment: .top) { ApmRule() }
                    }
                    .buttonStyle(ApmRowPress())
                    .padding(.top, 28)
                    ApmFootnote(text: "Student prototype. Not affiliated with or endorsed by the University of Ottawa.")
                        .padding(.bottom, 28)
                }
                .listRowInsets(EdgeInsets())
                .listRowSeparator(.hidden)
                .listRowBackground(Color.apmPage)
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            .environment(\.defaultMinListRowHeight, 0)
            .apmRootChrome(.flame)
            .navigationDestination(for: PlanRoute.self) { route in
                switch route {
                case .service(let service): ServiceDetail(service: service)
                case .data: DataView()
                }
            }
        }
    }

    private func quests(_ n: Int) -> String { n == 1 ? "1 quest" : "\(n) quests" }

    private var header: some View {
        ApmBand(tint: .flame, top: 6, bottom: 20) {
            ApmHeaderTitle(text: "My Plan")
            XPBar(progress: PlanScore.progress(plan), fill: .apmLime)
                .padding(.top, 18)
            Text("XP is just for fun and stays on this device. It isn't a Library reward.")
                .apmText(.small)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.top, 12)
        }
        .listRowBackground(Color.apmFlame)
    }

    private var empty: some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: "checklist")
                .font(.system(size: 26, weight: .regular))
                .padding(.bottom, 6)
                .accessibilityHidden(true)
            Text("Nothing Saved Yet").apmText(.h4)
            Text("Add a service from Find and it shows up here.").apmText(.body)
                .fixedSize(horizontal: false, vertical: true)
        }
        .foregroundStyle(Color.apmInk)
        .padding(ApmLayout.gutter)
        .padding(.vertical, 12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .overlay(alignment: .bottom) { ApmRule() }
        .accessibilityElement(children: .combine)
    }

    /// The old progress row and clicks-saved figure, as two ruled cells.
    private var tally: some View {
        HStack(spacing: 0) {
            cell(value: "\(done.count) of \(plan.count)", label: "done")
                .accessibilityLabel("\(done.count) of \(plan.count) done")
            Rectangle().fill(Color.apmInk).frame(width: 2).accessibilityHidden(true)
            cell(value: "\(clicksSaved)", label: "Website clicks saved")
                .accessibilityLabel("Website clicks saved: \(clicksSaved)")
        }
        .fixedSize(horizontal: false, vertical: true)
        .background(Color.apmBone)
        .overlay(alignment: .bottom) { ApmRule() }
    }

    private func cell(value: String, label: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(value).apmText(.numeral)
            Text(label).apmText(.label)
        }
        .foregroundStyle(Color.apmInk)
        .padding(ApmLayout.gutter)
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityElement(children: .ignore)
    }

    private var stampBook: some View {
        VStack(alignment: .leading, spacing: 0) {
            ApmSectionHead(title: "Stamps", trailing: "\(stamps.filled.count) of \(stamps.total) stamps")
            StampCollection(filled: stamps.filled)
                .padding(ApmLayout.gutter)
                .padding(.vertical, 4)
            Text("Finish a quest to ink its stamp.").apmText(.label)
                .foregroundStyle(Color.apmInk.opacity(0.75))
                .padding(.horizontal, ApmLayout.gutter)
                .padding(.bottom, 16)
        }
        .background(Color.apmPaper)
        .padding(.top, 28)
        .overlay(alignment: .top) { ApmRule().padding(.top, 28) }
        .overlay(alignment: .bottom) { ApmRule() }
    }

    @ViewBuilder
    private func row(_ item: PlanItem) -> some View {
        if let service = Catalog.service(item.serviceID) {
            let finished = item.doneAt != nil
            HStack(spacing: 12) {
                Button { ctx.toggleDone(item.serviceID) } label: {
                    ZStack {
                        Circle().fill(finished ? Color.apmInk : Color.apmBone)
                        Circle().strokeBorder(Color.apmInk, lineWidth: 2)
                        if finished {
                            Image(systemName: "checkmark")
                                .font(.system(size: 13, weight: .bold))
                                .foregroundStyle(Color.apmLime)
                        }
                    }
                    .frame(width: 30, height: 30)
                    .frame(width: 44, height: 44)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel(finished ? "Mark \(service.title) as not done" : "Mark \(service.title) as done")

                Button { path.append(.service(service)) } label: {
                    HStack(spacing: 10) {
                        Text(service.title)
                            .apmText(.title)
                            .strikethrough(finished)
                            .multilineTextAlignment(.leading)
                            .fixedSize(horizontal: false, vertical: true)
                        Spacer(minLength: 6)
                        RewardPill(done: finished)
                        ApmArrow()
                    }
                    .frame(maxWidth: .infinity, minHeight: 44, alignment: .leading)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel(service.title)
                .accessibilityValue(finished ? "Done, \(Game.questXP) XP earned" : "Quest, worth \(Game.questXP) XP")
            }
            .foregroundStyle(Color.apmInk)
            .padding(.leading, 6)
            .padding(.trailing, ApmLayout.gutter)
            .padding(.vertical, 6)
            .background(Color.apmPage)
            .overlay(alignment: .bottom) { ApmRule() }
            .swipeActions {
                Button("Remove", role: .destructive) { ctx.removeFromPlan(item.serviceID) }
                    .tint(Color.apmInk)
            }
        }
    }
}

struct DataView: View {
    @Environment(\.modelContext) private var ctx
    @Environment(\.dismiss) private var dismiss
    @Environment(\.apmTint) private var tint
    @Query private var plan: [PlanItem]
    @Environment(ApmDialogs.self) private var dialogs: ApmDialogs?
    @AppStorage("onboarded") private var onboarded = true

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                ApmBand(tint: tint, top: 4, bottom: 24) {
                    ApmHeaderTitle(text: "Your Data", style: .h2)
                }

                ApmSectionHead(title: "Stored on This Phone")
                ApmFactRow(label: "Saved items", value: "\(plan.count)")
                ApmFactRow(label: "serviceID", value: "Which service")
                ApmFactRow(label: "source", value: "Where you added it")
                ApmFactRow(label: "addedAt", value: "Date added")
                ApmFactRow(label: "doneAt", value: "Date finished")
                ApmFootnote(text: "One local table, encrypted by iOS while the phone is locked, and left out of backups.")
                ApmFootnote(text: "XP, chapters and stamps are worked out from this table. They aren't stored on their own, and erasing it resets them.")

                ApmSectionHead(title: "Never Collected")
                never("person.slash", "Name, email or student number")
                never("key.slash", "Library account or password")
                never("location.slash", "Location or analytics")
                never("bubble.left.and.exclamationmark.bubble.right", "Chat history")

                ApmSectionHead(title: "What Leaves This Phone")
                Text(Guide.onlineConfigured
                     ? "Only the questions you type in Ask, when Online AI is on. They go to DeepSeek with emails, phone numbers and ID numbers removed first. Official pages you open follow the Library's own privacy notice."
                     : "Nothing from this app. Official pages you open follow the Library's own privacy notice.")
                    .apmText(.body)
                    .foregroundStyle(Color.apmInk)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(ApmLayout.gutter)

                Button("Erase Everything", role: .destructive) { confirmErase() }
                    .buttonStyle(ApmPillStyle(fullWidth: true))
                    .padding(ApmLayout.gutter)
                    .padding(.top, 12)
                    .padding(.bottom, 28)
            }
            .background(Color.apmPage)
        }
        .apmPushedChrome(tint)
        .navigationBarTitleDisplayMode(.inline)
    }

    private func confirmErase() {
        dialogs?.show(ApmDialogModel(
            title: "Erase your plan from this phone?",
            message: "This can't be undone.",
            actions: [
                ApmDialogAction(title: "Erase Everything", role: .destructive) {
                    ctx.eraseEverything()
                    onboarded = false
                    dismiss()
                },
                ApmDialogAction(title: "Cancel", role: .cancel),
            ]))
    }

    private func never(_ symbol: String, _ text: String) -> some View {
        HStack(spacing: 12) {
            ApmIcon(symbol: symbol, size: 18)
            Text(text).apmText(.body)
            Spacer(minLength: 0)
        }
        .foregroundStyle(Color.apmInk)
        .padding(.horizontal, ApmLayout.gutter)
        .padding(.vertical, 12)
        .overlay(alignment: .bottom) { ApmHairline().padding(.horizontal, ApmLayout.gutter) }
        .accessibilityElement(children: .combine)
    }
}
