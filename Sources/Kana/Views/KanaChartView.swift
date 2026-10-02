import AppKit
import SwiftUI

/// The kana chart: one line per gojūon row. Clicking works, but the point is that `Space` toggles
/// the character under the cursor and `R` toggles the whole row — that is how you "learn them in
/// rows" without ever reaching for the mouse.
///
/// Clicking a row label and then ⇧-clicking another takes every row in between, the way a Finder
/// list behaves: the last plain click decides whether the range is selected or cleared.
///
/// With the heat map on, every cell is tinted by how hard that card is fighting back — hue for the
/// struggle, opacity for how much evidence is behind the number, and a faint neutral for a card
/// with no history at all — and each row label carries a dot showing the row's average. Selection
/// moves to the stroke while it is on, so the heat and the selection never fight for the same space.
struct KanaChartView: View {
    @Environment(AppModel.self) private var model

    /// Scroll target for a row, so arrowing off-screen can reveal the cursor row.
    static func rowID(_ rowIndex: Int) -> String { "kana-chart-row-\(rowIndex)" }

    var body: some View {
        SectionCard(
            title: "Kana chart",
            hint: "←→↑↓ · Space · R row · ⇧-click · ⌘A · G heat map"
        ) {
            VStack(alignment: .leading, spacing: 12) {
                heatMapControls

                VStack(alignment: .leading, spacing: 6) {
                    ForEach(Array(model.chartRows.enumerated()), id: \.offset) { rowIndex, cards in
                        HStack(spacing: 5) {
                            rowLabelButton(rowIndex, cards: cards)
                            ForEach(Array(cards.enumerated()), id: \.element.id) { columnIndex, card in
                                cell(card, row: rowIndex, column: columnIndex)
                            }
                            Spacer(minLength: 0)
                        }
                        .id(KanaChartView.rowID(rowIndex))
                    }
                }
            }
        }
    }

    // MARK: - Heat map controls

    private var heatMapControls: some View {
        @Bindable var model = model

        return HStack(spacing: 10) {
            Toggle("Heat map", isOn: $model.showHeatmap)
                .toggleStyle(.switch)
                .controlSize(.small)
                .help("Tint every kana by how well you know it (G)")

            Spacer(minLength: 8)

            if model.showHeatmap { legend }
        }
    }

    /// What the colours mean: a faint swatch for cards with no history, then the ramp itself.
    private var legend: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(Color.primary.opacity(0.10))
                .overlay(Circle().stroke(Theme.hairline, lineWidth: 0.5))
                .frame(width: 7, height: 7)
            Text("not started").font(.caption2).foregroundStyle(.secondary)
            Text("solid").font(.caption2).foregroundStyle(.secondary)
            Capsule()
                .fill(HeatScale.legend)
                .frame(width: 90, height: 7)
            Text("struggling").font(.caption2).foregroundStyle(.secondary)
        }
        .lineLimit(1)
        .layoutPriority(-1)   // the switch keeps its size; the legend gives way first
    }

    // MARK: - Rows

    private func rowLabelButton(_ rowIndex: Int, cards: [Kana]) -> some View {
        let labels = model.chartRowLabels
        let label = labels.indices.contains(rowIndex) ? labels[rowIndex].label(for: model.chartScript) : ""

        return Button {
            model.toggleRow(at: rowIndex, extending: NSEvent.modifierFlags.contains(.shift))
        } label: {
            HStack(spacing: 5) {
                if let heat = rowHeat(cards) {
                    Circle()
                        .fill(heat.color)
                        .frame(width: 7, height: 7)
                        .help("\(heat.started) of \(cards.count) started")
                }
                Text(label)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
            }
            .frame(width: 54, alignment: .leading)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .help("Toggle the whole \(label) row (R) — ⇧-click to take every row since the last one you clicked")
    }

    /// The row's average struggle across the cards that have any history behind them.
    private func rowHeat(_ cards: [Kana]) -> (color: Color, started: Int)? {
        guard model.showHeatmap else { return nil }
        let started = cards.filter { (model.progress[$0.id] ?? CardProgress()).isStarted }
        guard !started.isEmpty else { return nil }
        let total = started.reduce(0.0) { $0 + (model.progress[$1.id] ?? CardProgress()).struggle }
        return (HeatScale.color(for: total / Double(started.count)), started.count)
    }

    // MARK: - Cells

    private func cell(_ card: Kana, row: Int, column: Int) -> some View {
        let isSelected = model.selectedKanaIDs.contains(card.id)
        let isCursor = model.cursor.row == row && model.cursor.column == column
        let progress = model.showHeatmap ? (model.progress[card.id] ?? CardProgress()) : nil
        let shape = RoundedRectangle(cornerRadius: Theme.controlRadius, style: .continuous)

        return Button {
            model.cursor = .init(row: row, column: column)
            model.toggle(card, atRow: row)
        } label: {
            VStack(spacing: 0) {
                Text(card.kana)
                    .font(.system(size: 21, weight: .medium))
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
                    .foregroundStyle(kanaColor(progress))
                Text(card.romaji).font(.system(size: 9)).foregroundStyle(.secondary)
            }
            .frame(minWidth: 36)
            .padding(.horizontal, 3)
            .padding(.vertical, 4)
            .background(background(isSelected: isSelected, progress: progress), in: shape)
            .overlay(
                shape.stroke(
                    strokeColor(isCursor: isCursor, isSelected: isSelected, progress: progress),
                    lineWidth: isCursor ? 2 : 1
                )
            )
        }
        .buttonStyle(.plain)
        .help("\(card.kana) — \(card.romaji)")
    }

    /// With the heat map off this is the plain chart, where selection is the fill. With it on the
    /// fill carries the heat instead and selection moves to the stroke.
    private func background(isSelected: Bool, progress: CardProgress?) -> Color {
        guard let progress else {
            return isSelected ? Theme.accent.opacity(0.18) : Color.primary.opacity(0.05)
        }
        guard progress.isStarted else { return Color.primary.opacity(0.03) }
        return HeatScale.color(for: progress.struggle).opacity(0.12 + 0.30 * progress.heatConfidence)
    }

    private func strokeColor(isCursor: Bool, isSelected: Bool, progress: CardProgress?) -> Color {
        if isCursor { return Theme.accent }
        if isSelected { return Theme.accent.opacity(0.55) }
        if let progress, progress.isStarted {
            return HeatScale.color(for: progress.struggle).opacity(0.45)
        }
        return Theme.hairline
    }

    /// A card with no history stays faint, so the studied ones are the ones that read.
    private func kanaColor(_ progress: CardProgress?) -> Color {
        guard let progress, !progress.isStarted else { return .primary }
        return Color.primary.opacity(0.55)
    }
}
