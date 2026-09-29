import Foundation

/// Integrity check for the authored content tables (`swift run Kana --verify-data`).
///
/// The data files are hand-written, so this is the guard that keeps 208 cards honest: exact
/// inventory and gojūon order, no duplicate ids, no empty fields, and no example word that fails to
/// contain its own kana.
enum DataVerifier {
    /// Expected inventory, one array per gojūon row, in `KanaRows.all` order. Yōon cards are two
    /// characters each, so a row cannot be modelled as one concatenated string.
    private static let expectedHiragana: [[String]] = [
        ["あ", "い", "う", "え", "お"], ["か", "き", "く", "け", "こ"], ["さ", "し", "す", "せ", "そ"],
        ["た", "ち", "つ", "て", "と"], ["な", "に", "ぬ", "ね", "の"], ["は", "ひ", "ふ", "へ", "ほ"],
        ["ま", "み", "む", "め", "も"], ["や", "ゆ", "よ"], ["ら", "り", "る", "れ", "ろ"],
        ["わ", "を"], ["ん"],
        ["が", "ぎ", "ぐ", "げ", "ご"], ["ざ", "じ", "ず", "ぜ", "ぞ"], ["だ", "ぢ", "づ", "で", "ど"],
        ["ば", "び", "ぶ", "べ", "ぼ"], ["ぱ", "ぴ", "ぷ", "ぺ", "ぽ"],
        ["きゃ", "きゅ", "きょ"], ["しゃ", "しゅ", "しょ"], ["ちゃ", "ちゅ", "ちょ"],
        ["にゃ", "にゅ", "にょ"], ["ひゃ", "ひゅ", "ひょ"], ["みゃ", "みゅ", "みょ"],
        ["りゃ", "りゅ", "りょ"], ["ぎゃ", "ぎゅ", "ぎょ"], ["じゃ", "じゅ", "じょ"],
        ["びゃ", "びゅ", "びょ"], ["ぴゃ", "ぴゅ", "ぴょ"]
    ]

    private static let expectedKatakana: [[String]] = [
        ["ア", "イ", "ウ", "エ", "オ"], ["カ", "キ", "ク", "ケ", "コ"], ["サ", "シ", "ス", "セ", "ソ"],
        ["タ", "チ", "ツ", "テ", "ト"], ["ナ", "ニ", "ヌ", "ネ", "ノ"], ["ハ", "ヒ", "フ", "ヘ", "ホ"],
        ["マ", "ミ", "ム", "メ", "モ"], ["ヤ", "ユ", "ヨ"], ["ラ", "リ", "ル", "レ", "ロ"],
        ["ワ", "ヲ"], ["ン"],
        ["ガ", "ギ", "グ", "ゲ", "ゴ"], ["ザ", "ジ", "ズ", "ゼ", "ゾ"], ["ダ", "ヂ", "ヅ", "デ", "ド"],
        ["バ", "ビ", "ブ", "ベ", "ボ"], ["パ", "ピ", "プ", "ペ", "ポ"],
        ["キャ", "キュ", "キョ"], ["シャ", "シュ", "ショ"], ["チャ", "チュ", "チョ"],
        ["ニャ", "ニュ", "ニョ"], ["ヒャ", "ヒュ", "ヒョ"], ["ミャ", "ミュ", "ミョ"],
        ["リャ", "リュ", "リョ"], ["ギャ", "ギュ", "ギョ"], ["ジャ", "ジュ", "ジョ"],
        ["ビャ", "ビュ", "ビョ"], ["ピャ", "ピュ", "ピョ"]
    ]

