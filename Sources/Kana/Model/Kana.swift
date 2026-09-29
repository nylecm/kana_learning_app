import Foundation

/// The writing system a card belongs to.
enum KanaScript: String, Codable, CaseIterable, Sendable, Identifiable {
    case hiragana
    case katakana

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .hiragana: "Hiragana"
        case .katakana: "Katakana"
        }
    }

    var japaneseName: String {
        switch self {
        case .hiragana: "ひらがな"
        case .katakana: "カタカナ"
        }
    }

    var other: KanaScript {
        switch self {
        case .hiragana: .katakana
        case .katakana: .hiragana
        }
    }
}

/// Which gojūon family a card belongs to.
enum KanaKind: String, Codable, CaseIterable, Sendable, Identifiable {
    case basic
    case dakuten
    case yoon

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .basic: "Basic"
        case .dakuten: "Dakuten"
        case .yoon: "Yōon"
        }
    }
}

/// A single study card: one character in one writing system, plus everything shown on its back.
struct Kana: Identifiable, Hashable, Sendable {
    let script: KanaScript
    let kana: String
    let romaji: String
    let alternates: [String]
    let rowID: String
    let kind: KanaKind
    let mnemonic: String
    let exampleWord: String
    let exampleRomaji: String
    let exampleMeaning: String

    var id: String { "\(script.rawValue):\(kana)" }

    /// Every spelling that typing mode accepts, primary first.
    var acceptedSpellings: [String] { [romaji] + alternates }

    /// Whether `input` is an accepted rōmaji answer (case-, space- and hyphen-insensitive).
    func accepts(typed input: String) -> Bool {
        let normalized = Kana.normalize(input)
        guard !normalized.isEmpty else { return false }
        return acceptedSpellings.contains { Kana.normalize($0) == normalized }
    }

    static func normalize(_ text: String) -> String {
        text.trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()
            .replacingOccurrences(of: "-", with: "")
            .replacingOccurrences(of: " ", with: "")
            .replacingOccurrences(of: "　", with: "")
    }

    // MARK: - Data-file constructors

    /// Positional constructor used by the `Sources/Kana/Data` tables.
    /// Order: kana, romaji, alternates, rowID, kind, mnemonic, exampleWord, exampleRomaji, exampleMeaning.
    static func hira(
        _ kana: String,
        _ romaji: String,
        _ alternates: [String],
        _ rowID: String,
        _ kind: KanaKind,
        _ mnemonic: String,
        _ exampleWord: String,
        _ exampleRomaji: String,
        _ exampleMeaning: String
    ) -> Kana {
        Kana(
            script: .hiragana, kana: kana, romaji: romaji, alternates: alternates,
            rowID: rowID, kind: kind, mnemonic: mnemonic,
            exampleWord: exampleWord, exampleRomaji: exampleRomaji, exampleMeaning: exampleMeaning
        )
    }

    static func kata(
        _ kana: String,
        _ romaji: String,
        _ alternates: [String],
        _ rowID: String,
        _ kind: KanaKind,
        _ mnemonic: String,
        _ exampleWord: String,
        _ exampleRomaji: String,
        _ exampleMeaning: String
    ) -> Kana {
        Kana(
            script: .katakana, kana: kana, romaji: romaji, alternates: alternates,
            rowID: rowID, kind: kind, mnemonic: mnemonic,
            exampleWord: exampleWord, exampleRomaji: exampleRomaji, exampleMeaning: exampleMeaning
        )
    }
}
