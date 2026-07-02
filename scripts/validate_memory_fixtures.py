#!/usr/bin/env python3
"""Validate memory card test fixtures against the V1 schema.

Ensures all required fields are present in expected_memory_cards.json
and that all JSON fixtures parse without errors.
"""
import json, pathlib, sys

required = {
    "memory_id", "created_at", "updated_at", "source_type",
    "source_conversation_id", "title", "summary", "raw_transcript",
    "emotion_tags", "topic_tags", "people_tags", "place_tags",
    "goal_tags", "importance_score", "confidence_score",
    "is_favorite", "is_archived", "is_deleted"
}

root = pathlib.Path(__file__).resolve().parents[1]

# Validate all fixture files parse
for rel in ["test_data/sample_transcripts.json", "test_data/expected_memory_cards.json", "test_data/recall_test_cases.json"]:
    path = root / rel
    if path.exists():
        json.loads(path.read_text())
        print(f"  ✓ {rel} — valid JSON")
    else:
        print(f"  ⚠ {rel} — not found (skipped)")

# Validate memory card fields
cards_path = root / "test_data/expected_memory_cards.json"
if cards_path.exists():
    cards = json.loads(cards_path.read_text())
    missing = [sorted(required - set(card)) for card in cards]
    if any(m for m in missing if m):
        print(f"✗ Missing required fields: {missing}", file=sys.stderr)
        sys.exit(1)
    print(f"✓ Validated {len(cards)} V1 memory card fixture(s).")
else:
    print("⚠ test_data/expected_memory_cards.json not found — create it to validate")
