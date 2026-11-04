import SwiftUI
import SwiftData

struct OnboardingView: View {
    let onDone: () -> Void
    @State private var showDeck = false

    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            IconTile(symbol: "books.vertical.fill", color: .brand, size: 80)
            Text("Welcome to\nFirst Chapter")
                .font(.largeTitle.bold())
                .multilineTextAlignment(.center)
            VStack(alignment: .leading, spacing: 20) {
                feature("magnifyingglass", "Find it fast", "Study rooms, citation help, printing and more.")
                feature("camera", "Borrow gear", "Cameras, mics and tripods, and how to get them.")
                feature("lock", "No login", "Your plan stays on this phone.")
            }
            Spacer()
            VStack(spacing: 8) {
                Button { showDeck = true } label: {
                    Text("Show Me What's Here").frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                Button("Skip", action: onDone).controlSize(.large)
            }
        }
        .padding(24)
        .fullScreenCover(isPresented: $showDeck) {
            SwipeDeck {
                showDeck = false
                onDone()
            }
        }
    }

    private func feature(_ symbol: String, _ title: String, _ body: String) -> some View {
        HStack(alignment: .top, spacing: 16) {
            Image(systemName: symbol).font(.title2).foregroundStyle(Color.brand).frame(width: 32)
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.headline)
                Text(body).font(.subheadline).foregroundStyle(.secondary)
            }
        }
    }
}

/// You can't search for a service you don't know exists, so this brings them to you.
struct SwipeDeck: View {
    let onDone: () -> Void
    @Environment(\.modelContext) private var ctx
    @State private var index = 0
    @State private var drag: CGSize = .zero
    private let cards = Catalog.discover

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Text("Swipe right to add to your plan, left to skip.")
                    .font(.subheadline).foregroundStyle(.secondary)
                ZStack {
                    if index + 1 < cards.count {
                        DeckCard(service: cards[index + 1]).scaleEffect(0.95)
                    }
                    if index < cards.count {
                        DeckCard(service: cards[index])
                            .id(index)
                            .offset(drag)
                            .rotationEffect(.degrees(Double(drag.width) / 24))
                            .gesture(DragGesture()
                                .onChanged { drag = $0.translation }
                                .onEnded { value in
                                    if abs(value.translation.width) > 90 {
                                        decide(value.translation.width > 0)
                                    } else {
                                        withAnimation(.snappy) { drag = .zero }
                                    }
                                })
                    }
                }
                .frame(maxHeight: .infinity)
                HStack(spacing: 12) {
                    Button { decide(false) } label: { Text("Not Now").frame(maxWidth: .infinity) }
                        .buttonStyle(.bordered)
                    Button { decide(true) } label: { Text("Add to Plan").frame(maxWidth: .infinity) }
                        .buttonStyle(.borderedProminent)
                }
                .controlSize(.large)
            }
            .padding()
            .background(Color(.systemGroupedBackground))
            .navigationTitle("\(min(index + 1, cards.count)) of \(cards.count)")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) { Button("Done", action: onDone) }
            }
        }
    }

    private func decide(_ keep: Bool) {
        guard index < cards.count else { return }
        if keep { ctx.addToPlan(cards[index].id, source: "swipe") }
        withAnimation(.easeOut(duration: 0.25)) { drag = CGSize(width: keep ? 520 : -520, height: 0) }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            drag = .zero
            index += 1
            if index >= cards.count { onDone() }
        }
    }
}

struct DeckCard: View {
    let service: Service
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            IconTile(symbol: service.icon, color: service.color, size: 64)
            Text(service.title).font(.title.bold())
            Text(service.answer).font(.body).foregroundStyle(.secondary)
            Spacer()
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        .shadow(color: .black.opacity(0.08), radius: 12, y: 4)
    }
}
