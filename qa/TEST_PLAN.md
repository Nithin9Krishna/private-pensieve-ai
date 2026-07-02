# QA Test Plan

## P0 critical tests
1. App works in airplane mode.
2. App does not require account.
3. App does not call server.
4. Memory saves locally.
5. Memory recall returns the correct memory.
6. If no memory is found, app says: "I don't remember you telling me that yet."
7. Delete all removes local memories.
8. Export/import works for encrypted `.pensieve` backups.

## Test cases

### QA-002 Offline mode
- Enable airplane mode.
- Launch app.
- Open Talk, Vault, Recall, Privacy.
- Expected: all screens load; no account/server prompt appears.

### QA-003 No-network test
- Inspect Android manifest and iOS entitlements.
- Expected: no Android INTERNET permission and no unapproved network/cloud capability.

### QA-004 Memory extraction
- Use `test_data/sample_transcripts.json`.
- Expected: extracted card matches V1 fields and durable memory content.

### QA-005 Recall correctness
- Ask: `When did I talk to Maya about work?`
- Expected: recalls `memory-001`.

### QA-006 No fake memory
- Ask unrelated question with empty vault.
- Expected: exact fallback sentence.

### QA-007 Delete data
- Save memory, delete all data, reopen app.
- Expected: vault is empty and recall returns fallback.

### QA-008 Backup/restore
- Export `.pensieve`, delete local data, import backup.
- Expected: restore preview appears and selected memories return after confirmation.

### QA-009 Voice flow
- Hold to Speak, record, stop, preview/edit transcript, save, hear reply.
- Expected: flow completes locally.

### QA-010 Battery/performance
- 10-minute voice/memory session.
- Expected: no excessive battery, heat, or memory growth.
