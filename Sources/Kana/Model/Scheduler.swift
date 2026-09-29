import Foundation

/// The SM-2 derived scheduler described in spec.md §7.
///
/// New cards walk two learning steps (1 min, 10 min) before graduating to a 1-day interval.
/// Review cards are rescheduled from their interval and ease factor, with a four-grade scale.
enum Scheduler {
    /// Learning steps, in seconds.
    static let learningSteps: [TimeInterval] = [60, 600]
    static let graduationIntervalDays: Double = 1
    static let easyGraduationIntervalDays: Double = 4
    static let startingEase: Double = 2.5
    static let minimumEase: Double = 1.3
    static let maximumEase: Double = 3.0

    private static let day: TimeInterval = 86_400

    /// Records one answer and moves the card to its next due date.
    static func apply(grade: Grade, to progress: inout CardProgress, now: Date) {
        progress.reviews += 1
        if grade.isCorrect { progress.correct += 1 }
        progress.lastReviewed = now

        switch progress.phase {
        case .new, .learning:
            applyLearning(grade: grade, to: &progress, now: now)
        case .review:
            applyReview(grade: grade, to: &progress, now: now)
        }
    }

    private static func applyLearning(grade: Grade, to progress: inout CardProgress, now: Date) {
        progress.phase = .learning

        switch grade {
        case .again:
            progress.learningStep = 0
            progress.due = now.addingTimeInterval(learningSteps[0])

        case .hard:
            let step = min(progress.learningStep, learningSteps.count - 1)
            progress.learningStep = step
            progress.due = now.addingTimeInterval(learningSteps[step])

        case .good:
            let next = progress.learningStep + 1
            if next >= learningSteps.count {
                graduate(to: &progress, intervalDays: graduationIntervalDays, now: now)
            } else {
                progress.learningStep = next
                progress.due = now.addingTimeInterval(learningSteps[next])
            }

        case .easy:
            graduate(to: &progress, intervalDays: easyGraduationIntervalDays, now: now)
        }
    }

    private static func graduate(to progress: inout CardProgress, intervalDays: Double, now: Date) {
        progress.phase = .review
        progress.learningStep = 0
        progress.intervalDays = intervalDays
        progress.due = now.addingTimeInterval(intervalDays * day)
    }

    private static func applyReview(grade: Grade, to progress: inout CardProgress, now: Date) {
        switch grade {
        case .again:
            progress.lapses += 1
            progress.ease = max(minimumEase, progress.ease - 0.20)
            progress.intervalDays = max(1, (progress.intervalDays * 0.5).rounded())
            progress.phase = .learning
            progress.learningStep = 0
            progress.due = now.addingTimeInterval(learningSteps[0])

        case .hard:
            progress.ease = max(minimumEase, progress.ease - 0.15)
            progress.intervalDays = max(progress.intervalDays + 1, (progress.intervalDays * 1.20).rounded())
            progress.due = now.addingTimeInterval(progress.intervalDays * day)

        case .good:
            progress.intervalDays = max(1, (progress.intervalDays * progress.ease).rounded())
            progress.due = now.addingTimeInterval(progress.intervalDays * day)

        case .easy:
            progress.ease = min(maximumEase, progress.ease + 0.10)
            progress.intervalDays = max(1, (max(progress.intervalDays, 1) * progress.ease * 1.30).rounded())
            progress.due = now.addingTimeInterval(progress.intervalDays * day)
        }
    }

    // MARK: - Grade button previews

    /// For each grade, what the interval would become — shown on the buttons so the keyboard path
    /// is as informative as the mouse path.
    static func previews(for progress: CardProgress, now: Date) -> [Grade: String] {
        var result: [Grade: String] = [:]
        for grade in Grade.allCases {
            var copy = progress
            apply(grade: grade, to: &copy, now: now)
            result[grade] = describe(interval: copy.due.timeIntervalSince(now))
        }
        return result
    }

    /// "10m", "1d", "3wk", "2mo" — short enough to sit inside a button.
    static func describe(interval: TimeInterval) -> String {
        if interval < 60 { return "<1m" }
        if interval < 3_600 { return "\(Int((interval / 60).rounded()))m" }
        if interval < day { return "\(Int((interval / 3_600).rounded()))h" }

        let days = interval / day
        if days < 14 { return "\(Int(days.rounded()))d" }
        if days < 60 { return "\(Int((days / 7).rounded()))wk" }
        if days < 365 { return "\(Int((days / 30.4).rounded()))mo" }
        return "\(Int((days / 365).rounded()))y"
    }
}
