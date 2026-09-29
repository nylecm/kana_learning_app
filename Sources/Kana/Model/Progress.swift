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
}

/// Per-day counters, keyed by local date, used for the daily limits.
struct DayLog: Codable, Hashable, Sendable {
    var newIntroduced: Int = 0
    var reviews: Int = 0
}
