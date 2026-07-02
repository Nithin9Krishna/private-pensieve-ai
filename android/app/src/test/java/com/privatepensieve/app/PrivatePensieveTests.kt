package com.privatepensieve.app

import com.privatepensieve.app.models.*
import com.privatepensieve.app.providers.*
import kotlinx.coroutines.test.runTest
import org.junit.Assert.*
import org.junit.Test
import java.time.Instant
import java.time.LocalDate

/**
 * Unit tests for canonical models, fake providers, and critical recall fallback.
 * Tests run without network, AI model, or device hardware.
 */
class MemoryModelTests {

    // MARK: - Schema Parity Tests

    @Test
    fun conversationHasAllSchemaFields() {
        val conversation = Conversation(
            conversationId = "conv-001",
            createdAt = Instant.parse("2026-07-01T00:00:00Z"),
            sourceType = Conversation.SourceType.VOICE,
            userTranscript = "I was nervous today.",
            aiReply = "That sounds important.",
            audioRetained = false,
            audioFilePath = null,
            isArchived = false,
            isDeleted = false
        )

        assertEquals("conv-001", conversation.conversationId)
        assertEquals(Conversation.SourceType.VOICE, conversation.sourceType)
        assertFalse(conversation.audioRetained)
        assertNull(conversation.audioFilePath)
    }

    @Test
    fun memoryCardHasAllSchemaFields() {
        val card = MemoryCard(
            memoryId = "mem-001",
            createdAt = Instant.now(),
            updatedAt = Instant.now(),
            sourceConversationId = "conv-001",
            title = "Concern and hope about the private app idea",
            summary = "User felt nervous but hopeful.",
            emotionTags = listOf("nervous", "hopeful"),
            topicTags = listOf("app idea", "privacy"),
            peopleTags = emptyList(),
            placeTags = emptyList(),
            goalTags = emptyList(),
            importanceScore = 7,
            confidenceScore = 0.85,
            duplicateGroupId = null,
            isFavorite = false,
            isSensitive = false,
            isArchived = false,
            isDeleted = false
        )

        assertEquals("mem-001", card.memoryId)
        assertEquals(7, card.importanceScore)
        assertEquals(0.85, card.confidenceScore, 0.001)
        assertEquals(2, card.emotionTags.size)
        assertTrue(card.emotionTags.contains("nervous"))
        assertTrue(card.emotionTags.contains("hopeful"))
    }

    @Test
    fun dailySummaryHasAllSchemaFields() {
        val summary = DailySummary(
            date = LocalDate.of(2026, 7, 1),
            summary = "You shared 3 thoughts today.",
            topEmotions = listOf("hopeful"),
            topTopics = listOf("privacy"),
            importantMemoryIds = listOf("mem-001"),
            updatedAt = Instant.now()
        )

        assertEquals(LocalDate.of(2026, 7, 1), summary.date)
        assertEquals(1, summary.importantMemoryIds.size)
    }

    @Test
    fun longTermFactHasAllSchemaFields() {
        val fact = LongTermFact(
            factId = "fact-001",
            factType = LongTermFact.FactType.GOAL,
            factText = "User wants to build a privacy-first AI memory app.",
            confidenceScore = 0.9,
            sourceMemoryIds = listOf("mem-001", "mem-002"),
            requiresUserConfirmation = true,
            isDeleted = false
        )

        assertEquals(LongTermFact.FactType.GOAL, fact.factType)
        assertTrue(fact.requiresUserConfirmation)
        assertEquals(2, fact.sourceMemoryIds.size)
    }

    @Test
    fun memoryEdgeHasAllSchemaFields() {
        val edge = MemoryEdge(
            edgeId = "edge-001",
            fromMemoryId = "mem-001",
            toMemoryId = "mem-002",
            edgeType = MemoryEdge.EdgeType.SAME_TOPIC,
            weight = 0.75
        )

        assertEquals(MemoryEdge.EdgeType.SAME_TOPIC, edge.edgeType)
        assertEquals(0.75, edge.weight, 0.001)
    }
}

// MARK: - AI Brain Tests

class FakeAIBrainTests {

    private val brain = FakeAIBrain()

    /**
     * CRITICAL TEST: exact fallback text when no memory evidence exists.
     * This is a non-negotiable product requirement from AGENTS.md.
     */
    @Test
    fun noMemoryFallbackExactText() = runTest {
        val answer = brain.answerFromEvidence(
            question = "What did I say about my wedding?",
            evidence = emptyList()
        )
        assertEquals(
            "I don't remember you telling me that yet.",
            answer
        )
    }

    @Test
    fun answerWithEvidence() = runTest {
        val evidence = listOf(
            MemoryCard(
                sourceConversationId = "conv-001",
                title = "Offline access matters",
                summary = "User wants the app to work without internet when flying or camping.",
                topicTags = listOf("offline", "travel"),
                importanceScore = 6,
                confidenceScore = 0.85
            )
        )

        val answer = brain.answerFromEvidence(
            question = "Why does offline access matter to me?",
            evidence = evidence
        )

        // Should NOT return the fallback when evidence exists
        assertNotEquals(FakeAIBrain.NO_MEMORY_FALLBACK, answer)
        assertTrue(
            answer.contains("flying or camping") || answer.contains("without internet"),
        )
    }

    @Test
    fun extractMemoryReturnsCards() = runTest {
        val cards = brain.extractMemory(
            "I was nervous today about whether this app can work."
        )
        assertTrue(cards.isNotEmpty())
        assertEquals(5, cards.first().importanceScore)
        assertEquals(0.8, cards.first().confidenceScore, 0.001)
    }

    @Test
    fun fakeAIBrainIsAlwaysAvailable() {
        assertTrue(brain.isAvailable)
    }
}

// MARK: - Fake STT Tests

class FakeSpeechToTextTests {

    @Test
    fun fakeSTTReturnsConfigurableTranscript() = runTest {
        val stt = FakeSpeechToText()
        stt.nextTranscript = "I want this friend to work without the internet."

        val result = stt.transcribe("/fake/audio.m4a")

        assertEquals("I want this friend to work without the internet.", result.text)
        assertTrue(result.confidence > 0.0)
    }

    @Test
    fun fakeSTTIsAlwaysAvailable() {
        val stt = FakeSpeechToText()
        assertTrue(stt.isAvailable)
    }
}

// MARK: - Fake TTS Tests

class FakeTTSTests {

    @Test
    fun fakeTTSSpeaks() = runTest {
        val tts = FakeTTS()
        tts.speak("That sounds important.")
        assertEquals("That sounds important.", tts.lastSpokenText)
    }

    @Test
    fun fakeTTSIsAlwaysAvailable() {
        val tts = FakeTTS()
        assertTrue(tts.isAvailable)
    }
}
