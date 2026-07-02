# First Prompt to Paste into Codex

You are the lead implementation agent for the `private-pensieve-ai` repository.

Read `AGENTS.md` first, then read every document in `docs/` in the repository reading order. Treat those files as binding project contracts.

Your immediate objective is **not** to implement the entire app in one change. Create a safe, parallelizable implementation plan and then begin P0 work.

## Step 1 — Repository audit
1. Inspect the repo structure and identify missing files or contradictions.
2. Create `docs/IMPLEMENTATION_PLAN.md` with:
   - dependency graph for all P0/P1/P2 tasks,
   - native iOS and Android ownership boundaries,
   - exact branch/worktree plan,
   - risks and assumptions,
   - acceptance checks for each milestone.
3. Do not modify product constraints without recording the reason in `docs/DECISIONS.md`.

## Step 2 — Create workstreams
Create or delegate these workstreams in parallel, each confined to its module:
- `feature/ci-cd`: CI policy checks and PR workflow
- `feature/ios-core`: iOS SwiftUI shell and navigation
- `feature/android-core`: Android Compose shell and navigation
- `feature/vault-security`: vault interfaces, schemas, secure storage plan
- `feature/voice-engine`: recording/STT/TTS abstractions with fake local providers
- `feature/memory-engine`: canonical models, ingestion pipeline, fixtures
- `feature/recall-engine`: hybrid local retrieval, ranking, context compressor
- `feature/ai-brain`: provider interfaces and deterministic fake brain
- `research/memory-optimization`: research memo mapping findings to now/later/reject

## Step 3 — First implementation milestone
Complete only these deliverables before advancing:
1. Both native app shells build with four placeholder tabs: Talk, Vault, Recall, Privacy.
2. The Android manifest contains no INTERNET permission.
3. A repo policy CI job rejects banned cloud/analytics dependencies.
4. Canonical domain models exist on both platforms and match `docs/MEMORY_SCHEMA.md`.
5. Deterministic fake providers support testable save/recall flow without real AI or network.
6. Unit tests use `test_data/` fixtures and include the no-memory fallback.

## Hard rules
- Never add a backend, login, analytics, cloud storage, remote STT, remote TTS, remote LLM, or remote fallback.
- Never claim zero hallucination. Enforce memory-grounded claims with evidence and the exact no-memory fallback.
- Do not add a vector database or embeddings until `PERF-001` demonstrates metadata + full-text retrieval is insufficient.
- Keep V1 scope: no voice cloning, social features, subscriptions, cloud sync, or web app.
- Do not push directly to `main` or `dev`; use feature branches and PRs.
- Update the appropriate agent log before each PR.

At the end of this first task, provide:
- a concise status report,
- links/paths to changed files,
- tests run and results,
- blocked decisions,
- the next three recommended PRs.
