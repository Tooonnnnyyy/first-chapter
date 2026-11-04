import SwiftUI

/// Tokens ported 1:1 from ideamap's docs/DESIGN-SYSTEM.md:
/// zinc surfaces, one amber accent, borders instead of shadows, 4px spacing.
extension Color {
    init(hex: UInt32) {
        self.init(
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255
        )
    }

    static let dsBg = Color(hex: 0xFAFAFA)
    static let dsSurface = Color.white
    static let dsBorder = Color(hex: 0xE4E4E7)
    static let dsText = Color(hex: 0x18181B)
    static let dsMuted = Color(hex: 0x52525B)
    static let dsAccent = Color(hex: 0xB45309)
    static let dsAccentSoft = Color(hex: 0xFEF3C7)
    static let dsSuccess = Color(hex: 0x15803D)
    static let dsSuccessSoft = Color(hex: 0xDCFCE7)
    static let dsDanger = Color(hex: 0xB91C1C)
}

enum DS {
    static let radiusSm: CGFloat = 4
    static let radiusMd: CGFloat = 6
    static let radiusLg: CGFloat = 8
    static let radius2xl: CGFloat = 16
    static let inset: CGFloat = 16
}

struct CardStyle: ViewModifier {
    var dashed = false
    func body(content: Content) -> some View {
        content
            .background(Color.dsSurface)
            .clipShape(RoundedRectangle(cornerRadius: DS.radiusLg))
            .overlay(
                RoundedRectangle(cornerRadius: DS.radiusLg)
                    .strokeBorder(Color.dsBorder, style: StrokeStyle(lineWidth: 1, dash: dashed ? [4] : []))
            )
    }
}

extension View {
    func card(dashed: Bool = false) -> some View { modifier(CardStyle(dashed: dashed)) }
}

struct PrimaryButton: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 15, weight: .semibold))
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity, minHeight: 44)
            .background(Color.dsAccent.opacity(configuration.isPressed ? 0.85 : 1))
            .clipShape(RoundedRectangle(cornerRadius: DS.radiusMd))
    }
}

struct SecondaryButton: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 15, weight: .medium))
            .foregroundStyle(Color.dsText)
            .frame(maxWidth: .infinity, minHeight: 44)
            .background(configuration.isPressed ? Color.dsBorder : Color.dsSurface)
            .clipShape(RoundedRectangle(cornerRadius: DS.radiusMd))
            .overlay(RoundedRectangle(cornerRadius: DS.radiusMd).strokeBorder(Color.dsBorder))
    }
}

struct Badge: View {
    enum Tone { case neutral, accent, success }
    let text: String
    var tone: Tone = .neutral
    var body: some View {
        Text(text)
            .font(.system(size: 11, weight: .semibold, design: .monospaced))
            .foregroundStyle(tone == .accent ? Color.dsAccent : tone == .success ? Color.dsSuccess : Color.dsMuted)
            .padding(.horizontal, 6)
            .padding(.vertical, 3)
            .background(tone == .accent ? Color.dsAccentSoft : tone == .success ? Color.dsSuccessSoft : Color(hex: 0xF4F4F5))
            .clipShape(RoundedRectangle(cornerRadius: DS.radiusSm))
    }
}

struct Wordmark: View {
    var body: some View {
        Text("firstchapter")
            .font(.system(size: 15, weight: .semibold, design: .monospaced))
            .foregroundStyle(Color.dsAccent)
    }
}

struct SectionTitle: View {
    let text: String
    var body: some View {
        Text(text)
            .font(.system(size: 13, weight: .semibold))
            .foregroundStyle(Color.dsMuted)
            .textCase(.uppercase)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}
