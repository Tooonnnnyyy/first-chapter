import SwiftUI

/// P0: borrowing gear, without hunting across two websites.
struct BorrowView: View {
    private var camera: Service { Catalog.service("camera")! }
    private let grid = [GridItem(.flexible(), spacing: 8), GridItem(.flexible(), spacing: 8)]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Borrow gear").font(.system(size: 28, weight: .bold)).foregroundStyle(Color.dsText)
                    StepsBadge(service: camera)

                    SectionTitle(text: "What the Library lends")
                    if let url = URL(string: Catalog.gearURL) {
                        LazyVGrid(columns: grid, spacing: 8) {
                            ForEach(Catalog.gear, id: \.name) { item in
                                Link(destination: url) {
                                    VStack(alignment: .leading, spacing: 10) {
                                        Image(systemName: item.icon).font(.system(size: 22)).foregroundStyle(Color.dsAccent)
                                        Text(item.name).font(.system(size: 14, weight: .semibold)).foregroundStyle(Color.dsText)
                                            .multilineTextAlignment(.leading).lineLimit(2)
                                        Spacer(minLength: 0)
                                    }
                                    .padding(12)
                                    .frame(maxWidth: .infinity, minHeight: 92, alignment: .leading)
                                    .card()
                                }
                            }
                        }
                    }

                    SectionTitle(text: "The rules, in one place")
                    VStack(spacing: 0) {
                        rule("calendar", "Loan", "7 days, 2 renewals")
                        Divider()
                        rule("mappin.and.ellipse", "Pick up", "Morisset main service desk")
                        Divider()
                        rule("person.text.rectangle", "Who", "Current students, faculty, employees")
                        Divider()
                        rule("creditcard", "Bring", "A valid library card")
                        Divider()
                        rule("arrow.uturn.left", "Return", "With all accessories, same desk")
                    }
                    .card()

                    NavigationLink(value: camera) {
                        Text("How borrowing works").frame(maxWidth: .infinity)
                    }
                    .buttonStyle(SecondaryButton())

                    Text("Tapping a category opens the Library's official equipment list, where you can check availability.")
                        .font(.system(size: 12)).foregroundStyle(Color.dsMuted)
                        .padding(.bottom, 64)
                }
                .padding(DS.inset)
            }
            .background(Color.dsBg)
            .toolbar { ToolbarItem(placement: .principal) { Wordmark().fixedSize() } }
            .navigationDestination(for: Service.self) { ServiceDetail(service: $0) }
        }
    }

    private func rule(_ icon: String, _ label: String, _ value: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: icon).frame(width: 20).foregroundStyle(Color.dsMuted)
            Text(label).font(.system(size: 14, weight: .medium)).foregroundStyle(Color.dsText)
            Spacer()
            Text(value).font(.system(size: 13)).foregroundStyle(Color.dsMuted).multilineTextAlignment(.trailing)
        }
        .padding(12)
    }
}
