// AppleSpeechRecognizer.swift
// Private Pensieve AI — iOS
// Real on-device speech-to-text using Apple's Speech framework.
// Uses on-device recognition (requiresOnDeviceRecognition = true). No cloud.

import Speech
import Foundation

/// On-device speech-to-text using Apple's SFSpeechRecognizer.
/// Implements the SpeechToTextProvider protocol.
final class AppleSpeechRecognizer: SpeechToTextProvider {

    private let recognizer: SFSpeechRecognizer?

    var isAvailable: Bool {
        guard let recognizer = recognizer else { return false }
        return recognizer.isAvailable
    }

    init(locale: Locale = .current) {
        self.recognizer = SFSpeechRecognizer(locale: locale)
    }

    /// Transcribe an audio file using on-device recognition only.
    func transcribe(audioFileURL: URL) async throws -> TranscriptionResult {
        guard let recognizer = recognizer, recognizer.isAvailable else {
            throw SpeechError.recognizerNotAvailable
        }

        let request = SFSpeechURLRecognitionRequest(url: audioFileURL)

        // Force on-device recognition — no data leaves the device
        request.requiresOnDeviceRecognition = true
        request.shouldReportPartialResults = false
        request.addsPunctuation = true

        return try await withCheckedThrowingContinuation { continuation in
            recognizer.recognitionTask(with: request) { result, error in
                if let error = error {
                    continuation.resume(throwing: SpeechError.recognitionFailed(error.localizedDescription))
                    return
                }

                guard let result = result, result.isFinal else { return }

                let segments = result.bestTranscription.segments.map { seg in
                    TranscriptionSegment(
                        text: seg.substring,
                        startTime: seg.timestamp,
                        endTime: seg.timestamp + seg.duration,
                        confidence: Double(seg.confidence)
                    )
                }

                let overall = TranscriptionResult(
                    text: result.bestTranscription.formattedString,
                    confidence: Double(segments.map(\.confidence).reduce(0, +)) / Double(max(segments.count, 1)),
                    segments: segments
                )

                continuation.resume(returning: overall)
            }
        }
    }

    /// Request speech recognition permission.
    static func requestPermission() async -> SFSpeechRecognizerAuthorizationStatus {
        await withCheckedContinuation { continuation in
            SFSpeechRecognizer.requestAuthorization { status in
                continuation.resume(returning: status)
            }
        }
    }

    enum SpeechError: LocalizedError {
        case recognizerNotAvailable
        case recognitionFailed(String)
        case permissionDenied

        var errorDescription: String? {
            switch self {
            case .recognizerNotAvailable: return "Speech recognizer is not available on this device."
            case .recognitionFailed(let msg): return "Recognition failed: \(msg)"
            case .permissionDenied: return "Speech recognition permission denied."
            }
        }
    }
}
