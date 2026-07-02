package com.privatepensieve.app.vault

import android.content.ContentValues
import android.database.Cursor
import com.privatepensieve.app.models.Conversation
import java.time.Instant

/**
 * Data access object for conversations table.
 * Raw transcripts + AI replies. All local-only.
 */
class ConversationDao(private val db: VaultDatabase) {

    fun insert(conversation: Conversation) {
        val values = ContentValues().apply {
            put("conversation_id", conversation.conversationId)
            put("created_at", conversation.createdAt.toString())
            put("user_transcript", conversation.userTranscript)
            put("ai_reply", conversation.aiReply)
            put("source_type", conversation.sourceType.name.lowercase())
            put("audio_file_path", conversation.audioFilePath)
            put("is_archived", if (conversation.isArchived) 1 else 0)
            put("is_deleted", if (conversation.isDeleted) 1 else 0)
        }
        db.writableDatabase.insertWithOnConflict(
            "conversations", null, values,
            android.database.sqlite.SQLiteDatabase.CONFLICT_REPLACE
        )
    }

    fun fetchAll(): List<Conversation> {
        val cursor = db.readableDatabase.rawQuery(
            "SELECT * FROM conversations WHERE is_deleted = 0 ORDER BY created_at DESC", null
        )
        return cursor.use { mapCursorToList(it) }
    }

    fun fetchById(id: String): Conversation? {
        val cursor = db.readableDatabase.rawQuery(
            "SELECT * FROM conversations WHERE conversation_id = ?", arrayOf(id)
        )
        return cursor.use { if (it.moveToFirst()) mapCursorToConversation(it) else null }
    }

    fun fetchRecent(limit: Int = 10): List<Conversation> {
        val cursor = db.readableDatabase.rawQuery(
            "SELECT * FROM conversations WHERE is_deleted = 0 ORDER BY created_at DESC LIMIT ?",
            arrayOf(limit.toString())
        )
        return cursor.use { mapCursorToList(it) }
    }

    fun softDelete(id: String) {
        db.writableDatabase.execSQL(
            "UPDATE conversations SET is_deleted = 1 WHERE conversation_id = ?", arrayOf(id)
        )
    }

    fun deleteAll() {
        db.writableDatabase.execSQL("DELETE FROM conversations")
    }

    fun activeCount(): Int {
        val cursor = db.readableDatabase.rawQuery(
            "SELECT COUNT(*) FROM conversations WHERE is_deleted = 0", null
        )
        return cursor.use { if (it.moveToFirst()) it.getInt(0) else 0 }
    }

    private fun mapCursorToList(cursor: Cursor): List<Conversation> {
        val list = mutableListOf<Conversation>()
        while (cursor.moveToNext()) { list.add(mapCursorToConversation(cursor)) }
        return list
    }

    private fun mapCursorToConversation(c: Cursor): Conversation {
        val sourceStr = c.getString(c.getColumnIndexOrThrow("source_type"))
        return Conversation(
            conversationId = c.getString(c.getColumnIndexOrThrow("conversation_id")),
            createdAt = Instant.parse(c.getString(c.getColumnIndexOrThrow("created_at"))),
            sourceType = try { Conversation.SourceType.valueOf(sourceStr.uppercase()) }
                catch (_: Exception) { Conversation.SourceType.VOICE },
            userTranscript = c.getString(c.getColumnIndexOrThrow("user_transcript")),
            aiReply = c.getString(c.getColumnIndexOrThrow("ai_reply")),
            audioFilePath = c.getString(c.getColumnIndexOrThrow("audio_file_path")),
            isArchived = c.getInt(c.getColumnIndexOrThrow("is_archived")) == 1,
            isDeleted = c.getInt(c.getColumnIndexOrThrow("is_deleted")) == 1
        )
    }
}
