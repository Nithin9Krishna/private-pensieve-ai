package com.privatepensieve.app.vault

import android.content.ContentValues
import android.database.Cursor

/**
 * Data access object for daily_summaries table.
 * One compact summary per day aggregating that day's memories.
 */
class DailySummaryDao(private val db: VaultDatabase) {

    fun upsert(entity: DailySummaryEntity) {
        val values = ContentValues().apply {
            put("date", entity.date)
            put("summary", entity.summary)
            put("top_emotions", entity.topEmotions)
            put("top_topics", entity.topTopics)
            put("important_memory_ids", entity.importantMemoryIds)
            put("created_at", entity.createdAt)
            put("updated_at", entity.updatedAt)
        }
        db.writableDatabase.insertWithOnConflict(
            "daily_summaries", null, values,
            android.database.sqlite.SQLiteDatabase.CONFLICT_REPLACE
        )
    }

    fun fetchByDate(date: String): DailySummaryEntity? {
        val cursor = db.readableDatabase.rawQuery(
            "SELECT * FROM daily_summaries WHERE date = ?", arrayOf(date)
        )
        return cursor.use { if (it.moveToFirst()) mapCursorToEntity(it) else null }
    }

    fun fetchRecent(limit: Int = 7): List<DailySummaryEntity> {
        val cursor = db.readableDatabase.rawQuery(
            "SELECT * FROM daily_summaries ORDER BY date DESC LIMIT ?",
            arrayOf(limit.toString())
        )
        return cursor.use { mapCursorToList(it) }
    }

    fun deleteAll() {
        db.writableDatabase.execSQL("DELETE FROM daily_summaries")
    }

    private fun mapCursorToList(cursor: Cursor): List<DailySummaryEntity> {
        val list = mutableListOf<DailySummaryEntity>()
        while (cursor.moveToNext()) { list.add(mapCursorToEntity(cursor)) }
        return list
    }

    private fun mapCursorToEntity(c: Cursor): DailySummaryEntity {
        return DailySummaryEntity(
            date = c.getString(c.getColumnIndexOrThrow("date")),
            summary = c.getString(c.getColumnIndexOrThrow("summary")),
            topEmotions = c.getString(c.getColumnIndexOrThrow("top_emotions")) ?: "[]",
            topTopics = c.getString(c.getColumnIndexOrThrow("top_topics")) ?: "[]",
            importantMemoryIds = c.getString(c.getColumnIndexOrThrow("important_memory_ids")) ?: "[]",
            createdAt = c.getString(c.getColumnIndexOrThrow("created_at")),
            updatedAt = c.getString(c.getColumnIndexOrThrow("updated_at"))
        )
    }
}
