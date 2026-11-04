import SwiftUI
import SwiftData

struct StepsBadge: View {
    let service: Service
    var body: some View {
        Badge(text: "WEBSITE \(service.webClicks) CLICKS → HERE 1 TAP", tone: .accent)
    }
}

struct ServiceRow: View {
    let service: Service
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: service.icon)
                .font(.system(size: 18))
                .foregroundStyle(Color.dsAccent)
                .frame(width: 40, height: 40)
                .background(Color.dsAccentSoft)
                .clipShape(RoundedRectangle(cornerRadius: DS.radiusMd))
            VStack(alignment: .leading, spacing: 2) {
                Text(service.title).font(.system(size: 15, weight: .semibold)).foregroundStyle(Color.dsText)
                Text(service.oneLiner).font(.system(size: 13)).foregroundStyle(Color.dsMuted).lineLimit(2).multilineTextAlignment(.leading)
            }
            Spacer(minLength: 0)
            Image(systemName: "chevron.right").font(.system(size: 12)).foregroundStyle(Color.dsMuted)
        }
        .padding(12)
        .card()
    }
}

struct FindView: View {
    @Query(sort: \PlanItem.addedAt) private var plan: [PlanItem]
    @State private var query = ""
    private let grid = [GridItem(.flexible(), spacing: 8), GridItem(.flexible(), spacing: 8)]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("What do you need?").font(.system(size: 28, weight: .bold)).foregroundStyle(Color.dsText)
                    HStack(spacing: 8) {
                        Image(systemName: "magnifyingglass").foregroundStyle(Color.dsMuted)
                        TextField("camera, APA, quiet room…", text: $query)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                        if !query.isEmpty {
                            Button { query = "" } label: { Image(systemName: "xmark.circle.fill") }
                                .foregroundStyle(Color.dsMuted)
                                .accessibilityLabel("Clear search")
                        }
                    }
                    .padding(12)
                    .card()

                    if query.isEmpty {
                        SectionTitle(text: "One tap")
                        LazyVGrid(columns: grid, spacing: 8) {
                            ForEach(Catalog.quick.compactMap(Catalog.service)) { s in
                                NavigationLink(value: s) {
                                    VStack(alignment: .leading, spacing: 12) {
                                        Image(systemName: s.icon).font(.system(size: 22)).foregroundStyle(Color.dsAccent)
                                        Text(s.title).font(.system(size: 14, weight: .semibold)).foregroundStyle(Color.dsText)
                                            .multilineTextAlignment(.leading).lineLimit(2)
                                        Spacer(minLength: 0)
                                        Text(s.webClicks == 2 ? "saves 1 click" : "saves \(max(s.webClicks - 1, 0)) clicks").font(.system(size: 11, design: .monospaced)).foregroundStyle(Color.dsMuted)
                                    }
                                    .padding(12)
                                    .frame(maxWidth: .infinity, minHeight: 116, alignment: .leading)
                                    .card()
                                }
                            }
                        }
                        if !plan.isEmpty {
                            SectionTitle(text: "Your plan")
                            let done = plan.filter { $0.doneAt != nil }.count
                            VStack(alignment: .leading, spacing: 8) {
                                Text("\(done) of \(plan.count) tried").font(.system(size: 14, weight: .medium)).foregroundStyle(Color.dsText)
                                ProgressView(value: Double(done), total: Double(plan.count)).tint(Color.dsSuccess)
                            }
                            .padding(12)
                            .card()
                            ForEach(plan.filter { $0.doneAt == nil }.compactMap { Catalog.service($0.serviceID) }) { s in
                                NavigationLink(value: s) { ServiceRow(service: s) }
                            }
                        }
                    } else {
                        let results = Catalog.search(query)
                        if results.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("No match for \"\(query)\"").font(.system(size: 14, weight: .medium))
                                Text("Try the Ask tab, or text a librarian at 613-801-5603.").font(.system(size: 13)).foregroundStyle(Color.dsMuted)
                            }
                            .padding(12)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .card(dashed: true)
                        }
                        ForEach(results) { s in
                            NavigationLink(value: s) { ServiceRow(service: s) }
                        }
                    }
                }
                .padding(DS.inset)
            }
            .background(Color.dsBg)
            .toolbar { ToolbarItem(placement: .principal) { Wordmark().fixedSize() } }
            .navigationDestination(for: Service.self) { ServiceDetail(service: $0) }
        }
    }
}

struct ServiceDetail: View {
    let service: Service
    @Environment(\.modelContext) private var ctx
    @Query private var plan: [PlanItem]
    private var item: PlanItem? { plan.first { $0.serviceID == service.id } }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Image(systemName: service.icon)
                    .font(.system(size: 28)).foregroundStyle(Color.dsAccent)
                    .frame(width: 56, height: 56).background(Color.dsAccentSoft)
                    .clipShape(RoundedRectangle(cornerRadius: DS.radiusLg))
                Text(service.title).font(.system(size: 24, weight: .bold)).foregroundStyle(Color.dsText)
                StepsBadge(service: service)
                Text(service.oneLiner).font(.system(size: 16)).foregroundStyle(Color.dsMuted)

                SectionTitle(text: "How it works")
                VStack(alignment: .leading, spacing: 12) {
                    ForEach(Array(service.steps.enumerated()), id: \.offset) { i, step in
                        HStack(alignment: .top, spacing: 10) {
                            Text("\(i + 1)").font(.system(size: 12, weight: .bold, design: .monospaced))
                                .foregroundStyle(Color.dsAccent).frame(width: 22, height: 22)
                                .background(Color.dsAccentSoft).clipShape(Circle())
                            Text(step).font(.system(size: 14)).foregroundStyle(Color.dsText)
                        }
                    }
                }
                .padding(12).frame(maxWidth: .infinity, alignment: .leading).card()

                SectionTitle(text: "Where")
                Label(service.whereAt, systemImage: "mappin.and.ellipse").font(.system(size: 14)).foregroundStyle(Color.dsText)

                if let url = URL(string: service.url) {
                    Link(destination: url) { Label(service.cta, systemImage: "arrow.up.right") }
                        .buttonStyle(PrimaryButton())
                }
                if item?.doneAt != nil {
                    Label("Stamped in your passport", systemImage: "checkmark.seal.fill")
                        .font(.system(size: 14, weight: .semibold)).foregroundStyle(Color.dsSuccess)
                        .frame(maxWidth: .infinity, minHeight: 44)
                } else {
                    HStack(spacing: 8) {
                        if item == nil {
                            Button("Save to plan") { ctx.addToPlan(service.id, source: "find") }.buttonStyle(SecondaryButton())
                        }
                        Button("I did this") { ctx.markDone(service.id) }.buttonStyle(SecondaryButton())
                    }
                }
                Text("Sign-in and bookings happen on the Library's own site.").font(.system(size: 12)).foregroundStyle(Color.dsMuted)
            }
            .padding(DS.inset)
        }
        .background(Color.dsBg)
        .navigationBarTitleDisplayMode(.inline)
    }
}
