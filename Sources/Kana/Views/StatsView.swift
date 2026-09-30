import SwiftUI

/// Progress over the whole library: totals, one bar per gojūon row, and a full card table.
struct StatsView: View {
    @Environment(AppModel.self) private var model

    private struct CardStat: Identifiable {
        let id: String
        let kana: Kana
        let progress: CardProgress
    }

    private struct RowSummary: Identifiable {
        let id: String
        let label: String
        let script: KanaScript
        let total: Int
        let seen: Int
        let accuracy: Double
        let struggling: Int
    }

    var body: some View {
        VStack(spacing: 0) {
            summary
            Divider()
            rowBars
            Divider()
            table
        }
        .navigationTitle("Progress")
        .navigationSubtitle(subtitle)
    }

    private var subtitle: String {
        "\(stats.count) cards · \(stats.filter { $0.progress.isStarted }.count) started"
    }

    // MARK: - Totals

    private var stats: [CardStat] {
        model.library.map {
            CardStat(id: $0.id, kana: $0, progress: model.progress[$0.id] ?? CardProgress())
        }
    }

    private var summary: some View {
        let all = stats
        let reviews = all.reduce(0) { $0 + $1.progress.reviews }
        let correct = all.reduce(0) { $0 + $1.progress.correct }
        let accuracy = reviews == 0 ? 0 : Double(correct) / Double(reviews)

        return HStack(spacing: 26) {
            tile("Cards", "\(all.count)")
            tile("Started", "\(all.filter { $0.progress.isStarted }.count)")
            tile("Learning", "\(all.filter { $0.progress.phase == .learning }.count)")
            tile("Mature", "\(all.filter { $0.progress.isMature }.count)")
            tile("Struggling", "\(all.filter { $0.progress.isStruggling }.count)", tint: Theme.warn)
            tile("Answers", "\(reviews)")
            tile("Accuracy", String(format: "%.0f%%", accuracy * 100))
            Spacer()
        }
        .padding(.horizontal, 22)
        .padding(.vertical, 16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .glassSurface(in: RoundedRectangle(cornerRadius: Theme.cardRadius, style: .continuous))
        .padding(.horizontal, 20)
        .padding(.top, 16)
        .padding(.bottom, 12)
    }

    private func tile(_ label: String, _ value: String, tint: Color? = nil) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(value)
                .font(.system(size: 20, weight: .semibold, design: .rounded))
                .foregroundStyle(tint ?? .primary)
            Text(label).font(.caption).foregroundStyle(.secondary)
        }
    }

    // MARK: - Per-row bars

    private var rowSummaries: [RowSummary] {
        var result: [RowSummary] = []
        for script in KanaScript.allCases {
            let cards = model.library.filter { $0.script == script }
            for row in KanaRows.all {
                let group = cards.filter { $0.rowID == row.id }
                guard !group.isEmpty else { continue }
                let reviews = group.reduce(0) { $0 + (model.progress[$1.id]?.reviews ?? 0) }
                let correct = group.reduce(0) { $0 + (model.progress[$1.id]?.correct ?? 0) }
                result.append(
                    RowSummary(
                        id: "\(script.rawValue).\(row.id)",
                        label: row.label(for: script),
                        script: script,
                        total: group.count,
                        seen: group.filter { (model.progress[$0.id] ?? CardProgress()).isStarted }.count,
                        accuracy: reviews == 0 ? 0 : Double(correct) / Double(reviews),
                        struggling: group.filter { (model.progress[$0.id] ?? CardProgress()).isStruggling }.count
                    )
                )
            }
        }
        return result
    }

    private var rowBars: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(rowSummaries) { row in
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: 4) {
                            Text(row.label).font(.caption.weight(.semibold))
                            if row.script == .katakana {
                                Text("カ").font(.system(size: 8)).foregroundStyle(.tertiary)
                            }
                            if row.struggling > 0 {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .font(.system(size: 9))
                                    .foregroundStyle(Theme.warn)
                            }
                        }
                        Text("\(row.seen)/\(row.total)")
                            .font(.caption2.monospacedDigit())
                            .foregroundStyle(.secondary)
                        ProgressView(value: row.accuracy)
                            .frame(width: 74)
                            .tint(row.accuracy >= 0.8 ? Theme.good : (row.accuracy >= 0.5 ? Theme.warn : Theme.accent))
                    }
                    .padding(8)
                    .background(.quaternary, in: RoundedRectangle(cornerRadius: Theme.controlRadius, style: .continuous))
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
        }
    }

    // MARK: - Table

    private var table: some View {
        Table(stats) {
            TableColumn("Kana") { stat in
                HStack(spacing: 5) {
                    if stat.progress.isStruggling {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 9))
                            .foregroundStyle(Theme.warn)
                            .help("Struggling")
                    }
                    Text(stat.kana.kana).font(.system(size: 15, weight: .medium))
                }
            }
            .width(min: 54, ideal: 70)

            TableColumn("Rōmaji") { stat in Text(stat.kana.romaji) }
                .width(min: 60, ideal: 80)

            TableColumn("Script") { stat in
                Text(stat.kana.script.displayName).foregroundStyle(.secondary)
            }
            .width(min: 60, ideal: 80)

            TableColumn("Row") { stat in
                Text(KanaRows.row(id: stat.kana.rowID)?.label(for: stat.kana.script) ?? stat.kana.rowID)
                    .foregroundStyle(.secondary)
            }
            .width(min: 50, ideal: 64)

            TableColumn("Phase") { stat in
                Text(stat.progress.phase.rawValue).foregroundStyle(.secondary)
            }
            .width(min: 50, ideal: 66)

            TableColumn("Reviews") { stat in
                Text("\(stat.progress.reviews)").monospacedDigit()
            }
            .width(min: 50, ideal: 64)

            TableColumn("Accuracy") { stat in
                Text(stat.progress.reviews == 0 ? "—" : String(format: "%.0f%%", stat.progress.accuracy * 100))
                    .monospacedDigit()
            }
            .width(min: 56, ideal: 70)

            TableColumn("Lapses") { stat in
                Text("\(stat.progress.lapses)").monospacedDigit()
                    .foregroundStyle(stat.progress.lapses >= 3 ? Theme.warn : .primary)
            }
            .width(min: 40, ideal: 56)

            TableColumn("Ease") { stat in
                Text(String(format: "%.2f", stat.progress.ease)).monospacedDigit()
            }
            .width(min: 42, ideal: 52)

            TableColumn("Interval · due") { stat in
                if stat.progress.phase == .new {
                    Text("—").foregroundStyle(.secondary)
                } else {
                    HStack(spacing: 6) {
                        Text(intervalLabel(stat.progress)).monospacedDigit()
                        Text("·").foregroundStyle(.tertiary)
                        Text(dueLabel(stat.progress)).foregroundStyle(.secondary)
                    }
                }
            }
            .width(min: 110, ideal: 150)
        }
    }

    private func intervalLabel(_ progress: CardProgress) -> String {
        guard progress.phase != .new else { return "—" }
        guard progress.phase == .review else { return "learning" }
        return Scheduler.describe(interval: progress.intervalDays * 86_400)
    }

    private func dueLabel(_ progress: CardProgress) -> String {
        guard progress.phase != .new else { return "—" }
        let remaining = progress.due.timeIntervalSinceNow
        return remaining <= 0 ? "due now" : "in \(Scheduler.describe(interval: remaining))"
    }
}
