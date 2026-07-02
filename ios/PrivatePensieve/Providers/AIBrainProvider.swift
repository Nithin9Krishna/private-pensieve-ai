// AIBrainProvider.swift
// Private Pensieve AI — iOS
// AI brain interface + deterministic fake provider for tests
// No remote inference. No cloud fallback. Ever.

import Foundation

// MARK: - AI Brain Protocol

/// Core AI brain interface. Every app feature must work with FakeAIBrain.
/// Real providers (Apple Foundation Models, downloaded packs) implement this.
protocol AIBrainProvider {
    /// Check if the provider is currently available on this device
    var isAvailable: Bool { get }

    /// Generate a warm, non-judgmental friend reply to user speech
    func generateFriendReply(transcript: String, recentMemories: [MemoryCard]) async throws -> String

    /// Extract structured memory cards from a transcript
    func extractMemory(transcript: String) async throws -> [MemoryCard]

    /// Generate a daily summary from today's memory cards
    func summarizeDay(memories: [MemoryCard]) async throws -> DailySummary

    /// Answer a recall question using only the provided evidence
    /// Returns the exact fallback when evidence is empty.
    func answerFromEvidence(question: String, evidence: [MemoryCard]) async throws -> String
}

// MARK: - Fake AI Brain (Deterministic, for tests)

/// Deterministic fake provider that works without any AI model or network.
/// Used for all unit/integration tests and as fallback when no real provider is available.
final class FakeAIBrain: AIBrainProvider {

    /// The exact fallback text per AGENTS.md and RECALL_PIPELINE.md
    static let noMemoryFallback = "I don't remember you telling me that yet."

    var isAvailable: Bool { true }

    func generateFriendReply(transcript: String, recentMemories: [MemoryCard]) async throws -> String {
        return "That sounds important. What part of it stayed with you most?"
    }

    func extractMemory(transcript: String) async throws -> [MemoryCard] {
        let id = UUID().uuidString
        let now = Date()
        return [
            MemoryCard(
                id: id,
                createdAt: now,
                updatedAt: now,
                sourceConversationId: UUID().uuidString,
                title: String(transcript.prefix(60)),
                summary: transcript,
                emotionTags: [],
                topicTags: [],
                peopleTags: [],
                placeTags: [],
                goalTags: [],
                importanceScore: 5,
                confidenceScore: 0.8,
                duplicateGroupId: nil,
                isFavorite: false,
                isSensitive: false,
                isArchived: false,
                isDeleted: false
            )
        ]
    }

    func summarizeDay(memories: [MemoryCard]) async throws -> DailySummary {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return DailySummary(
            date: formatter.string(from: Date()),
            summary: "You shared \(memories.count) thoughts today.",
            topEmotions: [],
            topTopics: [],
            importantMemoryIds: memories.filter { $0.importanceScore >= 7 }.map(\.id),
            updatedAt: Date()
        )
    }

    func answerFromEvidence(question: String, evidence: [MemoryCard]) async throws -> String {
        if evidence.isEmpty {
            return FakeAIBrain.noMemoryFallback
        }
        let summaries = evidence.map { "- \($0.summary)" }.joined(separator: "\n")
        return "Based on what you've shared:\n\(summaries)"
    }
}

// MARK: - Speech-to-Text Provider

/// Abstraction for on-device speech recognition.
protocol SpeechToTextProvider {
    var isAvailable: Bool { get }
    func transcribe(audioFileURL: URL) async throws -> TranscriptionResult
}

struct TranscriptionResult {
    let text: String
    let confidence: Double
    let segments: [TranscriptionSegment]
}

struct TranscriptionSegment {
    let text: String
    let startTime: TimeInterval
    let endTime: TimeInterval
    let confidence: Double
}

/// Deterministic fake STT for tests — no microphone or model required.
final class FakeSpeechToText: SpeechToTextProvider {
    var isAvailable: Bool { true }

    /// Configurable transcript for test scenarios
    var nextTranscript: String = "I was nervous today about whether this app can work, but I still feel it can help people keep their thoughts private."

    func transcribe(audioFileURL: URL) async throws -> TranscriptionResult {
        return TranscriptionResult(
            text: nextTranscript,
            confidence: 0.92,
            segments: [
                TranscriptionSegment(text: nextTranscript, startTime: 0, endTime: 5.0, confidence: 0.92)
            ]
        )
    }
}

// MARK: - TTS Provider

/// Abstraction for on-device text-to-speech.
protocol TTSProvider {
    var isAvailable: Bool { get }
    func speak(text: String) async throws
    func stop()
}

/// Deterministic fake TTS for tests — no audio output.
final class FakeTTS: TTSProvider {
    var isAvailable: Bool { true }
    private(set) var lastSpokenText: String?
    private(set) var isSpeaking = false

    func speak(text: String) async throws {
        lastSpokenText = text
        isSpeaking = true
        // Simulate speech duration
        try await Task.sleep(nanoseconds: 100_000_000) // 0.1s
        isSpeaking = false
    }

    func stop() {
        isSpeaking = false
    }
}
