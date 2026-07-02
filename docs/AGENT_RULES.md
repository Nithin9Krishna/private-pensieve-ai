# Agent Rules

You are building Private Pensieve AI.

Hard rules:
1. Native only.
2. iOS uses Swift + SwiftUI.
3. Android uses Kotlin + Jetpack Compose.
4. No backend.
5. No login.
6. No cloud database.
7. No analytics.
8. No tracking SDK.
9. No user memory should leave the device.
10. All personal memory must be stored locally.
11. App must work in airplane mode.
12. Do not add network permissions unless explicitly approved.
13. Follow docs/MEMORY_SCHEMA.md exactly.
14. Follow docs/PRIVACY_RULES.md exactly.
15. Add tests where possible.
16. Update your agent log before finishing.
17. Open PR into dev, not main.

## Branching
Every agent works on its assigned `feature/*` branch. No direct pushes to `main` or `dev`.

## Task backlog

All agents must follow the task format and assigned backlog in `docs/AGENT_TASKS.md`.
