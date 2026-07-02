# LocalAiBrain

Offline-only interface:

- `generateFriendReply(transcript, recentContext)`
- `extractMemoryCard(transcript)`
- `generateRecallAnswer(question, retrievedMemories)`
- `summarizeDay(memories)`

Implementations:
- V1: deterministic `MockAiBrain` for tests and fallback.
- iOS later: Apple Foundation Models wrapper placeholder.
- Android later: Gemini Nano / AICore wrapper placeholder.

Rules:
- Do not search the internet.
- Do not invent memories.
- Return the exact fallback when missing: `I don't remember you telling me that yet.`
