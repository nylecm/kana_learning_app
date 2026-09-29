import Foundation

// HiraganaDakuten.swift — dakuten and handakuten rows, 25 characters.
// Fields: kana, romaji, alternates, rowID, kind, mnemonic, exampleWord, exampleRomaji, exampleMeaning
enum HiraganaDakuten {
    static let all: [Kana] = [
        .hira("が", "ga", [], "ga", .dakuten, "か with a noisy flag on its shoulder — the k hardens into g, giving ga.", "がっこう", "gakkou", "school"),
        .hira("ぎ", "gi", [], "ga", .dakuten, "き plus two small dashes that turn k into g — gi, the start of giggle.", "ぎんこう", "ginkou", "bank"),
        .hira("ぐ", "gu", [], "ga", .dakuten, "く with a small flag that makes it gruff — gu, the start of gulp.", "ぐあい", "guai", "condition"),
        .hira("げ", "ge", [], "ga", .dakuten, "け wearing two dashes that harden k into g — ge, the start of gate.", "げんき", "genki", "healthy"),
        .hira("ご", "go", [], "ga", .dakuten, "こ with a noisy flag, turning ko into go — go, the start of going.", "ごはん", "gohan", "rice"),

        .hira("ざ", "za", [], "za", .dakuten, "さ with a buzzing zigzag flag that turns s into z — za, the start of zap.", "ざっし", "zasshi", "magazine"),
        .hira("じ", "ji", ["zi"], "za", .dakuten, "し plus a humming flag that turns a hush into a buzz — ji, the start of jeep.", "じかん", "jikan", "time"),
        .hira("ず", "zu", [], "za", .dakuten, "す with two dashes that hum s into z — zu, the start of zoo.", "ずっと", "zutto", "always"),
        .hira("ぜ", "ze", [], "za", .dakuten, "せ wearing a buzz that swaps s for z — ze, the start of zebra.", "ぜんぶ", "zenbu", "all"),
        .hira("ぞ", "zo", [], "za", .dakuten, "そ with a noisy flag, buzzing s into z — zo, the start of zone.", "ぞう", "zou", "elephant"),

        .hira("だ", "da", [], "da", .dakuten, "た with a hard little flag, turning t into d — da, the start of dad.", "だいがく", "daigaku", "university"),
        .hira("ぢ", "ji", ["di", "dji"], "da", .dakuten, "ち plus dakuten, the rare twin of じ — ぢ is also said ji.", "ちぢむ", "chijimu", "to shrink"),
        .hira("づ", "zu", ["du", "dzu"], "da", .dakuten, "つ plus dakuten, the rare twin of ず — づ is also said zu.", "つづく", "tsuzuku", "to continue"),
        .hira("で", "de", [], "da", .dakuten, "て wearing one small flag, turning te into de — de, the start of deck.", "でんわ", "denwa", "telephone"),
        .hira("ど", "do", [], "da", .dakuten, "と with a flag that hardens t into d — do, the first note of the scale.", "どうぞ", "douzo", "please"),

        .hira("ば", "ba", [], "ba", .dakuten, "は with a flag, popping h into b — ba, the start of babble.", "ばしょ", "basho", "place"),
        .hira("び", "bi", [], "ba", .dakuten, "ひ plus dakuten, turning h into b — bi, the start of busy.", "びょういん", "byouin", "hospital"),
        .hira("ぶ", "bu", [], "ba", .dakuten, "ふ wearing a flag that puffs h into b — bu, the start of buzz.", "ぶた", "buta", "pig"),
        .hira("べ", "be", [], "ba", .dakuten, "へ with two dashes, changing h into b — be, the start of bell.", "べんきょう", "benkyou", "study"),
        .hira("ぼ", "bo", [], "ba", .dakuten, "ほ with one flag, turning h into b — bo, the start of bounce.", "ぼうし", "boushi", "hat"),

        .hira("ぱ", "pa", [], "pa", .dakuten, "は with a small circle, popping h into p — pa, the start of popcorn.", "ぱん", "pan", "bread"),
        .hira("ぴ", "pi", [], "pa", .dakuten, "ひ wearing a circle that pops h into p — pi, the start of pizza.", "ぴあの", "piano", "piano"),
        .hira("ぷ", "pu", [], "pa", .dakuten, "ふ with a circle, puffing h into p — pu, the start of pudding.", "おんぷ", "onpu", "musical note"),
        .hira("ぺ", "pe", [], "pa", .dakuten, "へ with a circle, popping h into p — pe, the start of pencil.", "ぺこぺこ", "pekopeko", "starving"),
        .hira("ぽ", "po", [], "pa", .dakuten, "ほ with a circle that pops h into p — po, the start of pocket.", "さんぽ", "sanpo", "walk")
    ]
}
