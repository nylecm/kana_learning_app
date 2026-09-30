import SwiftUI

/// A live sitting. Everything here is reachable from the keyboard (spec.md §6).
///
/// The session chrome lives in the window toolbar — title, progress and *End* — so the content area
/// is only ever the card itself.
struct SessionView: View {
    @Environment(AppModel.self) private var model
    let session: StudySession

    @FocusState private var typingFocused: Bool
    @State private var draft = ""

    var body: some View {
        VStack(spacing: 0) {
            if session.finished {
                SummaryView(session: session)
            } else {
                cardArea
                Divider()
                footer
            }
        }
        .navigationTitle(session.title)
        .navigationSubtitle("\(session.answeredCount) of \(session.plannedTotal) reviewed")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("End") { model.endSession() }
                    .glassButtonStyle()
                    .help("End the session (Esc)")
            }
        }
        .onChange(of: session.presentationIndex) { _, _ in syncFocus() }
        .onChange(of: session.stage) { _, _ in syncFocus() }
        .onAppear { syncFocus() }
    }

    // MARK: - Card

    private var cardArea: some View {
        VStack(spacing: 22) {
            Spacer(minLength: 8)

            if let card = session.current {
                Text("\(card.script.displayName) · \(card.kind.displayName)")
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(.quaternary, in: Capsule())
            }

            prompt
            answerControls

            Spacer(minLength: 8)
        }
        .padding(.horizontal, 24)
        .frame(maxWidth: .infinity)
    }

    /// The card front, on its own glass stage — the one place in the window where the material is
    /// doing real work, holding the character up above everything else.
    @ViewBuilder
    private var prompt: some View {
        if let card = session.current {
            VStack(spacing: 12) {
                HStack(spacing: 18) {
                    Text(card.kana)
                        .font(.system(size: 116, weight: .medium, design: .rounded))
                        .minimumScaleFactor(0.5)
                        .lineLimit(1)

                    Button {
                        model.speak(card.kana)
                    } label: {
                        Image(systemName: "speaker.wave.2.fill").font(.title2)
                    }
                    .buttonStyle(.borderless)
                    .help("Hear the character (R)")
                }

                if session.stage == .asking && session.mode == .flip {
                    Text("Recall the sound, then press Space to check.")
                        .font(.callout)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.horizontal, 46)
            .padding(.vertical, 28)
            .glassSurface(in: RoundedRectangle(cornerRadius: 32, style: .continuous))
        }
    }

    @ViewBuilder
    private var answerControls: some View {
        if let card = session.current {
            switch session.mode {
            case .flip:
                if session.stage == .asking {
                    Button("Show answer") { session.reveal() }
                        .glassButtonStyle(prominent: true, tint: Theme.accent)
                        .controlSize(.large)
                } else {
                    GradeButtons(session: session, card: card)
                }

            case .choice:
                if session.stage == .asking {
                    ChoiceButtons(session: session)
                } else {
                    RevealPanel(session: session, card: card)
                    continueButton
                }

            case .typing:
                if session.stage == .asking {
                    typingField
                } else {
                    RevealPanel(session: session, card: card)
                    continueButton
                }

            case .mixed:
                EmptyView()
            }
        }
    }

    private var typingField: some View {
        VStack(spacing: 8) {
            TextField("rōmaji…", text: $draft)
                .textFieldStyle(.roundedBorder)
                .font(.system(size: 22, design: .rounded))
                .frame(width: 260)
                .multilineTextAlignment(.center)
                .focused($typingFocused)
                .onSubmit(submitTyped)

            HStack(spacing: 6) {
                KeyCap(text: "⏎")
                Text("to check").font(.caption).foregroundStyle(.secondary)
            }
        }
    }

    private var continueButton: some View {
        Button("Continue") { session.continueToNext() }
            .glassButtonStyle(prominent: true, tint: Theme.accent)
            .controlSize(.large)
    }

    private func submitTyped() {
        session.setTypedAnswer(draft)
        session.submitTyped()
        typingFocused = false
    }

    private func syncFocus() {
        if session.mode == .typing && session.stage == .asking && !session.finished {
            draft = ""
            typingFocused = true
        } else {
            typingFocused = false
        }
    }

    // MARK: - Footer

    private var footer: some View {
        HStack(spacing: 18) {
            switch session.mode {
            case .flip:
                KeyHint(key: "Space", label: "reveal / continue")
                KeyHint(key: "1–4", label: "grade")
            case .choice:
                KeyHint(key: "1–4", label: "pick an answer")
                KeyHint(key: "Space", label: "continue")
            case .typing:
                KeyHint(key: "⏎", label: "check / continue")
            case .mixed:
                KeyHint(key: "Space", label: "reveal or continue")
                KeyHint(key: "1–4", label: "grade or pick")
            }
            KeyHint(key: "R", label: "hear kana")
            KeyHint(key: "W", label: "hear word")
            KeyHint(key: "Esc", label: "end session")
            Spacer()
            if session.mode == .mixed {
                Text("mixed: \(session.mode.shortName)…")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
            ProgressView(value: session.progress)
                .progressViewStyle(.linear)
                .frame(width: 110)
                .help("\(session.answeredCount) of \(session.plannedTotal) reviewed")
            Text("\(session.answeredCount)/\(session.plannedTotal)")
                .font(.caption.monospacedDigit())
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
    }
}

// MARK: - Pieces

private struct GradeButtons: View {
    @Environment(AppModel.self) private var model
    let session: StudySession
    let card: Kana

    var body: some View {
        let previews = Scheduler.previews(for: model.progress[card.id] ?? CardProgress(), now: .now)

        return HStack(spacing: 10) {
            ForEach(Grade.allCases) { grade in
                Button {
                    session.gradeFlip(grade)
                } label: {
                    VStack(spacing: 3) {
                        HStack(spacing: 6) {
                            KeyCap(text: grade.keyLabel)
                            Text(grade.title).font(.callout.weight(.semibold))
                        }
                        Text(previews[grade] ?? "")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 6)
                }
                .glassButtonStyle(tint: Theme.tint(for: grade))
                .help("\(grade.title) — next in \(previews[grade] ?? "?")")
            }
        }
        .frame(maxWidth: 560)
    }
}

private struct ChoiceButtons: View {
    let session: StudySession

    var body: some View {
        VStack(spacing: 10) {
            ForEach(Array(session.choices.enumerated()), id: \.offset) { index, option in
                Button {
                    session.answerChoice(option)
                } label: {
                    HStack(spacing: 10) {
                        KeyCap(text: String(index + 1))
                        Text(option).font(.system(size: 18, design: .rounded))
                        Spacer()
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .frame(maxWidth: .infinity)
                }
                .glassButtonStyle()
            }
        }
        .frame(maxWidth: 340)
    }
}

private struct RevealPanel: View {
    @Environment(AppModel.self) private var model
    let session: StudySession
    let card: Kana

    var body: some View {
        VStack(spacing: 12) {
            HStack(spacing: 10) {
                Image(systemName: session.lastAnswerWasCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .foregroundStyle(session.lastAnswerWasCorrect ? Theme.good : Theme.accent)
                    .font(.title3)

                Text(card.romaji)
                    .font(.system(size: 30, weight: .semibold, design: .rounded))

                if let picked = session.pickedChoice, !session.lastAnswerWasCorrect {
                    Text("you picked \(picked)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Text(card.mnemonic)
                .font(.callout)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
                .frame(maxWidth: 520)

            Button {
                model.speak(card.exampleWord)
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "speaker.wave.2")
                    Text(card.exampleWord).font(.system(size: 20))
                    Text(card.exampleRomaji).font(.callout).foregroundStyle(.secondary)
                    Text("·").foregroundStyle(.tertiary)
                    Text(card.exampleMeaning).font(.callout).foregroundStyle(.secondary)
                    KeyCap(text: "W")
                }
            }
            .buttonStyle(.plain)
            .help("Hear the example word")
        }
        .padding(18)
        .frame(maxWidth: 620)
        .glassSurface(in: RoundedRectangle(cornerRadius: Theme.cardRadius, style: .continuous))
    }
}

private struct SummaryView: View {
    @Environment(AppModel.self) private var model
    let session: StudySession

    var body: some View {
        VStack(spacing: 20) {
            Spacer()

            Text("Session complete")
                .font(.title2.weight(.semibold))

            HStack(spacing: 34) {
                tile("Reviewed", "\(session.answeredCount)")
                tile("Accuracy", String(format: "%.0f%%", session.accuracy * 100))
                tile("Misses", "\(session.gradeCounts[.again] ?? 0)")
                tile("Answers", "\(session.answers.count)")
            }
            .padding(.horizontal, 34)
            .padding(.vertical, 18)
            .glassSurface(in: RoundedRectangle(cornerRadius: Theme.cardRadius, style: .continuous))

            if !session.difficultCards.isEmpty {
                VStack(spacing: 8) {
                    Text("Worth another look")
                        .font(.callout.weight(.semibold))
                    HStack(spacing: 6) {
                        ForEach(session.difficultCards.prefix(12)) { card in
                            Text(card.kana)
                                .font(.system(size: 18))
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Theme.accent.opacity(0.14), in: RoundedRectangle(cornerRadius: 7, style: .continuous))
                        }
                    }
                    .frame(maxWidth: 640)
                }
            }

            HStack(spacing: 12) {
                Button("Study again") {
                    model.session = nil
                    model.startSession()
                }
                .glassButtonStyle(prominent: true, tint: Theme.accent)
                .controlSize(.large)

                Button("Back to setup") { model.session = nil }
                    .glassButtonStyle()
                    .controlSize(.large)
            }

            HStack(spacing: 18) {
                KeyHint(key: "⏎", label: "study again")
                KeyHint(key: "Esc", label: "back to setup")
            }

            Spacer()
        }
        .frame(maxWidth: .infinity)
    }

    private func tile(_ label: String, _ value: String) -> some View {
        VStack(spacing: 3) {
            Text(value).font(.system(size: 26, weight: .semibold, design: .rounded))
            Text(label).font(.caption).foregroundStyle(.secondary)
        }
    }
}
