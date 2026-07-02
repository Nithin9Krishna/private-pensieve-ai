#!/usr/bin/env python3
"""Mock offline AI brain — deterministic memory extraction and recall.

No remote model calls. No cloud APIs. Works entirely offline.
Exact fallback: "I don't remember you telling me that yet."
"""
import json, re, sys
from datetime import datetime, timezone

MISSING = "I don't remember you telling me that yet."


class MockAiBrain:
    """Deterministic offline AI brain for testing and fallback."""

    def generateFriendReply(self, transcript, recentContext=None):
        if not transcript.strip():
            return "I'm here whenever you want to talk."
        return "I'll remember what matters from that, and keep it on this device."

    def extractMemoryCard(self, transcript):
        now = datetime.now(timezone.utc).isoformat()
        people = re.findall(r"\b[A-Z][a-z]+\b", transcript)
        topics = [
            w
            for w in ["job search", "coffee", "family", "health", "school", "work"]
            if w in transcript.lower()
        ]
        emotions = [
            w
            for w in ["calm", "happy", "sad", "anxious", "excited", "tired"]
            if w in transcript.lower()
        ]
        return {
            "memory_id": "memory-mock-001",
            "created_at": now,
            "updated_at": now,
            "source_type": "voice",
            "source_conversation_id": "conversation-mock-001",
            "title": (transcript[:42] or "Memory").strip(),
            "summary": transcript.strip(),
            "raw_transcript": transcript.strip(),
            "emotion_tags": emotions,
            "topic_tags": topics,
            "people_tags": people[:5],
            "place_tags": [],
            "goal_tags": [t for t in topics if "job" in t],
            "importance_score": 3,
            "confidence_score": 0.7,
            "is_favorite": False,
            "is_archived": False,
            "is_deleted": False,
        }

    def generateRecallAnswer(self, question, retrievedMemories):
        if not retrievedMemories:
            return MISSING
        return "I remember this: " + retrievedMemories[0].get("summary", MISSING)

    def summarizeDay(self, memories):
        if not memories:
            return "No memories saved today."
        return "Today's remembered moments: " + "; ".join(
            m.get("title", "Untitled") for m in memories[:5]
        )


if __name__ == "__main__":
    brain = MockAiBrain()
    transcript = " ".join(sys.argv[1:]) or "I had coffee with Maya and felt calm about my job search."
    print(json.dumps(brain.extractMemoryCard(transcript), indent=2))
