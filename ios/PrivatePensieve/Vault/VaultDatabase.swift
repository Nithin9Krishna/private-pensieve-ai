// VaultDatabase.swift
// Private Pensieve AI — iOS
// SQLite database wrapper — local-only, no cloud, no sync.
// V1: Plain SQLite. V2: SQLCipher encryption layer.

import Foundation
import SQLite3

/// Thread-safe SQLite database wrapper for the Pensieve vault.
/// All data stays on-device. No network. No cloud.
final class VaultDatabase {

    // MARK: - Singleton

    static let shared = VaultDatabase()

    // MARK: - Properties

    private var db: OpaquePointer?
    private let queue = DispatchQueue(label: "com.privatepensieve.vault.db", qos: .userInitiated)
    private let dbPath: String

    // MARK: - Init

    private init() {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let vaultDir = documentsPath.appendingPathComponent("vault", isDirectory: true)

        // Create vault directory if needed
        try? FileManager.default.createDirectory(at: vaultDir, withIntermediateDirectories: true)

        self.dbPath = vaultDir.appendingPathComponent("pensieve.db").path
    }

    // MARK: - Open / Close

    /// Open the database and create tables if they don't exist.
    func open() throws {
        try queue.sync {
            guard db == nil else { return }

            if sqlite3_open(dbPath, &db) != SQLITE_OK {
                let error = String(cString: sqlite3_errmsg(db))
                throw VaultError.openFailed(error)
            }

            // Enable WAL mode for better concurrent read performance
            try execute("PRAGMA journal_mode=WAL")
            // Foreign keys
            try execute("PRAGMA foreign_keys=ON")

            try createTables()
        }
    }

    /// Close the database connection.
    func close() {
        queue.sync {
            if db != nil {
                sqlite3_close(db)
                db = nil
            }
        }
    }

    // MARK: - Schema

