import Foundation

// HiraganaBasic.swift — basic gojūon, 46 characters.
// Fields: kana, romaji, alternates, rowID, kind, mnemonic, exampleWord, exampleRomaji, exampleMeaning
enum HiraganaBasic {
    static let all: [Kana] = [
        .hira("あ", "a", [], "a", .basic, "A round little A with an antenna, drawn in one loop — a is for antenna.", "あめ", "ame", "rain"),
        .hira("い", "i", [], "a", .basic, "Two slim strokes leaning apart like ink lines from a pen — i for ink.", "いぬ", "inu", "dog"),
        .hira("う", "u", [], "a", .basic, "A little hook with a cap on top, curling under like a cup — u.", "うみ", "umi", "sea"),
        .hira("え", "e", [], "a", .basic, "A zigzag dancer kicking one leg out wide — e for energetic exercise.", "えき", "eki", "station"),
        .hira("お", "o", [], "a", .basic, "A round loop with a tail flying sideways — o, the first sound of oval.", "おかね", "okane", "money"),

        .hira("か", "ka", [], "ka", .basic, "A K with one extra arm waving — ka, the caw of a crow.", "かさ", "kasa", "umbrella"),
        .hira("き", "ki", [], "ka", .basic, "A key with two teeth cut across its shaft — ki, the key to the lock.", "きく", "kiku", "to listen"),
        .hira("く", "ku", [], "ka", .basic, "A single bent angle like a bird's open beak — ku, the call of a cuckoo.", "くつ", "kutsu", "shoes"),
        .hira("け", "ke", [], "ka", .basic, "A keg tipped onto its side with one tap pulled out — ke, as in keg.", "けさ", "kesa", "this morning"),
        .hira("こ", "ko", [], "ka", .basic, "Two short bars lying stacked like a coiled rope — ko, the start of coil.", "こえ", "koe", "voice"),

        .hira("さ", "sa", [], "sa", .basic, "A crossed line with a curved tail, like a fishhook — sa, the hiss of a snake.", "さかな", "sakana", "fish"),
        .hira("し", "shi", ["si"], "sa", .basic, "One smooth hook like a fish hook — shi, the quiet hush of shh.", "しお", "shio", "salt"),
        .hira("す", "su", [], "sa", .basic, "A loop with a hanging tail, like a swing rope — su, the swish of swinging.", "すし", "sushi", "sushi"),
        .hira("せ", "se", [], "sa", .basic, "A cross with a small tail, like a person seated — se, as in settle down.", "せんせい", "sensei", "teacher"),
        .hira("そ", "so", [], "sa", .basic, "A zigzag drawn like a loose thread — so, the first sound of soccer.", "そら", "sora", "sky"),

        .hira("た", "ta", [], "ta", .basic, "A cross with a small tail, tapping out a beat — ta, the tap of a drum.", "たまご", "tamago", "egg"),
        .hira("ち", "chi", ["ti"], "ta", .basic, "A cross with a curling tail, like a cheeky grin — chi, as in cheeky.", "ちず", "chizu", "map"),
        .hira("つ", "tsu", ["tu"], "ta", .basic, "One curved wave rolling to the left — tsu, the start of tsunami.", "つくえ", "tsukue", "desk"),
        .hira("て", "te", [], "ta", .basic, "A hand reaching over a rail, fingers curled — te, the start of ten.", "てがみ", "tegami", "letter"),
        .hira("と", "to", [], "ta", .basic, "A sharp thorn stuck into a toe — to, the first sound of toe.", "とり", "tori", "bird"),

        .hira("な", "na", [], "na", .basic, "A small cross with a knot at its base — na, the start of naughty.", "なつ", "natsu", "summer"),
        .hira("に", "ni", [], "na", .basic, "Two legs with a bent knee between them — ni, the start of nimble.", "にく", "niku", "meat"),
        .hira("ぬ", "nu", [], "na", .basic, "A tangled loop like a twisted rope end — nu, the start of nutshell.", "ぬの", "nuno", "cloth"),
        .hira("ね", "ne", [], "na", .basic, "A curled tail beside a post, like a resting cat — ne, the start of nest.", "ねこ", "neko", "cat"),
        .hira("の", "no", [], "na", .basic, "A single spiral swirl like a snail shell — no, the start of nothing.", "のり", "nori", "seaweed"),

        .hira("は", "ha", [], "ha", .basic, "A cross with a small loop, like a happy face waving — ha, the start of happy.", "はな", "hana", "flower"),
        .hira("ひ", "hi", [], "ha", .basic, "A wide open mouth grinning sideways — hi, the start of a hiccup laugh.", "ひと", "hito", "person"),
        .hira("ふ", "fu", ["hu"], "ha", .basic, "A shape like a small mound under a roof — fu, the start of fluffy.", "ふゆ", "fuyu", "winter"),
        .hira("へ", "he", [], "ha", .basic, "A single bent peak like a low hill ridge — he, the start of hello.", "へや", "heya", "room"),
        .hira("ほ", "ho", [], "ha", .basic, "A cross with two small bars to the right — ho, the start of hop.", "ほし", "hoshi", "star"),

        .hira("ま", "ma", [], "ma", .basic, "A ship mast with two crossbars and a sail — ma, the start of mast.", "まど", "mado", "window"),
        .hira("み", "mi", [], "ma", .basic, "A small figure stretching two arms wide — mi, the start of midnight.", "みず", "mizu", "water"),
        .hira("む", "mu", [], "ma", .basic, "A cow's head with a horn and a curled tail — mu, the start of mushroom.", "むし", "mushi", "insect"),
        .hira("め", "me", [], "ma", .basic, "An eye with a curved lid, drawn in one stroke — me, the start of memory.", "めがね", "megane", "glasses"),
        .hira("も", "mo", [], "ma", .basic, "A fishing hook with two barbs on its shank — mo, the start of more.", "もも", "momo", "peach"),

        .hira("や", "ya", [], "ya", .basic, "A slanted sail above a small hull — ya, the start of yacht.", "やま", "yama", "mountain"),
        .hira("ゆ", "yu", [], "ya", .basic, "A loop with a long tail, like a yo-yo string — yu, the start of you.", "ゆき", "yuki", "snow"),
        .hira("よ", "yo", [], "ya", .basic, "A cross with a hanging loop under it — yo, the start of yo-yo.", "よる", "yoru", "night"),

        .hira("ら", "ra", [], "ra", .basic, "A small hook tucked under a little roof — ra, the start of rabbit.", "さくら", "sakura", "cherry blossom"),
        .hira("り", "ri", [], "ra", .basic, "Two slim strokes leaning like reeds by water — ri, the start of river.", "りんご", "ringo", "apple"),
        .hira("る", "ru", [], "ra", .basic, "A looping path that curls sharply at the end — ru, the start of rubber.", "くるま", "kuruma", "car"),
        .hira("れ", "re", [], "ra", .basic, "A bent leg kicking out sideways in one stroke — re, the start of reckless.", "きれい", "kirei", "pretty"),
        .hira("ろ", "ro", [], "ra", .basic, "A winding road with an open end and no loop — ro, the start of road.", "ろく", "roku", "six"),

        .hira("わ", "wa", [], "wa", .basic, "A round hoop with a small beak attached — wa, the start of waddle.", "わたし", "watashi", "I"),
        .hira("を", "wo", ["o"], "wa", .basic, "A dancer kicking a leg beneath a cross — wo, the particle that marks an object.", "ほんをよむ", "hon o yomu", "read a book"),

        .hira("ん", "n", ["nn"], "n", .basic, "One soft squiggle like a snake's tail — n, the humming sound that ends a word.", "ほん", "hon", "book")
    ]
}
