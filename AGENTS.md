# Private Pensieve AI — Agent Operating Contract

## Mission
Build a free, offline, local-only AI memory companion. It listens to a user, stores compact personal memory records in an encrypted on-device vault, and retrieves only relevant memories when the user asks.

## Non-negotiable product constraints
1. No user account, login, or identity service.
2. No backend, cloud database, cloud backup, remote inference, analytics, ads, telemetry, or behavioral tracking.
3. No personal content may leave the device.
4. V1 must function in airplane mode after installation and device AI setup.
5. Do not call internet search, web APIs, or third-party AI APIs from the app.
6. The AI must never invent a personal memory. If relevant local evidence is absent, reply: `I don’t remember you telling me that yet.`
7. Keep user control visible: delete, export, import, audio retention, and privacy status.
8. V1 excludes voice cloning, social features, subscriptions, cloud sync, wearable integration, and web clients.

## Repository reading order
Before editing code, read:
- `README.md`
- `docs/PRD.md`
- `docs/ARCHITECTURE.md`
- `docs/PRIVACY_RULES.md`
- `docs/MEMORY_SCHEMA.md`
- `docs/RECALL_PIPELINE.md`
- `docs/AGENT_TASKS.md`

## Native-first architecture
- iOS: Swift + SwiftUI only. Use native system frameworks and project-local code.
- Android: Kotlin + Jetpack Compose only. Use native Android frameworks and project-local code.
- Do not introduce Flutter, React Native, a shared JavaScript runtime, or a server layer.
- Maintain semantic schema compatibility between the two native apps. Do not force code sharing across platforms.

## Data rules
- Persist only the minimum data needed for user-selected features.
- Audio recording retention defaults to OFF after transcription; retain audio only when the user explicitly enables it.
- Store raw transcript, structured memory cards, summaries, and stable facts in separate tables.
- Use deterministic IDs and ISO-8601 UTC timestamps.
- Do not infer sensitive traits, diagnoses, sexuality, religion, politics, race, or medical status unless the user explicitly states them; even then, do not promote them into long-term facts automatically.

## Security rules
- Vault database must be encrypted at rest.
- Database/backup key material must be protected using Keychain on iOS and Android Keystore on Android.
- Backup export must use authenticated encryption and a password-derived key; document exact cryptographic choices in `docs/SECURITY_DESIGN.md`.
- Never log transcripts, memory cards, encryption keys, or backup content to console in release builds.

## Agent workflow
- Work on a dedicated feature branch or worktree.
- Keep commits small and module-specific.
- Never push directly to `main` or `dev`.
- Open a PR into `dev` only.
- Update `docs/agent_logs/<agent-name>.md` with files changed, tests run, decisions made, and open risks.
- If a requirement is unclear, add a `BLOCKED` note in the agent log and choose the safest local-only default. Do not add cloud services to unblock yourself.

## Coding quality rules
- Prefer small interfaces and dependency injection.
- All business logic must be testable without UI.
- Use immutable domain models where practical.
- Avoid premature vector databases. V1 retrieval is hybrid: metadata + full-text + ranking.
- Every new dependency must include a license check and privacy justification in the PR.

## Definition of done
- Compiles
- Unit/integration tests pass where applicable
- No unauthorized network capability introduced
- Privacy impact documented
- Offline behavior documented
- Agent log updated
