# Agent Task Board

## Execution order
P0 contracts → native shells → vault → voice → memory ingestion → recall → AI providers → backup → QA/release.

## P0 — Foundation
### SPEC-001 — Create project contracts
- Owner: Spec Architect
- Branch: `feature/spec-docs`
- Deliverables: all `docs/` files in this handoff, reconciled and internally consistent.
- Acceptance: no contradictions with AGENTS.md; PR into `dev`.

### CI-001 — Set up quality gates
- Owner: CI/CD Agent
- Branch: `feature/ci-cd`
- Deliverables: Android build/test workflow, iOS lint/build workflow where runner permits, secret scan, dependency/license report placeholder, PR template.
- Acceptance: PRs run static checks; failures block merge.

### IOS-001 — Scaffold native iOS app
- Owner: iOS Native Agent
- Branch: `feature/ios-core`
- Deliverables: SwiftUI app shell, four-tab nav, feature folders, dependency injection skeleton, placeholder screens.
- Acceptance: compiles; no network entitlements; unit test target created.

### AND-001 — Scaffold native Android app
- Owner: Android Native Agent
- Branch: `feature/android-core`
- Deliverables: Kotlin/Compose shell, four-tab nav, feature modules, DI skeleton, placeholder screens.
- Acceptance: builds; INTERNET permission absent; unit test setup created.

## P1 — Secure local vault
### VAULT-001 — Define encrypted vault abstraction
- Owner: Vault Security Agent
- Branch: `feature/vault-security`
- Deliverables: VaultRepository API, schema migrations, secure key-provider interfaces for iOS/Android.
- Acceptance: no plaintext persistence in app documents; tests for CRUD/migration; security design doc added.

### VAULT-002 — Implement canonical schema
- Owner: Vault Security Agent + platform agents
- Dependencies: VAULT-001
- Deliverables: Conversation, MemoryCard, DailySummary, LongTermFact tables/models per schema.
- Acceptance: round-trip tests; migration tests; schema parity document for both platforms.

### VAULT-003 — Biometric/passcode access gate
- Owner: iOS Native + Android Native
- Deliverables: optional biometric unlock; local passcode UX; lock on background/resume policy.
- Acceptance: does not claim unrecoverable protection beyond documented scope.

## P1 — Voice experience
### VOICE-001 — Voice recorder
- Owner: Voice Engine Agent
- Branch: `feature/voice-engine`
- Deliverables: recording abstraction, silence/manual stop, waveform state model, temporary file cleanup.
- Acceptance: microphone denied state works; no audio retained by default after processing.

### VOICE-002 — Offline transcription abstraction
- Owner: Voice Engine Agent
- Deliverables: `SpeechToTextProvider`, platform/provider capability checker, deterministic fake provider for tests.
- Acceptance: app can run with fake/local provider; no remote STT dependency.

### VOICE-003 — Transcript review
- Owner: UI Agent
- Deliverables: editable transcript, save/discard, audio-retention toggle.
- Acceptance: saved content follows privacy retention policy.

### TTS-001 — Local synthetic reply
- Owner: Voice Engine Agent
- Deliverables: TTS interface, system voice provider, mute/replay/speed controls.
- Acceptance: works without network and can be disabled.

## P1 — Memory engine
### MEM-001 — Build transcript-to-memory pipeline
- Owner: Memory Engine Agent
- Branch: `feature/memory-engine`
- Deliverables: thought segmentation, extraction interface, confidence/importance scoring, persistence orchestration.
- Acceptance: uses canonical schema; fixture tests generate expected cards.

### MEM-002 — Deduplication and fact promotion
- Owner: Memory Engine Agent
- Deliverables: duplicate grouping using normalized tags/title + lexical similarity; LongTermFact candidate policy.
- Acceptance: repeated statement does not create uncontrolled duplicate facts; user confirmation required for stable fact promotion in V1.

### MEM-003 — Daily summary rollup
- Owner: Memory Engine Agent
- Deliverables: incremental daily summary service.
- Acceptance: does not need full transcript scan every time; test fixture passes.

## P1 — Recall engine
### RECALL-001 — Implement local retrieval
- Owner: Recall Engine Agent
- Branch: `feature/recall-engine`
- Deliverables: query classifier, metadata filter, keyword/full-text search abstraction, ranking function.
- Acceptance: candidate list excludes deleted content; ranking fixture tests pass.

### RECALL-002 — Context compressor
- Owner: Recall Engine Agent
- Deliverables: top 3–5 compact evidence cards; char/token budget constant.
- Acceptance: never includes full vault; deterministic test demonstrates truncation/compression.

### RECALL-003 — Evidence-bound answer policy
- Owner: Recall Engine + AI Brain Agent
- Deliverables: no-evidence fallback and answer contracts.
- Acceptance: hallucination fixtures return exact fallback when evidence absent.

## P1 — On-device AI integration
### AI-001 — Define AI brain interface
- Owner: AI Brain Agent
- Branch: `feature/ai-brain`
- Deliverables: `generateFriendReply`, `extractMemory`, `summarizeDay`, `answerFromEvidence` interfaces + fake implementation.
- Acceptance: every app feature can run with fake provider in tests.

### AI-002 — iOS on-device provider adapter
- Owner: iOS AI Agent
- Deliverables: Apple on-device model adapter behind interface; controlled unavailable state.
- Acceptance: no remote fallback; graceful UI state when unavailable.

### AI-003 — Android on-device provider adapter
- Owner: Android AI Agent
- Deliverables: Android on-device AI adapter behind interface; controlled unavailable state.
- Acceptance: no remote fallback; graceful UI state when unavailable.

## P2 — Backup and privacy
### BACKUP-001 — Encrypted export/import
- Owner: Backup Agent
- Branch: `feature/backup-export`
- Deliverables: versioned `.pensieve` container, password-derived key, authenticated encryption, checksum/integrity, import preview.
- Acceptance: export/import round trip fixture; wrong password and corrupt file fail safely.

### PRIV-001 — Privacy dashboard and data deletion
- Owner: Privacy/UI Agent
- Deliverables: privacy status UI, delete transcripts/memories/audio/reset vault workflows.
- Acceptance: destructive actions require confirmation and are test-covered.

## P2 — QA and performance
### QA-001 — Offline and network guard tests
- Owner: QA/CI Agent
- Deliverables: automated scan for forbidden dependencies/permissions and manual airplane-mode checklist.
- Acceptance: Android INTERNET permission absent; no known remote endpoint present.

### QA-002 — Memory quality test suite
- Owner: QA Agent
- Deliverables: fixture corpus, expected cards, recall precision checks, no-memory fallback checks.
- Acceptance: regression test run documented in CI.

### PERF-001 — Profile storage and latency
- Owner: Performance Agent
- Deliverables: measurements for 100/1,000/5,000 memories; memory/vault size; recall p50/p95; report in `docs/performance/`.
- Acceptance: actionable thresholds and bottlenecks documented.

## Research workstream (parallel; does not block P1)
### RES-001 — Tiered memory and context compression
- Owner: Memory Research Agent
- Branch: `research/memory-optimization`
- Deliverables: compare tiered memory, prompt compression, graph recall, mobile RAG, vector quantization; map each finding to `now | later | reject`.
- Acceptance: no unverified implementation claims; citations/links in research memo.

### RES-002 — Local retrieval benchmark design
- Owner: Memory Research Agent + Performance Agent
- Deliverables: evaluation set for personal-memory retrieval and storage budget experiments.
- Acceptance: includes recall precision, latency, vault size, and battery/RAM metrics.
