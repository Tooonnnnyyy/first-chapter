// apm-style for First Chapter: the owner's saved style, adapted from the skill's
// ApmStyle.swift. Flat color bands, 2pt ink rules, square corners (pills and circles
// only), solid offset shadows, no gradients, no blur. Light scheme only.
// Fonts: Manrope and DM Mono (SIL OFL) in Fonts/, registered at launch.

import SwiftUI
import UIKit
import CoreText

// MARK: - Color

extension Color {
    init(apmHex hex: UInt32) {
        self.init(.sRGB,
                  red: Double((hex >> 16) & 0xFF) / 255,
                  green: Double((hex >> 8) & 0xFF) / 255,
                  blue: Double(hex & 0xFF) / 255)
    }
    static let apmInk       = Color(apmHex: 0x11120F)
    static let apmInkRaised = Color(apmHex: 0x191A17)
    static let apmPage      = Color(apmHex: 0xFFFFFF)
    static let apmPaper     = Color(apmHex: 0xF3EFE3)
    static let apmBone      = Color(apmHex: 0xFFFDF7)
    static let apmLime      = Color(apmHex: 0xD9FF43)
    static let apmFlame     = Color(apmHex: 0xFF5A36)
    static let apmViolet    = Color(apmHex: 0xB7A7FF)
    static let apmMint      = Color(apmHex: 0x75DED1)
    static let apmCobalt    = Color(apmHex: 0x2864FF)
    static let apmMute      = Color(apmHex: 0xD8D8D2)
}

/// A band color and the text color that is allowed on it (see the skill's contrast table).
struct ApmTint: Equatable {
    let fill: Color
    let ink: Color
    static let lime = ApmTint(fill: .apmLime, ink: .apmInk)
    static let cobalt = ApmTint(fill: .apmCobalt, ink: .apmBone)
    static let violet = ApmTint(fill: .apmViolet, ink: .apmInk)
    static let flame = ApmTint(fill: .apmFlame, ink: .apmInk)
    static let mint = ApmTint(fill: .apmMint, ink: .apmInk)
    static let paper = ApmTint(fill: .apmPaper, ink: .apmInk)
}

private struct ApmTintKey: EnvironmentKey {
    static let defaultValue = ApmTint.lime
}

extension EnvironmentValues {
    /// The current tab's band color, so pushed screens keep it.
    var apmTint: ApmTint {
        get { self[ApmTintKey.self] }
        set { self[ApmTintKey.self] = newValue }
    }
}

// MARK: - Glyphs

/// iOS draws a bare arrow as a blue emoji tile. These force the text form.
enum ApmGlyph {
    static let out = "\u{2197}\u{FE0E}"    // north-east arrow
    static let down = "\u{2193}\u{FE0E}"   // down arrow
    static let right = "\u{2192}\u{FE0E}"  // right arrow
}

// MARK: - Motion

enum ApmMotion {
    /// The web easing cubic-bezier(.16, 1, .3, 1).
    static func snap(_ duration: Double = 0.25) -> Animation {
        .timingCurve(0.16, 1, 0.3, 1, duration: duration)
    }
}

// MARK: - Fonts

enum ApmFace {
    /// Set to false to drop monospace from labels, buttons and numerals.
    static let monoLabels = true
    static let textRegular = "Manrope-Regular"
    static let textMedium = "Manrope-Medium"
    static var labelRegular: String { monoLabels ? "DMMono-Regular" : textMedium }
    static var labelMedium: String { monoLabels ? "DMMono-Medium" : textMedium }
}

/// Registers the bundled fonts once, at launch. A face that fails to register falls back
/// to the system font with the same size, weight and Dynamic Type anchor.
enum ApmFonts {
    static let names = ["Manrope-Regular", "Manrope-Medium", "DMMono-Regular", "DMMono-Medium"]

