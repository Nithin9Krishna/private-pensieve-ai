package com.privatepensieve.app

import com.privatepensieve.app.vault.VaultTypeConverters
import org.junit.Assert.*
import org.junit.Test

/**
 * Unit tests for VaultTypeConverters — JSON serialization of tag lists.
 */
class VaultTypeConvertersTest {

    @Test
    fun `converts list to JSON and back`() {
        val original = listOf("happy", "calm", "hopeful")
        val json = VaultTypeConverters.toJsonString(original)
        val restored = VaultTypeConverters.fromJsonString(json)
        assertEquals(original, restored)
    }

    @Test
    fun `handles empty list`() {
        val json = VaultTypeConverters.toJsonString(emptyList())
        val restored = VaultTypeConverters.fromJsonString(json)
        assertTrue(restored.isEmpty())
    }

    @Test
    fun `handles null or invalid JSON gracefully`() {
        val restored = VaultTypeConverters.fromJsonString(null)
        assertTrue(restored.isEmpty())
    }

    @Test
    fun `nowISO returns valid ISO-8601 string`() {
        val iso = VaultTypeConverters.nowISO()
        assertTrue(iso.contains("T"))
        assertTrue(iso.length > 10)
    }
}
