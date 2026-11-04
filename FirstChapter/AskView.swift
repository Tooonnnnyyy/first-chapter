import SwiftUI

struct ChatLine: Identifiable {
    let id = UUID()
    let fromStudent: Bool
    let text: String
    var service: Service? = nil
}

/// Messages live in memory only. Nothing is saved or sent.
struct AskView: View {
    @State private var lines: [ChatLine] = []
    @State private var input = ""
    @State private var thinking = false
    private let prompts = ["I need a camera for a class project", "My paper is due Friday and I don't know APA", "Where can my group study?"]

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                ScrollView {
                    VStack(alignment: .leading, spacing: 12) {
                        Badge(text: Guide.modelAvailable ? "ON-DEVICE AI · NOTHING LEAVES THIS PHONE" : "ON-DEVICE SEARCH · NOTHING LEAVES THIS PHONE",
                              tone: .success)
                        if lines.isEmpty {
                            Text("Ask anything about the Library").font(.system(size: 24, weight: .bold)).foregroundStyle(Color.dsText)
                            ForEach(prompts, id: \.self) { p in
                                Button { send(p) } label: {
                                    Text(p).font(.system(size: 14)).foregroundStyle(Color.dsText)
                                        .frame(maxWidth: .infinity, alignment: .leading).padding(12).card()
                                }
                            }
                        }
                        ForEach(lines) { line in
                            VStack(alignment: line.fromStudent ? .trailing : .leading, spacing: 8) {
                                Text(line.text)
                                    .font(.system(size: 15))
                                    .foregroundStyle(line.fromStudent ? Color.white : Color.dsText)
                                    .padding(12)
                                    .background(line.fromStudent ? Color.dsAccent : Color.dsSurface)
                                    .clipShape(RoundedRectangle(cornerRadius: DS.radiusLg))
                                    .overlay(RoundedRectangle(cornerRadius: DS.radiusLg).strokeBorder(line.fromStudent ? Color.clear : Color.dsBorder))
                                if let s = line.service {
                                    NavigationLink(value: s) { ServiceRow(service: s) }
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: line.fromStudent ? .trailing : .leading)
                        }
                        if thinking {
                            ProgressView().padding(8)
                        }
                    }
                    .padding(DS.inset)
                }
                HStack(spacing: 8) {
                    TextField("Ask…", text: $input)
                        .padding(12).card()
                        .onSubmit { send(input) }
                    Button { send(input) } label: {
                        Image(systemName: "arrow.up").foregroundStyle(.white).frame(width: 44, height: 44)
                            .background(Color.dsAccent).clipShape(RoundedRectangle(cornerRadius: DS.radiusMd))
                    }
                    .accessibilityLabel("Send")
                    .disabled(input.trimmingCharacters(in: .whitespaces).isEmpty)
                }
                .padding(DS.inset)
            }
            .background(Color.dsBg)
            .toolbar { ToolbarItem(placement: .topBarLeading) { Wordmark() } }
            .navigationDestination(for: Service.self) { ServiceDetail(service: $0) }
        }
    }

    private func send(_ text: String) {
        let q = text.trimmingCharacters(in: .whitespaces)
        guard !q.isEmpty, !thinking else { return }
        lines.append(ChatLine(fromStudent: true, text: q))
        input = ""
        thinking = true
        Task {
            let reply = await Guide.answer(q)
            await MainActor.run {
                lines.append(ChatLine(fromStudent: false, text: reply.text, service: reply.service))
                thinking = false
            }
        }
    }
}