    /// Faces that are usable. Reading it the first time registers the fonts.
    static let available: Set<String> = {
        var urls = Bundle.main.urls(forResourcesWithExtension: "ttf", subdirectory: nil) ?? []
        urls += Bundle.main.urls(forResourcesWithExtension: "ttf", subdirectory: "Fonts") ?? []
        for url in urls {
            var error: Unmanaged<CFError>?
            // An "already registered" error is harmless; anything else is caught by the check below.
            _ = CTFontManagerRegisterFontsForURL(url as CFURL, .process, &error)
        }
        let found = Set(names.filter { UIFont(name: $0, size: 12) != nil })
        for name in names where !found.contains(name) {
            print("apm-style: font not registered, using the system font: \(name)")
        }
        return found
    }()

    static func register() { _ = available }
}

// MARK: - Type

enum ApmText {
    case hero, h1, h2, h3, h4, title, note, lede, body, small, label, eyebrow, tag, button, numeral

    private var spec: (face: String, size: CGFloat, em: CGFloat, line: CGFloat, base: Font.TextStyle) {
        switch self {                                 // size   tracking  line   Dynamic Type anchor
        case .hero:    return (ApmFace.textMedium,      56,   -0.038,  0.90, .largeTitle)
        case .h1:      return (ApmFace.textMedium,      48,   -0.038,  0.94, .largeTitle)
        case .h2:      return (ApmFace.textMedium,      38,   -0.038,  0.96, .title)
        case .h3:      return (ApmFace.textMedium,      30,   -0.035,  1.00, .title2)
        case .h4:      return (ApmFace.textMedium,      25,   -0.035,  1.02, .title3)
        case .title:   return (ApmFace.textMedium,      19,   -0.020,  1.20, .headline)
        case .note:    return (ApmFace.textMedium,      22,   -0.010,  1.08, .title3)
        case .lede:    return (ApmFace.textRegular,     18,    0,      1.30, .body)
        case .body:    return (ApmFace.textRegular,     16,    0,      1.45, .body)
        case .small:   return (ApmFace.textRegular,     14.5,  0,      1.38, .subheadline)
        case .label:   return (ApmFace.labelRegular,    12.5,  0,      1.40, .footnote)
        case .eyebrow: return (ApmFace.labelRegular,    12.5,  0.08,   1.40, .footnote)
        case .tag:     return (ApmFace.labelMedium,     11.5,  0.06,   1.30, .caption)
        case .button:  return (ApmFace.labelMedium,     14,    0,      1.20, .callout)
        case .numeral: return (ApmFace.textMedium,      28,   -0.035,  1.00, .title2)
        }
    }

    var font: Font {
        let s = spec
        let custom = Font.custom(s.face, size: s.size, relativeTo: s.base)
        if ApmFonts.available.contains(s.face) { return custom }
        // Fallback: Font.custom with a missing face gives the system font at the same size.
        let weighted = custom.weight(s.face.hasSuffix("Medium") ? .medium : .regular)
        return s.face.hasPrefix("DMMono") ? weighted.monospaced() : weighted
    }
    var tracking: CGFloat { spec.size * spec.em }
    var lineMultiple: CGFloat { spec.line }
    var isUppercase: Bool { self == .eyebrow || self == .tag }
}

extension View {
    /// Face, tracking, line height and case for one of the three type voices.
    func apmText(_ style: ApmText) -> some View {
        self
            .font(style.font)
            .tracking(style.tracking)
            .textCase(style.isUppercase ? .uppercase : nil)
            // Display sizes go no tighter than 1.2: below that, iOS clips the last line's
            // descenders. Still tighter than Manrope's natural line box of about 1.37.
            .lineHeight(.multiple(factor: max(style.lineMultiple, 1.2)))
    }
}

// MARK: - Buttons

struct ApmPillStyle: ButtonStyle {
    enum Kind { case primary, ghost, mute, lime }
    var kind: Kind = .primary
    var fullWidth = false
    /// Flame by default. Pass lime on a flame band, where a flame shadow would vanish.
    var shadow: Color = .apmFlame
    @Environment(\.isEnabled) private var isEnabled

