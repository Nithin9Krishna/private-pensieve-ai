// LongTermFactDAO.swift
// Private Pensieve AI — iOS
// CRUD operations for long_term_facts table.

import Foundation

/// Data access object for LongTermFact entities.
final class LongTermFactDAO {

    private let db: VaultDatabase

    init(db: VaultDatabase = .shared) {
        self.db = db
    }

    // MARK: - Insert

    func insert(_ fact: LongTermFact) throws {
        let sql = """
        INSERT OR REPLACE INTO long_term_facts (
            fact_id, fact_type, fact_text, confidence_score,
            source_memory_ids, created_at, updated_at, is_deleted
        ) VALUES (?, ?, ?, ?, ?, ?, ?, ?)
        """
        let now = Date().iso8601String
        try db.execute(sql, params: [
            fact.id,
            fact.factType.rawValue,
            fact.factText,
            fact.confidenceScore,
            fact.sourceMemoryIds.jsonString,
            now, now,
            fact.isDeleted
        ])
    }

    // MARK: - Query

    func fetchAll() throws -> [LongTermFact] {
        let sql = "SELECT * FROM long_term_facts WHERE is_deleted = 0 ORDER BY confidence_score DESC"
        return try db.query(sql).map { try Self.fromRow($0) }
    }

    func fetchByType(_ type: LongTermFact.FactType) throws -> [LongTermFact] {
        let sql = "SELECT * FROM long_term_facts WHERE fact_type = ? AND is_deleted = 0"
        return try db.query(sql, params: [type.rawValue]).map { try Self.fromRow($0) }
    }

    // MARK: - Delete

    func softDelete(_ id: String) throws {
        try db.execute("UPDATE long_term_facts SET is_deleted = 1, updated_at = ? WHERE fact_id = ?",
                       params: [Date().iso8601String, id])
    }

    func deleteAll() throws {
        try db.execute("DELETE FROM long_term_facts")
    }

    // MARK: - Row Mapping

    private static func fromRow(_ row: [String: Any?]) throws -> LongTermFact {
        guard let id = row["fact_id"] as? String,
              let typeStr = row["fact_type"] as? String,
              let text = row["fact_text"] as? String else {
            throw VaultError.executeFailed("Missing required fields in long_term_facts row")
        }

        return LongTermFact(
            id: id,
            factType: LongTermFact.FactType(rawValue: typeStr) ?? .preference,
            factText: text,
            confidenceScore: (row["confidence_score"] as? Double) ?? 0.0,
            sourceMemoryIds: .fromJSON(row["source_memory_ids"] as? String),
            requiresUserConfirmation: true,
            isDeleted: ((row["is_deleted"] as? Int) ?? 0) == 1
        )
    }
}
