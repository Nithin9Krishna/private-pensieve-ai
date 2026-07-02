# Enhancement Proposals — Private Pensieve AI

> Audit date: 2026-07-01
> Source: Repository audit + user design specification analysis
> Status: Proposals for review — none implemented yet

---

## How to Read This Document

Each enhancement is categorized as:

| Category | Meaning |
|----------|---------|
| 🟢 **Now** | Can be incorporated into current milestone without risk |
| 🟡 **Soon** | Should be planned for the next milestone or sprint |
| 🔵 **Later** | Valid but deferred — requires research or performance proof |
| 🔴 **Reject** | Conflicts with project constraints or V1 scope |

---

## A. CI / Quality Gates Enhancements

### A1. 🟢 Expand Forbidden Dependency Scan
**Current state**: `ci.yml` greps for 8 patterns (`firebase|supabase|amplitude|mixpanel|segment|sentry|openai.*api|anthropic`).

**Enhancement**: The scan misses many patterns from `PRIVACY_RULES.md`:
- Add: `crashlytics`, `appsflyer`, `braze`, `adjust`, `cloud_firestore`, `aws-sdk`, `azure`, `googleapis.com`, `api.openai`, `huggingface.*api`, `replicate`, `together.*api`, `groq`, `login`, `auth0`, `clerk`, `okta`
- Add: `INTERNET` permission check should also verify no `uses-permission` for `ACCESS_NETWORK_STATE`, `ACCESS_WIFI_STATE` (not strictly forbidden, but worth flagging)
- Add: License compatibility check for any new dependency added to `build.gradle.kts` or `Package.swift`

**Effort**: Small
**Risk**: None

### A2. 🟢 Add iOS Build-and-Test CI Job
**Current state**: iOS CI job only does `find ios -maxdepth 3 -type f | head -100` — no actual build.

**Enhancement**: Replace with:
```yaml
- name: Build iOS
  run: xcodebuild -project ios/PrivatePensieve.xcodeproj -scheme PrivatePensieve -sdk iphonesimulator -destination 'platform=iOS Simulator,name=iPhone 15' build test
```

**Effort**: Small (once project exists)
**Risk**: macOS runner availability and cost

### A3. 🟡 Add Dependency Lock File Audit
**Enhancement**: Fail CI if `Podfile.lock` / `Package.resolved` (iOS) or `gradle.lockfile` (Android) changes without a corresponding entry in the PR description explaining the new dependency + license + privacy justification.

**Effort**: Medium
**Risk**: None

### A4. 🟡 Secret Scanning Workflow
**Current state**: No secret scanning beyond `.gitignore`.

**Enhancement**: Add `trufflehog` or GitHub's built-in secret scanning to reject commits containing API keys, encryption keys, or credentials.

**Effort**: Small
**Risk**: None

---

## B. Design System Enhancements

### B1. 🟢 Create Complete Design System Document
**Current state**: `UI_UX_SPEC.md` is a baseline with no colors, typography scales, spacing, shapes, or motion specifications.

**Enhancement**: The user request provides a complete design system specification. Create `docs/DESIGN_SYSTEM.md` with:
- Full color palette with hex values and semantic naming
- Typography scale mapped to SF Pro (iOS) and Material 3 (Android)
- Shape system (card radius, button radius, bottom sheet radius)
- Motion system (orb breathing, pulse, ripple, transition durations)
- Touch target minimums (44pt iOS / 48dp Android)
- Accessibility tokens (high contrast variants, reduce motion alternatives)

This should be the **single source of truth** for both platform implementations.

**Effort**: Medium
**Risk**: None — it's specification, not code

### B2. 🟢 Define Light Mode as Secondary
**Current state**: Spec says dark mode first, but no light mode is defined at all.

