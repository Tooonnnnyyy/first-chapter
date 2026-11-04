import SwiftUI
import SwiftData

struct PlanView: View {
    @Environment(\.modelContext) private var ctx
    @Query(sort: \PlanItem.addedAt) private var plan: [PlanItem]

    private var todo: [PlanItem] { plan.filter { $0.doneAt == nil } }
    private var done: [PlanItem] { plan.filter { $0.doneAt != nil } }
    private var clicksSaved: Int {
        done.compactMap { Catalog.service($0.serviceID) }.reduce(0) { $0 + max($1.webClicks - 1, 0) }
    }

    var body: some View {
        NavigationStack {
            List {
                if plan.isEmpty {
                    ContentUnavailableView("Nothing Saved Yet", systemImage: "checklist",
                                           description: Text("Add a service from Find and it shows up here."))
                } else {
                    Section {
                        ProgressView(value: Double(done.count), total: Double(plan.count)) {
                            Text("\(done.count) of \(plan.count) done")
                        }
                        LabeledContent("Website clicks saved", value: "\(clicksSaved)")
                    }
                    if !todo.isEmpty {
                        Section("To Do") { ForEach(todo) { row($0) } }
                    }
                    if !done.isEmpty {
                        Section("Done") { ForEach(done) { row($0) } }
                    }
                }
                Section("Contact the Library") {
                    if let url = URL(string: "sms:6138015603") { Link(destination: url) { Label("Text 613-801-5603", systemImage: "message") } }
                    if let url = URL(string: "tel:6135625213") { Link(destination: url) { Label("Call 613-562-5213", systemImage: "phone") } }
                    if let url = URL(string: "mailto:bibliolibrary@uOttawa.ca") { Link(destination: url) { Label("bibliolibrary@uOttawa.ca", systemImage: "envelope") } }
                }
                Section {
                    NavigationLink { DataView() } label: { Label("Your Data", systemImage: "lock") }
                } footer: {
                    Text("Student prototype. Not affiliated with or endorsed by the University of Ottawa.")
                }
            }
            .navigationTitle("My Plan")
            .navigationDestination(for: Service.self) { ServiceDetail(service: $0) }
        }
    }

    @ViewBuilder
    private func row(_ item: PlanItem) -> some View {
        if let service = Catalog.service(item.serviceID) {
            HStack(spacing: 12) {
                Button { ctx.toggleDone(item.serviceID) } label: {
                    Image(systemName: item.doneAt == nil ? "circle" : "checkmark.circle.fill")
                        .font(.title2)
                        .foregroundStyle(item.doneAt == nil ? Color.secondary : Color.green)
                }
                .buttonStyle(.plain)
                .accessibilityLabel(item.doneAt == nil ? "Mark \(service.title) as done" : "Mark \(service.title) as not done")
                NavigationLink(value: service) {
                    Text(service.title).strikethrough(item.doneAt != nil)
                }
            }
            .swipeActions {
                Button("Remove", role: .destructive) { ctx.removeFromPlan(item.serviceID) }
            }
        }
    }
}

struct DataView: View {
    @Environment(\.modelContext) private var ctx
    @Environment(\.dismiss) private var dismiss
    @Query private var plan: [PlanItem]
    @AppStorage("onboarded") private var onboarded = true
    @State private var confirming = false

    var body: some View {
        List {
            Section {
                LabeledContent("Saved items", value: "\(plan.count)")
                LabeledContent("serviceID", value: "Which service")
                LabeledContent("source", value: "Where you added it")
                LabeledContent("addedAt", value: "Date added")
                LabeledContent("doneAt", value: "Date finished")
            } header: {
                Text("Stored on This Phone")
            } footer: {
                Text("One local table, encrypted by iOS while the phone is locked, and left out of backups.")
            }
            Section("Never Collected") {
                Label("Name, email or student number", systemImage: "person.slash")
                Label("Library account or password", systemImage: "key.slash")
                Label("Location or analytics", systemImage: "location.slash")
                Label("Chat history", systemImage: "bubble.left.and.exclamationmark.bubble.right")
            }
            Section {
                Text(Guide.onlineConfigured
                     ? "Only the questions you type in Ask, when Online AI is on. They go to DeepSeek with emails, phone numbers and ID numbers removed first. Official pages you open follow the Library's own privacy notice."
                     : "Nothing from this app. Official pages you open follow the Library's own privacy notice.")
                    .font(.subheadline)
            } header: {
                Text("What Leaves This Phone")
            }
            Section {
                Button("Erase Everything", role: .destructive) { confirming = true }
            }
        }
        .navigationTitle("Your Data")
        .navigationBarTitleDisplayMode(.inline)
        .confirmationDialog("Erase your plan from this phone?", isPresented: $confirming, titleVisibility: .visible) {
            Button("Erase Everything", role: .destructive) {
                ctx.eraseEverything()
                onboarded = false
                dismiss()
            }
        } message: {
            Text("This can't be undone.")
        }
    }
}
