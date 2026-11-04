import SwiftUI
import SafariServices
import UIKit

/// Design system: Apple Human Interface Guidelines. Native components, system
/// colors and Dynamic Type throughout. The only custom values are the app tint
/// and the Settings-style icon tile below.
extension Color {
    static let brand = Color(UIColor { trait in
        trait.userInterfaceStyle == .dark
            ? UIColor(red: 0.96, green: 0.45, blue: 0.48, alpha: 1)
            : UIColor(red: 0.56, green: 0.00, blue: 0.10, alpha: 1)
    })
}

struct IconTile: View {
    let symbol: String
    let color: Color
    var size: CGFloat = 30
    var body: some View {
        Image(systemName: symbol)
            .font(.system(size: size * 0.52, weight: .medium))
            .foregroundStyle(.white)
            .frame(width: size, height: size)
            .background(color.gradient, in: RoundedRectangle(cornerRadius: size * 0.225, style: .continuous))
            .accessibilityHidden(true)
    }
}

struct SafariView: UIViewControllerRepresentable {
    let url: URL
    func makeUIViewController(context: Context) -> SFSafariViewController { SFSafariViewController(url: url) }
    func updateUIViewController(_ controller: SFSafariViewController, context: Context) {}
}

/// Opens an official Library page inside the app, so students don't lose their place.
struct WebLink<Content: View>: View {
    let url: String
    @ViewBuilder let content: () -> Content
    @State private var showing = false
    var body: some View {
        Button { showing = true } label: { content().contentShape(Rectangle()) }
            .buttonStyle(.plain)
            .sheet(isPresented: $showing) {
                if let target = URL(string: url) { SafariView(url: target).ignoresSafeArea() }
            }
    }
}

struct ServiceRow: View {
    let service: Service
    var body: some View {
        HStack(spacing: 12) {
            IconTile(symbol: service.icon, color: service.color)
            VStack(alignment: .leading, spacing: 2) {
                Text(service.title).font(.body).foregroundStyle(.primary)
                Text(service.answer).font(.subheadline).foregroundStyle(.secondary)
                    .multilineTextAlignment(.leading)
            }
        }
        .padding(.vertical, 2)
    }
}

/// The app's one showpiece: a sunset mesh, deep enough for white text.
struct FancyBackground: View {
    var body: some View {
        MeshGradient(width: 3, height: 3, points: [
            .init(0, 0), .init(0.5, 0), .init(1, 0),
            .init(0, 0.5), .init(0.55, 0.45), .init(1, 0.5),
            .init(0, 1), .init(0.5, 1), .init(1, 1),
        ], colors: [
            Color(red: 0.56, green: 0.00, blue: 0.10), Color(red: 0.80, green: 0.08, blue: 0.40), Color(red: 0.90, green: 0.30, blue: 0.15),
            Color(red: 0.70, green: 0.05, blue: 0.35), Color(red: 0.55, green: 0.12, blue: 0.70), Color(red: 0.80, green: 0.15, blue: 0.40),
            Color(red: 0.25, green: 0.18, blue: 0.70), Color(red: 0.42, green: 0.15, blue: 0.85), Color(red: 0.60, green: 0.05, blue: 0.45),
        ])
    }
}
