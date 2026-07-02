// AppleTTS.swift
// Private Pensieve AI — iOS
// Real on-device text-to-speech using AVSpeechSynthesizer. No cloud.

import AVFoundation

/// On-device text-to-speech using Apple's AVSpeechSynthesizer.
/// Implements the TTSProvider protocol.
final class AppleTTS: NSObject, TTSProvider, AVSpeechSynthesizerDelegate {

    private let synthesizer = AVSpeechSynthesizer()
    private var speakContinuation: CheckedContinuation<Void, Error>?

    var isAvailable: Bool { true }

    override init() {
        super.init()
        synthesizer.delegate = self
    }

    func speak(text: String) async throws {
        // Configure audio session for playback
        let session = AVAudioSession.sharedInstance()
        try session.setCategory(.playback, mode: .spokenAudio)
        try session.setActive(true)

        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        utterance.rate = AVSpeechUtteranceDefaultSpeechRate * 0.9 // Slightly slower for warmth
        utterance.pitchMultiplier = 1.0
        utterance.postUtteranceDelay = 0.3

        return try await withCheckedThrowingContinuation { continuation in
            self.speakContinuation = continuation
            synthesizer.speak(utterance)
        }
    }

    func stop() {
        synthesizer.stopSpeaking(at: .immediate)
        speakContinuation?.resume()
        speakContinuation = nil
    }

    // MARK: - AVSpeechSynthesizerDelegate

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        speakContinuation?.resume()
        speakContinuation = nil
    }

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        speakContinuation?.resume()
        speakContinuation = nil
    }
}