    private var fill: Color {
        switch kind { case .primary: .apmInk; case .ghost: .clear; case .mute: .apmMute; case .lime: .apmLime }
    }
    private var ink: Color { kind == .primary ? .apmBone : .apmInk }
    private var shadowOffset: CGFloat {
        guard isEnabled else { return 0 }
        switch kind { case .primary: return 4; case .lime: return 6; default: return 0 }
    }

    func makeBody(configuration: Configuration) -> some View {
        // Touch has no hover: where the web lifts on hover, iOS sinks into the shadow on press.
        let sink: CGFloat = configuration.isPressed ? shadowOffset * 0.6 : 0
        configuration.label
            // A tap that changes the label ("Mark as Done" to "Mark as Not Done") swaps it at
            // once. Without this the release animation cross-faded the two labels on top of
            // each other for a quarter second.
            .transaction { $0.animation = nil }
            .apmText(.button)
            .multilineTextAlignment(.center)
            .foregroundStyle(ink)
            .padding(.vertical, 12)
            .padding(.horizontal, 20)
            .frame(maxWidth: fullWidth ? .infinity : nil, minHeight: 48)
            .background(Capsule().fill(fill))
            .overlay(Capsule().strokeBorder(kind == .mute ? Color.apmInk.opacity(0.45) : .apmInk, lineWidth: 2))
            .contentShape(Capsule())
            // Only the sink animates. A value-based animation here also cross-faded the label
            // when a tap changed it ("Mark as Done" to "Mark as Not Done").
            .animation(ApmMotion.snap()) { $0.offset(x: sink, y: sink) }
            .background(Capsule().fill(shadowOffset > 0 ? shadow : .clear).offset(x: shadowOffset, y: shadowOffset))
            .opacity(isEnabled ? 1 : 0.55)
            .sensoryFeedback(.impact(weight: .light), trigger: configuration.isPressed) { _, pressed in pressed }
    }
}

/// Press feedback for whole rows: a light ink wash, no movement.
struct ApmRowPress: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(configuration.isPressed ? Color.apmInk.opacity(0.07) : .clear)
            .contentShape(Rectangle())
    }
}

/// Press feedback for cards with a solid shadow: the card sinks into its shadow.
struct ApmCardPress: ButtonStyle {
    var depth: CGFloat = 4
    func makeBody(configuration: Configuration) -> some View {
        let sink = configuration.isPressed ? depth : 0
        configuration.label
            .animation(ApmMotion.snap()) { $0.offset(x: sink, y: sink) }
            .contentShape(Rectangle())
    }
}

// MARK: - Glyphs as views

/// A plain SF Symbol in a fixed box, so wide symbols (three people, a printer) line up
/// with narrow ones (a bookmark) in a column of rows. Never inside a tile.
struct ApmIcon: View {
    let symbol: String
    var size: CGFloat = 19
    var body: some View {
        Image(systemName: symbol)
            .resizable()
            .scaledToFit()
            .frame(width: size * 1.4, height: size)
            .frame(width: 28)
            .accessibilityHidden(true)
    }
}

/// Trailing row arrow. Drawn as a symbol: Manrope has no north-east arrow, and the
/// fallback face drew it twice the size and a third of the weight of the right arrow.
struct ApmArrow: View {
    enum Kind { case right, out }
    var kind: Kind = .right
    var body: some View {
        Image(systemName: kind == .out ? "arrow.up.right" : "arrow.right")
            .font(.system(size: 17, weight: .regular))
            .frame(width: 22)
            .accessibilityHidden(true)
    }
}

// MARK: - Surfaces

struct ApmRule: View {
    var color: Color = .apmInk
    var body: some View { Rectangle().fill(color).frame(height: 2).accessibilityHidden(true) }
}

/// 1pt ink at 25%, between rows inside a ruled group.
struct ApmHairline: View {
    var body: some View { Rectangle().fill(Color.apmInk.opacity(0.25)).frame(height: 1).accessibilityHidden(true) }
}

