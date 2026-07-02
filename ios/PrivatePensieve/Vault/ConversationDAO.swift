// ConversationDAO.swift
// Private Pensieve AI — iOS
// CRUD operations for conversations table.

import Foundation

/// Data access object for Conversation entities.
final class ConversationDAO {

    private let db: VaultDatabase

    init(db: VaultDatabase = .shared) {
        self.db = db
    }

    // MARK: - Insert

    func insert(_ conversation: Conversation) throws {
        let sql = """
        INSERT OR REPLACE INTO conversations (
            conversation_id, created_at, user_transcript, ai_reply,
            source_type, audio_file_path, is_archived, is_deleted
        ) VALUES (?, ?, ?, ?, ?, ?, ?, ?)
        """
        try db.execute(sql, params: [
            conversation.id,
            conversation.createdAt.iso8601String,
            conversation.userTranscript,
            conversation.aiReply,
            conversation.sourceType.rawValue,
            conversation.audioFilePath,
            conversation.isArchived,
            conversation.isDeleted
        ])
    }

    // MARK: - Query

    func fetchAll() throws -> [Conversation] {
        let sql = """
        SELECT * FROM conversations
        WHERE is_deleted = 0
        ORDER BY created_at DESC
        """
        return try db.query(sql).map { try Self.fromRow($0) }
    }

    func fetchById(_ id: String) throws -> Conversation? {
        let sql = "SELECT * FROM conversations WHERE conversation_id = ?"
        return try db.query(sql, params: [id]).first.map { try Self.fromRow($0) }
    }

    func fetchRecent(limit: Int = 10) throws -> [Conversation] {
        let sql = """
        SELECT * FROM conversations
        WHERE is_deleted = 0
        ORDER BY created_at DESC
        LIMIT ?
        """
        return try db.query(sql, params: [limit]).map { try Self.fromRow($0) }
    }

    // MARK: - Delete

    func softDelete(_ id: String) throws {
        try db.execute("UPDATE conversations SET is_deleted = 1 WHERE conversation_id = ?", params: [id])
    }

    func deleteAll() throws {
        try db.execute("DELETE FROM conversations")
    }

    // MARK: - Stats

    func activeCount() throws -> Int {
        let rows = try db.query("SELECT COUNT(*) as count FROM conversations WHERE is_deleted = 0")
        return (rows.first?["count"] as? Int) ?? 0
    }

    // MARK: - Row Mapping

    private static func fromRow(_ row: [String: Any?]) throws -> Conversation {
        guard let id = row["conversation_id"] as? String,
              let createdStr = row["created_at"] as? String,
              let transcript = row["user_transcript"] as? String,
              let sourceStr = row["source_type"] as? String else {
            throw VaultError.executeFailed("Missing required fields in conversations row")
        }

        return Conversation(
            id: id,
            createdAt: Date.fromISO8601(createdStr) ?? Date(),
            sourceType: Conversation.SourceType(rawValue: sourceStr) ?? .voice,
            userTranscript: transcript,
            aiReply: row["ai_reply"] as? String,
            audioRetained: false,
            audioFilePath: row["audio_file_path"] as? String,
            isArchived: ((row["is_archived"] as? Int) ?? 0) == 1,
            isDeleted: ((row["is_deleted"] as? Int) ?? 0) == 1
        )
    }
}
