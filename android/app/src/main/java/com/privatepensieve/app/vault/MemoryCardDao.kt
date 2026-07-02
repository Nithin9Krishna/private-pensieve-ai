package com.privatepensieve.app.vault

import android.content.ContentValues
import android.database.Cursor
import com.privatepensieve.app.models.MemoryCard
import java.time.Instant
import java.util.UUID

/**
 * Data access object for memory_cards table.
 * All operations local-only. No network.
 */
class MemoryCardDao(private val db: VaultDatabase) {

    // MARK: - Insert

    fun insert(card: MemoryCard) {
        val values = ContentValues().apply {
            put("memory_id", card.memoryId)
            put("created_at", card.createdAt.toString())
            put("updated_at", card.updatedAt.toString())
            put("source_type", "voice")
            put("source_conversation_id", card.sourceConversationId)
            put("title", card.title)
            put("summary", card.summary)
            put("emotion_tags", VaultTypeConverters.toJsonString(card.emotionTags))
            put("topic_tags", VaultTypeConverters.toJsonString(card.topicTags))
            put("people_tags", VaultTypeConverters.toJsonString(card.peopleTags))
            put("place_tags", VaultTypeConverters.toJsonString(card.placeTags))
            put("goal_tags", VaultTypeConverters.toJsonString(card.goalTags))
            put("importance_score", card.importanceScore)
            put("confidence_score", card.confidenceScore)
            put("is_favorite", if (card.isFavorite) 1 else 0)
            put("is_sensitive", if (card.isSensitive) 1 else 0)
            put("is_archived", if (card.isArchived) 1 else 0)
            put("is_deleted", if (card.isDeleted) 1 else 0)
        }
        db.writableDatabase.insertWithOnConflict(
            "memory_cards", null, values,
            android.database.sqlite.SQLiteDatabase.CONFLICT_REPLACE
        )
    }

    // MARK: - Query

    fun fetchAll(): List<MemoryCard> {
        val cursor = db.readableDatabase.rawQuery(
            "SELECT * FROM memory_cards WHERE is_deleted = 0 AND is_archived = 0 ORDER BY created_at DESC",
            null
        )
        return cursor.use { mapCursorToList(it) }
    }

    fun fetchById(id: String): MemoryCard? {
        val cursor = db.readableDatabase.rawQuery(
            "SELECT * FROM memory_cards WHERE memory_id = ?",
            arrayOf(id)
        )
        return cursor.use { if (it.moveToFirst()) mapCursorToCard(it) else null }
    }

    fun fetchFiltered(
        searchText: String? = null,
        tag: String? = null,
        favoritesOnly: Boolean = false,
        minImportance: Int? = null,
        limit: Int? = null
    ): List<MemoryCard> {
        val conditions = mutableListOf("is_deleted = 0", "is_archived = 0")
        val args = mutableListOf<String>()

        if (favoritesOnly) conditions.add("is_favorite = 1")

        minImportance?.let {
            conditions.add("importance_score >= ?")
            args.add(it.toString())
        }

        tag?.let {
            conditions.add("(emotion_tags LIKE ? OR topic_tags LIKE ? OR people_tags LIKE ? OR goal_tags LIKE ?)")
            val wildcard = "%\"$it\"%"
            args.addAll(listOf(wildcard, wildcard, wildcard, wildcard))
        }

        searchText?.let {
            if (it.isNotBlank()) {
                conditions.add("(title LIKE ? OR summary LIKE ?)")
                val wildcard = "%$it%"
                args.addAll(listOf(wildcard, wildcard))
            }
        }

        var sql = "SELECT * FROM memory_cards WHERE ${conditions.joinToString(" AND ")} ORDER BY created_at DESC"
        limit?.let { sql += " LIMIT $it" }

        val cursor = db.readableDatabase.rawQuery(sql, args.toTypedArray())
        return cursor.use { mapCursorToList(it) }
    }

    fun search(query: String, limit: Int = 10): List<MemoryCard> {
        return fetchFiltered(searchText = query, limit = limit)
    }

