import Foundation

// MARK: - Voice State Machine

/// State machine for the voice recording flow.
/// Transitions: idle → recording → transcribing → preview → idle
///                                               → failed → idle
public enum VoiceState: Equatable {
    case idle
    case recording
    case transcribing
    case preview(String)
    case failed(String)
}

// MARK: - Local Speech Transcriber

/// On-device speech-to-text abstraction.
/// Implementations: Apple Speech (real), MockSpeechTranscriber (test)
public protocol LocalSpeechTranscriber {
    func transcribeLocalAudio(at fileURL: URL) async throws -> String
}

// MARK: - Voice Reply Speaker

/// On-device text-to-speech abstraction.
/// Implementations: AVSpeechSynthesizer (real), mock (test)
public protocol VoiceReplySpeaker {
    func speak(_ text: String)
    func stop()
}

// MARK: - Mock Implementations

/// Deterministic mock for tests — no microphone or model required.
public final class MockSpeechTranscriber: LocalSpeechTranscriber {
    public var nextTranscript = "Mock local transcript from recorded audio."

    public init() {}

    public func transcribeLocalAudio(at fileURL: URL) async throws -> String {
        return nextTranscript
    }
}

/// Deterministic mock TTS for tests — no audio output.
public final class MockVoiceReplySpeaker: VoiceReplySpeaker {
    public private(set) var lastSpokenText: String?
    public private(set) var isSpeaking = false

    public init() {}

    public func speak(_ text: String) {
        lastSpokenText = text
        isSpeaking = true
    }

    public func stop() {
        isSpeaking = false
    }
}
