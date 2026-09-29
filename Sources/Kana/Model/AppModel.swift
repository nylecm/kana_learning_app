import AppKit
import Foundation

/// The single source of truth: the card library, the learner's progress, preferences, the kana
/// chart selection, and the active session. Persisted to `~/Library/Application Support/Kana`.
@MainActor
@Observable
final class AppModel {
    enum Tab: String, CaseIterable, Identifiable {
        case study
        case progress
        case settings

        var id: String { rawValue }

        var title: String {
            switch self {
            case .study: "Study"
            case .progress: "Progress"
            case .settings: "Settings"
            }
        }
    }

    struct ChartCursor: Equatable {
        var row = 0
        var column = 0
    }

    // MARK: - Stored state

    private(set) var progress: [String: CardProgress] = [:]
    private(set) var dailyLog: [String: DayLog] = [:]
    private(set) var lastScript: KanaScript?

    var settings = Settings() { didSet { scheduleSave() } }

    // Home screen configuration. Persisted, so the app resumes exactly where the learner left it.
    var tab: Tab = .study
    var scriptMode: ScriptMode = .hiragana { didSet { scheduleSave() } }
    var scope: Scope = .all { didSet { scheduleSave() } }
    var selectedKanaIDs: Set<String> = [] { didSet { scheduleSave() } }
    var mixedChartScript: KanaScript = .hiragana { didSet { scheduleSave() } }
    var ignoreDue = false
    var cursor = ChartCursor()

    var session: StudySession?

    let library = KanaLibrary.all
    let speech = Speech()

    private var router: KeyRouter?
    private var saveTask: Task<Void, Never>?
    private var saveFailureNotified = false

    // MARK: - Lifecycle

    init() {
        load()
    }

    /// Installs the key router and starts observing termination. Safe to call more than once.
    func start() {
        guard router == nil else { return }
        router = KeyRouter(model: self)
        router?.install()

        NotificationCenter.default.addObserver(
            forName: NSApplication.willTerminateNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            MainActor.assumeIsolated { self?.saveNow() }
        }
    }

    // MARK: - Derived: chart

    var chartScript: KanaScript {
        switch scriptMode {
        case .hiragana: .hiragana
        case .katakana: .katakana
        case .mixed: mixedChartScript
        }
    }

    var chartRows: [[Kana]] { KanaLibrary.chartRows[chartScript] ?? [] }
    var chartRowLabels: [KanaRow] { KanaLibrary.chartRowLabels[chartScript] ?? [] }

    var cursorKana: Kana? {
        let rows = chartRows
        guard rows.indices.contains(cursor.row) else { return nil }
        let row = rows[cursor.row]
        guard row.indices.contains(cursor.column) else { return nil }
        return row[cursor.column]
    }

    // MARK: - Derived: deck

    /// The script the *next* session will use. `nil` means "every script" (Struggling).
    var activeScript: KanaScript? {
        if scope == .struggling { return nil }
        switch scriptMode {
        case .hiragana: return .hiragana
        case .katakana: return .katakana
        case .mixed: return nextSessionScript
        }
    }

    /// Mixed mode alternates: whatever we did last time, do the other one.
    var nextSessionScript: KanaScript {
        guard let lastScript else { return .hiragana }
        return lastScript.other
    }

    var pool: [Kana] {
        Deck.pool(
            library: library,
            script: activeScript,
            scope: scope,
            selectedIDs: selectedKanaIDs,
            progress: progress
        )
    }

    var plannedQueue: [Kana] {
        Deck.queue(
            pool: pool,
            scope: scope,
            progress: progress,
            now: .now,
            newLimit: remainingNewLimit,
            reviewLimit: remainingReviewLimit,
            ignoreDue: ignoreDue
        )
    }

    var dueCount: Int {
        Deck.dueCount(pool: pool, scope: scope, progress: progress, now: .now)
    }

    var newCount: Int { Deck.newCount(pool: pool, progress: progress) }

