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
    @FocusState private var typing: Bool
    @Environment(\.accessibilityReduceMotion) private var calm
    private let prompts = ["I need a camera for a class project", "How do I cite my sources?", "Where can my group study?", "How much does printing cost?"]

    var body: some View {
        NavigationStack {
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        header
                        VStack(alignment: .leading, spacing: 14) {
                            if lines.isEmpty {
                                ForEach(prompts, id: \.self) { prompt in
                                    Button(prompt) { send(prompt) }
                                        .buttonStyle(ApmPillStyle(kind: .ghost))
                                }
                                privacyNote.padding(.top, 10)
                            }
                            ForEach(lines) { line in bubble(line) }
                            if thinking {
                                HStack(spacing: 10) {
                                    ApmLiveDot()
                                    Text("Thinking").apmText(.eyebrow)
                                }
                                .padding(.vertical, 8)
                                .accessibilityElement(children: .combine)
                                .id("thinking")
                            }
                        }
                        .padding(ApmLayout.gutter)
                        .padding(.top, 8)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        // Scroll target below the last message, so it keeps its margin.
                        Color.clear.frame(height: 1).id("end")
                    }
                    .background(Color.apmPage)
                }
                .scrollDismissesKeyboard(.interactively)
                .onChange(of: lines.count) {
                    guard !lines.isEmpty else { return }
                    if calm { proxy.scrollTo("end", anchor: .bottom) }
                    else { withAnimation { proxy.scrollTo("end", anchor: .bottom) } }
                }
            }
            .safeAreaInset(edge: .bottom, spacing: 0) { composer }
            .apmRootChrome(.violet)
            .navigationDestination(for: Service.self) { ServiceDetail(service: $0) }
        }
    }

    private var header: some View {
        ApmBand(tint: .violet, top: 6, bottom: 28) {
            HStack(alignment: .top) {
                ApmHeaderTitle(text: "Ask")
                Spacer()
                if Guide.onlineConfigured {
                    Menu {
                        Toggle("Online AI (DeepSeek)", isOn: $useOnline)
                    } label: {
                        Image(systemName: useOnline ? "cloud" : "cloud.slash")
                            .font(.system(size: 18, weight: .regular))
                            .foregroundStyle(Color.apmInk)
                            .frame(width: 46, height: 46)
                            .background(Circle().fill(Color.apmBone))
                            .overlay(Circle().strokeBorder(Color.apmInk, lineWidth: 2))
                    }
                    .accessibilityLabel("Online AI setting")
                }
            }
        }
        .overlay(alignment: .bottomTrailing) {
            if !Guide.onlineConfigured {
                ApmBlob(fill: .apmMint, size: 110).offset(x: 30, y: 52)
            }
        }
        .clipped()
        // Redraw the band's rule over the blob, so the blob sits behind it.
        .overlay(alignment: .bottom) { ApmRule() }
    }

    private var privacyNote: some View {
        Text(Guide.onlineConfigured && useOnline
             ? "Questions go to DeepSeek to answer. Emails, phone numbers and ID numbers are removed first, and nothing is saved here. Turn this off with the cloud button."
             : "Answers come from this phone. Nothing is sent or saved.")
            .apmText(.small)
            .foregroundStyle(Color.apmInk.opacity(0.75))
            .fixedSize(horizontal: false, vertical: true)
    }

    private var composer: some View {
        HStack(spacing: 10) {
            TextField("Ask about the Library", text: $input,
                      prompt: Text("Ask about the Library").foregroundStyle(Color.apmInk.opacity(0.55)))
                .apmText(.body)
                .focused($typing)
                .submitLabel(.send)
                .onSubmit { send(input) }
                .padding(.horizontal, 14)
                .frame(minHeight: 48)
                .background(Color.apmBone)
                .overlay(Rectangle().strokeBorder(Color.apmInk, lineWidth: typing ? 3 : 2))
            let idle = input.trimmingCharacters(in: .whitespaces).isEmpty || thinking
            Button { send(input) } label: {
                // Disabled: a quiet outlined circle with no shadow, rather than a faded one.
                Image(systemName: "arrow.up")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(idle ? Color.apmInk.opacity(0.4) : Color.apmBone)
                    .frame(width: 48, height: 48)
                    .background(Circle().fill(idle ? Color.apmPaper : Color.apmInk))
                    .overlay(Circle().strokeBorder(Color.apmInk.opacity(idle ? 0.35 : 1), lineWidth: 2))
                    .background(Circle().fill(idle ? Color.clear : Color.apmFlame).offset(x: 3, y: 3))
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Send")
            .disabled(idle)
        }
        .foregroundStyle(Color.apmInk)
        .padding(.horizontal, ApmLayout.gutter)
        .padding(.vertical, 10)
        .background(Color.apmPage)
        .overlay(alignment: .top) { ApmRule() }
    }

    private func bubble(_ line: ChatLine) -> some View {
        VStack(alignment: line.fromStudent ? .trailing : .leading, spacing: 8) {
            Text(line.text)
                .apmText(.body)
                .foregroundStyle(line.fromStudent ? Color.apmBone : Color.apmInk)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(line.fromStudent ? Color.apmInk : Color.apmBone)
                .overlay(Rectangle().strokeBorder(Color.apmInk, lineWidth: 2))
                .background(Rectangle().fill(line.fromStudent ? Color.apmFlame : Color.apmInk).offset(x: 4, y: 4))
                .padding(.leading, line.fromStudent ? 44 : 0)
                .padding(.trailing, line.fromStudent ? 4 : 44)
            if let source = line.source {
                Text("Answered by \(source.rawValue)").apmText(.label)
                    .foregroundStyle(Color.apmInk.opacity(0.75))
                    .padding(.top, 2)
            }
            if let service = line.service {
                NavigationLink(value: service) {
                    ServiceRow(service: service)
                        .background(Color.apmPaper)
                        .overlay(Rectangle().strokeBorder(Color.apmInk, lineWidth: 2))
                }
                .buttonStyle(ApmCardPress(depth: 2))
                .padding(.trailing, 4)
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
