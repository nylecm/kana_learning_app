import SwiftUI

/// The kana chart: one line per gojūon row. Clicking works, but the point is that `Space` toggles
/// the character under the cursor and `R` toggles the whole row — that is how you "learn them in
/// rows" without ever reaching for the mouse.
struct KanaChartView: View {
    @Environment(AppModel.self) private var model

    var body: some View {
        SectionCard(
            title: "Kana chart",
            hint: "←→↑↓ move · Space pick · R whole row · ⌘A all · ⌘⇧A none"
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
                }
            }
        }
    }

    private func rowLabelButton(_ rowIndex: Int) -> some View {
        let labels = model.chartRowLabels
        let label = labels.indices.contains(rowIndex) ? labels[rowIndex].label(for: model.chartScript) : ""

        return Button {
            model.cursor.row = rowIndex
            model.toggleCursorRow()
        } label: {
            Text(label)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
                .frame(width: 52, alignment: .leading)
        }
        .buttonStyle(.plain)
        .help("Toggle the whole \(label) row (R)")
    }

    private func cell(_ card: Kana, row: Int, column: Int) -> some View {
        let isSelected = model.selectedKanaIDs.contains(card.id)
        let isCursor = model.cursor.row == row && model.cursor.column == column

        return Button {
            model.cursor = .init(row: row, column: column)
            model.toggle(card)
        } label: {
            VStack(spacing: 0) {
                Text(card.kana).font(.system(size: 19, weight: .medium))
                Text(card.romaji).font(.system(size: 9)).foregroundStyle(.secondary)
            }
            .frame(minWidth: 42)
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
