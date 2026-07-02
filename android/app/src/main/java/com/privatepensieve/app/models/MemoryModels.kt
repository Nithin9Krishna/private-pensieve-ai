package com.privatepensieve.app.models

import java.time.Instant
import java.time.LocalDate
import java.util.UUID

/**
 * Canonical memory models matching docs/MEMORY_SCHEMA.md exactly.
 * All field names use the snake_case JSON keys from the schema.
 * Kotlin properties use camelCase; serialization maps to schema keys.
 */

// MARK: - Conversation

/**
 * A recorded conversation between the user and the AI.
 * Raw transcript lives here, not duplicated in MemoryCard.
 */
data class Conversation(
    val conversationId: String = UUID.randomUUID().toString(),
    val createdAt: Instant = Instant.now(),
    val sourceType: SourceType = SourceType.VOICE,
    val userTranscript: String,
    val aiReply: String? = null,
    val audioRetained: Boolean = false,
    val audioFilePath: String? = null,
    val isArchived: Boolean = false,
    val isDeleted: Boolean = false
) {
    enum class SourceType { VOICE, TEXT, IMPORTED }
}

// MARK: - MemoryCard

/**
 * The primary recall unit. Extracted from a conversation by the AI brain.
 */
data class MemoryCard(
    val memoryId: String = UUID.randomUUID().toString(),
    val createdAt: Instant = Instant.now(),
    val updatedAt: Instant = Instant.now(),
    val sourceConversationId: String,
    val title: String,
    val summary: String,
    val emotionTags: List<String> = emptyList(),
    val topicTags: List<String> = emptyList(),
    val peopleTags: List<String> = emptyList(),
    val placeTags: List<String> = emptyList(),
    val goalTags: List<String> = emptyList(),
    val importanceScore: Int = 1,        // 1–10
    val confidenceScore: Double = 0.0,   // 0.0–1.0
    val duplicateGroupId: String? = null,
    val isFavorite: Boolean = false,
    val isSensitive: Boolean = false,
    val isArchived: Boolean = false,
    val isDeleted: Boolean = false
)

// MARK: - DailySummary

/**
 * Compact aggregation of a day's memories.
 */
data class DailySummary(
    val date: LocalDate = LocalDate.now(),
    val summary: String,
    val topEmotions: List<String> = emptyList(),
    val topTopics: List<String> = emptyList(),
    val importantMemoryIds: List<String> = emptyList(),
    val updatedAt: Instant = Instant.now()
)

// MARK: - LongTermFact

/**
 * A stable fact promoted from repeated evidence or explicit user confirmation.
 */
data class LongTermFact(
    val factId: String = UUID.randomUUID().toString(),
    val factType: FactType,
    val factText: String,
    val confidenceScore: Double = 0.0,
    val sourceMemoryIds: List<String> = emptyList(),
    val requiresUserConfirmation: Boolean = true,
    val isDeleted: Boolean = false
) {
    enum class FactType {
        PREFERENCE,
        GOAL,
        RELATIONSHIP_CONTEXT,
        RECURRING_THEME
    }
}

// MARK: - MemoryEdge (future-compatible, optional V1)

/**
 * Relationship between two memories.
 */
data class MemoryEdge(
    val edgeId: String = UUID.randomUUID().toString(),
    val fromMemoryId: String,
    val toMemoryId: String,
    val edgeType: EdgeType,
    val weight: Double = 0.0
) {
    enum class EdgeType {
        SAME_TOPIC,
        SAME_PERSON,
        SAME_GOAL,
        EMOTIONAL_PATTERN,
        TEMPORAL_FOLLOWUP
    }
}
