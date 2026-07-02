# Product Requirements Document

## Product
**Private Pensieve AI** is a voice-first, local-only AI memory companion. A user talks naturally. The app transcribes on device, creates compact private memories, and later retrieves those memories with a warm, non-judgmental response.

## Core user promise
> Speak freely. Save privately. Recall clearly.

## Primary user jobs
1. Speak through a thought without needing to type.
2. Save meaningful moments, feelings, decisions, goals, and ideas privately.
3. Ask about the past: “What did I say about my career?”
4. Retrieve personal memories without cloud dependence.
5. Export a user-owned encrypted vault when changing devices.

## V1 must-have features
- Local vault creation with app passcode and optional biometric unlock
- Voice-first Talk screen with manual start/stop recording
- On-device transcription through platform/provider abstraction
- Transcript review/edit before saving
- AI friend reply through on-device model/provider abstraction
- Structured memory-card extraction
- Hybrid local recall: date, tag, keyword/full-text, importance, recency
- Memory-grounded replies only
- Synthetic local/system TTS voice reply
- Memory vault and simple timeline
- Encrypted manual export/import
- Privacy dashboard and delete-all controls
- Airplane-mode functional test

## V1 non-goals
- Voice cloning
- Cloud sync
- Login/account system
- Remote model/API fallback
- Social sharing/community
- Therapy, medical diagnosis, crisis counseling, or medical claims
- Ads, subscriptions, or telemetry
- Wearables, desktop client, browser app
- Full graph ranking or vector DB as hard dependency

## Success criteria for alpha
- A new user can create a vault and speak a memory in under 60 seconds.
- User can retrieve a saved memory using date/topic/keywords.
- App says “I don’t remember you telling me that yet.” when evidence is absent.
- No app-generated network request is required for normal V1 behavior.
- User can export, import, and delete a local vault.

## Core user flow
1. Open app.
2. Create local vault; set passcode/biometric protection.
3. Press and hold/tap microphone; speak.
4. Review transcription.
5. App gives a short friend-like reply and saves structured memories locally.
6. User asks a recall question.
7. App retrieves compact evidence and responds only from that evidence.
