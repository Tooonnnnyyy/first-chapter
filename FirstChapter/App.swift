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

    var body: some View {
        if onboarded {
            TabView {
                Tab("Find", systemImage: "magnifyingglass") { FindView() }
                Tab("Borrow", systemImage: "camera") { BorrowView() }
                Tab("Ask", systemImage: "bubble.left.and.text.bubble.right") { AskView() }
                Tab("My Plan", systemImage: "checklist") { PlanView() }
            }
        } else {
            OnboardingView { onboarded = true }
        }
    }
}
