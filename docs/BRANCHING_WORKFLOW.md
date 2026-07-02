# Branching Workflow

```text
main
└── dev
    ├── feature/specs
    ├── feature/ios-core
    ├── feature/android-core
    ├── feature/ios-voice
    ├── feature/android-voice
    ├── feature/memory-vault
    ├── feature/ai-brain
    ├── feature/recall-engine
    ├── feature/security-backup
    ├── feature/ui-polish
    ├── feature/research-memory-optimization
    ├── feature/ci-cd
    └── feature/qa
```

## Rules
- No direct push to `main`.
- No direct push to `dev`.
- Every agent works on its own `feature/*` branch.
- Every agent updates `docs/agent_logs/[agent-name].md`.
- Every PR must pass CI.
- Only merge to `dev` after review.
- Only merge `dev` to `main` for release.
