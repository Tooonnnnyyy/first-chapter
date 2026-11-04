import SwiftUI
import SwiftData

@main
struct FirstChapterApp: App {
    let container = Store.makeContainer()
    var body: some Scene {
        WindowGroup {
            RootView().tint(Color.brand)
        }
        .modelContainer(container)
    }
}

struct RootView: View {
    @AppStorage("onboarded") private var onboarded = false
    /// Screenshot helper: DEMO_TAB=0...3 opens that tab, 9 opens Your Data.
    @State private var demo = Int(ProcessInfo.processInfo.environment["DEMO_TAB"] ?? "") ?? -1
    @State private var sel = 0

    var body: some View {
        Group {
            if demo == 9 {
                NavigationStack { DataView() }
            } else {
                TabView(selection: $sel) {
                    Tab("Find", systemImage: "magnifyingglass", value: 0) { FindView() }
                    Tab("Borrow", systemImage: "camera", value: 1) { BorrowView() }
                    Tab("Ask", systemImage: "bubble.left.and.text.bubble.right", value: 2) { AskView() }
                    Tab("My Plan", systemImage: "checklist", value: 3) { PlanView() }
                }
            }
        }
        .onAppear { if (0...3).contains(demo) { sel = demo } }
        .overlay { if !onboarded { OnboardingView { onboarded = true } } }
    }
}
