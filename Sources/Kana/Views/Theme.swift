import SwiftUI

/// Shared colours and small building blocks. Colours use system semantic values where possible so
/// light and dark appearance both work without a second palette.
enum Theme {
    static let accent = Color(red: 0.84, green: 0.24, blue: 0.20)
    static let good = Color(red: 0.20, green: 0.55, blue: 0.36)
    static let warn = Color(red: 0.86, green: 0.55, blue: 0.10)
    static let info = Color(red: 0.22, green: 0.45, blue: 0.78)

    static let panel = Color(nsColor: .controlBackgroundColor)
    static let canvas = Color(nsColor: .underPageBackgroundColor)
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

/// A titled panel with an optional keyboard hint in the corner.
struct SectionCard<Content: View>: View {
    let title: String
    var hint: String?
    @ViewBuilder var content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Text(title).font(.headline)
                Spacer(minLength: 8)
                if let hint {
                    Text(hint).font(.caption).foregroundStyle(.secondary)
                }
            }
            content
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Theme.panel, in: RoundedRectangle(cornerRadius: 12))
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Theme.hairline))
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
            .background(Color.primary.opacity(0.07), in: RoundedRectangle(cornerRadius: 4))
            .overlay(RoundedRectangle(cornerRadius: 4).stroke(Theme.hairline))
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
