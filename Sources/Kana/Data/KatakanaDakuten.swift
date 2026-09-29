import Foundation

// KatakanaDakuten.swift - katakana dakuten and handakuten gojuon (25 characters).
// Fields: kana, romaji, alternates, rowID, kind, mnemonic, exampleWord, exampleRomaji, exampleMeaning
enum KatakanaDakuten {
    static let all: [Kana] = [
        .kata("ガ", "ga", [], "ga", .dakuten, "カ with two noisy flags on its shoulder - the same ka shape, now hardened into g.", "ガラス", "garasu", "glass"),
        .kata("ギ", "gi", [], "ga", .dakuten, "キ wearing two small marks - the same ki skeleton, now buzzing with g.", "ギター", "gitaa", "guitar"),
        .kata("グ", "gu", [], "ga", .dakuten, "ク plus two ticks that roughen the sound - the same swoosh, now grownling gu.", "グループ", "guruupu", "group"),
        .kata("ゲ", "ge", [], "ga", .dakuten, "ケ with a voiced pair of specks - a blade of ke that now cuts as ge.", "ゲーム", "geemu", "game"),
        .kata("ゴ", "go", [], "ga", .dakuten, "コ with two small flags - the boxy ko shape, now voiced as go.", "ゴルフ", "gorufu", "golf"),

        .kata("ザ", "za", [], "za", .dakuten, "サ holding two buzzing marks - the same scaffold, now said za.", "ピザ", "piza", "pizza"),
        .kata("ジ", "ji", ["zi"], "za", .dakuten, "シ with two ticks - the same three dashes now buzz into ji.", "ジーンズ", "jiinzu", "jeans"),
        .kata("ズ", "zu", [], "za", .dakuten, "ス plus a voiced pair - the same swoosh, now humming as zu.", "ズボン", "zubon", "trousers"),
        .kata("ゼ", "ze", [], "za", .dakuten, "セ carrying two specks - the lean se now sounds as ze.", "ゼリー", "zerii", "jelly"),
        .kata("ゾ", "zo", [], "za", .dakuten, "ソ with two small flags - the same falling dashes, now voiced zo.", "ゾーン", "zoon", "zone"),

        .kata("ダ", "da", [], "da", .dakuten, "タ wearing two marks - the same blade, now thudding out da.", "ダンス", "dansu", "dance"),
        .kata("ヂ", "ji", ["di", "dji"], "da", .dakuten, "チ with voicing marks, a ji nearly extinct today and almost always written ジ.", "ヂ", "ji", "rare katakana ji, normally written with the common ji kana"),
        .kata("ヅ", "zu", ["du", "dzu"], "da", .dakuten, "ツ plus two ticks, a rare zu that modern katakana almost always writes ズ.", "ヅ", "zu", "rare katakana zu, normally written with the common zu kana"),
        .kata("デ", "de", [], "da", .dakuten, "テ with two voiced specks - the same bar and hook, now sounding de.", "デザート", "dezaato", "dessert"),
        .kata("ド", "do", [], "da", .dakuten, "ト wearing two flags - the same upright post, now booming do.", "ドア", "doa", "door"),

        .kata("バ", "ba", [], "ba", .dakuten, "ハ with two marks - the open roof now buzzes as ba.", "バス", "basu", "bus"),
        .kata("ビ", "bi", [], "ba", .dakuten, "ヒ plus a voiced pair - the same heel now sounds bi.", "ビール", "biiru", "beer"),
        .kata("ブ", "bu", [], "ba", .dakuten, "フ carrying two specks - the light flag now lands as bu.", "ブラシ", "burashi", "brush"),
        .kata("ベ", "be", [], "ba", .dakuten, "ヘ with two voiced ticks - the same chevron now says be.", "ベッド", "beddo", "bed"),
        .kata("ボ", "bo", [], "ba", .dakuten, "ホ wearing two marks - the cross and its legs now ring as bo.", "ボール", "booru", "ball"),

        .kata("パ", "pa", [], "pa", .dakuten, "ハ with a small circle instead - a puff of p turns ha into pa.", "パーティー", "paatii", "party"),
        .kata("ピ", "pi", [], "pa", .dakuten, "ヒ plus a tiny circle - the same heel pops out pi.", "ピアノ", "piano", "piano"),
        .kata("プ", "pu", [], "pa", .dakuten, "フ with a small ring - the flag now pops as pu.", "プール", "puuru", "pool"),
        .kata("ペ", "pe", [], "pa", .dakuten, "ヘ carrying a circle - the chevron puffs into pe.", "ペン", "pen", "pen"),
        .kata("ポ", "po", [], "pa", .dakuten, "ホ with a small circle - the cross now pops as po.", "ポスト", "posuto", "postbox")
    ]
}
