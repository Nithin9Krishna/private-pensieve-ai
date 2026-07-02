#!/usr/bin/env python3
"""Offline recall engine prototype — keyword/tag ranking over local memory cards.

Ranking formula (from docs/RECALL_PIPELINE.md):
  score = keyword_match * 0.30 + tag_match * 0.25 + recency * 0.15 + importance * 0.20 + confidence * 0.10

No network calls. No remote APIs. Runs entirely on local JSON fixtures.
"""
import json, math, pathlib, re, sys

MISSING = "I don't remember you telling me that yet."


def tokens(s):
    """Tokenize a string into lowercase word-fragments."""
    return set(re.findall(r"[a-z0-9]+", s.lower()))


def score(query, card):
    """Score a single memory card against a query using the recall formula."""
    q = tokens(query)
    text = tokens(" ".join(str(card.get(k, "")) for k in ["title", "summary", "raw_transcript"]))
    tags = tokens(
        " ".join(
            " ".join(card.get(k, []))
            for k in ["emotion_tags", "topic_tags", "people_tags", "place_tags", "goal_tags"]
        )
    )
    keyword = len(q & text) / max(len(q), 1)
    tag = len(q & tags) / max(len(q), 1)
    recency = 0.5  # Placeholder — real impl uses date proximity
    importance = min(card.get("importance_score", 1) / 5, 1)
    confidence = card.get("confidence_score", 0)
    return keyword * 0.30 + tag * 0.25 + recency * 0.15 + importance * 0.20 + confidence * 0.10


def recall(query, cards, limit=5):
    """Retrieve top-k memory cards matching a query, excluding deleted ones."""
    visible = [c for c in cards if not c.get("is_deleted")]
    ranked = sorted(((score(query, c), c) for c in visible), reverse=True, key=lambda x: x[0])
    return [c for s, c in ranked[:limit] if s > 0.05]


if __name__ == "__main__":
    root = pathlib.Path(__file__).resolve().parents[1]
    cards = json.loads((root / "test_data/expected_memory_cards.json").read_text())
    query = " ".join(sys.argv[1:]) or "When did I talk to Maya about work?"
    hits = recall(query, cards)
    print(
        json.dumps(
            {
                "answer": MISSING if not hits else hits[0]["summary"],
                "memory_ids": [h["memory_id"] for h in hits],
            },
            indent=2,
        )
    )
