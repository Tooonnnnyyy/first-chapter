import SwiftUI

struct ChatLine: Identifiable {
    let id = UUID()
    let fromStudent: Bool
    let text: String
    var service: Service? = nil
    var source: Guide.Source? = nil
}

/// Messages live in memory only and are never saved.
struct AskView: View {
    @AppStorage("useOnlineAI") private var useOnline = true
    @State private var lines: [ChatLine] = []
    @State private var input = ""
    @State private var thinking = false
    private let prompts = ["I need a camera for a class project", "How do I cite my sources?", "Where can my group study?", "How much does printing cost?"]

    var body: some View {
        NavigationStack {
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(alignment: .leading, spacing: 12) {
                        if lines.isEmpty {
                            ForEach(prompts, id: \.self) { prompt in
                                Button(prompt) { send(prompt) }.buttonStyle(.bordered)
                            }
                            privacyNote.padding(.top, 8)
                        }
                        ForEach(lines) { line in bubble(line) }
                        if thinking {
                            ProgressView().padding(8).id("thinking")
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .onChange(of: lines.count) {
                    if let last = lines.last { withAnimation { proxy.scrollTo(last.id, anchor: .bottom) } }
                }
            }
            .safeAreaInset(edge: .bottom) { composer }
            .navigationTitle("Ask")
            .navigationDestination(for: Service.self) { ServiceDetail(service: $0) }
            .toolbar {
                if Guide.onlineConfigured {
                    ToolbarItem(placement: .topBarTrailing) {
                        Menu {
                            Toggle("Online AI (DeepSeek)", isOn: $useOnline)
                        } label: {
                            Image(systemName: useOnline ? "cloud" : "cloud.slash")
                        }
                        .accessibilityLabel("Online AI setting")
                    }
                }
            }
        }
    }

    private var privacyNote: some View {
        Text(Guide.onlineConfigured && useOnline
             ? "Questions go to DeepSeek to answer. Emails, phone numbers and ID numbers are removed first, and nothing is saved here. Turn this off with the cloud button."
             : "Answers come from this phone. Nothing is sent or saved.")
            .font(.footnote)
            .foregroundStyle(.secondary)
    }

    private var composer: some View {
        HStack(spacing: 8) {
            TextField("Ask about the Library", text: $input)
                .textFieldStyle(.roundedBorder)
                .onSubmit { send(input) }
            Button { send(input) } label: { Image(systemName: "arrow.up") }
                .buttonStyle(.borderedProminent)
                .accessibilityLabel("Send")
                .disabled(input.trimmingCharacters(in: .whitespaces).isEmpty || thinking)
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(.bar)
    }

    private func bubble(_ line: ChatLine) -> some View {
        VStack(alignment: line.fromStudent ? .trailing : .leading, spacing: 6) {
            Text(line.text)
                .foregroundStyle(line.fromStudent ? Color.white : Color.primary)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(line.fromStudent ? Color.brand : Color(.secondarySystemBackground),
                            in: RoundedRectangle(cornerRadius: 16, style: .continuous))
            if let source = line.source {
                Text("Answered by \(source.rawValue)").font(.caption).foregroundStyle(.secondary)
            }
            if let service = line.service {
                NavigationLink(value: service) {
                    HStack {
                        ServiceRow(service: service)
                        Spacer(minLength: 0)
                        Image(systemName: "chevron.right").font(.footnote.weight(.semibold)).foregroundStyle(.tertiary)
                    }
                    .padding(10)
                    .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                }
                .buttonStyle(.plain)
            }
        }
        .frame(maxWidth: .infinity, alignment: line.fromStudent ? .trailing : .leading)
        .id(line.id)
    }

    private func send(_ text: String) {
        let question = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !question.isEmpty, !thinking else { return }
        lines.append(ChatLine(fromStudent: true, text: question))
        input = ""
        thinking = true
        let online = useOnline
        Task {
            let reply = await Guide.answer(question, online: online)
            await MainActor.run {
                lines.append(ChatLine(fromStudent: false, text: reply.text, service: reply.service, source: reply.source))
                thinking = false
            }
        }
    }
}