    var todayLog: DayLog { dailyLog[AppModel.dayKey(Date())] ?? DayLog() }

    var remainingNewLimit: Int {
        settings.newPerDay <= 0 ? Int.max : max(0, settings.newPerDay - todayLog.newIntroduced)
    }

    var remainingReviewLimit: Int {
        settings.reviewsPerDay <= 0 ? Int.max : max(0, settings.reviewsPerDay - todayLog.reviews)
    }

    var selectionCount: Int { pool.count }

    var canStart: Bool { !plannedQueue.isEmpty }

    /// Why the session cannot start, in terms the learner can act on.
    var emptyReason: String? {
        guard !canStart else { return nil }

        switch scope {
        case .struggling:
            return "No struggling cards yet — a card shows up here after 3 lapses, or 5 reviews below 70%."

        case .selected:
            let script = activeScript
            let name = script?.displayName ?? "this deck"
            let otherScript = script?.other ?? .katakana
            let otherHasCards = library.contains { $0.script == otherScript && selectedKanaIDs.contains($0.id) }

            if otherHasCards {
                return "Nothing selected for \(name). Press T to switch the chart to \(otherScript.displayName), which does have cards."
            }
            return "Nothing selected for \(name) yet — turn on characters in the chart."

        case .all:
            if remainingNewLimit == 0 {
                return "Daily new-card limit reached. Raise it in Settings."
            }
            if remainingReviewLimit == 0 {
                return "Daily review limit reached. Raise it in Settings."
            }
            return "Everything is scheduled for later. Press S to study ahead."
        }
    }

    var sessionTitle: String {
        switch scope {
        case .struggling:
            return "Struggling cards"
        case .all:
            return "\(scriptLabel) · everything"
        case .selected:
            return "\(scriptLabel) · your selection"
        }
    }

    private var scriptLabel: String {
        if let script = activeScript, scriptMode == .mixed { return script.displayName }
        return scriptMode.displayName
    }

    // MARK: - Session control

    func startSession() {
        let queue = plannedQueue
        guard !queue.isEmpty else { return }

        if let script = activeScript { lastScript = script }

        let pool = self.pool
        session = StudySession(
            title: sessionTitle,
            scope: scope,
            mode: settings.answerMode,
            pool: pool,
            queue: queue
        ) { [weak self] card, grade in
            self?.record(card: card, grade: grade) ?? .learning
        }
        saveNow()
    }

    func endSession() {
        session?.end()
        session = nil
        speech.stop()
    }

    @discardableResult
    func record(card: Kana, grade: Grade) -> CardPhase {
        var state = progress[card.id] ?? CardProgress()
        let wasNew = state.phase == .new

        Scheduler.apply(grade: grade, to: &state, now: .now)
        progress[card.id] = state

        let key = AppModel.dayKey(Date())
        var log = dailyLog[key] ?? DayLog()
        if wasNew { log.newIntroduced += 1 } else { log.reviews += 1 }
        dailyLog[key] = log

        scheduleSave()
        return state.phase
    }

    func resetProgress() {
        progress = [:]
        dailyLog = [:]
        lastScript = nil
        session = nil
        saveNow()
    }

    // MARK: - Speech

    func speak(_ text: String) {
        speech.speak(text, voiceIdentifier: settings.voiceIdentifier, rate: Float(settings.speechRate))
    }

    func speakCurrentKana() {
        guard let card = session?.current else { return }
        speak(card.kana)
    }

    func speakCurrentWord() {
        guard let card = session?.current else { return }
        speak(card.exampleWord)
    }

    // MARK: - Chart interaction

    func moveCursor(rowDelta: Int, columnDelta: Int) {
        let rows = chartRows
        guard !rows.isEmpty else { return }

        if rowDelta != 0 {
            let next = max(0, min(rows.count - 1, cursor.row + rowDelta))
            cursor.row = next
            cursor.column = min(cursor.column, max(0, rows[next].count - 1))
        }
        if columnDelta != 0 {
            let columns = rows[cursor.row].count
            cursor.column = max(0, min(columns - 1, cursor.column + columnDelta))
        }
    }

