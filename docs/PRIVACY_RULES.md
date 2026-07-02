# Privacy Rules

## Product privacy claims
- No account required.
- No backend is required for normal use.
- No journal content, transcript, memory record, audio, embedding, or vault backup is uploaded by the app.
- App works offline after initial install/model availability.

## Allowed device permissions
- Microphone: required for voice mode, requested just-in-time.
- Notifications: optional and OFF by default.
- Biometric: optional, protects app vault.
- Files: only for user-initiated backup import/export.

## Forbidden dependencies
- Analytics SDKs
- Crash reporting that uploads user payloads
- Advertising SDKs
- Cloud DB SDKs
- Login SDKs
- Remote LLM SDKs
- Remote speech-to-text SDKs

## Data retention
- Raw audio: OFF by default; if enabled, user can delete all audio separately.
- Raw transcript: retained locally until user deletes it.
- Memory cards: retained locally until user deletes them.
- Backup: user-owned file only.

## Safety language
The app is not a therapist, clinician, or emergency service. It should not claim diagnosis, treatment, or crisis intervention capability.
