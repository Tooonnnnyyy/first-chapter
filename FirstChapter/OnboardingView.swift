import SwiftUI
import SwiftData

struct OnboardingView: View {
    let onDone: () -> Void
    @State private var started = false
    var body: some View {
        if started {
            SwipeDeck(onDone: onDone)
        } else {
            VStack(alignment: .leading, spacing: 16) {
                Wordmark()
                Spacer()
                Text("The Library does more than you think.")
                    .font(.system(size: 34, weight: .bold))
                    .foregroundStyle(Color.dsText)
                Text("Cameras. Podcast studios. Study rooms. Librarians who know your subject. Find any of it in one tap.")
                    .font(.system(size: 16))
                    .foregroundStyle(Color.dsMuted)
                VStack(alignment: .leading, spacing: 8) {
                    Label("No login, no student number", systemImage: "lock.fill")
                    Label("Everything stays on this phone", systemImage: "iphone")
                }
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(Color.dsSuccess)
                Spacer()
                Button("Show me, 30 seconds") { withAnimation { started = true } }
                    .buttonStyle(PrimaryButton())
            }
            .padding(24)
            .background(Color.dsBg)
        }
    }
}

struct SwipeDeck: View {
    let onDone: () -> Void
    @Environment(\.modelContext) private var ctx
    @State private var index = 0
    @State private var drag: CGSize = .zero
    private let cards = Catalog.services

    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Wordmark()
                Spacer()
                Button("Skip") { onDone() }.font(.system(size: 14)).foregroundStyle(Color.dsMuted)
            }
            ProgressView(value: Double(index), total: Double(cards.count)).tint(Color.dsAccent)
            Text("Did you know? Swipe right if you'd use it.")
                .font(.system(size: 14)).foregroundStyle(Color.dsMuted)
            ZStack {
                if index + 1 < cards.count {
                    DeckCard(service: cards[index + 1]).scaleEffect(0.96).offset(y: 10)
                }
                if index < cards.count {
                    DeckCard(service: cards[index])
                        .id(index)
                        .overlay(alignment: drag.width > 0 ? .topLeading : .topTrailing) {
                            if abs(drag.width) > 30 {
                                Badge(text: drag.width > 0 ? "NEED IT" : "SKIP", tone: drag.width > 0 ? .success : .neutral).padding(16)
                            }
                        }
                        .offset(drag)
                        .rotationEffect(.degrees(Double(drag.width) / 22))
                        .gesture(DragGesture()
                            .onChanged { drag = $0.translation }
                            .onEnded { v in
                                if abs(v.translation.width) > 90 { decide(v.translation.width > 0) }
                                else { withAnimation(.easeOut(duration: 0.2)) { drag = .zero } }
                            })
                }
            }
            .frame(maxHeight: .infinity)
            HStack(spacing: 12) {
                Button("Not now") { decide(false) }.buttonStyle(SecondaryButton())
                Button("I need this") { decide(true) }.buttonStyle(PrimaryButton())
            }
        }
        .padding(DS.inset)
        .background(Color.dsBg)
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
        VStack(alignment: .leading, spacing: 16) {
            Image(systemName: service.icon)
                .font(.system(size: 44))
                .foregroundStyle(Color.dsAccent)
                .frame(width: 88, height: 88)
                .background(Color.dsAccentSoft)
                .clipShape(RoundedRectangle(cornerRadius: DS.radius2xl))
            Text(service.title).font(.system(size: 28, weight: .bold)).foregroundStyle(Color.dsText)
            Text(service.oneLiner).font(.system(size: 16)).foregroundStyle(Color.dsMuted)
            Spacer()
            Label(service.whereAt, systemImage: "mappin.and.ellipse")
                .font(.system(size: 14)).foregroundStyle(Color.dsMuted)
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .background(Color.dsSurface)
        .clipShape(RoundedRectangle(cornerRadius: DS.radius2xl))
        .overlay(RoundedRectangle(cornerRadius: DS.radius2xl).strokeBorder(Color.dsBorder))
    }
}