/// Full-bleed color block closed by a 2pt ink rule.
struct ApmBand<Content: View>: View {
    var tint: ApmTint = .paper
    var top: CGFloat = 20
    var bottom: CGFloat = 20
    @ViewBuilder var content: Content
    var body: some View {
        VStack(alignment: .leading, spacing: 0) { content }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, ApmLayout.gutter)
            .padding(.top, top)
            .padding(.bottom, bottom)
            .foregroundStyle(tint.ink)
            .background(tint.fill)
            .overlay(alignment: .bottom) { ApmRule() }
    }
}

enum ApmLayout {
    static let gutter: CGFloat = 16
}

/// Square card, 2pt outline, solid offset shadow, optional tilt. Never rounded, never blurred.
struct ApmCard<Content: View>: View {
    var fill: Color = .apmPaper
    var ink: Color = .apmInk
    var tilt: Double = 0
    var shadow: Color = .apmInk
    var shadowOffset: CGFloat = 7
    var padding: CGFloat = 20
    @ViewBuilder var content: Content
    var body: some View {
        // The stack matters: without it, several children would each get their own card.
        VStack(alignment: .leading, spacing: 0) { content }
            .padding(padding)
            .frame(maxWidth: .infinity, alignment: .leading)
            .foregroundStyle(ink)
            .background(fill)
            .overlay(Rectangle().strokeBorder(Color.apmInk, lineWidth: 2))
            .background(Rectangle().fill(shadow).offset(x: shadowOffset, y: shadowOffset))
            .rotationEffect(.degrees(tilt))
    }
}

/// Small pill label: "Soon", "+50 XP", "Done +50".
struct ApmTag: View {
    let text: String
    var fill: Color = .apmLime
    var ink: Color = .apmInk
    var body: some View {
        Text(text)
            .apmText(.tag)
            .lineLimit(1)
            .fixedSize()
            .foregroundStyle(ink)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(Capsule().fill(fill))
            .overlay(Capsule().strokeBorder(Color.apmInk, lineWidth: 2))
    }
}

/// Eyebrow over a 2pt rule. Replaces grouped-list section headers.
struct ApmSectionHead: View {
    let title: String
    var trailing: String? = nil
    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            Text(title).apmText(.eyebrow)
            Spacer(minLength: 8)
            if let trailing { Text(trailing).apmText(.eyebrow) }
        }
        .foregroundStyle(Color.apmInk)
        .padding(.horizontal, ApmLayout.gutter)
        .padding(.top, 26)
        .padding(.bottom, 10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .overlay(alignment: .bottom) { ApmRule() }
        .accessibilityAddTraits(.isHeader)
    }
}

/// Small print under a group, where a grouped list would put its footer.
struct ApmFootnote: View {
    let text: String
    var body: some View {
        Text(text)
            .apmText(.small)
            .foregroundStyle(Color.apmInk.opacity(0.72))
            .padding(.horizontal, ApmLayout.gutter)
            .padding(.top, 10)
            .padding(.bottom, 4)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}

/// Label and value on one ruled line, for facts.
struct ApmFactRow: View {
    let label: String
    let value: String
    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 16) {
            Text(label).apmText(.label).foregroundStyle(Color.apmInk.opacity(0.75))
            Spacer(minLength: 8)
            Text(value).apmText(.body).multilineTextAlignment(.trailing)
        }
        .foregroundStyle(Color.apmInk)
        .padding(.horizontal, ApmLayout.gutter)
        .padding(.vertical, 12)
        .overlay(alignment: .bottom) { ApmHairline().padding(.horizontal, ApmLayout.gutter) }
        .accessibilityElement(children: .combine)
    }
}

/// Oversized off-center shape, clipped by its parent.
struct ApmBlob: View {
    var fill: Color = .apmFlame
    var size: CGFloat = 180
    var body: some View {
        let s = size / 180
        let shape = UnevenRoundedRectangle(cornerRadii: .init(topLeading: 86 * s, bottomLeading: 112 * s,
                                                              bottomTrailing: 68 * s, topTrailing: 94 * s))
        shape.fill(fill)
            .overlay(shape.strokeBorder(Color.apmInk, lineWidth: 2))
            .frame(width: size, height: size)
            .accessibilityHidden(true)
    }
}

