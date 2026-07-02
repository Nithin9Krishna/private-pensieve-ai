// DailySummaryDAO.swift
// Private Pensieve AI — iOS
// CRUD operations for daily_summaries table.

import Foundation

/// Data access object for DailySummary entities.
final class DailySummaryDAO {

    private let db: VaultDatabase

    init(db: VaultDatabase = .shared) {
        self.db = db
    }

    // MARK: - Insert / Update

    func upsert(_ summary: DailySummary) throws {
        let sql = """
        INSERT OR REPLACE INTO daily_summaries (
            date, summary, top_emotions, top_topics, important_memory_ids, created_at, updated_at
        ) VALUES (?, ?, ?, ?, ?, ?, ?)
        """
        let now = Date().iso8601String
        try db.execute(sql, params: [
            summary.date,
            summary.summary,
            summary.topEmotions.jsonString,
            summary.topTopics.jsonString,
            summary.importantMemoryIds.jsonString,
            now, // created_at (ignored on replace since date is PK)
            summary.updatedAt.iso8601String
        ])
    }

    // MARK: - Query

    func fetchByDate(_ date: String) throws -> DailySummary? {
        let sql = "SELECT * FROM daily_summaries WHERE date = ?"
        return try db.query(sql, params: [date]).first.map { try Self.fromRow($0) }
    }

    func fetchRecent(limit: Int = 7) throws -> [DailySummary] {
        let sql = "SELECT * FROM daily_summaries ORDER BY date DESC LIMIT ?"
        return try db.query(sql, params: [limit]).map { try Self.fromRow($0) }
    }

    // MARK: - Delete

    func deleteAll() throws {
        try db.execute("DELETE FROM daily_summaries")
    }

    // MARK: - Row Mapping

    private static func fromRow(_ row: [String: Any?]) throws -> DailySummary {
        guard let date = row["date"] as? String,
              let summary = row["summary"] as? String,
              let updatedStr = row["updated_at"] as? String else {
            throw VaultError.executeFailed("Missing required fields in daily_summaries row")
        }

        return DailySummary(
            date: date,
            summary: summary,
            topEmotions: .fromJSON(row["top_emotions"] as? String),
            topTopics: .fromJSON(row["top_topics"] as? String),
            importantMemoryIds: .fromJSON(row["important_memory_ids"] as? String),
            updatedAt: Date.fromISO8601(updatedStr) ?? Date()
        )
    }
}