    static func run() -> Bool {
        var failures: [String] = []

        func check(_ condition: Bool, _ message: String) {
            if !condition { failures.append(message) }
        }

        let library = KanaLibrary.all
        print("Kana dataset check")
        print("─────────────────────────────────────────────")

        check(library.count == 208, "expected 208 cards, found \(library.count)")

        let ids = Set(library.map(\.id))
        check(ids.count == library.count, "duplicate card ids: \(library.count - ids.count)")

        for script in KanaScript.allCases {
            let cards = library.filter { $0.script == script }
            let expected = script == .hiragana ? expectedHiragana : expectedKatakana
            let expectedKinds: [KanaKind] = KanaRows.all.map(\.kind)

            check(cards.count == 104, "\(script.displayName): expected 104 cards, found \(cards.count)")
            check(
                cards.filter { $0.kind == .basic }.count == 46,
                "\(script.displayName): expected 46 basic cards"
            )
            check(
                cards.filter { $0.kind == .dakuten }.count == 25,
                "\(script.displayName): expected 25 dakuten cards"
            )
            check(
                cards.filter { $0.kind == .yoon }.count == 33,
                "\(script.displayName): expected 33 yōon cards"
            )

            let rows = KanaLibrary.chartRows[script] ?? []
            check(rows.count == expected.count, "\(script.displayName): expected \(expected.count) chart rows, found \(rows.count)")

            for (index, row) in rows.enumerated() where index < expected.count && index < KanaRows.all.count {
                let rowDefinition = KanaRows.all[index]
                let want = expected[index]
                let got = row.map(\.kana)

                check(
                    got == want,
                    "\(script.displayName) row \(rowDefinition.id): expected \(want.joined(separator: ",")), found \(got.joined(separator: ","))"
                )
                check(
                    row.allSatisfy { $0.rowID == rowDefinition.id },
                    "\(script.displayName) row \(rowDefinition.id): a card has the wrong rowID"
                )
                check(
                    row.allSatisfy { $0.kind == expectedKinds[index] },
                    "\(script.displayName) row \(rowDefinition.id): a card has the wrong kind"
                )
            }

            print("\(script.displayName): \(cards.count) cards across \(rows.count) rows")
        }

        for card in library {
            check(!card.romaji.isEmpty, "\(card.id): empty rōmaji")
            check(card.romaji.allSatisfy { $0.isASCII && ($0.isLetter || $0 == "-") }, "\(card.id): non-ASCII rōmaji \(card.romaji)")
            check(!card.mnemonic.isEmpty, "\(card.id): empty mnemonic")
            check(card.mnemonic.count >= 20, "\(card.id): mnemonic looks too short")
            check(!card.exampleWord.isEmpty, "\(card.id): empty example word")
            check(!card.exampleRomaji.isEmpty, "\(card.id): empty example rōmaji")
            check(!card.exampleMeaning.isEmpty, "\(card.id): empty example meaning")
            check(
                card.exampleWord.contains(card.kana),
                "\(card.id): example word \(card.exampleWord) does not contain \(card.kana)"
            )
            check(
                card.exampleWord.allSatisfy { $0.isASCII } == false,
                "\(card.id): example word \(card.exampleWord) is not Japanese"
            )
            check(
                card.exampleWord.allSatisfy { $0.scriptCharacterIsCorrect(for: card.script) },
                "\(card.id): example word \(card.exampleWord) mixes scripts"
            )

            let normalizedPrimary = Kana.normalize(card.romaji)
            var seenAlternates: Set<String> = []
            for alternate in card.alternates {
                let normalized = Kana.normalize(alternate)
                check(!normalized.isEmpty, "\(card.id): empty alternate")
                check(normalized != normalizedPrimary, "\(card.id): alternate \(alternate) repeats the primary rōmaji")
                check(seenAlternates.insert(normalized).inserted, "\(card.id): duplicate alternate \(alternate)")
            }
        }

        print("Fields, alternates and example words checked for \(library.count) cards")
        print("─────────────────────────────────────────────")

        if failures.isEmpty {
            print("PASS — dataset is complete and consistent.")
            return true
        }

        print("FAIL — \(failures.count) problem(s):")
        for failure in failures.prefix(60) { print("  • \(failure)") }
        if failures.count > 60 { print("  … and \(failures.count - 60) more") }
        return false
    }
}

private extension Character {
    /// Loose check that an example word stays inside its own writing system (kana, or the
    /// prolonged-sound mark / middle dot that legitimately appear alongside them).
    func scriptCharacterIsCorrect(for script: KanaScript) -> Bool {
        if self == "ー" || self == "・" || self == "　" { return true }
        guard let scalar = unicodeScalars.first else { return false }
        switch script {
        case .hiragana:
            return (0x3041...0x309F).contains(scalar.value)
        case .katakana:
            return (0x30A0...0x30FF).contains(scalar.value)
        }
    }
}
