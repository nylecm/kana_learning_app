import AppKit
import SwiftUI

/// The kana chart: one line per gojūon row. Clicking works, but the point is that `Space` toggles
/// the character under the cursor and `R` toggles the whole row — that is how you "learn them in
/// rows" without ever reaching for the mouse.
///
/// Clicking a row label and then ⇧-clicking another takes every row in between, the way a Finder
/// list behaves: the last plain click decides whether the range is selected or cleared.
struct KanaChartView: View {
    @Environment(AppModel.self) private var model

    /// Scroll target for a row, so arrowing off-screen can reveal the cursor row.
    static func rowID(_ rowIndex: Int) -> String { "kana-chart-row-\(rowIndex)" }

    var body: some View {
        SectionCard(
            title: "Kana chart",
            hint: "←→↑↓ move · Space pick · R whole row · ⇧-click extends · ⌘A all · ⌘⇧A none"
        ) {
            VStack(alignment: .leading, spacing: 6) {
                ForEach(Array(model.chartRows.enumerated()), id: \.offset) { rowIndex, cards in
                    HStack(spacing: 5) {
                        rowLabelButton(rowIndex)
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

    private func rowLabelButton(_ rowIndex: Int) -> some View {
        let labels = model.chartRowLabels
        let label = labels.indices.contains(rowIndex) ? labels[rowIndex].label(for: model.chartScript) : ""

        return Button {
            model.toggleRow(at: rowIndex, extending: NSEvent.modifierFlags.contains(.shift))
        } label: {
            Text(label)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
                .frame(width: 46, alignment: .leading)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .help("Toggle the whole \(label) row (R) — ⇧-click to take every row since the last one you clicked")
    }

    private func cell(_ card: Kana, row: Int, column: Int) -> some View {
        let isSelected = model.selectedKanaIDs.contains(card.id)
        let isCursor = model.cursor.row == row && model.cursor.column == column

        return Button {
            model.cursor = .init(row: row, column: column)
            model.toggle(card, atRow: row)
        } label: {
            VStack(spacing: 0) {
                Text(card.kana)
                    .font(.system(size: 21, weight: .medium))
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
                Text(card.romaji).font(.system(size: 9)).foregroundStyle(.secondary)
            }
            .frame(minWidth: 36)
            .padding(.horizontal, 3)
            .padding(.vertical, 4)
            .background(
                isSelected ? Theme.accent.opacity(0.18) : Color.primary.opacity(0.05),
                in: RoundedRectangle(cornerRadius: Theme.controlRadius, style: .continuous)
            )
            .overlay(
                RoundedRectangle(cornerRadius: Theme.controlRadius, style: .continuous)
                    .stroke(
                        isCursor ? Theme.accent : (isSelected ? Theme.accent.opacity(0.55) : Theme.hairline),
                        lineWidth: isCursor ? 2 : 1
                    )
            )
        }
        .buttonStyle(.plain)
        .help("\(card.kana) — \(card.romaji)")
    }
}
