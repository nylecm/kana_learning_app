import SwiftUI

/// Shared colours, materials and small building blocks.
///
/// The window is a native `NavigationSplitView`, so macOS supplies the sidebar, toolbar and the
/// Liquid Glass behind them. Everything the app draws *itself* goes through the helpers at the
/// bottom of this file: on macOS 26 that is real Liquid Glass, and below it the same layout with a
/// material, so the app keeps working on the older systems the package still supports.
///
/// Colours stay semantic where possible, so light and dark appearance need no second palette.
enum Theme {
    static let accent = Color(red: 0.84, green: 0.24, blue: 0.20)
    static let good = Color(red: 0.20, green: 0.55, blue: 0.36)
    static let warn = Color(red: 0.86, green: 0.55, blue: 0.10)
    static let info = Color(red: 0.22, green: 0.45, blue: 0.78)

    /// Nested shapes stay concentric with the window and with each other: cards, the controls
    /// inside them and the chart cells all agree on these radii.
    static let cardRadius: CGFloat = 16
    static let controlRadius: CGFloat = 9
    static let cardSpacing: CGFloat = 14

    static let hairline = Color(nsColor: .separatorColor)

    static func tint(for grade: Grade) -> Color {
        switch grade {
        case .again: accent
        case .hard: warn
        case .good: good
        case .easy: info
        }
    }
}

// MARK: - Liquid Glass

/// Builds the `Glass` configuration outside of any `ViewBuilder`, which cannot hold the
/// conditionals that assembling a tint/interaction need.
@available(macOS 26.0, *)
private enum GlassStyle {
    static func make(tint: Color?, interactive: Bool) -> Glass {
        var glass: Glass = .regular
        if let tint { glass = glass.tint(tint) }
        if interactive { glass = glass.interactive() }
        return glass
    }
}

extension View {
    /// A surface the app draws itself: Liquid Glass on macOS 26, a material everywhere older.
    ///
    /// Use this for custom content, not for buttons — for those, prefer the system styles via
    /// `glassButtonStyle`, so the material stays a system decision.
    @ViewBuilder
    func glassSurface<S: Shape>(in shape: S, tint: Color? = nil, interactive: Bool = false) -> some View {
        if #available(macOS 26.0, *) {
            self.glassEffect(GlassStyle.make(tint: tint, interactive: interactive), in: shape)
        } else {
            self
                .background(.regularMaterial, in: shape)
                .overlay(shape.stroke(Theme.hairline, lineWidth: 1))
        }
    }

    /// The system button styles for glass, with the bordered styles as the pre-macOS 26 fallback.
    @ViewBuilder
    func glassButtonStyle(prominent: Bool = false, tint: Color? = nil) -> some View {
        if #available(macOS 26.0, *) {
            if prominent {
                self.buttonStyle(.glassProminent).tint(tint)
            } else {
                self.buttonStyle(.glass).tint(tint)
            }
        } else {
            if prominent {
                self.buttonStyle(.borderedProminent).tint(tint)
            } else {
                self.buttonStyle(.bordered).tint(tint)
            }
        }
    }
}

/// Groups several Liquid Glass surfaces that sit in one layout container so SwiftUI renders them
/// together, which is both faster and lets them blend. A plain pass-through below macOS 26.
struct GlassGroup<Content: View>: View {
    var spacing: CGFloat = 8
    @ViewBuilder var content: Content

    var body: some View {
        if #available(macOS 26.0, *) {
            GlassEffectContainer(spacing: spacing) { content }
        } else {
            content
        }
    }
}

// MARK: - Building blocks

/// A titled card. On macOS 26 it floats on Liquid Glass above the window content.
struct SectionCard<Content: View>: View {
    let title: String
    var symbol: String?
    var hint: String?
    @ViewBuilder var content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                if let symbol {
                    Image(systemName: symbol)
                        .font(.callout)
                        .foregroundStyle(Theme.accent)
                }
                Text(title)
                    .font(.headline)
                    .layoutPriority(1)
                Spacer(minLength: 8)
                if let hint {
                    Text(hint)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.trailing)
                        .lineLimit(2)
                }
            }
            content
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .glassSurface(in: RoundedRectangle(cornerRadius: Theme.cardRadius, style: .continuous))
    }
}

/// A little key cap, e.g. `⏎` or `Space`.
struct KeyCap: View {
    let text: String

    var body: some View {
        Text(text)
            .font(.system(size: 11, weight: .semibold, design: .rounded))
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(.quaternary, in: RoundedRectangle(cornerRadius: 5, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 5, style: .continuous)
                    .stroke(Theme.hairline, lineWidth: 1)
            )
    }
}

/// `KeyCap` + what it does, used in the footers.
struct KeyHint: View {
    let key: String
    let label: String

    var body: some View {
        HStack(spacing: 5) {
            KeyCap(text: key)
            Text(label).font(.caption).foregroundStyle(.secondary)
        }
    }
}

extension KanaScript {
    var tint: Color {
        switch self {
        case .hiragana: Theme.accent
        case .katakana: Theme.info
        }
    }
}