**Enhancement**: Define a light mode color palette as a secondary theme. Even if V1 ships dark-only, having the semantic color tokens ready means light mode is a simple token swap later. Proposed light palette:
- Background: `#F8F9FC`
- Primary surface: `#FFFFFF`
- Secondary surface: `#F0F2F7`
- Elevated card: `#FFFFFF` with subtle shadow
- Primary text: `#1A1D23`
- Accent colors: same hues, adjusted for light background contrast

**Effort**: Small (token definitions only)
**Risk**: None

### B3. 🟡 Haptic Feedback Specification
**Current state**: No mention of haptics in the design spec.

**Enhancement**: Add haptic feedback patterns for:
- **Hold to Speak start**: Light impact (iOS `UIImpactFeedbackGenerator(.light)`)
- **Release / stop recording**: Medium impact
- **Memory saved**: Success notification feedback
- **Delete confirmation**: Warning notification feedback
- **Orb transition states**: Subtle selection feedback

Haptics significantly improve the "felt" quality of the app, especially for a voice-first experience where the user may not be looking at the screen.

**Effort**: Small
**Risk**: None — platform-native APIs, no dependencies

### B4. 🟡 Animated Orb Specification Detail
**Current state**: Orb is described qualitatively ("breathing," "pulse," "ripple") but no mathematical specification.

**Enhancement**: Define the orb animation precisely:
- **Idle**: `scale(1.0)` → `scale(1.06)` over 3.5s, ease-in-out, reverse, 7s total cycle
- **Listening**: Base scale varies with RMS amplitude: `scale(1.0 + clamp(rms * 0.15, 0, 0.12))`, update at 20fps
- **Thinking**: Concentric ring opacity ripple, 2s period, 3 rings at 0°/120°/240° phase offset
- **Speaking**: Gentle horizontal sway ±2pt, synced with TTS output if available
- **Gradient**: Radial gradient from `#7C5CFC` center to `#A78BFA` → transparent edge, with slow 15s hue rotation

Platform-specific: Use `TimelineView` on iOS, `InfiniteTransition` on Android Compose.

**Effort**: Medium
**Risk**: Battery impact needs profiling under `PERF-001`

---

## C. Screen & UX Enhancements

### C1. 🟢 Define All Empty States
**Current state**: Only Vault empty state is specified ("Your vault is waiting").

**Enhancement**: Define empty states for every screen:
| Screen | Empty State Title | Supporting Text | CTA |
|--------|-------------------|-----------------|-----|
| Vault | Your vault is waiting. | The moments you choose to save will appear here. | Talk to me |
| Recall (no memories) | No memories yet. | Start a conversation and save some memories first. | Talk to me |
| Recall (no match) | I don't remember you telling me that yet. | Would you like to talk about it now? | Talk about it |
| Timeline | Your story is just beginning. | As you save memories, your timeline will unfold. | — |
| Privacy (all green) | Everything is private. | Your data stays on this device. | — |

**Effort**: Small
**Risk**: None

### C2. 🟢 Define Error States
**Current state**: No error states specified anywhere.

**Enhancement**: Define error handling UI for:
| Scenario | Display | Action |
|----------|---------|--------|
| Microphone permission denied | "Microphone access needed to talk" + Settings link | Open Settings |
| STT unavailable | "Speech recognition is not available on this device" | Use text input instead |
| AI brain unavailable | "AI features are warming up" | Memory still saved, reply deferred |
| Vault unlock failed | "Unable to open your vault" | Retry / Reset vault |
| Disk full | "Not enough storage to save this memory" | Manage storage |
| Backup import failed | "This backup file couldn't be opened" | Retry with different file |
| Backup wrong password | "Incorrect password for this backup" | Try again |

**Effort**: Small
**Risk**: None — these are essential for production quality

### C3. 🟢 Add Conversation History (Within Talk Tab)
**Current state**: Talk tab shows single conversation, but no way to see recent conversations or continue a previous one.

**Enhancement**: Add a small "Recent" button in the Talk tab header that opens a bottom sheet showing the last 5 conversations with timestamps. Tapping one opens it in read-only mode with a "Continue" option. This prevents the Talk tab from feeling stateless.

