package com.privatepensieve.app.vault

import java.time.Instant
import java.time.LocalDate
import java.time.format.DateTimeFormatter

/**
 * Room entities for the Pensieve vault database.
 * Maps directly to the schema in shared/sql/schema.sql.
 * All data local-only. No cloud. No sync.
 *
 * Note: Room annotations are commented as @Entity/@Dao patterns.
 * When Room is added as a dependency, uncomment the annotations.
 * For now, these are pure data classes matching the schema.
 */

// MARK: - MemoryCard Entity

data class MemoryCardEntity(
    val memoryId: String,
    val createdAt: String,         // ISO-8601
    val updatedAt: String,         // ISO-8601
    val sourceType: String = "voice",
    val sourceConversationId: String? = null,
    val title: String,
    val summary: String,
    val rawTranscript: String? = null,
    val emotionTags: String = "[]", // JSON array
    val topicTags: String = "[]",
    val peopleTags: String = "[]",
    val placeTags: String = "[]",
    val goalTags: String = "[]",
    val importanceScore: Int = 5,
    val confidenceScore: Double = 0.8,
    val isFavorite: Boolean = false,
    val isSensitive: Boolean = false,
    val isArchived: Boolean = false,
    val isDeleted: Boolean = false
)

// MARK: - Conversation Entity

data class ConversationEntity(
    val conversationId: String,
    val createdAt: String,
    val userTranscript: String,
    val aiReply: String? = null,
    val sourceType: String = "voice",
    val audioFilePath: String? = null,
    val isArchived: Boolean = false,
    val isDeleted: Boolean = false
)

// MARK: - DailySummary Entity

data class DailySummaryEntity(
    val date: String,              // "2026-07-01"
    val summary: String,
    val topEmotions: String = "[]", // JSON array
    val topTopics: String = "[]",
    val importantMemoryIds: String = "[]",
    val createdAt: String,
    val updatedAt: String
)

// MARK: - LongTermFact Entity

data class LongTermFactEntity(
    val factId: String,
    val factType: String,          // preference|goal|relationship_context|recurring_theme
    val factText: String,
    val confidenceScore: Double = 0.0,
    val sourceMemoryIds: String = "[]", // JSON array
    val createdAt: String,
    val updatedAt: String,
    val isDeleted: Boolean = false
)

// MARK: - MemoryEdge Entity

data class MemoryEdgeEntity(
    val edgeId: String,
    val fromId: String,
    val toId: String,
    val edgeType: String,          // same_topic|same_person|same_goal|emotional_pattern|temporal_followup
    val weight: Double = 0.0,
    val createdAt: String
)

// MARK: - Type Converters

object VaultTypeConverters {

    private val jsonListRegex = Regex(""""\s*([^"]*)\s*"""")

    /**
     * Convert List<String> to JSON array string for SQLite storage.
     */
    fun toJsonString(list: List<String>): String {
        if (list.isEmpty()) return "[]"
        return "[${list.joinToString(",") { "\"$it\"" }}]"
    }

    /**
     * Convert JSON array string from SQLite to List<String>.
     */
    fun fromJsonString(json: String?): List<String> {
        if (json.isNullOrBlank() || json == "[]") return emptyList()
        return jsonListRegex.findAll(json).map { it.groupValues[1] }.toList()
    }

    /**
     * Get current time as ISO-8601 string.
     */
    fun nowISO(): String = Instant.now().toString()

    /**
     * Get today's date as "yyyy-MM-dd" string.
     */
    fun todayDate(): String = LocalDate.now().format(DateTimeFormatter.ISO_LOCAL_DATE)
}