    func toggleCursorKana() {
        guard let card = cursorKana else { return }
        if selectedKanaIDs.contains(card.id) {
            selectedKanaIDs.remove(card.id)
        } else {
            selectedKanaIDs.insert(card.id)
        }
    }

    func toggleCursorRow() {
        let rows = chartRows
        guard rows.indices.contains(cursor.row) else { return }
        let row = rows[cursor.row]
        let allSelected = row.allSatisfy { selectedKanaIDs.contains($0.id) }
        for card in row {
            if allSelected { selectedKanaIDs.remove(card.id) } else { selectedKanaIDs.insert(card.id) }
        }
    }

    func toggle(_ card: Kana) {
        if selectedKanaIDs.contains(card.id) {
            selectedKanaIDs.remove(card.id)
        } else {
            selectedKanaIDs.insert(card.id)
        }
    }

    func selectAllInChartScript() {
        selectedKanaIDs.formUnion(library.filter { $0.script == chartScript }.map(\.id))
    }

    func clearSelection() {
        selectedKanaIDs.removeAll()
    }

    func cycleAnswerMode() {
        let modes = AnswerMode.allCases
        let index = modes.firstIndex(of: settings.answerMode) ?? 0
        settings.answerMode = modes[(index + 1) % modes.count]
    }

    // MARK: - Keyboard

    /// Returns `true` when the key was consumed.
    func handleKey(_ key: KeyPress) -> Bool {
        if let session {
            return handleSessionKey(key, session: session)
        }
        guard tab == .study else { return false }
        return handleHomeKey(key)
    }

    private func handleHomeKey(_ key: KeyPress) -> Bool {
        switch key {
        case .enter:
            startSession()
            return true

        case .space:
            guard scope == .selected else { return false }
            toggleCursorKana()
            return true

        case .left:
            guard scope == .selected else { return false }
            moveCursor(rowDelta: 0, columnDelta: -1)
            return true

        case .right:
            guard scope == .selected else { return false }
            moveCursor(rowDelta: 0, columnDelta: 1)
            return true

        case .up:
            guard scope == .selected else { return false }
            moveCursor(rowDelta: -1, columnDelta: 0)
            return true

        case .down:
            guard scope == .selected else { return false }
            moveCursor(rowDelta: 1, columnDelta: 0)
            return true

        case .character(let character):
            switch character {
            case "h": scriptMode = .hiragana
            case "k": scriptMode = .katakana
            case "m": scriptMode = .mixed
            case "1": scope = .all
            case "2": scope = .selected
            case "3": scope = .struggling
            case "a": cycleAnswerMode()
            case "t": mixedChartScript = mixedChartScript.other
            case "s": ignoreDue.toggle()
            case "r":
                guard scope == .selected else { return false }
                toggleCursorRow()
            default: return false
            }
            return true

        case .escape:
            return false
        }
    }

    private func handleSessionKey(_ key: KeyPress, session: StudySession) -> Bool {
        if key == .escape {
            endSession()
            return true
        }

        if session.finished {
            if key == .enter {
                session.end()
                self.session = nil
                startSession()
                return true
            }
            return false
        }

        switch key {
        case .space:
            switch session.stage {
            case .asking:
                session.reveal()
                return true
            case .feedback:
                session.continueToNext()
                return true
            }

        case .enter:
            guard session.stage == .feedback else { return false }
            session.continueToNext()
            return true

        case .character(let character):
            switch character {
            case "1", "2", "3", "4":
                guard let value = Int(String(character)),
                      let grade = Grade(rawValue: value - 1)
                else { return false }

                switch session.mode {
                case .flip:
                    guard session.stage == .feedback else { return false }
                    session.gradeFlip(grade)
                    return true
                case .choice:
                    guard session.stage == .asking, session.choices.indices.contains(value - 1) else { return false }
                    session.answerChoice(session.choices[value - 1])
                    return true
                default:
                    return false
                }

            case "r":
                speakCurrentKana()
                return true

            case "w":
                guard session.stage == .feedback else { return false }
                speakCurrentWord()
                return true

            default:
                return false
            }

        default:
            return false
        }
    }

