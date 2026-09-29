import Foundation

/// One sitting. Owns the card queue, per-card presentation state, and the session score.
///
/// Grading is delegated upward through `onGrade` (the model owns persistence), which returns the
/// card's new phase so the session knows whether to bring the card back before the sitting ends.
@MainActor
@Observable
final class StudySession {
    enum Stage {
        case asking
        case feedback
    }

    struct Answer: Identifiable {
        let id = UUID()
        let kana: Kana
        let grade: Grade
    }

    let title: String
    let scope: Scope
    let plannedMode: AnswerMode
    let pool: [Kana]
    let plannedTotal: Int

    private(set) var queue: [Kana]
    private(set) var current: Kana?
    private(set) var choices: [String] = []
    private(set) var stage: Stage = .asking
    private(set) var lastGrade: Grade?
    private(set) var pickedChoice: String?
    private(set) var typedAnswer = ""
    private(set) var presentationIndex = 0
    private(set) var answers: [Answer] = []
    private(set) var finished = false

    private var answeredIDs: Set<String> = []
    private let onGrade: (Kana, Grade) -> CardPhase

    init(
        title: String,
        scope: Scope,
        mode: AnswerMode,
        pool: [Kana],
        queue: [Kana],
        onGrade: @escaping (Kana, Grade) -> CardPhase
    ) {
        self.title = title
        self.scope = scope
        self.plannedMode = mode
        self.pool = pool
        self.queue = queue
        self.onGrade = onGrade
        self.plannedTotal = Set(queue.map(\.id)).count
        advance()
    }

    /// The answer mode for the card on screen right now (resolves `.mixed`).
    var mode: AnswerMode { plannedMode.resolved(forCardAt: presentationIndex) }

    var answeredCount: Int { answeredIDs.count }

    var progress: Double { plannedTotal == 0 ? 0 : Double(answeredCount) / Double(plannedTotal) }

    var correctCount: Int { answers.filter { $0.grade.isCorrect }.count }

    var accuracy: Double { answers.isEmpty ? 0 : Double(correctCount) / Double(answers.count) }

    var lastAnswerWasCorrect: Bool { lastGrade?.isCorrect ?? false }

    var gradeCounts: [Grade: Int] {
        var counts: [Grade: Int] = [:]
        for answer in answers { counts[answer.grade, default: 0] += 1 }
        return counts
    }

    /// Cards that were wrong at least once on the first pass — the session's "worth revisiting".
    var difficultCards: [Kana] {
        var seen = Set<String>()
        var result: [Kana] = []
        for answer in answers where !answer.grade.isCorrect {
            if seen.insert(answer.kana.id).inserted { result.append(answer.kana) }
        }
        return result
    }

    // MARK: - Actions

    func reveal() {
        guard stage == .asking, mode == .flip, current != nil else { return }
        stage = .feedback
    }

    func setTypedAnswer(_ text: String) {
        typedAnswer = text
    }

    func answerChoice(_ option: String) {
        guard stage == .asking, mode == .choice, let card = current else { return }
        pickedChoice = option
        apply(card.accepts(typed: option) ? .good : .again)
    }

    func submitTyped() {
        guard stage == .asking, mode == .typing, let card = current else { return }
        apply(card.accepts(typed: typedAnswer) ? .good : .again)
    }

    /// Flip mode grades itself: applying a grade also moves on.
    func gradeFlip(_ grade: Grade) {
        guard stage == .feedback, mode == .flip, current != nil else { return }
        apply(grade)
        advance()
    }

    func continueToNext() {
        guard stage == .feedback, mode != .flip else { return }
        advance()
    }

    func end() {
        finished = true
        current = nil
        queue = []
    }

    // MARK: - Internals

    private func apply(_ grade: Grade) {
        guard let card = current else { return }
        let phase = onGrade(card, grade)
        lastGrade = grade
        answers.append(Answer(kana: card, grade: grade))
        answeredIDs.insert(card.id)
        stage = .feedback

        // A card still in its learning steps comes back before the sitting ends.
        if phase == .learning {
            let offset = grade == .again ? 3 : 6
            queue.insert(card, at: min(offset, queue.count))
        }
    }

    private func advance() {
        stage = .asking
        lastGrade = nil
        pickedChoice = nil
        typedAnswer = ""
        choices = []

        guard !queue.isEmpty else {
            current = nil
            finished = true
            return
        }

        let card = queue.removeFirst()
        current = card
        presentationIndex += 1
        if mode == .choice { choices = makeChoices(for: card) }
    }

    /// Three distractors: same row first, then same kind, then anything — never a duplicate rōmaji.
    private func makeChoices(for card: Kana) -> [String] {
        let sameRow = pool.filter { $0.script == card.script && $0.rowID == card.rowID }
        let sameKind = pool.filter { $0.script == card.script && $0.kind == card.kind }

        var picked: [String] = []
        for candidate in sameRow.shuffled() + sameKind.shuffled() + pool.shuffled() {
            if picked.count == 3 { break }
            if candidate.romaji == card.romaji { continue }
            if picked.contains(candidate.romaji) { continue }
            picked.append(candidate.romaji)
        }
        return ([card.romaji] + picked).shuffled()
    }
}
