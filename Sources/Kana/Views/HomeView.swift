import SwiftUI

struct HomeView: View {
    @Environment(AppModel.self) private var model

    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 14) {
                    scriptCard
                    scopeCard
                    if model.scope == .selected { KanaChartView() }
                    answerModeCard
                }
                .padding(20)
            }

            Divider()

            startPanel
                .frame(width: 330)
                .padding(20)
        }
    }

    // MARK: - Script

    private var scriptCard: some View {
        @Bindable var model = model

        return SectionCard(title: "Script", hint: "H · K · M") {
            VStack(alignment: .leading, spacing: 10) {
                Picker("Script", selection: $model.scriptMode) {
                    ForEach(ScriptMode.allCases) { mode in
                        Text(mode.displayName).tag(mode)
                    }
                }
                .pickerStyle(.segmented)
                .labelsHidden()

                if model.scriptMode == .mixed {
                    HStack(spacing: 8) {
                        Image(systemName: "arrow.left.arrow.right")
                            .foregroundStyle(Theme.accent)
                        Text("Sessions alternate script. The next one is \(model.nextSessionScript.displayName).")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Spacer()
                        if model.scope == .selected {
                            Button("Chart: \(model.mixedChartScript.displayName)") {
                                model.mixedChartScript = model.mixedChartScript.other
                            }
                            .font(.caption)
                        }
                    }
                }
            }
        }
    }

    // MARK: - Scope

    private var scopeCard: some View {
        @Bindable var model = model
        let counts = scopeCounts

        return SectionCard(title: "Scope", hint: "1 · 2 · 3") {
            VStack(alignment: .leading, spacing: 10) {
                Picker("Scope", selection: $model.scope) {
                    Text("All · \(counts.all)").tag(Scope.all)
                    Text("Selected · \(counts.selected)").tag(Scope.selected)
                    Text("Struggling · \(counts.struggling)").tag(Scope.struggling)
                }
                .pickerStyle(.segmented)
                .labelsHidden()

                Text(model.scope.blurb)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var scopeCounts: (all: Int, selected: Int, struggling: Int) {
        let scriptCards: [Kana]
        if let script = model.activeScript {
            scriptCards = model.library.filter { $0.script == script }
        } else {
            scriptCards = model.library
        }
        return (
            scriptCards.count,
            scriptCards.filter { model.selectedKanaIDs.contains($0.id) }.count,
            model.library.filter { (model.progress[$0.id] ?? CardProgress()).isStruggling }.count
        )
    }

    // MARK: - Answer mode

    private var answerModeCard: some View {
        @Bindable var model = model

        return SectionCard(title: "How you answer", hint: "A cycles") {
            VStack(alignment: .leading, spacing: 8) {
                Picker("Answer mode", selection: $model.settings.answerMode) {
                    ForEach(AnswerMode.allCases) { mode in
                        Text(mode.displayName).tag(mode)
                    }
                }
                .pickerStyle(.segmented)
                .labelsHidden()

                Text(model.settings.answerMode.blurb)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }

    // MARK: - Start panel

    private var startPanel: some View {
        @Bindable var model = model
        let queue = model.plannedQueue

        return VStack(alignment: .leading, spacing: 16) {
            SectionCard(title: "Today") {
                VStack(alignment: .leading, spacing: 8) {
                    statRow("New cards introduced", "\(model.todayLog.newIntroduced)")
                    statRow("Reviews answered", "\(model.todayLog.reviews)")
                    if model.settings.newPerDay > 0 {
                        statRow("New cards left today", "\(model.remainingNewLimit)")
                    }
                    if model.settings.reviewsPerDay > 0 {
                        statRow("Reviews left today", "\(model.remainingReviewLimit)")
                    }
                }
            }

            SectionCard(title: "This session") {
                VStack(alignment: .leading, spacing: 8) {
                    statRow("Cards queued", "\(queue.count)")
                    statRow("Due now", "\(model.dueCount)")
                    statRow("Never seen", "\(model.newCount)")
                }
            }

            Spacer(minLength: 0)

            Button {
                model.startSession()
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "play.fill")
                    Text(model.canStart ? "Start session" : "Nothing queued")
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 6)
            }
            .buttonStyle(.borderedProminent)
            .tint(Theme.accent)
            .controlSize(.large)
            .disabled(!model.canStart)

            HStack(alignment: .top, spacing: 6) {
                KeyCap(text: "⏎")
                Text(model.canStart ? "starts the session" : (model.emptyReason ?? ""))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            if model.canStart && model.dueCount == 0 && model.newCount > 0 {
                Text("Nothing is due yet — everything queued here is a first exposure.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Toggle(isOn: $model.ignoreDue) {
                HStack(spacing: 5) {
                    Text("Study ahead")
                    KeyCap(text: "S")
                }
                .font(.callout)
            }
            .help("Ignore due dates and work through the queue anyway")

            Text("Progress is saved to ~/Library/Application Support/Kana/state.json")
                .font(.caption2)
                .foregroundStyle(.tertiary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private func statRow(_ label: String, _ value: String) -> some View {
        HStack {
            Text(label).font(.callout).foregroundStyle(.secondary)
            Spacer()
            Text(value).font(.callout.monospacedDigit().weight(.medium))
        }
    }
}