    // MARK: - Persistence

    private struct PersistedState: Codable {
        var version: Int = 1
        var settings: Settings = Settings()
        var dailyLog: [String: DayLog] = [:]
        var lastScript: KanaScript?
        var cards: [String: CardProgress] = [:]
        /// Home-screen setup, so a relaunch does not silently lose the chart selection.
        var scriptMode: ScriptMode = .hiragana
        var scope: Scope = .all
        var mixedChartScript: KanaScript = .hiragana
        var selectedKanaIDs: Set<String> = []
    }

    static let stateURL: URL = {
        let base = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
            ?? URL(fileURLWithPath: NSHomeDirectory()).appending(path: "Library/Application Support")
        return base.appending(path: "Kana", directoryHint: .isDirectory).appending(path: "state.json")
    }()

    private static let dayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()

    static func dayKey(_ date: Date) -> String { dayFormatter.string(from: date) }

    private func load() {
        guard let data = try? Data(contentsOf: AppModel.stateURL),
              let state = try? JSONDecoder().decode(PersistedState.self, from: data)
        else {
            applyFirstRunDefaults()
            return
        }

        settings = state.settings
        dailyLog = state.dailyLog
        lastScript = state.lastScript
        progress = state.cards.filter { KanaLibrary.byID[$0.key] != nil }
        scriptMode = state.scriptMode
        scope = state.scope
        mixedChartScript = state.mixedChartScript
        selectedKanaIDs = state.selectedKanaIDs.filter { KanaLibrary.byID[$0] != nil }
    }

    /// A brand new learner starts with the あ row selected in both scripts — five cards, not 104.
    private func applyFirstRunDefaults() {
        scope = .selected
        for script in KanaScript.allCases {
            let ids = library.filter { $0.script == script && $0.rowID == "a" }.map(\.id)
            selectedKanaIDs.formUnion(ids)
        }
    }

    private func scheduleSave() {
        saveTask?.cancel()
        saveTask = Task { [weak self] in
            try? await Task.sleep(nanoseconds: 750_000_000)
            guard !Task.isCancelled else { return }
            self?.saveNow()
        }
    }

    func saveNow() {
        saveTask?.cancel()
        saveTask = nil

        let state = PersistedState(
            settings: settings,
            dailyLog: dailyLog,
            lastScript: lastScript,
            cards: progress,
            scriptMode: scriptMode,
            scope: scope,
            mixedChartScript: mixedChartScript,
            selectedKanaIDs: selectedKanaIDs
        )

        do {
            let url = AppModel.stateURL
            try FileManager.default.createDirectory(
                at: url.deletingLastPathComponent(),
                withIntermediateDirectories: true
            )
            let encoder = JSONEncoder()
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
            encoder.dateEncodingStrategy = .iso8601
            try encoder.encode(state).write(to: url, options: .atomic)
        } catch {
            notifySaveFailure(error)
        }
    }

    private func notifySaveFailure(_ error: Error) {
        guard !saveFailureNotified else { return }
        saveFailureNotified = true
        NSLog("Kana: could not save progress to %@ — %@", AppModel.stateURL.path, String(describing: error))
    }

    /// Used by the Settings screen.
    func revealDataFile() {
        let url = AppModel.stateURL
        if FileManager.default.fileExists(atPath: url.path) {
            NSWorkspace.shared.activateFileViewerSelecting([url])
        } else {
            NSWorkspace.shared.open(url.deletingLastPathComponent())
        }
    }
}