**Effort**: Medium
**Risk**: Must not become a feed/timeline — keep it minimal (max 5 items)

### C4. 🟡 Smart Suggested Questions in Recall
**Current state**: Recall shows static suggested questions.

**Enhancement**: After the user has 10+ memories, dynamically generate 3-4 suggested questions based on actual memory content:
- Recent topics → "What did I say about [topic] this week?"
- Recurring emotions → "When have I felt [emotion]?"
- People mentioned → "What have I said about [person]?"

Generation uses the AI brain's `generateSuggestions` interface (new method on `AIBrainProvider`). Falls back to static suggestions if < 10 memories or AI unavailable.

**Effort**: Medium
**Risk**: Requires AI brain — defer to Milestone 5+

### C5. 🟡 Onboarding Skip Option
**Current state**: Onboarding has 4 screens (Welcome → Privacy → Vault → Brain Setup) with no skip.

**Enhancement**: Add "Skip for now" as a tertiary text button on screens 1B–1D. Skipping vault creation means the app starts with an unprotected local store and shows a persistent banner: "Set up vault protection →". This reduces friction for first-time exploration.

**Effort**: Small
**Risk**: Security implication — unprotected vault is acceptable for exploration but must be clearly communicated

### C6. 🟡 Undo Delete with Grace Period
**Current state**: Delete requires confirmation but is immediate and irreversible.

**Enhancement**: After confirming delete, show a 10-second toast: "Memory deleted. Undo?" The memory is soft-deleted (sets `is_deleted = true`) and permanently purged only after the grace period. This follows the same pattern as Gmail/iOS Mail.

**Effort**: Medium
**Risk**: None — improves user trust

### C7. 🔵 Conversation Threads / Topics
**Enhancement**: Allow the user to create named conversation threads (e.g., "Career thoughts," "Travel plans"). Each thread maintains its own context. The Talk tab shows the active thread, and a thread picker appears in the header.

**Effort**: Large
**Risk**: Adds complexity; may conflict with "minimal cognitive load" principle. Evaluate post-V1.

---

## D. Memory & Recall Enhancements

### D1. 🟢 Memory Card Preview Before Save
**Current state**: Spec mentions "What I'll remember" cards at conversation end, but the data flow for showing generated cards before persist is not defined.

**Enhancement**: After conversation ends, the AI brain extracts MemoryCards and presents them in a review screen. User can:
- Tap a card to edit title/tags/summary
- Swipe to remove a card
- Add an importance star
- Confirm "Save all" or "Save selected"

This is already in the user spec — it just needs formal data flow documentation.

**Effort**: Medium (UI) + Small (data flow)
**Risk**: None — critical for user trust

### D2. 🟡 Memory Linking Suggestions
**Current state**: MemoryEdge is defined in schema but labeled "future-compatible."

**Enhancement**: After saving a new MemoryCard, run a lightweight match (tag overlap + date proximity) against recent cards. If a likely link exists, show: "This seems related to [linked memory title]. Link them?" User confirms or dismisses. This creates MemoryEdge records incrementally without requiring graph infrastructure.

**Effort**: Medium
**Risk**: Tag-based linking may produce low-quality suggestions. Start with high-confidence matches only (3+ tag overlap).

### D3. 🟡 Batch Memory Export (Selective)
**Current state**: Only full vault export is specified.

**Enhancement**: Allow the user to select specific memories (date range, tag, or manual multi-select) and export just those as a `.pensieve` file. Use case: sharing specific memories with a trusted person, or partial backup.

**Effort**: Medium
**Risk**: Must maintain same encryption standards as full export

### D4. 🔵 Sentiment Trend Visualization
**Enhancement**: In the Timeline secondary screen, show a subtle line chart of emotion distribution over time (not a score, just a visual pattern). Uses only data from existing emotion_tags on MemoryCards.

