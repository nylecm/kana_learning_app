import Foundation

/// Pure deck-building logic (spec.md §9). `Int.max` means "no limit".
enum Deck {
    /// The set of cards a session may draw from.
    static func pool(
        library: [Kana],
        script: KanaScript?,
        scope: Scope,
        selectedIDs: Set<String>,
        progress: [String: CardProgress]
    ) -> [Kana] {
        switch scope {
        case .struggling:
            // Deliberately ignores the script filter and the due schedule.
            return library
                .filter { progress[$0.id]?.isStruggling == true }
                .sorted { lhs, rhs in
                    let left = progress[lhs.id] ?? CardProgress()
                    let right = progress[rhs.id] ?? CardProgress()
                    if left.accuracy != right.accuracy { return left.accuracy < right.accuracy }
                    if left.lapses != right.lapses { return left.lapses > right.lapses }
                    if lhs.script != rhs.script { return lhs.script == .hiragana }
                    return KanaRows.order(of: lhs.rowID) < KanaRows.order(of: rhs.rowID)
                }

        case .all, .selected:
            var cards = library
            if let script { cards = cards.filter { $0.script == script } }
            if scope == .selected { cards = cards.filter { selectedIDs.contains($0.id) } }
            return cards
        }
    }

    /// The ordered queue for a session: due learning cards, then due reviews, then new cards.
    static func queue(
        pool: [Kana],
        scope: Scope,
        progress: [String: CardProgress],
        now: Date,
        newLimit: Int,
        reviewLimit: Int,
        ignoreDue: Bool
    ) -> [Kana] {
        // A Struggling session is a deliberate cram: no schedule, no caps.
        if scope == .struggling { return pool }

        func state(_ card: Kana) -> CardProgress { progress[card.id] ?? CardProgress() }

        let learningDue = pool
            .filter { state($0).phase == .learning && (ignoreDue || state($0).due <= now) }
            .sorted { state($0).due < state($1).due }

        let reviewDue = pool
            .filter { state($0).phase == .review && (ignoreDue || state($0).due <= now) }
            .sorted { state($0).due < state($1).due }

        let unseen = pool.filter { state($0).phase == .new }

        let reviews = reviewLimit == Int.max ? reviewDue : Array(reviewDue.prefix(reviewLimit))
        let news = newLimit == Int.max ? unseen : Array(unseen.prefix(newLimit))
        return learningDue + reviews + news
    }

    /// Cards ready to be shown right now — drives the "due today" counter on the home screen.
    static func dueCount(
        pool: [Kana],
        scope: Scope,
        progress: [String: CardProgress],
        now: Date
    ) -> Int {
        if scope == .struggling { return pool.count }
        return pool.filter {
            let state = progress[$0.id] ?? CardProgress()
            return (state.phase == .learning || state.phase == .review) && state.due <= now
        }.count
    }

    static func newCount(pool: [Kana], progress: [String: CardProgress]) -> Int {
        pool.filter { (progress[$0.id] ?? CardProgress()).phase == .new }.count
    }
}
