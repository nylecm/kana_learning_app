import Foundation

/// A gojūon row. Row IDs are shared between scripts (the か row is かきくけこ and カキクケコ).
struct KanaRow: Identifiable, Hashable, Sendable {
    let id: String
    let kind: KanaKind
    let hiraganaLabel: String
    let katakanaLabel: String

    func label(for script: KanaScript) -> String {
        switch script {
        case .hiragana: hiraganaLabel
        case .katakana: katakanaLabel
        }
    }
}

enum KanaRows {
    /// Gojūon order, basic → dakuten → yōon.
    static let all: [KanaRow] = [
        KanaRow(id: "a", kind: .basic, hiraganaLabel: "あ行", katakanaLabel: "ア行"),
        KanaRow(id: "ka", kind: .basic, hiraganaLabel: "か行", katakanaLabel: "カ行"),
        KanaRow(id: "sa", kind: .basic, hiraganaLabel: "さ行", katakanaLabel: "サ行"),
        KanaRow(id: "ta", kind: .basic, hiraganaLabel: "た行", katakanaLabel: "タ行"),
        KanaRow(id: "na", kind: .basic, hiraganaLabel: "な行", katakanaLabel: "ナ行"),
        KanaRow(id: "ha", kind: .basic, hiraganaLabel: "は行", katakanaLabel: "ハ行"),
        KanaRow(id: "ma", kind: .basic, hiraganaLabel: "ま行", katakanaLabel: "マ行"),
        KanaRow(id: "ya", kind: .basic, hiraganaLabel: "や行", katakanaLabel: "ヤ行"),
        KanaRow(id: "ra", kind: .basic, hiraganaLabel: "ら行", katakanaLabel: "ラ行"),
        KanaRow(id: "wa", kind: .basic, hiraganaLabel: "わ行", katakanaLabel: "ワ行"),
        KanaRow(id: "n", kind: .basic, hiraganaLabel: "ん", katakanaLabel: "ン"),

        KanaRow(id: "ga", kind: .dakuten, hiraganaLabel: "が行", katakanaLabel: "ガ行"),
        KanaRow(id: "za", kind: .dakuten, hiraganaLabel: "ざ行", katakanaLabel: "ザ行"),
        KanaRow(id: "da", kind: .dakuten, hiraganaLabel: "だ行", katakanaLabel: "ダ行"),
        KanaRow(id: "ba", kind: .dakuten, hiraganaLabel: "ば行", katakanaLabel: "バ行"),
        KanaRow(id: "pa", kind: .dakuten, hiraganaLabel: "ぱ行", katakanaLabel: "パ行"),

        KanaRow(id: "kya", kind: .yoon, hiraganaLabel: "きゃ行", katakanaLabel: "キャ行"),
        KanaRow(id: "sha", kind: .yoon, hiraganaLabel: "しゃ行", katakanaLabel: "シャ行"),
        KanaRow(id: "cha", kind: .yoon, hiraganaLabel: "ちゃ行", katakanaLabel: "チャ行"),
        KanaRow(id: "nya", kind: .yoon, hiraganaLabel: "にゃ行", katakanaLabel: "ニャ行"),
        KanaRow(id: "hya", kind: .yoon, hiraganaLabel: "ひゃ行", katakanaLabel: "ヒャ行"),
        KanaRow(id: "mya", kind: .yoon, hiraganaLabel: "みゃ行", katakanaLabel: "ミャ行"),
        KanaRow(id: "rya", kind: .yoon, hiraganaLabel: "りゃ行", katakanaLabel: "リャ行"),
        KanaRow(id: "gya", kind: .yoon, hiraganaLabel: "ぎゃ行", katakanaLabel: "ギャ行"),
        KanaRow(id: "ja", kind: .yoon, hiraganaLabel: "じゃ行", katakanaLabel: "ジャ行"),
        KanaRow(id: "bya", kind: .yoon, hiraganaLabel: "びゃ行", katakanaLabel: "ビャ行"),
        KanaRow(id: "pya", kind: .yoon, hiraganaLabel: "ぴゃ行", katakanaLabel: "ピャ行")
    ]

    static let byID: [String: KanaRow] = Dictionary(
        uniqueKeysWithValues: all.map { ($0.id, $0) }
    )

    static func row(id: String) -> KanaRow? { byID[id] }

    static func order(of rowID: String) -> Int {
        all.firstIndex { $0.id == rowID } ?? Int.max
    }
}
