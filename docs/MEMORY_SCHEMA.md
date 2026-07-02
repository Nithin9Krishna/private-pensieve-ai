# Memory Schema

## Canonical entities

### Conversation
```json
{
  "conversation_id": "uuid",
  "created_at": "2026-07-01T00:00:00Z",
  "source_type": "voice|text|imported",
  "user_transcript": "string",
  "ai_reply": "string|null",
  "audio_retained": false,
  "audio_file_path": "string|null",
  "is_archived": false,
  "is_deleted": false
}
```

### MemoryCard
```json
{
  "memory_id": "uuid",
  "created_at": "2026-07-01T00:00:00Z",
  "updated_at": "2026-07-01T00:00:00Z",
  "source_conversation_id": "uuid",
  "title": "string",
  "summary": "string",
  "emotion_tags": ["string"],
  "topic_tags": ["string"],
  "people_tags": ["string"],
  "place_tags": ["string"],
  "goal_tags": ["string"],
  "importance_score": 1,
  "confidence_score": 0.0,
  "duplicate_group_id": "uuid|null",
  "is_favorite": false,
  "is_sensitive": false,
  "is_archived": false,
  "is_deleted": false
}
```

### DailySummary
```json
{
  "date": "2026-07-01",
  "summary": "string",
  "top_emotions": ["string"],
  "top_topics": ["string"],
  "important_memory_ids": ["uuid"],
  "updated_at": "2026-07-01T00:00:00Z"
}
```

### LongTermFact
```json
{
  "fact_id": "uuid",
  "fact_type": "preference|goal|relationship_context|recurring_theme",
  "fact_text": "string",
  "confidence_score": 0.0,
  "source_memory_ids": ["uuid"],
  "requires_user_confirmation": true,
  "is_deleted": false
}
```

### MemoryEdge (future-compatible)
```json
{
  "edge_id": "uuid",
  "from_memory_id": "uuid",
  "to_memory_id": "uuid",
  "edge_type": "same_topic|same_person|same_goal|emotional_pattern|temporal_followup",
  "weight": 0.0
}
```

## Storage rules
- `raw_transcript` remains in Conversation, not duplicated in MemoryCard.
- MemoryCard is the primary recall unit.
- DailySummary is a compact aggregation unit.
- LongTermFact must be based on repeated evidence or require explicit user confirmation.
- MemoryEdge is optional in V1 and must not block launch.
