import SwiftUI

/// P0: borrowing gear, without hunting across two websites.
struct BorrowView: View {
    private var camera: Service { Catalog.service("camera")! }
    private var books: Service { Catalog.service("books")! }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    // The blob hangs off the bottom corner, behind the band's closing rule.
                    // (At the top it was sliced flat by the status-bar strip.)
                    ApmBand(tint: .cobalt, top: 6, bottom: 28) {
                        ApmHeaderTitle(text: "Borrow")
                    }
                    .overlay(alignment: .bottomTrailing) {
                        ApmBlob(fill: .apmLime, size: 120).offset(x: 34, y: 52)
                    }
                    .clipped()
                    .overlay(alignment: .bottom) { ApmRule() }

                    ApmSectionHead(title: "Multimedia Equipment", trailing: String(format: "%02d", Catalog.gear.count))
                    ForEach(Catalog.gear, id: \.name) { item in
                        WebLink(url: Catalog.gearURL) {
                            ApmLineRow(symbol: item.icon, title: item.name, trailing: .out)
                        }
                        .buttonStyle(ApmRowPress())
                    }
                    ApmFootnote(text: "Opens the Library's official list, where you can check availability.")

                    ApmSectionHead(title: "Loan Rules")
                    ForEach(camera.facts, id: \.label) { ApmFactRow(label: $0.label, value: $0.value) }

                    NavigationLink(value: camera) {
                        ApmLineRow(symbol: "list.number", title: "How Borrowing Works")
                            .overlay(alignment: .top) { ApmRule() }
                    }
                    .buttonStyle(ApmRowPress())
                    .padding(.top, 28)

                    ApmSectionHead(title: "Also Borrow")
                    ServiceLink(service: books)
                }
                .padding(.bottom, 28)
                .background(Color.apmPage)
            }
            .apmRootChrome(.cobalt)
            .navigationDestination(for: Service.self) { ServiceDetail(service: $0) }
        }
    }
}
