# Recall Pipeline

## Goal
Answer personal-memory questions accurately while minimizing storage reads, prompt size, latency, and hallucinated memory claims.

## Query classes
- `MEMORY_RECALL`: user asks what they said, felt, did, wanted, promised, or discussed.
- `REFLECTION`: user asks for patterns based on known memories.
- `GENERAL_FRIEND`: user wants conversation/support without factual memory assertion.

## Retrieval stages
1. Extract query signals: time range, topic, people, emotions, goal, lexical keywords.
2. Metadata prefilter: date range, deleted/archived status, explicit tag matches.
3. Full-text/keyword search against title + summary, not raw transcript by default.
4. Ranking:
   - lexical relevance: 0.35
   - tag/entity match: 0.25
   - recency: 0.15
   - importance: 0.15
   - confidence: 0.10
5. Fetch top 3–5 MemoryCards and at most 1 DailySummary.
6. Context compressor formats compact evidence: date, title, summary, tags.
7. Local AI produces answer with evidence-bound instruction.
8. If no evidence passes threshold: exact fallback text, `I don’t remember you telling me that yet.`

## V1 exclusions
- No mandatory embedding model/vector DB.
- No loading of all raw transcripts.
- No external search.

## Future retrieval enhancements
- SQLite FTS5
- Optional local embedding model
- Quantized vector index
- Memory graph ranking
- Context/KV-cache optimization when self-hosted local runtime is used
