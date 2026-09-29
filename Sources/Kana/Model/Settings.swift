import Foundation

/// How a card is presented during a session.
enum AnswerMode: String, Codable, CaseIterable, Identifiable, Sendable {
    case flip
    case choice
    case typing
    case mixed

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .flip: "Flip"
        case .choice: "Multiple choice"
        case .typing: "Type rōmaji"
        case .mixed: "Mixed"
        }
    }

    var shortName: String {
        switch self {
        case .flip: "Flip"
        case .choice: "Choice"
        case .typing: "Type"
        case .mixed: "Mixed"
        }
    }

    var blurb: String {
        switch self {
        case .flip: "See the kana, recall the sound, reveal, then grade yourself."
        case .choice: "Pick the rōmaji from four options."
        case .typing: "Type the rōmaji. shi/si and friends are both accepted."
        case .mixed: "Cycles flip → choice → typing, one card at a time."
        }
    }

    /// The mode actually used for the card at `index` (resolves `.mixed`).
    func resolved(forCardAt index: Int) -> AnswerMode {
        switch self {
        case .mixed: [AnswerMode.flip, .choice, .typing][index % 3]
        default: self
        }
    }
}

/// Which script(s) a session draws from.
enum ScriptMode: String, Codable, CaseIterable, Identifiable, Sendable {
    case hiragana
    case katakana
    case mixed

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .hiragana: "Hiragana"
        case .katakana: "Katakana"
        case .mixed: "Mixed"
        }
    }

    var keyHint: String {
        switch self {
        case .hiragana: "H"
        case .katakana: "K"
        case .mixed: "M"
        }
    }
}

/// Which slice of the library a session draws from.
enum Scope: String, Codable, CaseIterable, Identifiable, Sendable {
    case all
    case selected
    case struggling

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .all: "All"
        case .selected: "Selected"
        case .struggling: "Struggling"
        }
    }

    var keyHint: String {
        switch self {
        case .all: "1"
        case .selected: "2"
        case .struggling: "3"
        }
    }

    var blurb: String {
        switch self {
        case .all: "Every character in the chosen script."
        case .selected: "Only the characters you toggle in the chart below."
        case .struggling: "Only characters you keep failing. Ignores script and selection."
        }
    }
}

/// User preferences, persisted alongside progress.
struct Settings: Codable, Hashable, Sendable {
    var answerMode: AnswerMode = .flip
    /// New cards allowed per day. `0` means unlimited.
    var newPerDay: Int = 0
    /// Review cards allowed per day. `0` means unlimited.
    var reviewsPerDay: Int = 0
    var voiceIdentifier: String?
    var speechRate: Double = 0.42
    /// Speak the character as soon as the answer is revealed.
    var speakOnReveal: Bool = true
    /// Speak the character the moment the card appears.
    var speakOnAppear: Bool = false
}
