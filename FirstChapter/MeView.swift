import SwiftUI
import SwiftData

struct MeView: View {
    @Environment(\.modelContext) private var ctx
    @Query(sort: \PlanItem.addedAt) private var plan: [PlanItem]
    @AppStorage("onboarded") private var onboarded = true
    @State private var confirmErase = false
    private let grid = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]

    private var doneIDs: Set<String> { Set(plan.filter { $0.doneAt != nil }.map(\.serviceID)) }
    private var clicksSaved: Int {
        Catalog.services.filter { doneIDs.contains($0.id) }.reduce(0) { $0 + max($1.webClicks - 1, 0) }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Your Library passport").font(.system(size: 24, weight: .bold)).foregroundStyle(Color.dsText)
                    HStack(spacing: 8) {
                        stat("\(doneIDs.count)", "stamps")
                        stat("\(plan.count)", "in plan")
                        stat("\(clicksSaved)", "clicks saved")
                    }
                    LazyVGrid(columns: grid, spacing: 8) {
                        ForEach(Catalog.services) { s in
                            let done = doneIDs.contains(s.id)
                            VStack(spacing: 6) {
                                Image(systemName: done ? "checkmark.seal.fill" : s.icon)
                                    .font(.system(size: 22))
                                    .foregroundStyle(done ? Color.dsSuccess : Color.dsMuted.opacity(0.5))
                                Text(s.title).font(.system(size: 10)).foregroundStyle(Color.dsMuted)
                                    .multilineTextAlignment(.center).lineLimit(2)
                            }
                            .padding(8)
                            .frame(maxWidth: .infinity, minHeight: 76)
                            .card(dashed: !done)
                        }
                    }

                    SectionTitle(text: "Your data, all of it")
                    VStack(alignment: .leading, spacing: 8) {
                        Text("PlanItem · \(plan.count) \(plan.count == 1 ? "row" : "rows")").font(.system(size: 13, weight: .semibold, design: .monospaced)).foregroundStyle(Color.dsText)
                        Text("serviceID  source  addedAt  doneAt").font(.system(size: 12, design: .monospaced)).foregroundStyle(Color.dsMuted)
                        Divider()
                        Label("No name, student number, email or login", systemImage: "person.slash")
                        Label("Chats are never saved", systemImage: "bubble.left.and.exclamationmark.bubble.right")
                        Label("Encrypted by iOS, on this phone only", systemImage: "lock.iphone")
                        Label("No analytics, no server", systemImage: "icloud.slash")
                    }
                    .font(.system(size: 13))
                    .foregroundStyle(Color.dsText)
                    .padding(12)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .card()

                    Button("Erase everything") { confirmErase = true }
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(Color.dsDanger)
                        .frame(maxWidth: .infinity, minHeight: 44)
                        .card()

                    SectionTitle(text: "Ask a person")
                    VStack(alignment: .leading, spacing: 8) {
                        if let t = URL(string: "sms:6138015603") { Link("Text 613-801-5603", destination: t) }
                        if let c = URL(string: "tel:6135625213") { Link("Call 613-562-5213", destination: c) }
                        if let e = URL(string: "mailto:bibliolibrary@uOttawa.ca") { Link("bibliolibrary@uOttawa.ca", destination: e) }
                    }
                    .font(.system(size: 14))
                    .padding(12)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .card()

                    Text("Student prototype. Not affiliated with or endorsed by the University of Ottawa.")
                        .font(.system(size: 12)).foregroundStyle(Color.dsMuted)
                }
                .padding(DS.inset)
            }
            .background(Color.dsBg)
            .toolbar { ToolbarItem(placement: .principal) { Wordmark().fixedSize() } }
            .confirmationDialog("Erase your plan and stamps from this phone?", isPresented: $confirmErase, titleVisibility: .visible) {
                Button("Erase everything", role: .destructive) {
                    ctx.eraseEverything()
                    onboarded = false
                }
            }
        }
    }

    private func stat(_ value: String, _ label: String) -> some View {
        VStack(spacing: 2) {
            Text(value).font(.system(size: 22, weight: .bold, design: .monospaced)).foregroundStyle(Color.dsAccent)
            Text(label).font(.system(size: 11)).foregroundStyle(Color.dsMuted)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .card()
    }
}