/// Pinned note: tinted card with a strip of tape. Holds no controls.
struct ApmNote: View {
    let tag: String
    let title: String
    var fill: Color = .apmViolet
    var tilt: Double = -4
    var width: CGFloat = 200
    var body: some View {
        ApmCard(fill: fill, tilt: tilt, shadow: Color.apmInk.opacity(0.3), shadowOffset: 8, padding: 16) {
            VStack(alignment: .leading, spacing: 14) {
                Text(tag).apmText(.tag)
                Text(title).apmText(.note)
            }
        }
        .frame(width: width)
        .overlay(alignment: .top) {
            Rectangle().fill(Color.apmBone.opacity(0.65))
                .frame(width: 72, height: 22)
                .rotationEffect(.degrees(tilt - 2))
                .offset(y: -11)
                .accessibilityHidden(true)
        }
        .accessibilityElement(children: .combine)
    }
}

struct ApmLiveDot: View {
    @Environment(\.accessibilityReduceMotion) private var calm
    @State private var low = false
    var body: some View {
        Circle().fill(Color.apmFlame).frame(width: 10, height: 10)
            .scaleEffect(low ? 0.7 : 1)
            .opacity(low ? 0.55 : 1)
            .background(Circle().fill(Color.apmFlame.opacity(0.2)).frame(width: 22, height: 22))
            .onAppear {
                guard !calm else { return }
                withAnimation(.easeInOut(duration: 1).repeatForever(autoreverses: true)) { low = true }
            }
            .accessibilityHidden(true)
    }
}

// MARK: - Screen chrome

extension View {
    /// Root tab screens draw their own header band, so the system bar is hidden. The status
    /// bar sits on a solid strip of the band color, and the system's scroll-edge blur is off.
    func apmRootChrome(_ tint: ApmTint) -> some View {
        self
            .toolbar(.hidden, for: .navigationBar)
            .toolbarColorScheme(tint.ink == .apmBone ? .dark : .light, for: .navigationBar)
            .scrollEdgeEffectHidden(true, for: .top)
            .safeAreaInset(edge: .top, spacing: 0) {
                Color.clear.frame(height: 0).background(tint.fill)
            }
            .background {
                // Band color shows if the list is pulled down, page color if pulled up.
                VStack(spacing: 0) { tint.fill.frame(height: 320); Color.apmPage }.ignoresSafeArea()
            }
            .environment(\.apmTint, tint)
    }

    /// Pushed screens keep the system navigation bar, on a solid band color. Its glass back
    /// button is swapped for a flat one (iOS 26 draws it as a tinted, glowing glass disc);
    /// edge swipe-back still works. `bottom` fills the space under short content.
    func apmPushedChrome(_ tint: ApmTint, bottom: Color = .apmPage) -> some View {
        self
            .toolbarBackground(tint.fill, for: .navigationBar)
            .toolbarBackgroundVisibility(.visible, for: .navigationBar)
            .toolbarColorScheme(tint.ink == .apmBone ? .dark : .light, for: .navigationBar)
            .scrollEdgeEffectHidden(true, for: .top)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) { ApmBackButton() }
                    .sharedBackgroundVisibility(.hidden)
            }
            .background { ApmSwipeBack() }
            .background {
                VStack(spacing: 0) { tint.fill.frame(height: 320); bottom }.ignoresSafeArea()
            }
    }
}

/// A 44pt bar button: bone disc, 2pt ink ring, plain glyph. No glass, no glow.
struct ApmBarGlyph: View {
    let symbol: String
    var body: some View {
        Image(systemName: symbol)
            .font(.system(size: 17, weight: .medium))
            .foregroundStyle(Color.apmInk)
            .frame(width: 44, height: 44)
            .background(Circle().fill(Color.apmBone))
            .overlay(Circle().strokeBorder(Color.apmInk, lineWidth: 2))
            .contentShape(Circle())
    }
}

