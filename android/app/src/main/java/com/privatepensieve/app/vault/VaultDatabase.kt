package com.privatepensieve.app.vault

import android.content.ContentValues
import android.content.Context
import android.database.Cursor
import android.database.sqlite.SQLiteDatabase
import android.database.sqlite.SQLiteOpenHelper

/**
 * SQLite database helper for the Pensieve vault.
 * All data local-only. No cloud. No sync. No INTERNET permission.
 *
 * V1: Plain SQLite via SQLiteOpenHelper.
 * V2: SQLCipher encrypted database.
 */
class VaultDatabase private constructor(context: Context) :
    SQLiteOpenHelper(context, DATABASE_NAME, null, DATABASE_VERSION) {

    companion object {
        private const val DATABASE_NAME = "pensieve.db"
        private const val DATABASE_VERSION = 1

        @Volatile
        private var instance: VaultDatabase? = null

        fun getInstance(context: Context): VaultDatabase {
            return instance ?: synchronized(this) {
                instance ?: VaultDatabase(context.applicationContext).also { instance = it }
            }
        }
    }

    override fun onCreate(db: SQLiteDatabase) {
        db.execSQL("""
            CREATE TABLE IF NOT EXISTS memory_cards (
                memory_id TEXT PRIMARY KEY,
                created_at TEXT NOT NULL,
                updated_at TEXT NOT NULL,
                source_type TEXT NOT NULL DEFAULT 'voice',
                source_conversation_id TEXT,
                title TEXT NOT NULL,
                summary TEXT NOT NULL,
                raw_transcript TEXT,
                emotion_tags TEXT DEFAULT '[]',
                topic_tags TEXT DEFAULT '[]',
                people_tags TEXT DEFAULT '[]',
                place_tags TEXT DEFAULT '[]',
                goal_tags TEXT DEFAULT '[]',
                importance_score INTEGER NOT NULL DEFAULT 5,
                confidence_score REAL NOT NULL DEFAULT 0.8,
                is_favorite INTEGER DEFAULT 0,
                is_sensitive INTEGER DEFAULT 0,
                is_archived INTEGER DEFAULT 0,
                is_deleted INTEGER DEFAULT 0
            )
        """.trimIndent())

        db.execSQL("""
            CREATE TABLE IF NOT EXISTS conversations (
                conversation_id TEXT PRIMARY KEY,
                created_at TEXT NOT NULL,
                user_transcript TEXT NOT NULL,
                ai_reply TEXT,
                source_type TEXT NOT NULL DEFAULT 'voice',
                audio_file_path TEXT,
                is_archived INTEGER DEFAULT 0,
                is_deleted INTEGER DEFAULT 0
            )
        """.trimIndent())

        db.execSQL("""
            CREATE TABLE IF NOT EXISTS daily_summaries (
                date TEXT PRIMARY KEY,
                summary TEXT NOT NULL,
                top_emotions TEXT DEFAULT '[]',
                top_topics TEXT DEFAULT '[]',
                important_memory_ids TEXT DEFAULT '[]',
                created_at TEXT NOT NULL,
                updated_at TEXT NOT NULL
            )
        """.trimIndent())

        db.execSQL("""
            CREATE TABLE IF NOT EXISTS long_term_facts (
                fact_id TEXT PRIMARY KEY,
                fact_type TEXT NOT NULL,
                fact_text TEXT NOT NULL,
                confidence_score REAL NOT NULL DEFAULT 0.0,
                source_memory_ids TEXT DEFAULT '[]',
                created_at TEXT NOT NULL,
                updated_at TEXT NOT NULL,
                is_deleted INTEGER DEFAULT 0
            )
        """.trimIndent())

        db.execSQL("""
            CREATE TABLE IF NOT EXISTS memory_edges (
                edge_id TEXT PRIMARY KEY,
                from_id TEXT NOT NULL,
                to_id TEXT NOT NULL,
                edge_type TEXT NOT NULL,
                weight REAL NOT NULL DEFAULT 0.0,
                created_at TEXT NOT NULL
            )
        """.trimIndent())

        // Indexes
        db.execSQL("CREATE INDEX IF NOT EXISTS idx_memory_created_at ON memory_cards(created_at)")
        db.execSQL("CREATE INDEX IF NOT EXISTS idx_memory_importance ON memory_cards(importance_score)")
        db.execSQL("CREATE INDEX IF NOT EXISTS idx_memory_deleted ON memory_cards(is_deleted)")
        db.execSQL("CREATE INDEX IF NOT EXISTS idx_memory_favorite ON memory_cards(is_favorite)")
        db.execSQL("CREATE INDEX IF NOT EXISTS idx_conversation_created_at ON conversations(created_at)")
        db.execSQL("CREATE INDEX IF NOT EXISTS idx_daily_date ON daily_summaries(date)")
        db.execSQL("CREATE INDEX IF NOT EXISTS idx_fact_type ON long_term_facts(fact_type)")
    }

    override fun onUpgrade(db: SQLiteDatabase, oldVersion: Int, newVersion: Int) {
        // Future migrations go here. Never drop user data.
    }

    override fun onOpen(db: SQLiteDatabase) {
        super.onOpen(db)
        db.execSQL("PRAGMA journal_mode=WAL")
        db.execSQL("PRAGMA foreign_keys=ON")
    }

    /**
     * Get database size in bytes.
     */
    fun databaseSizeBytes(context: Context): Long {
        val dbFile = context.getDatabasePath(DATABASE_NAME)
        return if (dbFile.exists()) dbFile.length() else 0L
    }

    /**
     * Delete all data (used by Privacy > Delete All Memories).
     */
    fun deleteAllData() {
        writableDatabase.apply {
            execSQL("DELETE FROM memory_cards")
            execSQL("DELETE FROM conversations")
            execSQL("DELETE FROM daily_summaries")
            execSQL("DELETE FROM long_term_facts")
            execSQL("DELETE FROM memory_edges")
        }
    }
}
