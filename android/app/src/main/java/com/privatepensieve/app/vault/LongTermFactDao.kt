package com.privatepensieve.app.vault

import android.content.ContentValues
import android.database.Cursor
import com.privatepensieve.app.models.LongTermFact
import java.time.Instant

/**
 * Data access object for long_term_facts table.
 * Stable truths extracted from repeated memory patterns.
 */
class LongTermFactDao(private val db: VaultDatabase) {

    fun insert(fact: LongTermFact) {
        val now = VaultTypeConverters.nowISO()
        val values = ContentValues().apply {
            put("fact_id", fact.factId)
            put("fact_type", fact.factType.name.lowercase())
            put("fact_text", fact.factText)
            put("confidence_score", fact.confidenceScore)
            put("source_memory_ids", VaultTypeConverters.toJsonString(fact.sourceMemoryIds))
            put("created_at", now)
            put("updated_at", now)
            put("is_deleted", if (fact.isDeleted) 1 else 0)
        }
        db.writableDatabase.insertWithOnConflict(
            "long_term_facts", null, values,
            android.database.sqlite.SQLiteDatabase.CONFLICT_REPLACE
        )
    }

    fun fetchAll(): List<LongTermFact> {
        val cursor = db.readableDatabase.rawQuery(
            "SELECT * FROM long_term_facts WHERE is_deleted = 0 ORDER BY confidence_score DESC", null
        )
        return cursor.use { mapCursorToList(it) }
    }

    fun fetchByType(type: String): List<LongTermFact> {
        val cursor = db.readableDatabase.rawQuery(
            "SELECT * FROM long_term_facts WHERE fact_type = ? AND is_deleted = 0", arrayOf(type)
        )
        return cursor.use { mapCursorToList(it) }
    }

    fun softDelete(id: String) {
        db.writableDatabase.execSQL(
            "UPDATE long_term_facts SET is_deleted = 1, updated_at = ? WHERE fact_id = ?",
            arrayOf(VaultTypeConverters.nowISO(), id)
        )
    }

    fun deleteAll() {
        db.writableDatabase.execSQL("DELETE FROM long_term_facts")
    }

    private fun mapCursorToList(cursor: Cursor): List<LongTermFact> {
        val list = mutableListOf<LongTermFact>()
        while (cursor.moveToNext()) { list.add(mapCursorToFact(cursor)) }
        return list
    }

    private fun mapCursorToFact(c: Cursor): LongTermFact {
        val typeStr = c.getString(c.getColumnIndexOrThrow("fact_type"))
        return LongTermFact(
            factId = c.getString(c.getColumnIndexOrThrow("fact_id")),
            factType = try { LongTermFact.FactType.valueOf(typeStr.uppercase()) }
                catch (_: Exception) { LongTermFact.FactType.PREFERENCE },
            factText = c.getString(c.getColumnIndexOrThrow("fact_text")),
            confidenceScore = c.getDouble(c.getColumnIndexOrThrow("confidence_score")),
            sourceMemoryIds = VaultTypeConverters.fromJsonString(
                c.getString(c.getColumnIndexOrThrow("source_memory_ids"))
            ),
            isDeleted = c.getInt(c.getColumnIndexOrThrow("is_deleted")) == 1
        )
    }
}