    // MARK: - Update

    fun toggleFavorite(id: String) {
        db.writableDatabase.execSQL(
            "UPDATE memory_cards SET is_favorite = NOT is_favorite, updated_at = ? WHERE memory_id = ?",
            arrayOf(VaultTypeConverters.nowISO(), id)
        )
    }

    fun updateTags(
        id: String,
        emotionTags: List<String>? = null,
        topicTags: List<String>? = null,
        peopleTags: List<String>? = null,
        goalTags: List<String>? = null
    ) {
        val values = ContentValues().apply {
            put("updated_at", VaultTypeConverters.nowISO())
            emotionTags?.let { put("emotion_tags", VaultTypeConverters.toJsonString(it)) }
            topicTags?.let { put("topic_tags", VaultTypeConverters.toJsonString(it)) }
            peopleTags?.let { put("people_tags", VaultTypeConverters.toJsonString(it)) }
            goalTags?.let { put("goal_tags", VaultTypeConverters.toJsonString(it)) }
        }
        db.writableDatabase.update("memory_cards", values, "memory_id = ?", arrayOf(id))
    }

    // MARK: - Delete

    fun softDelete(id: String) {
        db.writableDatabase.execSQL(
            "UPDATE memory_cards SET is_deleted = 1, updated_at = ? WHERE memory_id = ?",
            arrayOf(VaultTypeConverters.nowISO(), id)
        )
    }

    fun deleteAll() {
        db.writableDatabase.execSQL("DELETE FROM memory_cards")
    }

    // MARK: - Stats

    fun activeCount(): Int {
        val cursor = db.readableDatabase.rawQuery(
            "SELECT COUNT(*) FROM memory_cards WHERE is_deleted = 0", null
        )
        return cursor.use { if (it.moveToFirst()) it.getInt(0) else 0 }
    }

    // MARK: - Cursor Mapping

    private fun mapCursorToList(cursor: Cursor): List<MemoryCard> {
        val list = mutableListOf<MemoryCard>()
        while (cursor.moveToNext()) {
            list.add(mapCursorToCard(cursor))
        }
        return list
    }

    private fun mapCursorToCard(c: Cursor): MemoryCard {
        return MemoryCard(
            memoryId = c.getString(c.getColumnIndexOrThrow("memory_id")),
            createdAt = Instant.parse(c.getString(c.getColumnIndexOrThrow("created_at"))),
            updatedAt = Instant.parse(c.getString(c.getColumnIndexOrThrow("updated_at"))),
            sourceConversationId = c.getString(c.getColumnIndexOrThrow("source_conversation_id")) ?: "",
            title = c.getString(c.getColumnIndexOrThrow("title")),
            summary = c.getString(c.getColumnIndexOrThrow("summary")),
            emotionTags = VaultTypeConverters.fromJsonString(c.getString(c.getColumnIndexOrThrow("emotion_tags"))),
            topicTags = VaultTypeConverters.fromJsonString(c.getString(c.getColumnIndexOrThrow("topic_tags"))),
            peopleTags = VaultTypeConverters.fromJsonString(c.getString(c.getColumnIndexOrThrow("people_tags"))),
            placeTags = VaultTypeConverters.fromJsonString(c.getString(c.getColumnIndexOrThrow("place_tags"))),
            goalTags = VaultTypeConverters.fromJsonString(c.getString(c.getColumnIndexOrThrow("goal_tags"))),
            importanceScore = c.getInt(c.getColumnIndexOrThrow("importance_score")),
            confidenceScore = c.getDouble(c.getColumnIndexOrThrow("confidence_score")),
            isFavorite = c.getInt(c.getColumnIndexOrThrow("is_favorite")) == 1,
            isSensitive = c.getInt(c.getColumnIndexOrThrow("is_sensitive")) == 1,
            isArchived = c.getInt(c.getColumnIndexOrThrow("is_archived")) == 1,
            isDeleted = c.getInt(c.getColumnIndexOrThrow("is_deleted")) == 1
        )
    }
}
