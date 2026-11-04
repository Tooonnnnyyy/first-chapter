import SwiftUI
import SwiftData

@main
struct FirstChapterApp: App {
    let container = Store.makeContainer()
    var body: some Scene {
        WindowGroup {
            RootView()
                .preferredColorScheme(.light)
                .tint(Color.dsAccent)
        }
        .modelContainer(container)
    }
}

struct RootView: View {
    @AppStorage("onboarded") private var onboarded = false
    var body: some View {
        if onboarded {
            TabView {
                FindView().tabItem { Label("Find", systemImage: "magnifyingglass") }
                BorrowView().tabItem { Label("Borrow", systemImage: "camera") }
                AskView().tabItem { Label("Ask", systemImage: "sparkles") }
                MeView().tabItem { Label("Me", systemImage: "person.crop.circle") }
            }
        } else {
            OnboardingView { onboarded = true }
        }
    }
}
