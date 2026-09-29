import Foundation

/// The complete card library, assembled from the authored data tables and grouped the way the
/// kana chart needs it.
enum KanaLibrary {
    static let all: [Kana] =
        HiraganaBasic.all + HiraganaDakuten.all + HiraganaYoon.all +
        KatakanaBasic.all + KatakanaDakuten.all + KatakanaYoon.all

    static let byID: [String: Kana] = Dictionary(uniqueKeysWithValues: all.map { ($0.id, $0) })

    /// Cards of one script, one gojūon row each, in chart order.
    static let chartRows: [KanaScript: [[Kana]]] = [
        .hiragana: rows(for: .hiragana),
        .katakana: rows(for: .katakana)
    ]

    /// The row each chart line corresponds to, so the chart can label it.
    static let chartRowLabels: [KanaScript: [KanaRow]] = [
        .hiragana: rowLabels(for: .hiragana),
        .katakana: rowLabels(for: .katakana)
    ]

    static func cards(_ script: KanaScript) -> [Kana] {
        all.filter { $0.script == script }
    }

    private static func rows(for script: KanaScript) -> [[Kana]] {
        let cards = cards(script)
        return KanaRows.all.compactMap { row in
            let group = cards.filter { $0.rowID == row.id }
            return group.isEmpty ? nil : group
        }
    }

    private static func rowLabels(for script: KanaScript) -> [KanaRow] {
        let present = Set(cards(script).map(\.rowID))
        return KanaRows.all.filter { present.contains($0.id) }
    }
}
