import SwiftUI

/// P0: borrowing gear, without hunting across two websites.
struct BorrowView: View {
    private let needs: [(icon: String, title: String, detail: String)] = [
        ("camera.fill", "Photo or video project", "Ask about cameras and tripods"),
        ("mic.fill", "Audio or podcast", "Ask about microphones and recorders"),
        ("laptopcomputer", "Software on your laptop", "SPSS, Stata and ArcGIS through uOLabsPlus"),
    ]
    private var camera: Service { Catalog.service("camera")! }
    private var software: Service { Catalog.service("software")! }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Borrow gear").font(.system(size: 28, weight: .bold)).foregroundStyle(Color.dsText)
                    StepsBadge(service: camera)

                    SectionTitle(text: "The rules, in one place")
                    VStack(spacing: 0) {
                        rule("calendar", "Loan", "7 days, 2 renewals")
                        Divider()
                        rule("mappin.and.ellipse", "Pick up", "Morisset main service desk")
                        Divider()
                        rule("person.text.rectangle", "Who", "Current students, faculty, employees")
                        Divider()
                        rule("creditcard", "Bring", "A valid library card")
                    }
                    .card()

                    SectionTitle(text: "What are you making?")
                    ForEach(needs, id: \.title) { need in
                        NavigationLink(value: need.icon == "laptopcomputer" ? software : camera) {
                            HStack(spacing: 12) {
                                Image(systemName: need.icon).font(.system(size: 18)).foregroundStyle(Color.dsAccent)
                                    .frame(width: 40, height: 40).background(Color.dsAccentSoft)
                                    .clipShape(RoundedRectangle(cornerRadius: DS.radiusMd))
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(need.title).font(.system(size: 15, weight: .semibold)).foregroundStyle(Color.dsText)
                                    Text(need.detail).font(.system(size: 13)).foregroundStyle(Color.dsMuted)
                                }
                                Spacer(minLength: 0)
                                Image(systemName: "chevron.right").font(.system(size: 12)).foregroundStyle(Color.dsMuted)
                            }
                            .padding(12)
                            .card()
                        }
                    }
                    if let url = URL(string: camera.url) {
                        Link(destination: url) { Label("Check what's available", systemImage: "arrow.up.right") }
                            .buttonStyle(PrimaryButton())
                    }
                    Text("Availability lives on the Library's site. This prototype doesn't show live stock.")
                        .font(.system(size: 12)).foregroundStyle(Color.dsMuted)
                }
                .padding(DS.inset)
            }
            .background(Color.dsBg)
            .toolbar { ToolbarItem(placement: .topBarLeading) { Wordmark() } }
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