**Effort**: Medium
**Risk**: Must not feel like analytics/tracking. Use observational language. Defer until Timeline is built.

### D5. 🔵 Memory Importance Decay
**Enhancement**: Over time, reduce `importance_score` on memories that haven't been recalled, favorited, or linked. This makes recall more relevant by surfacing recently-important memories. Decay rate: -1 per 30 days without interaction, minimum floor of 1.

**Effort**: Small (background job)
**Risk**: Users may not expect their memories to lose importance. Needs user setting toggle.

---

## E. Voice Experience Enhancements

### E1. 🟢 Visual Waveform During Recording
**Current state**: Spec mentions orb responds to amplitude but no waveform visualization.

**Enhancement**: Show a subtle waveform bar beneath the orb during recording. Use 16-32 frequency bars with smooth animation. Color: `#A78BFA` at low amplitude → `#7C5CFC` at high amplitude. Height range: 4pt minimum → 24pt maximum.

**Effort**: Medium
**Risk**: None — purely visual enhancement using audio buffer data

### E2. 🟡 Pause/Resume Recording
**Current state**: Only Hold-to-Speak and Tap-to-Start/Stop modes.

**Enhancement**: Add a third mode: "Tap to Start → Tap to Pause → Tap to Resume → Tap to Stop." Useful for users who need to collect thoughts mid-sentence. Paused state shows the orb in a "breathing hold" (static slightly enlarged) with "Paused" text.

**Effort**: Medium
**Risk**: Adds complexity to voice state machine. Keep behind a toggle in settings.

### E3. 🟡 Whisper-Level Sensitivity Indicator
**Enhancement**: When the user speaks very quietly, show a subtle indicator: "I can hear you, but speaking a bit louder may improve accuracy." This helps with STT quality without making the user feel judged.

**Effort**: Small
**Risk**: Must not be annoying. Show only once per session and only when RMS is consistently below threshold.

### E4. 🔵 Background Listening Mode
**Enhancement**: Allow the app to listen continuously in the background (with explicit user opt-in) and auto-save when the user says a trigger phrase like "Remember this." 

**Effort**: Large
**Risk**: Battery drain, privacy perception, platform restrictions (iOS background audio limits). Defer to post-V1 research.

---

## F. Privacy & Security Enhancements

### F1. 🟢 Privacy Badge Animation on First Launch
**Current state**: Privacy chips shown on onboarding are static.

**Enhancement**: On the Welcome screen, animate the privacy chips appearing one by one with a soft fade-in (150ms stagger):
1. "No account" fades in
2. "No cloud" fades in
3. "Works offline" fades in

This makes the privacy promise feel intentional rather than decorative.

**Effort**: Small
**Risk**: None

### F2. 🟢 Persistent Privacy Footer
**Current state**: "Your memories stay on this device" is mentioned for the Talk screen.

**Enhancement**: Show a subtle, persistent privacy indicator on all main screens — not just Talk. Use a small lock icon + "Device only" text in the top status bar area. This reinforces trust without taking space.

**Effort**: Small
**Risk**: None — single line of UI

### F3. 🟡 Vault Auto-Lock Policy
**Current state**: Lock-on-background is mentioned but not specified.

**Enhancement**: Define explicit auto-lock policies:
- **Immediate**: Lock when app goes to background
- **After 1 minute**: Lock 1 minute after background
- **After 5 minutes**: Lock 5 minutes after background
- **Never**: Don't auto-lock (show warning)

Default: Immediate. User can change in Privacy settings.

**Effort**: Small
**Risk**: None

### F4. 🟡 Panic Button / Quick Lock
**Enhancement**: Add a discreet lock icon in the top-right of every screen. Tapping it immediately locks the vault and returns to the unlock screen. Useful for physical privacy situations.

**Effort**: Small
**Risk**: None — enhances user trust