struct ApmBackButton: View {
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        Button { dismiss() } label: { ApmBarGlyph(symbol: "chevron.left") }
            .buttonStyle(.plain)
            .accessibilityLabel("Back")
    }
}

/// Hiding the system back button also turns off the edge swipe. This keeps the swipe on
/// while a pushed screen is showing, and hands the gesture back when it goes away.
private struct ApmSwipeBack: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> Probe { Probe() }
    func updateUIViewController(_ controller: Probe, context: Context) {}

    final class Probe: UIViewController, UIGestureRecognizerDelegate {
        private weak var nav: UINavigationController?
        private weak var original: UIGestureRecognizerDelegate?

        override func viewDidAppear(_ animated: Bool) {
            super.viewDidAppear(animated)
            guard let nav = navigationController, let pop = nav.interactivePopGestureRecognizer,
                  pop.delegate !== self else { return }
            self.nav = nav
            original = pop.delegate
            pop.delegate = self
        }

        override func viewWillDisappear(_ animated: Bool) {
            super.viewWillDisappear(animated)
            // If the swipe is cancelled, viewDidAppear runs again and takes it back.
            if let pop = nav?.interactivePopGestureRecognizer, pop.delegate === self {
                pop.delegate = original
            }
        }

        func gestureRecognizerShouldBegin(_ gesture: UIGestureRecognizer) -> Bool {
            (nav?.viewControllers.count ?? 0) > 1
        }
    }
}

// MARK: - Dialog

/// The style's modal: square bone panel, 2pt outline, solid ink shadow, on ink at 50%,
/// no blur. Replaces the system alert and confirmation dialog, which are glass.
struct ApmDialogAction: Identifiable {
    let id = UUID()
    let title: String
    var role: ButtonRole? = nil
    var run: () -> Void = {}
}

struct ApmDialogModel: Identifiable {
    let id = UUID()
    let title: String
    let message: String
    let actions: [ApmDialogAction]
}

/// Shown above the tab bar by MainTabs; screens call `show`.
@Observable
final class ApmDialogs {
    var current: ApmDialogModel?
    func show(_ dialog: ApmDialogModel) { current = dialog }
}

struct ApmDialogView: View {
    let model: ApmDialogModel
    let close: () -> Void
    private var cancel: ApmDialogAction? { model.actions.first { $0.role == .cancel } }

    var body: some View {
        ZStack {
            Color.apmInk.opacity(0.5)
                .ignoresSafeArea()
                .onTapGesture { if let cancel { finish(cancel) } }
                .accessibilityHidden(true)
            ApmCard(fill: .apmBone, shadowOffset: 7, padding: 22) {
                Text(model.title).apmText(.h4)
                    .fixedSize(horizontal: false, vertical: true)
                    .accessibilityAddTraits(.isHeader)
                Text(model.message).apmText(.body)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.top, 10)
                VStack(spacing: 12) {
                    ForEach(model.actions) { action in
                        Button(action.title) { finish(action) }
                            .buttonStyle(ApmPillStyle(kind: action.role == .cancel && model.actions.count > 1 ? .ghost : .primary,
                                                      fullWidth: true))
                    }
                }
                .padding(.top, 22)
            }
            .frame(maxWidth: 360)
            .padding(.horizontal, 24)
            .accessibilityElement(children: .contain)
            .accessibilityAddTraits(.isModal)
            .accessibilityAction(.escape) { if let cancel { finish(cancel) } }
        }
    }

    private func finish(_ action: ApmDialogAction) {
        close()
        action.run()
    }
}

/// The big title at the top of a band.
struct ApmHeaderTitle: View {
    let text: String
    var style: ApmText = .h1
    var body: some View {
        Text(text)
            .apmText(style)
            .fixedSize(horizontal: false, vertical: true)
            .accessibilityAddTraits(.isHeader)
    }
}
