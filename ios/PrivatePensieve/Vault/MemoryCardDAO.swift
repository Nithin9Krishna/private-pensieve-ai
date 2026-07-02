// MemoryCardDAO.swift
// Private Pensieve AI — iOS
// CRUD operations for memory_cards table.
// All data local-only. No cloud. No sync.

import Foundation

/// Data access object for MemoryCard entities.
/// Talks to VaultDatabase directly. No network calls.
final class MemoryCardDAO {

    private let db: VaultDatabase

    init(db: VaultDatabase = .shared) {
        self.db = db
    }

    // MARK: - Insert

    /// Insert a new memory card into the vault.
    func insert(_ card: MemoryCard) throws {
        let sql = """
        INSERT OR REPLACE INTO memory_cards (
            memory_id, created_at, updated_at, source_type, source_conversation_id,
            title, summary, emotion_tags, topic_tags, people_tags, place_tags, goal_tags,
            importance_score, confidence_score, is_favorite, is_sensitive, is_archived, is_deleted
        ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        """
        try db.execute(sql, params: [
            card.id,
            card.createdAt.iso8601String,
            card.updatedAt.iso8601String,
            "voice", // source_type
            card.sourceConversationId,
            card.title,
            card.summary,
            card.emotionTags.jsonString,
            card.topicTags.jsonString,
            card.peopleTags.jsonString,
            card.placeTags.jsonString,
            card.goalTags.jsonString,
            card.importanceScore,
            card.confidenceScore,
            card.isFavorite,
            card.isSensitive,
            card.isArchived,
            card.isDeleted
        ])
    }

    // MARK: - Query

    /// Get all non-deleted, non-archived memory cards, newest first.
    func fetchAll() throws -> [MemoryCard] {
        let sql = """
        SELECT * FROM memory_cards
        WHERE is_deleted = 0 AND is_archived = 0
        ORDER BY created_at DESC
        """
        return try db.query(sql).map { try Self.fromRow($0) }
    }

    /// Get memory cards matching a filter.
    func fetch(filter: MemoryFilter) throws -> [MemoryCard] {
        var sql = "SELECT * FROM memory_cards WHERE is_deleted = 0 AND is_archived = 0"
        var params: [Any?] = []

        if filter.favoritesOnly {
            sql += " AND is_favorite = 1"
        }

        if let minImportance = filter.minImportance {
            sql += " AND importance_score >= ?"
            params.append(minImportance)
        }

        if let tag = filter.tag {
            // Search across all tag columns
            sql += " AND (emotion_tags LIKE ? OR topic_tags LIKE ? OR people_tags LIKE ? OR goal_tags LIKE ?)"
            let wildcard = "%\"\(tag)\"%"
            params.append(contentsOf: [wildcard, wildcard, wildcard, wildcard])
        }

        if let searchText = filter.searchText, !searchText.isEmpty {
            sql += " AND (title LIKE ? OR summary LIKE ?)"
            let wildcard = "%\(searchText)%"
            params.append(contentsOf: [wildcard, wildcard])
        }

        if let daysSince = filter.daysSince {
            let cutoff = Calendar.current.date(byAdding: .day, value: -daysSince, to: Date())!
            sql += " AND created_at >= ?"
            params.append(cutoff.iso8601String)
        }

        sql += " ORDER BY created_at DESC"

        if let limit = filter.limit {
            sql += " LIMIT ?"
            params.append(limit)
        }

        return try db.query(sql, params: params).map { try Self.fromRow($0) }
    }

    /// Get a single memory card by ID.
    func fetchById(_ id: String) throws -> MemoryCard? {
        let sql = "SELECT * FROM memory_cards WHERE memory_id = ?"
        let rows = try db.query(sql, params: [id])
        return try rows.first.map { try Self.fromRow($0) }
    }

    /// Search memory cards by title and summary text.
    func search(query: String, limit: Int = 10) throws -> [MemoryCard] {
        let filter = MemoryFilter(searchText: query, limit: limit)
        return try fetch(filter: filter)
    }

    // MARK: - Update