### F5. 🟡 Export Encryption Algorithm Transparency
**Current state**: `SECURITY_DESIGN.md` lists "authenticated encryption" without specifying algorithm.

**Enhancement**: Decide and document:
- **KDF**: Argon2id with 64MB memory, 3 iterations, 32-byte output (or PBKDF2-HMAC-SHA256 with 600K iterations if Argon2 library is unavailable)
- **Encryption**: AES-256-GCM with per-backup random 96-bit nonce
- **Container format**: `[4-byte magic "PNSV"][2-byte version][32-byte salt][12-byte nonce][ciphertext][16-byte GCM tag]`
- Show algorithm name in the export confirmation dialog: "Encrypted with AES-256-GCM"

**Effort**: Medium (decision + implementation)
**Risk**: KDF library availability on both platforms needs validation

### F6. 🔵 Decoy Vault
**Enhancement**: Allow the user to create a secondary "decoy" vault with a different passcode that shows innocuous placeholder memories. Protects against coerced unlocking.

**Effort**: Large
**Risk**: Complex UX; potential confusion. Evaluate post-V1.

---

## G. Architecture & Technical Enhancements

### G1. 🟢 Schema Version Tracking
**Current state**: No schema version field in the database or models.

**Enhancement**: Add a `schema_version` metadata table and include `schema_version` in the backup container. This enables safe migrations when the schema evolves.

**Effort**: Small
**Risk**: None — essential for upgradability

### G2. 🟢 Structured Logging (Non-User-Content)
**Current state**: "Never log transcripts or memory cards" is specified, but no logging framework is defined.

**Enhancement**: Use platform-native structured logging (`os_log` on iOS, `Timber` on Android) for:
- App lifecycle events
- Vault open/close (no content)
- Feature usage counts (local only, never exported)
- Error conditions

Never log: user content, encryption keys, transcripts, memory data.

**Effort**: Small
**Risk**: Must be audited to ensure no content leaks

### G3. 🟡 Dependency Injection Framework
**Current state**: "DI skeleton" is mentioned but no framework chosen.

**Enhancement**:
- **iOS**: Use Swift's native `@Environment` + manual constructor injection. Avoid heavy DI frameworks to keep dependencies minimal.
- **Android**: Use Hilt (part of Jetpack, well-supported). It adds build complexity but makes testing much easier.

Document the choice in `DECISIONS.md`.

**Effort**: Medium (Android Hilt setup)
**Risk**: Hilt adds compile-time annotation processing; acceptable for testability benefits

### G4. 🔵 Modular Build Structure (Android)
**Enhancement**: Split Android into Gradle modules:
- `:app` — UI, navigation
- `:core:models` — domain models
- `:core:vault` — encrypted storage
- `:core:voice` — recording, STT, TTS
- `:core:memory` — ingestion, deduplication
- `:core:recall` — retrieval, ranking
- `:core:ai` — AI brain interface + providers
- `:core:backup` — export/import

Benefits: faster incremental builds, enforced dependency boundaries, independent testing.

**Effort**: Large (restructure)
**Risk**: Premature if team is small. Evaluate after V1 alpha.

---

## H. Testing Enhancements

### H1. 🟢 Expand Test Fixtures
**Current state**: 3 transcripts, 2 recall test cases.

**Enhancement**: Add more fixture diversity:
- Emotional content (sadness, excitement, anger)
- Multi-topic transcripts
- Very short transcripts (< 10 words)
- Very long transcripts (500+ words)
- Transcripts with named people
- Transcripts with dates/times
- Transcripts in conversational style vs. monologue
- Recall queries with date ranges
- Recall queries matching multiple memories

Target: 15 transcripts, 10 recall test cases.

**Effort**: Small
**Risk**: None

### H2. 🟡 Snapshot Testing for UI Components
**Enhancement**: Use snapshot testing frameworks:
- **iOS**: `swift-snapshot-testing` (Point-Free) for SwiftUI previews
- **Android**: Compose Preview Screenshot Testing or Paparazzi

