# Offline Recall Engine

Ranking formula:

```text
score = keyword_match * 0.30 + tag_match * 0.25 + recency * 0.15 + importance * 0.20 + confidence * 0.10
```

V1 excludes `is_deleted = true`, retrieves top 3–5 memories, and never loads full transcript history unless a selected memory needs source context.
