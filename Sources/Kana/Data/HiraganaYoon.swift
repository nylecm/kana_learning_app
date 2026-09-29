import Foundation

// HiraganaYoon.swift — yōon combinations, 33 characters.
// Fields: kana, romaji, alternates, rowID, kind, mnemonic, exampleWord, exampleRomaji, exampleMeaning
enum HiraganaYoon {
    static let all: [Kana] = [
        .hira("きゃ", "kya", [], "kya", .yoon, "き plus a small や, squashing ki and ya into one beat — kya.", "きゃく", "kyaku", "guest"),
        .hira("きゅ", "kyu", [], "kya", .yoon, "き with a small ゆ squeezed close beside it — kyu, the start of cute.", "きゅうり", "kyuuri", "cucumber"),
        .hira("きょ", "kyo", [], "kya", .yoon, "き followed by a small よ, gliding the ki sound into kyo.", "きょうと", "kyouto", "Kyoto"),

        .hira("しゃ", "sha", ["sya"], "sha", .yoon, "し plus a small や, blending shi and ya into sha.", "しゃしん", "shashin", "photograph"),
        .hira("しゅ", "shu", ["syu"], "sha", .yoon, "し with a small ゆ, sliding the hush of shi into shu.", "しゅくだい", "shukudai", "homework"),
        .hira("しょ", "sho", ["syo"], "sha", .yoon, "し followed by a small よ, becoming sho as in shop.", "しょくぱん", "shokupan", "bread loaf"),

        .hira("ちゃ", "cha", ["tya", "cya"], "cha", .yoon, "ち plus a small や, turning chi into a quick cha.", "おちゃ", "ocha", "tea"),
        .hira("ちゅ", "chu", ["tyu", "cyu"], "cha", .yoon, "ち with a small ゆ, blending into chu like a choo-choo train.", "ちゅうい", "chuui", "caution"),
        .hira("ちょ", "cho", ["tyo", "cyo"], "cha", .yoon, "ち followed by a small よ, becoming cho as in chop.", "ちょっと", "chotto", "a little"),

        .hira("にゃ", "nya", [], "nya", .yoon, "に plus a small や, softening the ni into a catlike nya.", "こんにゃく", "konnyaku", "konjac"),
        .hira("にゅ", "nyu", [], "nya", .yoon, "に with a small ゆ, squeezing together into nyu as in news.", "にゅうがく", "nyuugaku", "school entrance"),
        .hira("にょ", "nyo", [], "nya", .yoon, "に followed by a small よ, gliding smoothly into nyo.", "にょろにょろ", "nyoronyoro", "slithering"),

        .hira("ひゃ", "hya", [], "hya", .yoon, "ひ plus a small や, blending hi and ya into hya.", "ひゃく", "hyaku", "hundred"),
        .hira("ひゅ", "hyu", [], "hya", .yoon, "ひ with a small ゆ, folding together into hyu like a gust.", "ひゅうひゅう", "hyuuhyuu", "whistling wind"),
        .hira("ひょ", "hyo", [], "hya", .yoon, "ひ followed by a small よ, sliding into hyo.", "ひょう", "hyou", "leopard"),

        .hira("みゃ", "mya", [], "mya", .yoon, "み plus a small や, blending the mi and ya into mya.", "みゃく", "myaku", "pulse"),
        .hira("みゅ", "myu", [], "mya", .yoon, "み with a small ゆ, squeezed together into myu as in music.", "みゅーじっく", "myuujikku", "music"),
        .hira("みょ", "myo", [], "mya", .yoon, "み followed by a small よ, becoming myo as in mysterious.", "みょうじ", "myouji", "surname"),

        .hira("りゃ", "rya", [], "rya", .yoon, "り plus a small や, blending the ri and ya into rya.", "りゃく", "ryaku", "abbreviation"),
        .hira("りゅ", "ryu", [], "rya", .yoon, "り with a small ゆ, flowing together into ryu like a dragon.", "りゅう", "ryuu", "dragon"),
        .hira("りょ", "ryo", [], "rya", .yoon, "り followed by a small よ, becoming ryo as in a rickshaw.", "りょこう", "ryokou", "travel"),

        .hira("ぎゃ", "gya", [], "gya", .yoon, "ぎ plus a small や, blending the gi and ya into gya.", "ぎゃく", "gyaku", "reverse"),
        .hira("ぎゅ", "gyu", [], "gya", .yoon, "ぎ with a small ゆ, squeezing tight together into gyu.", "ぎゅうにゅう", "gyuunyuu", "milk"),
        .hira("ぎょ", "gyo", [], "gya", .yoon, "ぎ followed by a small よ, becoming gyo as in goldfish.", "きんぎょ", "kingyo", "goldfish"),

        .hira("じゃ", "ja", ["zya"], "ja", .yoon, "じ plus a small や, blending the ji and ya into ja.", "じゃがいも", "jagaimo", "potato"),
        .hira("じゅ", "ju", ["zyu"], "ja", .yoon, "じ with a small ゆ, sliding together into ju as in juice.", "じゅぎょう", "jugyou", "class"),
        .hira("じょ", "jo", ["zyo"], "ja", .yoon, "じ followed by a small よ, becoming jo as in journey.", "じょせい", "josei", "woman"),

        .hira("びゃ", "bya", [], "bya", .yoon, "び plus a small や, blending the bi and ya into bya.", "さんびゃく", "sanbyaku", "three hundred"),
        .hira("びゅ", "byu", [], "bya", .yoon, "び with a small ゆ, squeezed together into byu like a gale.", "びゅうびゅう", "byuubyuu", "howling wind"),
        .hira("びょ", "byo", [], "bya", .yoon, "び followed by a small よ, becoming byo as in beyond.", "びょうき", "byouki", "illness"),

        .hira("ぴゃ", "pya", [], "pya", .yoon, "ぴ plus a small や, blending the pi and ya into pya.", "ろっぴゃく", "roppyaku", "six hundred"),
        .hira("ぴゅ", "pyu", [], "pya", .yoon, "ぴ with a small ゆ, squeezed together into pyu like a whistle.", "ぴゅーま", "pyuuma", "puma"),
        .hira("ぴょ", "pyo", [], "pya", .yoon, "ぴ followed by a small よ, becoming pyo as in a rabbit hop.", "ぴょんぴょん", "pyonpyon", "hopping")
    ]
}
