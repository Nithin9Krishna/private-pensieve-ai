// RecallEngine.swift
// Private Pensieve AI — iOS
// Core recall pipeline: query → classify → search → rank → compress → answer
// Implements the weighted scoring formula from docs/RECALL_PIPELINE.md

import Foundation

/// Recall Engine — answers personal memory questions using evidence-bound retrieval.
/// No hallucination. If no evidence passes threshold, returns exact fallback.
final class RecallEngine {

    // MARK: - Query Classification

    enum QueryClass {
        case memoryRecall   // "What did I say about..." — needs factual evidence
        case reflection     // "What patterns do I have..." — needs aggregated evidence
        case generalFriend  // "I'm feeling down" — conversation/support, no assertions
    }

    // MARK: - Scoring Weights (from RECALL_PIPELINE.md)

    private static let weightLexical: Double = 0.35
    private static let weightTagMatch: Double = 0.25
    private static let weightRecency: Double = 0.15
    private static let weightImportance: Double = 0.15
    private static let weightConfidence: Double = 0.10

    /// Minimum score to qualify as evidence.
    private static let evidenceThreshold: Double = 0.15

    // MARK: - Dependencies

    private let memoryCardDAO: MemoryCardDAO
    private let aiBrain: AIBrainProvider

    static let noMemoryFallback = "I don't remember you telling me that yet."

    init(memoryCardDAO: MemoryCardDAO = MemoryCardDAO(), aiBrain: AIBrainProvider = FakeAIBrain()) {
        self.memoryCardDAO = memoryCardDAO
        self.aiBrain = aiBrain
    }

    // MARK: - Recall

    /// Execute a full recall query. Returns (answer, evidence cards used).
    func recall(question: String) async throws -> RecallResult {
        // 1. Classify query
        let queryClass = classifyQuery(question)

        // 2. If general friend, skip evidence retrieval
        if queryClass == .generalFriend {
            let reply = try await aiBrain.generateFriendReply(transcript: question, recentMemories: [])
            return RecallResult(answer: reply, evidence: [], queryClass: queryClass)
        }

        // 3. Extract query signals
        let signals = extractSignals(from: question)

        // 4. Retrieve candidates (metadata prefilter + text search)
        let candidates = try memoryCardDAO.fetch(filter: MemoryFilter(
            searchText: question,
            limit: 20
        ))

        // 5. Score and rank candidates
        let scored = candidates.map { card in
            ScoredCard(card: card, score: computeScore(card: card, signals: signals))
        }
        .sorted { $0.score > $1.score }
        .filter { $0.score >= Self.evidenceThreshold }

        // 6. Top 3-5 evidence cards
        let topEvidence = Array(scored.prefix(5)).map(\.card)

        // 7. If no evidence, return exact fallback
        if topEvidence.isEmpty {
            return RecallResult(answer: Self.noMemoryFallback, evidence: [], queryClass: queryClass)
        }

        // 8. Generate evidence-bound answer
        let answer = try await aiBrain.answerFromEvidence(question: question, evidence: topEvidence)
        return RecallResult(answer: answer, evidence: topEvidence, queryClass: queryClass)
    }

    // MARK: - Query Classification

    private func classifyQuery(_ question: String) -> QueryClass {
        let lower = question.lowercased()

        // Memory recall keywords
        let recallKeywords = ["what did i", "when did i", "did i say", "did i mention",
                              "what was", "who was", "where was", "how did i",
                              "tell me about", "remind me", "what happened"]

        // Reflection keywords
        let reflectionKeywords = ["pattern", "how often", "what do i usually",
                                  "what's my", "trend", "most common", "frequently"]

        for keyword in recallKeywords {
            if lower.contains(keyword) { return .memoryRecall }
        }
        for keyword in reflectionKeywords {
            if lower.contains(keyword) { return .reflection }
        }

        return .generalFriend
    }

    // MARK: - Signal Extraction

    private struct QuerySignals {
        var keywords: [String]
        var normalizedQuery: String
    }

    private func extractSignals(from question: String) -> QuerySignals {
        let normalized = question.lowercased()
            .replacingOccurrences(of: "[^a-z0-9 ]", with: "", options: .regularExpression)

        let stopWords: Set<String> = ["the", "a", "an", "is", "was", "are", "were", "i", "my", "me",
                                       "did", "do", "what", "when", "where", "who", "how", "about",
                                       "tell", "remind", "say", "said", "think"]

        let keywords = normalized.split(separator: " ")
            .map(String.init)
            .filter { !stopWords.contains($0) && $0.count > 2 }

        return QuerySignals(keywords: keywords, normalizedQuery: normalized)
    }

    // MARK: - Scoring

    private func computeScore(card: MemoryCard, signals: QuerySignals) -> Double {
        let lexical = lexicalScore(card: card, keywords: signals.keywords)
        let tagMatch = tagMatchScore(card: card, keywords: signals.keywords)
        let recency = recencyScore(card: card)
        let importance = Double(card.importanceScore) / 10.0
        let confidence = card.confidenceScore

        return (Self.weightLexical * lexical)
             + (Self.weightTagMatch * tagMatch)
             + (Self.weightRecency * recency)
             + (Self.weightImportance * importance)
             + (Self.weightConfidence * confidence)
    }

    private func lexicalScore(card: MemoryCard, keywords: [String]) -> Double {
        guard !keywords.isEmpty else { return 0 }
        let text = (card.title + " " + card.summary).lowercased()
        let matches = keywords.filter { text.contains($0) }.count
        return Double(matches) / Double(keywords.count)
    }

    private func tagMatchScore(card: MemoryCard, keywords: [String]) -> Double {
        guard !keywords.isEmpty else { return 0 }
        let allTags = (card.emotionTags + card.topicTags + card.peopleTags + card.goalTags)
            .map { $0.lowercased() }
        let matches = keywords.filter { kw in allTags.contains { $0.contains(kw) } }.count
        return Double(matches) / Double(keywords.count)
    }

    private func recencyScore(card: MemoryCard) -> Double {
        let daysSince = Date().timeIntervalSince(card.createdAt) / 86400.0
        // Exponential decay: 1.0 for today, ~0.5 after 7 days, ~0.1 after 30 days
        return max(0, exp(-daysSince / 10.0))
    }
}

// MARK: - Supporting Types

struct ScoredCard {
    let card: MemoryCard
    let score: Double
}

struct RecallResult {
    let answer: String
    let evidence: [MemoryCard]
    let queryClass: RecallEngine.QueryClass
}
