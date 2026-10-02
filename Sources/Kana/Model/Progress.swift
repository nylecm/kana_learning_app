import Foundation

/// The four grades shown to the learner, mapped onto SM-2 qualities.
enum Grade: Int, CaseIterable, Identifiable, Sendable {
    case again = 0
    case hard
    case good
    case easy

    var id: Int { rawValue }

    var title: String {
        switch self {
        case .again: "Again"
        case .hard: "Hard"
        case .good: "Good"
        case .easy: "Easy"
        }
    }

    /// The key that selects this grade in flip mode.
    var keyLabel: String { String(rawValue + 1) }

    var sm2Quality: Int {
        switch self {
        case .again: 2
        case .hard: 3
        case .good: 4
        case .easy: 5
        }
    }

    var isCorrect: Bool { self != .again }
}

/// Where a card sits in the SM-2 lifecycle.
enum CardPhase: String, Codable, Sendable {
    case new
    case learning
    case review
}

/// Everything the scheduler remembers about one card.
struct CardProgress: Codable, Hashable, Sendable {
    var phase: CardPhase = .new
    var reviews: Int = 0
    var correct: Int = 0
    var lapses: Int = 0
    var ease: Double = 2.5
    var intervalDays: Double = 0
    var learningStep: Int = 0
    var due: Date = .distantPast
    var lastReviewed: Date?

    var accuracy: Double { reviews == 0 ? 0 : Double(correct) / Double(reviews) }

    /// The spec's definition of a card the learner keeps getting wrong.
    var isStruggling: Bool { lapses >= 3 || (reviews >= 5 && accuracy < 0.70) }

    var isMature: Bool { phase == .review && intervalDays >= 21 }

    var isStarted: Bool { reviews > 0 }

    /// How hard this card is fighting back: 0 is solid, 1 is struggling. Feeds the kana chart's heat
    /// map, so it deliberately mixes the three signals the scheduler already keeps.
    ///
    /// Seven tenths of it is how often the card has been missed — the most legible signal, and one a
    /// card can be bad at from its first answer — a fifth how often it has been forgotten outright,
    /// which is the signal the spec's own struggling rule leans on, and the rest how far the
    /// scheduler has had to push the ease down, which shows up before the score does. A card
    /// answered right every time lands on 0; one answered wrong every time is already deep in the
    /// red without needing a single lapse.
    var struggle: Double {
        guard isStarted else { return 0 }
        let missRate = 1 - accuracy
        let lapseLoad = min(Double(lapses) / 3, 1)
        let easeLoad = min(max((2.5 - ease) / 1.2, 0), 1)
        return min(1, missRate * 0.7 + lapseLoad * 0.2 + easeLoad * 0.1)
    }

    /// How much evidence sits behind `struggle`, which the heat map uses as its opacity: one lucky
    /// answer should look faint rather than confidently green.
    var heatConfidence: Double { min(1, Double(reviews) / 3) }
}

/// Per-day counters, keyed by local date, used for the daily limits.
struct DayLog: Codable, Hashable, Sendable {
    var newIntroduced: Int = 0
    var reviews: Int = 0
}
