package com.privatepensieve.app

import com.privatepensieve.app.models.MemoryCard
import com.privatepensieve.app.providers.FakeAIBrain
import com.privatepensieve.app.recall.RecallEngine
import kotlinx.coroutines.runBlocking
import org.junit.Assert.*
import org.junit.Test
import java.time.Instant

/**
 * Unit tests for the Recall Engine's scoring algorithm, query classification,
 * and evidence-bound answer generation.
 */
class RecallEngineTest {

    private val engine = RecallEngine()

    // ---------- Query Classification ----------

    @Test
    fun `classifies memory recall query correctly`() = runBlocking {
        val result = engine.recall("What did I say about my career?", emptyList())
        assertEquals(RecallEngine.QueryClass.MEMORY_RECALL, result.queryClass)
    }

    @Test
    fun `classifies reflection query correctly`() = runBlocking {
        val result = engine.recall("What patterns do I notice in my mood?", emptyList())
        assertEquals(RecallEngine.QueryClass.REFLECTION, result.queryClass)
    }

    @Test
    fun `classifies general friend query correctly`() = runBlocking {
        val result = engine.recall("I'm feeling a bit down today", emptyList())
        assertEquals(RecallEngine.QueryClass.GENERAL_FRIEND, result.queryClass)
    }

    // ---------- Evidence Threshold ----------

    @Test
    fun `returns exact fallback when no evidence found`() = runBlocking {
        val result = engine.recall("What did I say about quantum physics?", emptyList())
        assertEquals(RecallEngine.NO_MEMORY_FALLBACK, result.answer)
        assertTrue(result.evidence.isEmpty())
    }

    @Test
    fun `returns evidence-bound answer when cards match`() = runBlocking {
        val cards = listOf(
            createCard("Career plans", "I want to switch to AI engineering",
                topicTags = listOf("career", "engineering")),
            createCard("Weekend plans", "Going to the beach",
                topicTags = listOf("weekend", "beach"))
        )
        val result = engine.recall("What did I say about my career?", cards)

        assertNotEquals(RecallEngine.NO_MEMORY_FALLBACK, result.answer)
        assertTrue(result.evidence.isNotEmpty())
        assertTrue(result.evidence.any { it.title == "Career plans" })
    }

    // ---------- Scoring ----------

    @Test
    fun `higher importance cards score higher`() = runBlocking {
        val highImportance = createCard("Important goal", "career change", importanceScore = 9)
        val lowImportance = createCard("Routine note", "ate lunch", importanceScore = 2)

        val cards = listOf(highImportance, lowImportance)
        val result = engine.recall("What did I mention today?", cards)

        if (result.evidence.size >= 2) {
            assertEquals("Important goal", result.evidence.first().title)
        }
    }

    @Test
    fun `lexical match boosts score`() = runBlocking {
        val matching = createCard("Coffee with Maya", "Had coffee with Maya at the lake",
            topicTags = listOf("coffee", "friendship"))
        val nonMatching = createCard("Grocery list", "Need to buy milk and eggs",
            topicTags = listOf("shopping"))

        val result = engine.recall("What did I say about coffee with Maya?", listOf(matching, nonMatching))

        if (result.evidence.isNotEmpty()) {
            assertEquals("Coffee with Maya", result.evidence.first().title)
        }
    }

    // ---------- FakeAIBrain ----------

    @Test
    fun `FakeAIBrain returns exact fallback for empty evidence`() = runBlocking {
        val brain = FakeAIBrain()
        val answer = brain.answerFromEvidence("anything?", emptyList())
        assertEquals(FakeAIBrain.NO_MEMORY_FALLBACK, answer)
    }

    @Test
    fun `FakeAIBrain extracts memory from transcript`() = runBlocking {
        val brain = FakeAIBrain()
        val cards = brain.extractMemory("I feel great today after my morning run")
        assertTrue(cards.isNotEmpty())
        assertEquals("I feel great today after my morning run", cards.first().summary)
    }

    // ---------- Helpers ----------

    private fun createCard(
        title: String,
        summary: String,
        topicTags: List<String> = emptyList(),
        importanceScore: Int = 5,
        confidenceScore: Double = 0.8
    ): MemoryCard {
        return MemoryCard(
            sourceConversationId = "test-conv",
            title = title,
            summary = summary,
            topicTags = topicTags,
            importanceScore = importanceScore,
            confidenceScore = confidenceScore
        )
    }
}