Captures visual regressions in the design system components.

**Effort**: Medium
**Risk**: Snapshot tests are brittle across OS versions; use selectively

### H3. 🟡 Airplane Mode Integration Test
**Current state**: "Airplane-mode functional test" is listed as V1 must-have but only as a manual checklist.

**Enhancement**: Create an automated XCTest / Instrumented Android test that:
1. Disables network (mock or device setting)
2. Creates a vault
3. Records + transcribes (via fake provider)
4. Saves a memory
5. Recalls the memory
6. Asserts no network calls were made

**Effort**: Medium
**Risk**: Platform-specific network mocking may be fragile

---

## I. Documentation Enhancements

### I1. 🟢 Create `docs/DECISIONS.md`
**Current state**: Missing. Required by kickoff prompt.

**Enhancement**: Create a structured decision log:
```markdown
# Decisions Log
| # | Date | Decision | Rationale | Impact |
|---|------|----------|-----------|--------|
```

**Effort**: Trivial
**Risk**: None

### I2. 🟢 Reconcile `UI_UX_SPEC.md` with User Design Spec
**Current state**: `UI_UX_SPEC.md` is a 57-line baseline. The user request contains a 500+ line comprehensive spec.

**Enhancement**: Either:
- (a) Replace `UI_UX_SPEC.md` with the expanded spec, or
- (b) Keep `UI_UX_SPEC.md` as the baseline summary and create detailed sub-documents (`DESIGN_SYSTEM.md`, `SCREEN_STATES.md`, `USER_FLOWS.md`, `UI_COPY.md`)

**Recommendation**: Option (b) — keeps documents focused and reviewable.

**Effort**: Medium
**Risk**: None

### I3. 🟡 API Contract Documentation
**Enhancement**: Create `docs/API_CONTRACTS.md` documenting every internal interface:
- `VaultRepository` (CRUD for each entity)
- `SpeechToTextProvider` (start, stop, result callback)
- `TTSProvider` (speak, stop, rate, voice)
- `AIBrainProvider` (generateReply, extractMemory, summarizeDay, answerFromEvidence)
- `RecallEngine` (query, rank, compress)
- `BackupService` (export, import, verify)

This becomes the binding contract between platform implementations.

**Effort**: Medium
**Risk**: None — prevents implementation divergence

---

## J. User Experience Research Proposals

### J1. 🔵 Memory Confidence Calibration Study
**Enhancement**: Once real users generate memories, measure how often confidence_score correlates with actual accuracy. Adjust scoring algorithm based on findings.

### J2. 🔵 Recall Precision Benchmarking
**Enhancement**: After collecting 50+ user-generated memories, run structured recall queries and measure precision@3 and recall@5. Document in `docs/performance/`.

### J3. 🔵 Battery Impact Profiling
**Enhancement**: Measure battery drain during:
- 5-minute continuous recording
- STT processing of 60-second audio
- AI brain inference for memory extraction
- Recall query with 1000 memories

---

## Summary: Priority Matrix

| Priority | Count | Key Items |
|----------|-------|-----------|
| 🟢 Now | 14 | Expanded CI scan, iOS CI build, design system doc, empty/error states, schema versioning, test fixtures, decisions log |
| 🟡 Soon | 15 | Haptics, auto-lock, secret scanning, snapshot tests, pause recording, memory linking, selective export |
| 🔵 Later | 8 | Sentiment visualization, importance decay, background listening, decoy vault, modular Android build |
| 🔴 Reject | 0 | No proposals conflict with constraints |

---

## Next Steps

1. **Review this document** and mark which enhancements to include in current milestones.
2. **Create `docs/DECISIONS.md`** to track accepted/rejected proposals.
3. **Prioritize 🟢 Now items** alongside Milestone 1 foundation work.
4. **Schedule 🟡 Soon items** into Milestones 2–5.
5. **Park 🔵 Later items** in the research backlog.
