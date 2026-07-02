// MemoryModels.swift
// Private Pensieve AI — iOS
// Canonical memory models matching docs/MEMORY_SCHEMA.md exactly

import Foundation

// MARK: - Conversation

/// A recorded conversation between the user and the AI.
/// Raw transcript lives here, not duplicated in MemoryCard.
struct Conversation: Identifiable, Codable, Equatable {
    let id: String              // UUID string — deterministic
    let createdAt: Date         // ISO-8601 UTC
    let sourceType: SourceType
    var userTranscript: String
    var aiReply: String?
    var audioRetained: Bool
    var audioFilePath: String?
    var isArchived: Bool
    var isDeleted: Bool

    enum SourceType: String, Codable {
        case voice
        case text
        case imported
    }

    enum CodingKeys: String, CodingKey {
        case id = "conversation_id"
        case createdAt = "created_at"
        case sourceType = "source_type"
        case userTranscript = "user_transcript"
        case aiReply = "ai_reply"
        case audioRetained = "audio_retained"
        case audioFilePath = "audio_file_path"
        case isArchived = "is_archived"
        case isDeleted = "is_deleted"
    }
}

// MARK: - MemoryCard

/// The primary recall unit. Extracted from a conversation by the AI brain.
struct MemoryCard: Identifiable, Codable, Equatable {
    let id: String              // UUID string — deterministic
    let createdAt: Date         // ISO-8601 UTC
    var updatedAt: Date         // ISO-8601 UTC
    let sourceConversationId: String
    var title: String
    var summary: String
    var emotionTags: [String]
    var topicTags: [String]
    var peopleTags: [String]
    var placeTags: [String]
    var goalTags: [String]
    var importanceScore: Int    // 1–10
    var confidenceScore: Double // 0.0–1.0
    var duplicateGroupId: String?
    var isFavorite: Bool
    var isSensitive: Bool
    var isArchived: Bool
    var isDeleted: Bool

    enum CodingKeys: String, CodingKey {
        case id = "memory_id"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case sourceConversationId = "source_conversation_id"
        case title, summary
        case emotionTags = "emotion_tags"
        case topicTags = "topic_tags"
        case peopleTags = "people_tags"
        case placeTags = "place_tags"
        case goalTags = "goal_tags"
        case importanceScore = "importance_score"
        case confidenceScore = "confidence_score"
        case duplicateGroupId = "duplicate_group_id"
        case isFavorite = "is_favorite"
        case isSensitive = "is_sensitive"
        case isArchived = "is_archived"
        case isDeleted = "is_deleted"
    }
}

// MARK: - DailySummary

/// Compact aggregation of a day's memories.
struct DailySummary: Identifiable, Codable, Equatable {
    var id: String { date }     // date string is unique key
    let date: String            // "2026-07-01" format
    var summary: String
    var topEmotions: [String]
    var topTopics: [String]
    var importantMemoryIds: [String]
    var updatedAt: Date

    enum CodingKeys: String, CodingKey {
        case date, summary
        case topEmotions = "top_emotions"
        case topTopics = "top_topics"
        case importantMemoryIds = "important_memory_ids"
        case updatedAt = "updated_at"
    }
}

// MARK: - LongTermFact

/// A stable fact promoted from repeated evidence or explicit user confirmation.
struct LongTermFact: Identifiable, Codable, Equatable {
    let id: String              // UUID string
    let factType: FactType
    var factText: String
    var confidenceScore: Double
    var sourceMemoryIds: [String]
    var requiresUserConfirmation: Bool
    var isDeleted: Bool

    enum FactType: String, Codable {
        case preference
        case goal
        case relationshipContext = "relationship_context"
        case recurringTheme = "recurring_theme"
    }

    enum CodingKeys: String, CodingKey {
        case id = "fact_id"
        case factType = "fact_type"
        case factText = "fact_text"
        case confidenceScore = "confidence_score"
        case sourceMemoryIds = "source_memory_ids"
        case requiresUserConfirmation = "requires_user_confirmation"
        case isDeleted = "is_deleted"
    }
}

// MARK: - MemoryEdge (future-compatible, optional V1)

/// Relationship between two memories.
struct MemoryEdge: Identifiable, Codable, Equatable {
    let id: String
    let fromMemoryId: String
    let toMemoryId: String
    let edgeType: EdgeType
    var weight: Double

    enum EdgeType: String, Codable {
        case sameTopic = "same_topic"
        case samePerson = "same_person"
        case sameGoal = "same_goal"
        case emotionalPattern = "emotional_pattern"
        case temporalFollowup = "temporal_followup"
    }

    enum CodingKeys: String, CodingKey {
        case id = "edge_id"
        case fromMemoryId = "from_memory_id"
        case toMemoryId = "to_memory_id"
        case edgeType = "edge_type"
        case weight
    }
}
