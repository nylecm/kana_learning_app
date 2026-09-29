import Foundation

// KatakanaYoon.swift - katakana yoon combinations with small ヤ ユ ヨ (33 characters).
// Fields: kana, romaji, alternates, rowID, kind, mnemonic, exampleWord, exampleRomaji, exampleMeaning
enum KatakanaYoon {
    static let all: [Kana] = [
        .kata("キャ", "kya", [], "kya", .yoon, "キ plus a small ヤ - the ki sound slides into kya, snapping sharp in katakana.", "キャンプ", "kyanpu", "camp"),
        .kata("キュ", "kyu", [], "kya", .yoon, "キ with a small ユ pressed on - ki merges into the cute sound kyu.", "キュート", "kyuuto", "cute"),
        .kata("キョ", "kyo", [], "kya", .yoon, "キ plus a small ヨ - ki slides sideways into kyo.", "キョン", "kyon", "Reeves's muntjac (a small deer)"),

        .kata("シャ", "sha", ["sya"], "sha", .yoon, "シ and a small ヤ - shi glides into sha, all straight strokes.", "シャツ", "shatsu", "shirt"),
        .kata("シュ", "shu", ["syu"], "sha", .yoon, "シ with a small ユ - shi rounds off into shu.", "シューズ", "shuuzu", "shoes"),
        .kata("ショ", "sho", ["syo"], "sha", .yoon, "シ plus a small ヨ - shi glides into sho.", "ショップ", "shoppu", "shop"),

        .kata("チャ", "cha", ["tya", "cya"], "cha", .yoon, "チ with a small ヤ - chi snaps into cha.", "チャンス", "chansu", "chance"),
        .kata("チュ", "chu", ["tyu", "cyu"], "cha", .yoon, "チ and a small ユ - chi turns into chu.", "チューリップ", "chuurippu", "tulip"),
        .kata("チョ", "cho", ["tyo", "cyo"], "cha", .yoon, "チ plus a small ヨ - chi glides into cho, as in chocolate.", "チョコレート", "chokoreeto", "chocolate"),

        .kata("ニャ", "nya", [], "nya", .yoon, "ニ and a small ヤ - ni melts into the catlike nya.", "ニャー", "nyaa", "meow"),
        .kata("ニュ", "nyu", [], "nya", .yoon, "ニ plus a small ユ - ni narrows into nyu.", "ニュース", "nyuusu", "news"),
        .kata("ニョ", "nyo", [], "nya", .yoon, "ニ with a small ヨ - ni slants into nyo.", "ニョッキ", "nyokki", "gnocchi"),

        .kata("ヒャ", "hya", [], "hya", .yoon, "ヒ plus a small ヤ - hi thins into the rare hya.", "ヒャッ", "hyah", "a startled shriek"),
        .kata("ヒュ", "hyu", [], "hya", .yoon, "ヒ and a small ユ - hi funnels into hyu, as in a fuse.", "ヒューズ", "hyuuzu", "fuse"),
        .kata("ヒョ", "hyo", [], "hya", .yoon, "ヒ with a small ヨ - hi slides into the rare hyo.", "ヒョイ", "hyoi", "casually, with a hop"),

        .kata("ミャ", "mya", [], "mya", .yoon, "ミ plus a small ヤ - mi stretches into mya.", "ミャンマー", "myanmaa", "Myanmar"),
        .kata("ミュ", "myu", [], "mya", .yoon, "ミ and a small ユ - mi rounds into myu, as in music.", "ミュージック", "myuujikku", "music"),
        .kata("ミョ", "myo", [], "mya", .yoon, "ミ with a small ヨ - mi bends into myo.", "ミョウガ", "myouga", "myoga ginger"),

        .kata("リャ", "rya", [], "rya", .yoon, "リ plus a small ヤ - ri flicks into rya.", "リャマ", "ryama", "llama"),
        .kata("リュ", "ryu", [], "rya", .yoon, "リ and a small ユ - ri turns into ryu, as in a backpack.", "リュック", "ryuuku", "backpack"),
        .kata("リョ", "ryo", [], "rya", .yoon, "リ with a small ヨ - ri slides into the rare ryo.", "リョウ", "ryou", "Ryo, a Japanese given name"),

        .kata("ギャ", "gya", [], "gya", .yoon, "ギ plus a small ヤ - the voiced gi snaps into gya.", "ギャップ", "gyappu", "gap"),
        .kata("ギュ", "gyu", [], "gya", .yoon, "ギ with a small ユ - gi squeezes into gyu.", "ギュッ", "gyu", "a tight squeeze"),
        .kata("ギョ", "gyo", [], "gya", .yoon, "ギ and a small ヨ - gi slides into gyo, as in gyoza.", "ギョーザ", "gyooza", "gyoza dumplings"),

        .kata("ジャ", "ja", ["zya"], "ja", .yoon, "ジ plus a small ヤ - the voiced ji broadens into ja.", "ジャム", "jamu", "jam"),
        .kata("ジュ", "ju", ["zyu"], "ja", .yoon, "ジ with a small ユ - ji turns into ju, as in juice.", "ジュース", "juusu", "juice"),
        .kata("ジョ", "jo", ["zyo"], "ja", .yoon, "ジ and a small ヨ - ji slides into jo, as in jogging.", "ジョギング", "joggingu", "jogging"),

        .kata("ビャ", "bya", [], "bya", .yoon, "ビ plus a small ヤ - bi bends into the rare bya.", "ビャンビャン", "byanbyan", "biang biang (Chinese wheat noodles)"),
        .kata("ビュ", "byu", [], "bya", .yoon, "ビ with a small ユ - bi rounds into byu, as in a buffet.", "ビュー", "byuu", "view"),
        .kata("ビョ", "byo", [], "bya", .yoon, "ビ and a small ヨ - bi leans into the rare byo.", "ビョーク", "byooku", "Bjork, an Icelandic singer"),

        .kata("ピャ", "pya", [], "pya", .yoon, "ピ plus a small ヤ - pi pops into the rare pya.", "ピャッ", "pyah", "a sharp squeak"),
        .kata("ピュ", "pyu", [], "pya", .yoon, "ピ with a small ユ - pi purifies into pyu.", "ピュア", "pyua", "pure"),
        .kata("ピョ", "pyo", [], "pya", .yoon, "ピ and a small ヨ - pi springs into pyo, as in hopping.", "ピョンピョン", "pyonpyon", "hopping")
    ]
}
