// PrivatePensieveTests.swift
// Private Pensieve AI — iOS Unit Tests
// Tests canonical models, fake providers, and critical recall fallback

import XCTest
@testable import PrivatePensieve

final class MemoryModelTests: XCTestCase {

    // MARK: - Schema Parity Tests

    func testConversationRoundTrip() throws {
        let conversation = Conversation(
            id: "conv-001",
            createdAt: ISO8601DateFormatter().date(from: "2026-07-01T00:00:00Z")!,
            sourceType: .voice,
            userTranscript: "I was nervous today about whether this app can work.",
            aiReply: "That sounds important.",
            audioRetained: false,
            audioFilePath: nil,
            isArchived: false,
            isDeleted: false
        )

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(conversation)

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let decoded = try decoder.decode(Conversation.self, from: data)

        XCTAssertEqual(conversation, decoded)
    }

    func testMemoryCardRoundTrip() throws {
        let card = MemoryCard(
            id: "mem-001",
            createdAt: Date(),
            updatedAt: Date(),
            sourceConversationId: "conv-001",
            title: "Concern and hope about the private app idea",
            summary: "User felt nervous but hopeful about creating a privacy-first app.",
            emotionTags: ["nervous", "hopeful"],
            topicTags: ["app idea", "privacy"],
            peopleTags: [],
            placeTags: [],
            goalTags: [],
            importanceScore: 7,
            confidenceScore: 0.85,
            duplicateGroupId: nil,
            isFavorite: false,
            isSensitive: false,
            isArchived: false,
            isDeleted: false
        )

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(card)

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let decoded = try decoder.decode(MemoryCard.self, from: data)

        XCTAssertEqual(card, decoded)
    }

    func testDailySummaryRoundTrip() throws {
        let summary = DailySummary(
            date: "2026-07-01",
            summary: "You shared 3 thoughts today.",
            topEmotions: ["hopeful"],
            topTopics: ["privacy"],
            importantMemoryIds: ["mem-001"],
            updatedAt: Date()
        )

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(summary)

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let decoded = try decoder.decode(DailySummary.self, from: data)

        XCTAssertEqual(summary, decoded)
    }

    func testLongTermFactRoundTrip() throws {
        let fact = LongTermFact(
            id: "fact-001",
            factType: .goal,
            factText: "User wants to build a privacy-first AI memory app.",
            confidenceScore: 0.9,
            sourceMemoryIds: ["mem-001", "mem-002"],
            requiresUserConfirmation: true,
            isDeleted: false
        )

        let encoder = JSONEncoder()
        let data = try encoder.encode(fact)

        let decoder = JSONDecoder()
        let decoded = try decoder.decode(LongTermFact.self, from: data)

        XCTAssertEqual(fact, decoded)
    }

    func testMemoryCardJSONKeysMatchSchema() throws {
        let card = MemoryCard(
            id: "test",
            createdAt: Date(),
            updatedAt: Date(),
            sourceConversationId: "conv",
            title: "Test",
            summary: "Test summary",
            emotionTags: ["happy"],
            topicTags: ["test"],
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

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(card)
        let json = try JSONSerialization.jsonObject(with: data) as! [String: Any]

        // Verify schema keys match MEMORY_SCHEMA.md
        XCTAssertNotNil(json["memory_id"])
        XCTAssertNotNil(json["created_at"])
        XCTAssertNotNil(json["updated_at"])
        XCTAssertNotNil(json["source_conversation_id"])
        XCTAssertNotNil(json["title"])
        XCTAssertNotNil(json["summary"])
        XCTAssertNotNil(json["emotion_tags"])
        XCTAssertNotNil(json["topic_tags"])
        XCTAssertNotNil(json["people_tags"])
        XCTAssertNotNil(json["place_tags"])
        XCTAssertNotNil(json["goal_tags"])
        XCTAssertNotNil(json["importance_score"])
        XCTAssertNotNil(json["confidence_score"])
        XCTAssertNotNil(json["is_favorite"])
        XCTAssertNotNil(json["is_sensitive"])
        XCTAssertNotNil(json["is_archived"])
        XCTAssertNotNil(json["is_deleted"])
    }
}

// MARK: - AI Brain Tests

final class FakeAIBrainTests: XCTestCase {

    let brain = FakeAIBrain()

    /// Critical test: exact fallback text when no memory evidence exists.
    /// This is a non-negotiable product requirement from AGENTS.md.
    func testNoMemoryFallbackExactText() async throws {
        let answer = try await brain.answerFromEvidence(
            question: "What did I say about my wedding?",
            evidence: []
        )
        XCTAssertEqual(
            answer,
            "I don't remember you telling me that yet.",
            "Fallback text must match AGENTS.md exactly — no paraphrasing"
        )
    }

    func testAnswerWithEvidence() async throws {
        let evidence = [
            MemoryCard(
                id: "mem-001",
                createdAt: Date(),
                updatedAt: Date(),
                sourceConversationId: "conv-001",
                title: "Offline access matters",
                summary: "User wants the app to work without internet when flying or camping.",
                emotionTags: [],
                topicTags: ["offline", "travel"],
                peopleTags: [],
                placeTags: [],
                goalTags: [],
                importanceScore: 6,
                confidenceScore: 0.85,
                duplicateGroupId: nil,
                isFavorite: false,
                isSensitive: false,
                isArchived: false,
                isDeleted: false
            )
        ]

        let answer = try await brain.answerFromEvidence(
            question: "Why does offline access matter to me?",
            evidence: evidence
        )

        // Should NOT return the fallback when evidence exists
        XCTAssertNotEqual(answer, FakeAIBrain.noMemoryFallback)
        XCTAssertTrue(answer.contains("flying or camping") || answer.contains("without internet"),
                       "Answer should reference evidence content")
    }

    func testExtractMemory() async throws {
        let cards = try await brain.extractMemory(
            transcript: "I was nervous today about whether this app can work."
        )
        XCTAssertFalse(cards.isEmpty)
        XCTAssertEqual(cards.first?.importanceScore, 5)
        XCTAssertEqual(cards.first?.confidenceScore, 0.8)
    }

    func testFakeAIBrainIsAlwaysAvailable() {
        XCTAssertTrue(brain.isAvailable, "Fake brain must always be available for tests")
    }
}

// MARK: - Fake STT Tests

final class FakeSpeechToTextTests: XCTestCase {

    func testFakeSTTReturnsConfigurableTranscript() async throws {
        let stt = FakeSpeechToText()
        stt.nextTranscript = "I want this friend to work without the internet."

        let result = try await stt.transcribe(audioFileURL: URL(fileURLWithPath: "/fake/audio.m4a"))

        XCTAssertEqual(result.text, "I want this friend to work without the internet.")
        XCTAssertGreaterThan(result.confidence, 0.0)
    }

    func testFakeSTTIsAlwaysAvailable() {
        let stt = FakeSpeechToText()
        XCTAssertTrue(stt.isAvailable, "Fake STT must always be available for tests")
    }
}

// MARK: - Fake TTS Tests

final class FakeTTSTests: XCTestCase {

    func testFakeTTSSpeaks() async throws {
        let tts = FakeTTS()
        try await tts.speak(text: "That sounds important.")
        XCTAssertEqual(tts.lastSpokenText, "That sounds important.")
    }

    func testFakeTTSIsAlwaysAvailable() {
        let tts = FakeTTS()
        XCTAssertTrue(tts.isAvailable, "Fake TTS must always be available for tests")
    }
}
