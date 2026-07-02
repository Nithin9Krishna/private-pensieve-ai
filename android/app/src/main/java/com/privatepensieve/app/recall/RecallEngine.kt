package com.privatepensieve.app.recall

import com.privatepensieve.app.models.MemoryCard
import com.privatepensieve.app.providers.FakeAIBrain
import java.time.Duration
import java.time.Instant
import kotlin.math.exp
import kotlin.math.max

/**
 * Recall Engine — answers personal memory questions using evidence-bound retrieval.
 * Implements weighted scoring from docs/RECALL_PIPELINE.md.
 * No hallucination. No cloud. Local evidence only.
 */
class RecallEngine {

    enum class QueryClass { MEMORY_RECALL, REFLECTION, GENERAL_FRIEND }

    companion object {
        private const val WEIGHT_LEXICAL = 0.35
        private const val WEIGHT_TAG_MATCH = 0.25
        private const val WEIGHT_RECENCY = 0.15
        private const val WEIGHT_IMPORTANCE = 0.15
        private const val WEIGHT_CONFIDENCE = 0.10
        private const val EVIDENCE_THRESHOLD = 0.15
        const val NO_MEMORY_FALLBACK = "I don't remember you telling me that yet."
    }

    private val aiBrain = FakeAIBrain()

    data class RecallResult(
        val answer: String,
        val evidence: List<MemoryCard>,
        val queryClass: QueryClass
    )

    /**
     * Execute a full recall query.
     * For V1, candidates list is passed in from DAO externally.
     */
    suspend fun recall(question: String, candidates: List<MemoryCard>): RecallResult {
        val queryClass = classifyQuery(question)

        if (queryClass == QueryClass.GENERAL_FRIEND) {
            val reply = aiBrain.generateFriendReply(question, emptyList())
            return RecallResult(reply, emptyList(), queryClass)
        }

        val keywords = extractKeywords(question)
        val scored = candidates
            .map { ScoredCard(it, computeScore(it, keywords)) }
            .sortedByDescending { it.score }
            .filter { it.score >= EVIDENCE_THRESHOLD }

        val topEvidence = scored.take(5).map { it.card }

        if (topEvidence.isEmpty()) {
            return RecallResult(NO_MEMORY_FALLBACK, emptyList(), queryClass)
        }

        val answer = aiBrain.answerFromEvidence(question, topEvidence)
        return RecallResult(answer, topEvidence, queryClass)
    }

    private fun classifyQuery(question: String): QueryClass {
        val lower = question.lowercase()
        val recallKeywords = listOf("what did i", "when did i", "did i say", "did i mention",
            "what was", "who was", "where was", "tell me about", "remind me")
        val reflectionKeywords = listOf("pattern", "how often", "usually", "trend", "frequently")

        if (recallKeywords.any { lower.contains(it) }) return QueryClass.MEMORY_RECALL
        if (reflectionKeywords.any { lower.contains(it) }) return QueryClass.REFLECTION
        return QueryClass.GENERAL_FRIEND
    }

    private fun extractKeywords(question: String): List<String> {
        val stopWords = setOf("the", "a", "an", "is", "was", "are", "were", "i", "my", "me",
            "did", "do", "what", "when", "where", "who", "how", "about", "tell", "remind", "say")
        return question.lowercase().replace(Regex("[^a-z0-9 ]"), "")
            .split(" ").filter { it.length > 2 && it !in stopWords }
    }

    private fun computeScore(card: MemoryCard, keywords: List<String>): Double {
        val lexical = lexicalScore(card, keywords)
        val tagMatch = tagMatchScore(card, keywords)
        val recency = recencyScore(card)
        val importance = card.importanceScore / 10.0
        val confidence = card.confidenceScore

        return (WEIGHT_LEXICAL * lexical) + (WEIGHT_TAG_MATCH * tagMatch) +
               (WEIGHT_RECENCY * recency) + (WEIGHT_IMPORTANCE * importance) +
               (WEIGHT_CONFIDENCE * confidence)
    }

    private fun lexicalScore(card: MemoryCard, keywords: List<String>): Double {
        if (keywords.isEmpty()) return 0.0
        val text = "${card.title} ${card.summary}".lowercase()
        val matches = keywords.count { text.contains(it) }
        return matches.toDouble() / keywords.size
    }

    private fun tagMatchScore(card: MemoryCard, keywords: List<String>): Double {
        if (keywords.isEmpty()) return 0.0
        val allTags = (card.emotionTags + card.topicTags + card.peopleTags + card.goalTags)
            .map { it.lowercase() }
        val matches = keywords.count { kw -> allTags.any { it.contains(kw) } }
        return matches.toDouble() / keywords.size
    }

    private fun recencyScore(card: MemoryCard): Double {
        val daysSince = Duration.between(card.createdAt, Instant.now()).toDays().toDouble()
        return max(0.0, exp(-daysSince / 10.0))
    }

    private data class ScoredCard(val card: MemoryCard, val score: Double)
}
