# Decisions Log

> This document tracks product, architecture, and implementation decisions.
> Required by `CODEX_KICKOFF_PROMPT.md` — never modify product constraints without recording the reason here.

| # | Date | Decision | Rationale | Impact |
|---|------|----------|-----------|--------|
| D001 | 2026-07-01 | AI brain interface is V1 must-have; Apple Foundation Models adapter is best-effort | `ARCHITECTURE.md` says "when supported" but `PRD.md` lists AI as V1 feature. Resolution: the interface + fake provider are required; real on-device adapters are best-effort on supported hardware. | All app features testable with fake provider regardless of device capability |
| D002 | 2026-07-01 | MemoryEdge table is optional in V1 and will not block launch | Both `MEMORY_SCHEMA.md` and `RECALL_PIPELINE.md` agree this is future-compatible | Recall uses metadata + full-text only in V1 |
| D003 | 2026-07-01 | `UI_UX_SPEC.md` remains as baseline summary; detailed design splits into `DESIGN_SYSTEM.md`, `SCREEN_STATES.md`, `USER_FLOWS.md`, `UI_COPY.md`, `COMPONENT_INVENTORY.md` | Keeps documents focused and independently reviewable | 5 new docs created alongside baseline |
| D004 | 2026-07-01 | iOS uses Xcode project (`.xcodeproj`) not SPM-only | Standard for iOS app targets; SPM used for dependency management within the project | Familiar to iOS developers; CI uses `xcodebuild` |
| D005 | 2026-07-01 | Android uses manual constructor injection for V1, not Hilt | Keeps dependency count minimal; project is small enough for manual DI | May revisit for V2 if testing pain increases |
| D006 | 2026-07-01 | KDF decision deferred to VAULT-001 | Requires platform library availability validation on both iOS and Android | Will update `SECURITY_DESIGN.md` when decided |
