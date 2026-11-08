import SwiftUI
import SwiftData

struct OnboardingView: View {
    let onDone: () -> Void
    @State private var showDeck = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                ApmBand(tint: .lime, top: 24, bottom: 30) {
                    ApmHeaderTitle(text: "Welcome to\nFirst Chapter")
                    ApmNote(tag: "Chapter 1", title: "New Reader", fill: .apmViolet, tilt: 4, width: 170)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        .padding(.top, 26)
                        .padding(.trailing, 10)
                        .accessibilityLabel("You start at Chapter 1, New Reader")
                }
                .overlay(alignment: .bottomLeading) {
                    ApmBlob(fill: .apmFlame, size: 130).offset(x: -46, y: 58)
                }
                .clipped()
                // Redraw the band's rule over the blob, so the blob sits behind it.
                .overlay(alignment: .bottom) { ApmRule() }

                feature("magnifyingglass", "Find it fast", "Study rooms, citation help, printing and more.")
                feature("camera", "Borrow gear", "Cameras, mics and tripods, and how to get them.")
                feature("lock", "No login", "Your plan stays on this phone.", last: true)
            }
        }
        .scrollBounceBehavior(.basedOnSize)
        .safeAreaInset(edge: .top, spacing: 0) {
            Color.clear.frame(height: 0).background(Color.apmLime)
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            VStack(spacing: 12) {
                Button("Show Me What's Here") { showDeck = true }
                    .buttonStyle(ApmPillStyle(fullWidth: true))
                Button("Skip", action: onDone)
                    .buttonStyle(ApmPillStyle(kind: .ghost, fullWidth: true))
            }
            .padding(.horizontal, ApmLayout.gutter)
            .padding(.top, 16)
            .padding(.bottom, 8)
            .background(Color.apmPage)
            .overlay(alignment: .top) { ApmRule() }
        }
        .scrollEdgeEffectHidden(true, for: .all)
        .background {
            VStack(spacing: 0) { Color.apmLime; Color.apmPage }.ignoresSafeArea()
        }
        .fullScreenCover(isPresented: $showDeck) {
            SwipeDeck {
                showDeck = false
                onDone()
            }
        }
    }

    /// The last row has no rule of its own: the button bar below draws one.
    private func feature(_ symbol: String, _ title: String, _ body: String, last: Bool = false) -> some View {
        HStack(alignment: .top, spacing: 16) {
            Image(systemName: symbol)
                .font(.system(size: 22, weight: .regular))
                .frame(width: 30)
                .padding(.top, 2)
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 4) {
                Text(title).apmText(.h4)
                Text(body).apmText(.body)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer(minLength: 0)
        }
        .foregroundStyle(Color.apmInk)
        .padding(.horizontal, ApmLayout.gutter)
        .padding(.vertical, 18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.apmPage)
        .overlay(alignment: .bottom) { if !last { ApmRule() } }
        .accessibilityElement(children: .combine)
    }
}

/// You can't search for a service you don't know exists, so this brings them to you.
struct SwipeDeck: View {
    let onDone: () -> Void
    @Environment(\.modelContext) private var ctx
    @Environment(\.accessibilityReduceMotion) private var calm
    @Query private var plan: [PlanItem]
    @State private var index = 0
    @State private var drag: CGSize = .zero
    @State private var moving = false
    @State private var startXP: Int?
    @State private var savedBefore: Set<String> = []
    @State private var added = 0
    private let cards = Catalog.discover
    private static let tints: [(card: ApmTint, blob: Color)] = [
        (.violet, .apmLime), (.mint, .apmFlame), (.lime, .apmCobalt),
        (.cobalt, .apmLime), (.flame, .apmViolet), (.paper, .apmMint),
    ]

    private var xp: Int { PlanScore.xp(plan) }
    private var finished: Bool { index >= cards.count }

    var body: some View {
        VStack(spacing: 0) {
            header
            if finished {
                summary
            } else {
                deck
            }
        }
        .background(Color.apmPage)
        .xpFeedback(xp: xp, top: 112)
        .onAppear {
            guard startXP == nil else { return }
            startXP = xp
            savedBefore = Set(plan.map(\.serviceID))
        }
    }

    private var header: some View {
        ApmBand(tint: .lime, top: 8, bottom: 16) {
            HStack(alignment: .center, spacing: 12) {
                VStack(alignment: .leading, spacing: 10) {
                    Text(finished ? "Discovery done" : "Quest \(index + 1) of \(cards.count)")
                        .apmText(.eyebrow)
                        .accessibilityAddTraits(.isHeader)
                    HStack(spacing: 4) {
                        ForEach(cards.indices, id: \.self) { i in
                            Rectangle()
                                .fill(i < index ? Color.apmInk : (i == index ? Color.apmFlame : Color.apmBone))
                                .frame(height: 10)
                                .overlay(Rectangle().strokeBorder(Color.apmInk, lineWidth: 2))
                        }
                    }
                    .frame(maxWidth: 200)
                    .accessibilityHidden(true)
                }
                Spacer()
                Button("Done", action: onDone)
                    .buttonStyle(ApmPillStyle(kind: .ghost))
            }
            if !finished {
                Text("Swipe right to add to your plan, left to skip.")
                    .apmText(.small)
                    .padding(.top, 12)
            }
        }
        .background(Color.apmLime.ignoresSafeArea(edges: .top))
    }

