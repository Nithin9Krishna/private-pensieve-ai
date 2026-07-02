# Memory Optimization Strategy

## Product definition of memory optimization
1. Minimize persistent device storage.
2. Minimize RAM and prompt/context use during recall.
3. Minimize battery/latency during retrieval.
4. Preserve recall quality and user control.

## V1 implementation: tiered local memory
### Tier A — Active
Current conversation only. Cleared after save/close.

### Tier B — Recent
Current day and recent memory cards. Fast access.

### Tier C — Long-term
Important memory cards, confirmed facts, daily summaries.

### Tier D — Archive
Older raw transcripts; encrypted and accessed only for explicit detail requests.

## Ingestion optimization
- Transcribe locally.
- Build one compact MemoryCard per coherent thought cluster, not one card per sentence.
- Deduplicate against recent cards using normalized title/topic/person tags and lexical similarity.
- Update daily summary incrementally.
- Promote a LongTermFact only after repeat evidence or explicit confirmation.

## Recall optimization
- Use metadata and lexical search first.
- Retrieve summaries before raw transcripts.
- Limit model context to 3–5 evidence cards.
- Use an evidence-only response instruction.
- Avoid vector search in V1 unless profiling proves keyword/tag retrieval is insufficient.

## Future research track
- Quantized local embeddings/vector index
- Graph edges and associative retrieval
- Context compression inspired by long-context prompt compression work
- KV-cache quantization only if the project later controls a local LLM runtime
- Model-specific performance profiling on supported devices

## Metrics
- p50/p95 recall latency
- Memory-card size distribution
- Vault size per 100 conversations
- Average candidate count before ranking
- Context token/character count supplied to AI
- Recall precision@3 based on fixture tests
- Battery/RAM during 5-minute voice session
