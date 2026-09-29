import Foundation

// KatakanaBasic.swift - katakana basic gojuon (46 characters).
// Fields: kana, romaji, alternates, rowID, kind, mnemonic, exampleWord, exampleRomaji, exampleMeaning
enum KatakanaBasic {
    static let all: [Kana] = [
        .kata("ア", "a", [], "a", .basic, "Angular A - a sharp peak with a slanted leg, less round than hiragana あ, still saying a.", "アイス", "aisu", "ice cream"),
        .kata("イ", "i", [], "a", .basic, "Two clean diagonal strokes like a slanted lowercase i, thinner and straighter than い, sounding i.", "イス", "isu", "chair"),
        .kata("ウ", "u", [], "a", .basic, "A flat roof over a bent leg - an angular hut, unlike rounded う, that shelters the sound u.", "ウイルス", "uirusu", "virus"),
        .kata("エ", "e", [], "a", .basic, "Like a capital E laid into straight girders, all right angles, plainly saying e.", "エレベーター", "erebeetaa", "elevator"),
        .kata("オ", "o", [], "a", .basic, "A crossed pole with a flicked tail - the odd O of katakana, bold and straight, sounding o.", "オレンジ", "orenji", "orange"),

        .kata("カ", "ka", [], "ka", .basic, "A hard angled corner like a can opener handle - a crisp ka, sharper than curvy か.", "カメラ", "kamera", "camera"),
        .kata("キ", "ki", [], "ka", .basic, "Two horizontal slashes on a leaning post - a key made of straight strokes, saying ki.", "キウイ", "kiui", "kiwi fruit"),
        .kata("ク", "ku", [], "ka", .basic, "A swooping arrowhead with one short leg - cuckoo sharp and angular, sounding ku.", "クラス", "kurasu", "class"),
        .kata("ケ", "ke", [], "ka", .basic, "A narrow blade with a kicked-out foot - straight-edged ke, like a pared-down け.", "ケーキ", "keeki", "cake"),
        .kata("コ", "ko", [], "ka", .basic, "Two right angles stacked like an open box lid - a square ko, not the loop of こ.", "コーヒー", "koohii", "coffee"),

        .kata("サ", "sa", [], "sa", .basic, "Three straight strokes crossed by one bar - a scaffolding that says sa.", "サラダ", "sarada", "salad"),
        .kata("シ", "shi", ["si"], "sa", .basic, "Three short dashes stacked to the left - she slides in from the side, saying shi.", "シャツ", "shatsu", "shirt"),
        .kata("ス", "su", [], "sa", .basic, "A slanted stroke with a pointed boot - a swift swoosh, sharper than す, sounding su.", "スープ", "suupu", "soup"),
        .kata("セ", "se", [], "sa", .basic, "An upright post crossed by a broad slash - a lean se, straighter than the looped せ.", "セーター", "seetaa", "sweater"),
        .kata("ソ", "so", [], "sa", .basic, "Two quick dashes falling to the right - a swift so, unlike the looping そ.", "ソファ", "sofaa", "sofa"),

        .kata("タ", "ta", [], "ta", .basic, "A slanted blade over a crossed pole - tough and angular, sounding ta.", "タクシー", "takushii", "taxi"),
        .kata("チ", "chi", ["ti"], "ta", .basic, "A bar over a bending leg like a chevron - cheery chi, straighter than ち.", "チーズ", "chiizu", "cheese"),
        .kata("ツ", "tsu", ["tu"], "ta", .basic, "Three short strokes sweeping rightward - a tsunami of straight lines saying tsu.", "ツアー", "tsuaa", "tour"),
        .kata("テ", "te", [], "ta", .basic, "A long bar over a bent hook - a table of straight strokes, saying te.", "テレビ", "terebi", "television"),
        .kata("ト", "to", [], "ta", .basic, "A single upright with one short slash - a totem pole, minimal and straight, saying to.", "トマト", "tomato", "tomato"),

        .kata("ナ", "na", [], "na", .basic, "A cross with one long arm and a short leg - a knife-straight na, unlike な.", "ナイフ", "naifu", "knife"),
        .kata("ニ", "ni", [], "na", .basic, "Two parallel bars at knee height - the simplest katakana, ni, with no curl at all.", "ニュース", "nyuusu", "news"),
        .kata("ヌ", "nu", [], "na", .basic, "A crossed slash with a curling tail - a noodle of straight strokes, sounding nu.", "ヌードル", "nuudoru", "noodle"),
        .kata("ネ", "ne", [], "na", .basic, "A cross atop a bending stem - a net of sharp lines, saying ne.", "ネクタイ", "nekutai", "necktie"),
        .kata("ノ", "no", [], "na", .basic, "One bold diagonal slash - a single no, the most minimal stroke in the syllabary.", "ノート", "nooto", "notebook"),

        .kata("ハ", "ha", [], "ha", .basic, "Two strokes splitting like a little hut roof - a hearty ha, wide open.", "ハンバーガー", "hanbaagaa", "hamburger"),
        .kata("ヒ", "hi", [], "ha", .basic, "A vertical with a hooked foot - a high heel of straight lines, saying hi.", "ヒーター", "hiitaa", "heater"),
        .kata("フ", "fu", ["hu"], "ha", .basic, "One stroke bent like a flag - a fu that looks light enough to float, unlike looped ふ.", "フランス", "furansu", "France"),
        .kata("ヘ", "he", [], "ha", .basic, "A single angular chevron, dead straight - a he that is just one bent line.", "ヘルメット", "herumetto", "helmet"),
        .kata("ホ", "ho", [], "ha", .basic, "A cross with two small legs at the base - a whole hop of straight lines, saying ho.", "ホテル", "hoteru", "hotel"),

        .kata("マ", "ma", [], "ma", .basic, "Two short strokes hooked from a diagonal - a shopping cart silhouette, saying ma.", "マスク", "masuku", "mask"),
        .kata("ミ", "mi", [], "ma", .basic, "Three stacked diagonal dashes - a mi of strokes, like a musical note made angular.", "ミルク", "miruku", "milk"),
        .kata("ム", "mu", [], "ma", .basic, "A triangle with a crossing leg - a movable mu, all corners, no curve of む.", "ムード", "muudo", "mood"),
        .kata("メ", "me", [], "ma", .basic, "A cross like a star scribble - a me of two sharp strokes, no roundabout め.", "メニュー", "menyuu", "menu"),
        .kata("モ", "mo", [], "ma", .basic, "Two bars over a bending hook - a mo like a simplified も, straight and spare.", "モデル", "moderu", "model"),

        .kata("ヤ", "ya", [], "ya", .basic, "A sloping bar with two strokes crossing it - a yard-arm shape, saying ya.", "タイヤ", "taiya", "tire"),
        .kata("ユ", "yu", [], "ya", .basic, "Two right angles joined like a bent pipe - a unique yu, all corners, unlike ゆ.", "ユーモア", "yuumoa", "humor"),
        .kata("ヨ", "yo", [], "ya", .basic, "Three bars stacked on a spine - a comb of straight strokes, saying yo, not looped よ.", "ヨーグルト", "yooguruto", "yogurt"),

        .kata("ラ", "ra", [], "ra", .basic, "A bar over a hooked leg - a ladder rung that says ra, straighter than ら.", "ラジオ", "rajio", "radio"),
        .kata("リ", "ri", [], "ra", .basic, "Two vertical strokes of unequal height - a ri like a small reed pair, no curl.", "リスト", "risuto", "list"),
        .kata("ル", "ru", [], "ra", .basic, "Two strokes with one hooked up at the end - a rooted ru, unlike looped る.", "ルール", "ruuru", "rule"),
        .kata("レ", "re", [], "ra", .basic, "One stroke with a flick to the right - a lean bent re, straighter than れ.", "レストラン", "resutoran", "restaurant"),
        .kata("ロ", "ro", [], "ra", .basic, "A clean empty square box - a ro with four right angles, unlike round ろ.", "ロボット", "robotto", "robot"),

        .kata("ワ", "wa", [], "wa", .basic, "A boxy shape with a slanted side - a wide-open wa, unlike looping わ.", "ワイン", "wain", "wine"),
        .kata("ヲ", "wo", ["o"], "wa", .basic, "A short bar over a bent leg - the katakana wo, a particle rarely written this way.", "ヲ", "o", "object particle (rare in katakana)"),

        .kata("ン", "n", ["nn"], "n", .basic, "A short stroke climbing to the right - a single nasal n, unlike ソ.", "パン", "pan", "bread")
    ]
}