    private func createTables() throws {
        let schema = """
        CREATE TABLE IF NOT EXISTS memory_cards (
            memory_id TEXT PRIMARY KEY,
            created_at TEXT NOT NULL,
            updated_at TEXT NOT NULL,
            source_type TEXT NOT NULL DEFAULT 'voice',
            source_conversation_id TEXT,
            title TEXT NOT NULL,
            summary TEXT NOT NULL,
            raw_transcript TEXT,
            emotion_tags TEXT,
            topic_tags TEXT,
            people_tags TEXT,
            place_tags TEXT,
            goal_tags TEXT,
            importance_score INTEGER NOT NULL DEFAULT 5,
            confidence_score REAL NOT NULL DEFAULT 0.8,
            is_favorite INTEGER DEFAULT 0,
            is_sensitive INTEGER DEFAULT 0,
            is_archived INTEGER DEFAULT 0,
            is_deleted INTEGER DEFAULT 0
        );

        CREATE TABLE IF NOT EXISTS conversations (
            conversation_id TEXT PRIMARY KEY,
            created_at TEXT NOT NULL,
            user_transcript TEXT NOT NULL,
            ai_reply TEXT,
            source_type TEXT NOT NULL DEFAULT 'voice',
            audio_file_path TEXT,
            is_archived INTEGER DEFAULT 0,
            is_deleted INTEGER DEFAULT 0
        );

        CREATE TABLE IF NOT EXISTS daily_summaries (
            date TEXT PRIMARY KEY,
            summary TEXT NOT NULL,
            top_emotions TEXT,
            top_topics TEXT,
            important_memory_ids TEXT,
            created_at TEXT NOT NULL,
            updated_at TEXT NOT NULL
        );

        CREATE TABLE IF NOT EXISTS long_term_facts (
            fact_id TEXT PRIMARY KEY,
            fact_type TEXT NOT NULL,
            fact_text TEXT NOT NULL,
            confidence_score REAL NOT NULL DEFAULT 0.0,
            source_memory_ids TEXT,
            created_at TEXT NOT NULL,
            updated_at TEXT NOT NULL,
            is_deleted INTEGER DEFAULT 0
        );

        CREATE TABLE IF NOT EXISTS memory_edges (
            edge_id TEXT PRIMARY KEY,
            from_id TEXT NOT NULL,
            to_id TEXT NOT NULL,
            edge_type TEXT NOT NULL,
            weight REAL NOT NULL DEFAULT 0.0,
            created_at TEXT NOT NULL
        );

        CREATE INDEX IF NOT EXISTS idx_memory_created_at ON memory_cards(created_at);
        CREATE INDEX IF NOT EXISTS idx_memory_importance ON memory_cards(importance_score);
        CREATE INDEX IF NOT EXISTS idx_memory_deleted ON memory_cards(is_deleted);
        CREATE INDEX IF NOT EXISTS idx_memory_favorite ON memory_cards(is_favorite);
        CREATE INDEX IF NOT EXISTS idx_conversation_created_at ON conversations(created_at);
        CREATE INDEX IF NOT EXISTS idx_daily_date ON daily_summaries(date);
        CREATE INDEX IF NOT EXISTS idx_fact_type ON long_term_facts(fact_type);
        """

        for statement in schema.components(separatedBy: ";") where !statement.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            try execute(statement)
        }
    }

    // MARK: - Execute Helpers

    /// Execute a non-query SQL statement (CREATE, INSERT, UPDATE, DELETE).
    func execute(_ sql: String, params: [Any?] = []) throws {
        try queue.sync {
            var stmt: OpaquePointer?
            guard sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK else {
                let error = String(cString: sqlite3_errmsg(db))
                throw VaultError.prepareFailed(error)
            }
            defer { sqlite3_finalize(stmt) }

            try bindParams(stmt: stmt, params: params)

            let result = sqlite3_step(stmt)
            guard result == SQLITE_DONE || result == SQLITE_ROW else {
                let error = String(cString: sqlite3_errmsg(db))
                throw VaultError.executeFailed(error)
            }
        }
    }

    /// Execute a query and return rows as dictionaries.
    func query(_ sql: String, params: [Any?] = []) throws -> [[String: Any?]] {
        return try queue.sync {
            var stmt: OpaquePointer?
            guard sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK else {
                let error = String(cString: sqlite3_errmsg(db))
                throw VaultError.prepareFailed(error)
            }
            defer { sqlite3_finalize(stmt) }

            try bindParams(stmt: stmt, params: params)

            var rows: [[String: Any?]] = []
            let columnCount = sqlite3_column_count(stmt)

            while sqlite3_step(stmt) == SQLITE_ROW {
                var row: [String: Any?] = [:]
                for i in 0..<columnCount {
                    let name = String(cString: sqlite3_column_name(stmt, i))
                    switch sqlite3_column_type(stmt, i) {
                    case SQLITE_TEXT:
                        row[name] = String(cString: sqlite3_column_text(stmt, i))
                    case SQLITE_INTEGER:
                        row[name] = Int(sqlite3_column_int64(stmt, i))
                    case SQLITE_FLOAT:
                        row[name] = sqlite3_column_double(stmt, i)
                    case SQLITE_NULL:
                        row[name] = nil
                    default:
                        row[name] = nil
                    }
                }
                rows.append(row)
            }
            return rows
        }
    }

    // MARK: - Param Binding

    private func bindParams(stmt: OpaquePointer?, params: [Any?]) throws {
        for (index, param) in params.enumerated() {
            let i = Int32(index + 1)
            switch param {
            case let value as String:
                sqlite3_bind_text(stmt, i, (value as NSString).utf8String, -1, nil)
            case let value as Int:
                sqlite3_bind_int64(stmt, i, Int64(value))
            case let value as Double:
                sqlite3_bind_double(stmt, i, value)
            case let value as Bool:
                sqlite3_bind_int(stmt, i, value ? 1 : 0)
            case nil:
                sqlite3_bind_null(stmt, i)
            default:
                sqlite3_bind_text(stmt, i, "\(param!)" as NSString as? UnsafePointer<CChar>, -1, nil)
            }
        }
    }

    // MARK: - Utility

    /// Delete the database file. Used by "Delete all memories" in Privacy screen.
    func deleteAll() throws {
        close()
        try? FileManager.default.removeItem(atPath: dbPath)
        try open()
    }

    /// Get the database file size in bytes.
    var databaseSizeBytes: Int64 {
        let attrs = try? FileManager.default.attributesOfItem(atPath: dbPath)
        return (attrs?[.size] as? Int64) ?? 0
    }
}

// MARK: - Errors

enum VaultError: LocalizedError {
    case openFailed(String)
    case prepareFailed(String)
    case executeFailed(String)

    var errorDescription: String? {
        switch self {
        case .openFailed(let msg): return "Vault open failed: \(msg)"
        case .prepareFailed(let msg): return "SQL prepare failed: \(msg)"
        case .executeFailed(let msg): return "SQL execute failed: \(msg)"
        }
    }
}

// MARK: - ISO8601 Date Helpers

extension Date {
    var iso8601String: String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter.string(from: self)
    }

    static func fromISO8601(_ string: String) -> Date? {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter.date(from: string) ?? {
            // Fallback without fractional seconds
            formatter.formatOptions = [.withInternetDateTime]
            return formatter.date(from: string)
        }()
    }
}

// MARK: - JSON Array Helpers (for tag columns)

extension Array where Element == String {
    /// Serialize string array to JSON for storage in SQLite TEXT column
    var jsonString: String {
        guard let data = try? JSONEncoder().encode(self),
              let str = String(data: data, encoding: .utf8) else { return "[]" }
        return str
    }

    /// Deserialize JSON string from SQLite TEXT column to string array
    static func fromJSON(_ string: String?) -> [String] {
        guard let string = string,
              let data = string.data(using: .utf8),
              let arr = try? JSONDecoder().decode([String].self, from: data) else { return [] }
        return arr
    }
}
