import SwiftUI

struct SettingsView: View {
    @Environment(AppModel.self) private var model
    @State private var confirmingReset = false

    var body: some View {
        @Bindable var model = model

        Form {
            Section("Daily limits") {
                Stepper(value: $model.settings.newPerDay, in: 0...999) {
                    LabeledContent(
                        "New cards per day",
                        value: model.settings.newPerDay == 0 ? "Unlimited" : "\(model.settings.newPerDay)"
                    )
                }
                Stepper(value: $model.settings.reviewsPerDay, in: 0...9999) {
                    LabeledContent(
                        "Reviews per day",
                        value: model.settings.reviewsPerDay == 0 ? "Unlimited" : "\(model.settings.reviewsPerDay)"
                    )
                }
                Text("Zero means unlimited. Counters reset at local midnight.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Section("Answering") {
                Picker("Default answer mode", selection: $model.settings.answerMode) {
                    ForEach(AnswerMode.allCases) { mode in
                        Text(mode.displayName).tag(mode)
                    }
                }
                Text(model.settings.answerMode.blurb)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Section("Japanese audio") {
                Picker("Voice", selection: $model.settings.voiceIdentifier) {
                    Text("Automatic — \(Speech.displayName(for: Speech.defaultVoiceIdentifier))")
                        .tag(String?.none)
                    ForEach(Speech.japaneseVoices, id: \.identifier) { voice in
                        Text(voice.name).tag(String?.some(voice.identifier))
                    }
                }

                LabeledContent("Speed") {
                    Slider(value: $model.settings.speechRate, in: 0.25...0.6) {
                        EmptyView()
                    } minimumValueLabel: {
                        Image(systemName: "tortoise")
                    } maximumValueLabel: {
                        Image(systemName: "hare")
                    }
                    .frame(width: 220)
                }

                Toggle("Speak the character when the answer is revealed", isOn: $model.settings.speakOnReveal)
                Toggle("Speak the character as soon as the card appears", isOn: $model.settings.speakOnAppear)

                Button("Test voice") {
                    model.speak("こんにちは")
                }

                if Speech.japaneseVoices.isEmpty {
                    Text("No Japanese voice is installed. Add one in System Settings → Accessibility → Spoken Content → System Voice → Manage Voices.")
                        .font(.caption)
                        .foregroundStyle(Theme.warn)
                }
            }

            Section("Progress") {
                LabeledContent("Data file") {
                    Text(AppModel.stateURL.path)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .textSelection(.enabled)
                }

                HStack(spacing: 12) {
                    Button("Reveal in Finder") { model.revealDataFile() }
                    Button("Reset all progress", role: .destructive) { confirmingReset = true }
                }

                Text("\(model.library.count) cards · \(model.progress.count) with saved scheduling")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Section("Keyboard") {
                VStack(alignment: .leading, spacing: 6) {
                    keyRow("Space", "reveal the answer, then continue")
                    keyRow("1 2 3 4", "grade Again / Hard / Good / Easy, or pick a choice")
                    keyRow("⏎", "submit a typed answer, or start a session")
                    keyRow("R / W", "hear the character / the example word")
                    keyRow("Esc", "end the session")
                    keyRow("H K M", "script · 1 2 3 scope · A answer mode")
                    keyRow("G", "heat map — tint the chart by how well you know each kana")
                    keyRow("←→↑↓ + Space + R", "chart: move, pick a character, pick a whole row")
                    keyRow("⌘1 ⌘2 ⌘3", "Study / Progress / Settings")
                }
                .padding(.vertical, 2)
            }
        }
        .formStyle(.grouped)
        .navigationTitle("Settings")
        .confirmationDialog(
            "Reset all progress?",
            isPresented: $confirmingReset,
            titleVisibility: .visible
        ) {
            Button("Reset everything", role: .destructive) { model.resetProgress() }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Every card's scheduling, ease factor and history will be deleted. This cannot be undone.")
        }
    }

    private func keyRow(_ key: String, _ label: String) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: 10) {
            KeyCap(text: key)
                .frame(width: 130, alignment: .leading)
            Text(label).font(.callout).foregroundStyle(.secondary)
        }
    }
}
