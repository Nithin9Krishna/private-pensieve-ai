package com.privatepensieve.app.providers

import com.privatepensieve.app.models.DailySummary
import com.privatepensieve.app.models.MemoryCard
import java.time.LocalDate

/**
 * AI Brain Provider — core interface for on-device AI capabilities.
 * Every app feature must work with FakeAIBrain.
 * No remote inference. No cloud fallback. Ever.
 */
interface AIBrainProvider {
    /** Check if the provider is currently available on this device */
    val isAvailable: Boolean

    /** Generate a warm, non-judgmental friend reply to user speech */
    suspend fun generateFriendReply(transcript: String, recentMemories: List<MemoryCard>): String

    /** Extract structured memory cards from a transcript */
    suspend fun extractMemory(transcript: String): List<MemoryCard>

    /** Generate a daily summary from today's memory cards */
    suspend fun summarizeDay(memories: List<MemoryCard>): DailySummary

    /** Answer a recall question using only the provided evidence.
     *  Returns the exact fallback when evidence is empty. */
    suspend fun answerFromEvidence(question: String, evidence: List<MemoryCard>): String
}

/**
 * Deterministic fake provider for all tests.
 * Works without any AI model, hardware, or network.
 */
class FakeAIBrain : AIBrainProvider {

    companion object {
        /** The exact fallback text per AGENTS.md and RECALL_PIPELINE.md */
        const val NO_MEMORY_FALLBACK = "I don't remember you telling me that yet."
    }

    override val isAvailable: Boolean = true

    override suspend fun generateFriendReply(
        transcript: String,
        recentMemories: List<MemoryCard>
    ): String {
        return "That sounds important. What part of it stayed with you most?"
    }

    override suspend fun extractMemory(transcript: String): List<MemoryCard> {
        return listOf(
            MemoryCard(
                sourceConversationId = "fake-conv",
                title = transcript.take(60),
                summary = transcript,
                importanceScore = 5,
                confidenceScore = 0.8
            )
        )
    }

    override suspend fun summarizeDay(memories: List<MemoryCard>): DailySummary {
        return DailySummary(
            date = LocalDate.now(),
            summary = "You shared ${memories.size} thoughts today.",
            importantMemoryIds = memories.filter { it.importanceScore >= 7 }.map { it.memoryId }
        )
    }

    override suspend fun answerFromEvidence(
        question: String,
        evidence: List<MemoryCard>
    ): String {
        if (evidence.isEmpty()) {
            return NO_MEMORY_FALLBACK
        }
        val summaries = evidence.joinToString("\n") { "- ${it.summary}" }
        return "Based on what you've shared:\n$summaries"
    }
}

// MARK: - Speech-to-Text Provider

/** Abstraction for on-device speech recognition. */
interface SpeechToTextProvider {
    val isAvailable: Boolean
    suspend fun transcribe(audioFilePath: String): TranscriptionResult
}

data class TranscriptionResult(
    val text: String,
    val confidence: Double,
    val segments: List<TranscriptionSegment> = emptyList()
)

data class TranscriptionSegment(
    val text: String,
    val startTimeMs: Long,
    val endTimeMs: Long,
    val confidence: Double
)

/** Deterministic fake STT for tests — no microphone or model required. */
class FakeSpeechToText : SpeechToTextProvider {
    override val isAvailable: Boolean = true

    /** Configurable transcript for test scenarios */
    var nextTranscript: String =
        "I was nervous today about whether this app can work, but I still feel it can help people keep their thoughts private."

    override suspend fun transcribe(audioFilePath: String): TranscriptionResult {
        return TranscriptionResult(
            text = nextTranscript,
            confidence = 0.92,
            segments = listOf(
                TranscriptionSegment(nextTranscript, 0, 5000, 0.92)
            )
        )
    }
}

// MARK: - TTS Provider

/** Abstraction for on-device text-to-speech. */
interface TTSProvider {
    val isAvailable: Boolean
    suspend fun speak(text: String)
    fun stop()
}

/** Deterministic fake TTS for tests — no audio output. */
class FakeTTS : TTSProvider {
    override val isAvailable: Boolean = true
    var lastSpokenText: String? = null
        private set
    var isSpeaking: Boolean = false
        private set

    override suspend fun speak(text: String) {
        lastSpokenText = text
        isSpeaking = true
        // Simulate brief speech
        kotlinx.coroutines.delay(100)
        isSpeaking = false
    }

    override fun stop() {
        isSpeaking = false
    }
}
