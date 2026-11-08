import SwiftUI
import UIKit

/// Bridges the plan to the pure rules in Game.swift.
enum PlanScore {
    static var catalogIDs: [String] { Catalog.services.map(\.id) }

    static func entries(_ plan: [PlanItem]) -> [Game.Entry] {
        plan.map { Game.Entry(serviceID: $0.serviceID, done: $0.doneAt != nil) }
    }

    static func xp(_ plan: [PlanItem]) -> Int {
        Game.xp(entries(plan), catalog: Set(catalogIDs))
    }

    static func progress(_ plan: [PlanItem]) -> Game.Progress {
        Game.progress(xp: xp(plan))
    }
}

// MARK: - XP bar

/// Current chapter, XP, and XP to the next chapter.
struct XPBar: View {
    let progress: Game.Progress
    var fill: Color = .apmFlame
    @Environment(\.accessibilityReduceMotion) private var calm

    private var nextLine: String {
        guard let next = progress.next else { return "Last chapter reached" }
        return "\(progress.toNext) XP to Chapter \(next.number) · \(next.name)"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Text(progress.chapter.title).apmText(.eyebrow)
                Spacer(minLength: 8)
                Text("\(progress.xp) XP").apmText(.button)
                    .contentTransition(calm ? .identity : .numericText(value: Double(progress.xp)))
            }
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Rectangle().fill(Color.apmBone)
                    Rectangle().fill(fill)
                        .frame(width: geo.size.width * progress.fraction)
                        .overlay(alignment: .trailing) {
                            if progress.fraction > 0 && progress.fraction < 1 {
                                Rectangle().fill(Color.apmInk).frame(width: 2)
                            }
                        }
                }
            }
            .frame(height: 16)
            .overlay(Rectangle().strokeBorder(Color.apmInk, lineWidth: 2))
            .animation(calm ? nil : ApmMotion.snap(0.6), value: progress.fraction)
            Text(nextLine).apmText(.label)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(progress.chapter.title), \(progress.xp) XP")
        .accessibilityValue(nextLine)
    }
}

// MARK: - Quest pieces

/// "+50 XP" for an open quest, "Done +50" for a finished one.
struct RewardPill: View {
    let done: Bool
    var body: some View {
        if done {
            ApmTag(text: "Done +\(Game.questXP)", fill: .apmInk, ink: .apmLime)
        } else {
            ApmTag(text: "+\(Game.questXP) XP", fill: .apmLime, ink: .apmInk)
        }
    }
}

/// One stamp per catalog service, inked when that service is done.
struct StampCollection: View {
    let filled: Set<String>
    private let inks: [Color] = [.apmLime, .apmViolet, .apmMint, .apmFlame]
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 8), count: 5)

    var body: some View {
        LazyVGrid(columns: columns, spacing: 14) {
            ForEach(Array(Catalog.services.enumerated()), id: \.element.id) { index, service in
                stamp(service, index: index)
            }
        }
    }

    private func stamp(_ service: Service, index: Int) -> some View {
        let on = filled.contains(service.id)
        let tilt = Double((index % 3) - 1) * 6
        return ZStack {
            if on {
                Circle().fill(inks[index % inks.count])
                Circle().strokeBorder(Color.apmInk, lineWidth: 2)
            } else {
                Circle().strokeBorder(Color.apmInk.opacity(0.35), style: StrokeStyle(lineWidth: 2, dash: [4, 4]))
            }
            Image(systemName: service.icon)
                .font(.system(size: 19, weight: .regular))
                .foregroundStyle(Color.apmInk.opacity(on ? 1 : 0.3))
        }
        .frame(width: 54, height: 54)
        .rotationEffect(.degrees(on ? tilt : 0))
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(service.title)
        .accessibilityValue(on ? "Stamp collected" : "No stamp yet")
    }
}

// MARK: - Feedback

private struct XPToast: View {
    let gain: Int
    var shadow: Color = .apmFlame
    var body: some View {
        Text("+\(gain) XP")
            .apmText(.button)
            .foregroundStyle(Color.apmLime)
            .padding(.horizontal, 18)
            .padding(.vertical, 10)
            .background(Capsule().fill(Color.apmInk))
            .overlay(Capsule().strokeBorder(Color.apmInk, lineWidth: 2))
            .background(Capsule().fill(shadow).offset(x: 4, y: 4))
    }
}

