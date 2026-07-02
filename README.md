# Private Pensieve AI — Codex Handoff

A native, offline-first private AI memory companion for iOS and Android.

## Product promise
- No account
- No backend
- No cloud storage
- No analytics or advertising SDKs
- No journal content leaves the device
- Voice-first interaction
- Memory-grounded responses: the AI never claims the user said something unless it is in the local vault

## Target release
An 8-week deployable alpha for TestFlight and Google Play Internal Testing.

## Start here
1. Read `AGENTS.md`.
2. Read all files in `docs/` in this order:
   `PRD.md` → `ARCHITECTURE.md` → `PRIVACY_RULES.md` → `MEMORY_SCHEMA.md` → `RECALL_PIPELINE.md` → `AGENT_TASKS.md`.
3. Complete the `P0` tasks in `docs/AGENT_TASKS.md` in dependency order.
4. Never add cloud, login, analytics, remote inference, or telemetry without a written product decision.

## Monorepo layout
- `ios/` — Swift + SwiftUI native application
- `android/` — Kotlin + Jetpack Compose native application
- `docs/` — product contracts and engineering specs
- `test_data/` — deterministic fixtures for memory and recall tests
- `.github/` — CI and contribution templates

## Definition of done
A feature is complete only when it:
- Builds locally in its native target
- Has tests or a documented reason why tests are not feasible
- Works in airplane mode if it is a V1 feature
- Adds no unauthorized network dependency
- Documents privacy/storage impact in its pull request
