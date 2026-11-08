import SwiftUI
import SafariServices
import UIKit

/// Design system: the owner's apm-style (ApmStyle.swift). Flat palette bands, 2pt ink
/// rules, square corners, solid shadows, Manrope and DM Mono. Shared rows live here.

struct SafariView: UIViewControllerRepresentable {
    let url: URL
    func makeUIViewController(context: Context) -> SFSafariViewController {
        SFSafariViewController(url: url)
    }
    func updateUIViewController(_ controller: SFSafariViewController, context: Context) {}
}

/// Opens an official Library page inside the app, so students don't lose their place.
/// The caller picks the button style (a ruled row or a pill).
struct WebLink<Content: View>: View {
    let url: String
    @ViewBuilder let content: () -> Content
    @State private var showing = false
    var body: some View {
        Button { showing = true } label: { content().contentShape(Rectangle()) }
            .sheet(isPresented: $showing) {
                if let target = URL(string: url) {
                    SafariView(url: target).ignoresSafeArea().preferredColorScheme(.light)
                }
            }
    }
}

/// A list row: plain glyph, title, the answer itself, and a trailing arrow.
struct ServiceRow: View {
    let service: Service
    var trailing: ApmArrow.Kind? = .right
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            ApmIcon(symbol: service.icon)
                .padding(.top, 2)
            VStack(alignment: .leading, spacing: 4) {
                Text(service.title).apmText(.title)
                Text(service.answer).apmText(.small)
                    .foregroundStyle(Color.apmInk.opacity(0.78))
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer(minLength: 8)
            if let trailing { ApmArrow(kind: trailing).padding(.top, 2) }
        }
        .foregroundStyle(Color.apmInk)
        .padding(.horizontal, ApmLayout.gutter)
        .padding(.vertical, 14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityElement(children: .combine)
    }
}

/// Glyph, one line of text, trailing arrow, closed by a rule. For links and plain rows.
struct ApmLineRow: View {
    let symbol: String
    let title: String
    var detail: String? = nil
    var trailing: ApmArrow.Kind? = .right
    var body: some View {
        HStack(alignment: detail == nil ? .center : .top, spacing: 12) {
            ApmIcon(symbol: symbol, size: 18)
            VStack(alignment: .leading, spacing: 3) {
                Text(title).apmText(.title)
                if let detail {
                    Text(detail).apmText(.small).foregroundStyle(Color.apmInk.opacity(0.78))
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            Spacer(minLength: 8)
            if let trailing { ApmArrow(kind: trailing) }
        }
        .foregroundStyle(Color.apmInk)
        .padding(.horizontal, ApmLayout.gutter)
        .padding(.vertical, 14)
        .frame(maxWidth: .infinity, minHeight: 52, alignment: .leading)
        .overlay(alignment: .bottom) { ApmRule() }
        .accessibilityElement(children: .combine)
    }
}

/// Navigating row: a ServiceRow closed by a rule, with a paper wash on press.
struct ServiceLink: View {
    let service: Service
    var body: some View {
        NavigationLink(value: service) {
            ServiceRow(service: service).overlay(alignment: .bottom) { ApmRule() }
        }
        .buttonStyle(ApmRowPress())
    }
}