private struct LevelUpBanner: View {
    let chapter: Game.Chapter
    var body: some View {
        // A small fixed tilt, like a stamped note. It never animates.
        ApmCard(fill: .apmBone, tilt: -1.5, shadowOffset: 6, padding: 14) {
            HStack(spacing: 14) {
                Text("\(chapter.number)")
                    .apmText(.numeral)
                    .frame(width: 46, height: 46)
                    .background(Circle().fill(Color.apmLime))
                    .overlay(Circle().strokeBorder(Color.apmInk, lineWidth: 2))
                VStack(alignment: .leading, spacing: 2) {
                    Text("Level up").apmText(.tag)
                    Text("Chapter \(chapter.number) unlocked · \(chapter.name)").apmText(.title)
                        .fixedSize(horizontal: false, vertical: true)
                }
                Spacer(minLength: 0)
            }
        }
    }
}

/// Shows "+N XP" when the plan's XP goes up, and a banner when a chapter opens.
/// XP that goes down (remove, undo, erase) shows nothing.
private struct XPFeedback: ViewModifier {
    let xp: Int
    let enabled: Bool
    let top: CGFloat
    let atBottom: Bool
    let shadow: Color
    @Environment(\.accessibilityReduceMotion) private var calm
    @State private var gain: Int?
    @State private var unlocked: Game.Chapter?
    @State private var gains = 0
    @State private var levels = 0
    @State private var hideGain: Task<Void, Never>?
    @State private var hideLevel: Task<Void, Never>?

    func body(content: Content) -> some View {
        content
            .overlay(alignment: atBottom ? .bottom : .top) {
                VStack(spacing: 12) {
                    if let unlocked {
                        LevelUpBanner(chapter: unlocked)
                            .padding(.horizontal, ApmLayout.gutter)
                            .onTapGesture { withMotion { self.unlocked = nil } }
                            .transition(calm ? .identity : .move(edge: atBottom ? .bottom : .top).combined(with: .opacity))
                    }
                    if let gain {
                        XPToast(gain: gain, shadow: shadow)
                            .allowsHitTesting(false)
                            .transition(calm ? .identity : .scale(scale: 0.6).combined(with: .opacity))
                    }
                }
                .padding(atBottom ? .bottom : .top, top)
                .accessibilityHidden(true)
            }
            .onChange(of: xp) { old, new in
                guard enabled, new > old else { return }
                show(gain: new - old, chapter: Game.unlocked(from: old, to: new))
            }
            .sensoryFeedback(.impact(weight: .light), trigger: gains)
            .sensoryFeedback(.success, trigger: levels)
    }

    private func withMotion(_ change: () -> Void) {
        if calm { change() } else { withAnimation(ApmMotion.snap(0.35), change) }
    }

    private func show(gain amount: Int, chapter: Game.Chapter?) {
        var spoken = "Plus \(amount) XP."
        withMotion { gain = amount }
        gains += 1
        hideGain?.cancel()
        hideGain = Task { @MainActor in
            try? await Task.sleep(for: .seconds(1.8))
            guard !Task.isCancelled else { return }
            withMotion { gain = nil }
        }
        if let chapter {
            spoken += " Chapter \(chapter.number) unlocked, \(chapter.name)."
            withMotion { unlocked = chapter }
            levels += 1
            hideLevel?.cancel()
            hideLevel = Task { @MainActor in
                try? await Task.sleep(for: .seconds(3.5))
                guard !Task.isCancelled else { return }
                withMotion { unlocked = nil }
            }
        }
        UIAccessibility.post(notification: .announcement, argument: spoken)
    }
}

extension View {
    /// `top` moves the toast below a screen's own header, such as the deck's progress meter.
    /// With `atBottom` the feedback rises from the bottom edge instead and `top` is the gap
    /// above it: the tabs use this so it sits above the tab bar, clear of every header's
    /// chapter label and of a pushed screen's back and share buttons, as on the web.
    /// Pass a lime `shadow` over a flame band, where the toast's flame shadow would vanish.
    func xpFeedback(xp: Int, enabled: Bool = true, top: CGFloat = 58, atBottom: Bool = false, shadow: Color = .apmFlame) -> some View {
        modifier(XPFeedback(xp: xp, enabled: enabled, top: top, atBottom: atBottom, shadow: shadow))
    }
}