    private var deck: some View {
        VStack(spacing: 18) {
            ZStack {
                if index + 1 < cards.count {
                    DeckCard(service: cards[index + 1], number: index + 2, tint: Self.tints[(index + 1) % Self.tints.count],
                             saved: saved(cards[index + 1].id))
                        // Tilted enough to read as the next card in the pile; at -2.5° and 95%
                        // only a hairline showed at two corners and looked like a glitch.
                        .scaleEffect(0.96)
                        .rotationEffect(.degrees(-3.5))
                        .accessibilityHidden(true)
                }
                DeckCard(service: cards[index], number: index + 1, tint: Self.tints[index % Self.tints.count],
                         saved: saved(cards[index].id))
                    .overlay(alignment: .topLeading) { swipeStamp }
                    .id(index)
                    .offset(drag)
                    .rotationEffect(.degrees(calm ? 0 : Double(drag.width) / 24))
                    .gesture(DragGesture()
                        .onChanged { drag = $0.translation }
                        .onEnded { value in
                            if abs(value.translation.width) > 90 {
                                decide(value.translation.width > 0)
                            } else if calm {
                                drag = .zero
                            } else {
                                withAnimation(.snappy) { drag = .zero }
                            }
                        })
                    .accessibilityAction(named: "Add to Plan") { decide(true) }
                    .accessibilityAction(named: "Not Now") { decide(false) }
            }
            .padding(.horizontal, ApmLayout.gutter + 4)
            .padding(.top, 22)
            .frame(maxHeight: .infinity)

            HStack(spacing: 12) {
                Button("Not Now") { decide(false) }
                    .buttonStyle(ApmPillStyle(kind: .mute, fullWidth: true))
                // The card above already shows the +10 XP reward; the label stays on one line.
                Button { decide(true) } label: { Text("Add to Plan").lineLimit(1) }
                .buttonStyle(ApmPillStyle(fullWidth: true))
            }
            .padding(.horizontal, ApmLayout.gutter)
            .padding(.bottom, 12)
        }
    }

    /// "Add" or "Skip" appears on the card as it is dragged.
    @ViewBuilder
    private var swipeStamp: some View {
        let amount = min(abs(drag.width) / 90, 1)
        if drag.width > 12 {
            ApmTag(text: saved(cards[index].id) ? "Keep" : "Add +\(Game.saveXP) XP", fill: .apmLime)
                .scaleEffect(1.25)
                .rotationEffect(.degrees(-8))
                .padding(28)
                .opacity(amount)
                .accessibilityHidden(true)
        } else if drag.width < -12 {
            ApmTag(text: "Skip", fill: .apmMute)
                .scaleEffect(1.25)
                .rotationEffect(.degrees(8))
                .padding(28)
                .frame(maxWidth: .infinity, alignment: .trailing)
                .opacity(amount)
                .accessibilityHidden(true)
        }
    }

    private var summary: some View {
        let earned = max(xp - (startXP ?? xp), 0)
        return ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                ApmCard(fill: .apmViolet, tilt: -1.5) {
                    Text("\(cards.count) of \(cards.count) quests seen · XP earned").apmText(.eyebrow)
                        .fixedSize(horizontal: false, vertical: true)
                    Text("+\(earned) XP").apmText(.hero)
                        .padding(.top, 10)
                    Text(added == 0
                         ? "Nothing added this time. Every service is still in Find."
                         : "You added \(added) \(added == 1 ? "service" : "services") to My Plan.")
                        .apmText(.lede)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.top, 10)
                }
                .accessibilityElement(children: .combine)
                XPBar(progress: Game.progress(xp: xp))
                if added > 0 {
                    Text("Mark one done in My Plan for +\(Game.doneXP) XP more.")
                        .apmText(.body)
                        .fixedSize(horizontal: false, vertical: true)
                }
                Button("Done", action: onDone)
                    .buttonStyle(ApmPillStyle(fullWidth: true))
                    .padding(.top, 6)
            }
            .foregroundStyle(Color.apmInk)
            .padding(ApmLayout.gutter)
            .padding(.top, 18)
        }
    }

    /// Saved before the deck opened, so a right swipe earns nothing.
    private func saved(_ id: String) -> Bool { savedBefore.contains(id) }

    private func decide(_ keep: Bool) {
        guard index < cards.count, !moving else { return }
        let id = cards[index].id
        if keep {
            if !plan.contains(where: { $0.serviceID == id }) { added += 1 }
            ctx.addToPlan(id, source: "swipe")
        }
        if calm {
            drag = .zero
            index += 1
            return
        }
        moving = true
        withAnimation(.easeOut(duration: 0.25)) { drag = CGSize(width: keep ? 520 : -520, height: 0) }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            drag = .zero
            index += 1
            moving = false
        }
    }
}

struct DeckCard: View {
    let service: Service
    let number: Int
    let tint: (card: ApmTint, blob: Color)
    /// Already in My Plan: swiping right again earns nothing, so the card says so.
    var saved = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text("Quest \(String(format: "%02d", number))").apmText(.tag)
                Spacer()
                ApmTag(text: saved ? "Already in My Plan" : "+\(Game.saveXP) XP", fill: .apmBone)
            }
            Image(systemName: service.icon)
                .font(.system(size: 34, weight: .regular))
                .padding(.top, 28)
                .accessibilityHidden(true)
            Text(service.title).apmText(.h2)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.top, 16)
            Text(service.answer).apmText(.lede)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.top, 12)
            Spacer(minLength: 0)
        }
        .foregroundStyle(tint.card.ink)
        .padding(22)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(alignment: .bottomTrailing) {
            ZStack(alignment: .bottomTrailing) {
                tint.card.fill
                ApmBlob(fill: tint.blob, size: 170).offset(x: 60, y: 56)
            }
            .clipped()
        }
        .overlay(Rectangle().strokeBorder(Color.apmInk, lineWidth: 2))
        .background(Rectangle().fill(Color.apmInk).offset(x: 7, y: 7))
        .accessibilityElement(children: .combine)
    }
}
