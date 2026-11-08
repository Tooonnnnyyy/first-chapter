import SwiftUI
import SwiftData
import UIKit

@main
struct FirstChapterApp: App {
    let container = Store.makeContainer()

    init() {
        ApmFonts.register()
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .tint(Color.apmInk)
        }
        .modelContainer(container)
    }
}

struct RootView: View {
    @AppStorage("onboarded") private var onboarded = false

    var body: some View {
        if onboarded {
            MainTabs()
        } else {
            OnboardingView { onboarded = true }
                .preferredColorScheme(.light)
        }
    }
}

enum AppTab: Int, CaseIterable, Identifiable {
    case find, borrow, ask, plan
    var id: Int { rawValue }
    var title: String {
        switch self { case .find: "Find"; case .borrow: "Borrow"; case .ask: "Ask"; case .plan: "My Plan" }
    }
    var symbol: String {
        switch self {
        case .find: "magnifyingglass"
        case .borrow: "camera"
        case .ask: "bubble.left.and.text.bubble.right"
        case .plan: "checklist"
        }
    }
    var tint: ApmTint {
        switch self { case .find: .lime; case .borrow: .cobalt; case .ask: .violet; case .plan: .flame }
    }
}

/// Four tabs, each keeping its own navigation. The bar is drawn here because the
/// system bar is glass (a blur), which the style rules out.
struct MainTabs: View {
    @Query private var plan: [PlanItem]
    @State private var tab = AppTab.find
    @State private var deckOpen = false
    @State private var keyboardUp = false
    @State private var dialogs = ApmDialogs()
    @Environment(\.accessibilityReduceMotion) private var calm

    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                ForEach(AppTab.allCases) { item in
                    page(item)
                        .environment(\.apmTint, item.tint)
                        .opacity(item == tab ? 1 : 0)
                        .allowsHitTesting(item == tab)
                        .accessibilityHidden(item != tab)
                }
            }
            // The deck shows its own feedback above this screen. Here it rises above the tab
            // bar, clear of the chapter label in each header (the toast once covered it).
            .xpFeedback(xp: PlanScore.xp(plan), enabled: !deckOpen, top: 18, atBottom: true,
                        shadow: .apmFlame)
            // A plain stack, not a safe-area inset: insets don't reach into NavigationStack content.
            if !keyboardUp { ApmTabBar(selection: $tab) }
        }
        .environment(dialogs)
        .accessibilityHidden(dialogs.current != nil)
        // Dialogs sit above the tab bar, like the system alert they replace.
        .overlay {
            if let dialog = dialogs.current {
                ApmDialogView(model: dialog) { dialogs.current = nil }
                    .transition(.opacity)
            }
        }
        .animation(calm ? nil : ApmMotion.snap(0.25), value: dialogs.current?.id)
        // The app's colors are fixed, so the scheme only steers system chrome. A dark scheme
        // under the cobalt band turns the status bar bone (4.74:1) instead of ink (3.90:1).
        .preferredColorScheme(tab.tint.ink == .apmBone ? .dark : .light)
        // All four tabs stay mounted, so a field left focused on a hidden tab (Ask) kept the
        // keystrokes and blocked the next tab's search field. End editing on every switch.
        .onChange(of: tab) {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)) { _ in
            keyboardUp = true
        }
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)) { _ in
            keyboardUp = false
        }
    }

    @ViewBuilder
    private func page(_ item: AppTab) -> some View {
        switch item {
        case .find: FindView(showDeck: $deckOpen)
        case .borrow: BorrowView()
        case .ask: AskView()
        case .plan: PlanView()
        }
    }
}

struct ApmTabBar: View {
    @Binding var selection: AppTab

    var body: some View {
        HStack(spacing: 0) {
            ForEach(AppTab.allCases) { item in
                let on = item == selection
                Button { selection = item } label: {
                    VStack(spacing: 5) {
                        Image(systemName: item.symbol)
                            .font(.system(size: 19, weight: on ? .medium : .regular))
                            .frame(height: 22)
                        Text(item.title).apmText(.tag).lineLimit(1).minimumScaleFactor(0.8)
                    }
                    .foregroundStyle(on ? item.tint.ink : Color.apmInk)
                    .frame(maxWidth: .infinity, minHeight: 56)
                    .background(on ? item.tint.fill : Color.clear, ignoresSafeAreaEdges: [])
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel(item.title)
                .accessibilityAddTraits(on ? .isSelected : [])
                .sensoryFeedback(.selection, trigger: on) { _, now in now }
                if item != AppTab.allCases.last {
                    Rectangle().fill(Color.apmInk).frame(width: 2).accessibilityHidden(true)
                }
            }
        }
        .fixedSize(horizontal: false, vertical: true)
        .overlay(alignment: .top) { ApmRule() }
        .background(Color.apmBone.ignoresSafeArea(edges: .bottom))
    }
}
