import SwiftUI

/// P0: borrowing gear, without hunting across two websites.
struct BorrowView: View {
    private var camera: Service { Catalog.service("camera")! }
    private var books: Service { Catalog.service("books")! }

    var body: some View {
        NavigationStack {
            List {
                Section {
                    ForEach(Catalog.gear, id: \.name) { item in
                        WebLink(url: Catalog.gearURL) {
                            HStack(spacing: 12) {
                                IconTile(symbol: item.icon, color: item.color)
                                Text(item.name).foregroundStyle(.primary)
                                Spacer()
                                Image(systemName: "arrow.up.forward").font(.footnote.weight(.semibold)).foregroundStyle(.tertiary)
                            }
                        }
                    }
                } header: {
                    Text("Multimedia Equipment")
                } footer: {
                    Text("Opens the Library's official list, where you can check availability.")
                }
                Section("Loan Rules") {
                    ForEach(camera.facts, id: \.label) { fact in
                        LabeledContent(fact.label, value: fact.value)
                    }
                }
                Section {
                    NavigationLink("How Borrowing Works", value: camera)
                }
                Section("Also Borrow") {
                    NavigationLink(value: books) { ServiceRow(service: books) }
                }
            }
            .navigationTitle("Borrow")
            .navigationDestination(for: Service.self) { ServiceDetail(service: $0) }
        }
    }
}