    /// Toggle favorite status.
    func toggleFavorite(_ id: String) throws {
        let sql = "UPDATE memory_cards SET is_favorite = NOT is_favorite, updated_at = ? WHERE memory_id = ?"
        try db.execute(sql, params: [Date().iso8601String, id])
    }

    /// Update tags on a memory card.
    func updateTags(_ id: String, emotionTags: [String]? = nil, topicTags: [String]? = nil,
                    peopleTags: [String]? = nil, placeTags: [String]? = nil, goalTags: [String]? = nil) throws {
        var setClauses: [String] = ["updated_at = ?"]
        var params: [Any?] = [Date().iso8601String]

        if let tags = emotionTags { setClauses.append("emotion_tags = ?"); params.append(tags.jsonString) }
        if let tags = topicTags { setClauses.append("topic_tags = ?"); params.append(tags.jsonString) }
        if let tags = peopleTags { setClauses.append("people_tags = ?"); params.append(tags.jsonString) }
        if let tags = placeTags { setClauses.append("place_tags = ?"); params.append(tags.jsonString) }
        if let tags = goalTags { setClauses.append("goal_tags = ?"); params.append(tags.jsonString) }

        params.append(id)
        let sql = "UPDATE memory_cards SET \(setClauses.joined(separator: ", ")) WHERE memory_id = ?"
        try db.execute(sql, params: params)
    }

    // MARK: - Delete

    /// Soft-delete a memory card (sets is_deleted = 1).
    func softDelete(_ id: String) throws {
        let sql = "UPDATE memory_cards SET is_deleted = 1, updated_at = ? WHERE memory_id = ?"
        try db.execute(sql, params: [Date().iso8601String, id])
    }

    /// Hard-delete all soft-deleted cards (permanent removal).
    func purgeDeleted() throws {
        try db.execute("DELETE FROM memory_cards WHERE is_deleted = 1")
    }

    /// Delete ALL memory cards (used by Privacy > Delete All Memories).
    func deleteAll() throws {
        try db.execute("DELETE FROM memory_cards")
    }

    // MARK: - Stats

    /// Count of active (non-deleted) memory cards.
    func activeCount() throws -> Int {
        let rows = try db.query("SELECT COUNT(*) as count FROM memory_cards WHERE is_deleted = 0")
        return (rows.first?["count"] as? Int) ?? 0
    }

    // MARK: - Row Mapping

    private static func fromRow(_ row: [String: Any?]) throws -> MemoryCard {
        guard let id = row["memory_id"] as? String,
              let createdStr = row["created_at"] as? String,
              let updatedStr = row["updated_at"] as? String,
              let title = row["title"] as? String,
              let summary = row["summary"] as? String else {
            throw VaultError.executeFailed("Missing required fields in memory_cards row")
        }

        return MemoryCard(
            id: id,
            createdAt: Date.fromISO8601(createdStr) ?? Date(),
            updatedAt: Date.fromISO8601(updatedStr) ?? Date(),
            sourceConversationId: (row["source_conversation_id"] as? String) ?? "",
            title: title,
            summary: summary,
            emotionTags: .fromJSON(row["emotion_tags"] as? String),
            topicTags: .fromJSON(row["topic_tags"] as? String),
            peopleTags: .fromJSON(row["people_tags"] as? String),
            placeTags: .fromJSON(row["place_tags"] as? String),
            goalTags: .fromJSON(row["goal_tags"] as? String),
            importanceScore: (row["importance_score"] as? Int) ?? 5,
            confidenceScore: (row["confidence_score"] as? Double) ?? 0.8,
            duplicateGroupId: nil,
            isFavorite: ((row["is_favorite"] as? Int) ?? 0) == 1,
            isSensitive: ((row["is_sensitive"] as? Int) ?? 0) == 1,
            isArchived: ((row["is_archived"] as? Int) ?? 0) == 1,
            isDeleted: ((row["is_deleted"] as? Int) ?? 0) == 1
        )
    }
}

// MARK: - Filter

/// Filter criteria for querying memory cards.
struct MemoryFilter {
    var searchText: String? = nil
    var tag: String? = nil
    var favoritesOnly: Bool = false
    var minImportance: Int? = nil
    var daysSince: Int? = nil
    var limit: Int? = nil
}
