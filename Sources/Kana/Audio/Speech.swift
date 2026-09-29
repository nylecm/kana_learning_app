import AVFoundation
import Foundation

/// Thin wrapper over the system's local Japanese voices. Nothing leaves the machine.
@MainActor
final class Speech {
    private let synthesizer = AVSpeechSynthesizer()

    /// Voices installed for Japanese; the picker in Settings offers exactly these.
    static let japaneseVoices: [AVSpeechSynthesisVoice] =
        AVSpeechSynthesisVoice.speechVoices()
            .filter { $0.language.hasPrefix("ja") }
            .sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }

    /// Kyoko is the classic macOS Japanese voice; fall back to any other Japanese voice.
    static let defaultVoiceIdentifier: String? = {
        if let kyoko = japaneseVoices.first(where: { $0.name.contains("Kyoko") }) {
            return kyoko.identifier
        }
        if let otoya = japaneseVoices.first(where: { $0.name.contains("Otoya") }) {
            return otoya.identifier
        }
        return japaneseVoices.first?.identifier
    }()

    static func displayName(for identifier: String?) -> String {
        guard let identifier, let voice = AVSpeechSynthesisVoice(identifier: identifier) else {
            return "System default"
        }
        return voice.name
    }

    func speak(_ text: String, voiceIdentifier: String?, rate: Float) {
        guard !text.isEmpty else { return }
        if synthesizer.isSpeaking { synthesizer.stopSpeaking(at: .immediate) }

        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = resolveVoice(identifier: voiceIdentifier)
        utterance.rate = max(0.1, min(0.9, rate))
        synthesizer.speak(utterance)
    }

    func stop() {
        if synthesizer.isSpeaking { synthesizer.stopSpeaking(at: .immediate) }
    }

    private func resolveVoice(identifier: String?) -> AVSpeechSynthesisVoice? {
        if let identifier, let voice = AVSpeechSynthesisVoice(identifier: identifier) { return voice }
        if let fallback = Speech.defaultVoiceIdentifier,
           let voice = AVSpeechSynthesisVoice(identifier: fallback) {
            return voice
        }
        return AVSpeechSynthesisVoice(language: "ja-JP")
    }
}
