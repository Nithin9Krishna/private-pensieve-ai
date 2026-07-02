# Component Inventory — Private Pensieve AI

> Reusable UI components for both platforms.
> Each component has a defined API, states, and platform implementation notes.

---

## 1. PrivacyStatusPill

**Purpose**: Small badge showing "Local-only" or similar privacy status.

| Property | Type | Default |
|----------|------|---------|
| `text` | String | Required |
| `icon` | Icon? | Shield |
| `style` | `.privacy` / `.offline` / `.neutral` | `.privacy` |

**States**: Default only (always visible).

**Design**:
- Background: `surfaceSecondary`
- Text: `accentTeal` (privacy) / `accentBlue` (offline)
- Shape: `10px` radius pill
- Font: `caption` / `labelSmall`
- Padding: `spacingS` horizontal, `spacingXS` vertical

**iOS**: `struct PrivacyStatusPill: View`
**Android**: `@Composable fun PrivacyStatusPill(text: String, style: PillStyle)`

---

## 2. OfflineStatusPill

**Purpose**: Shows "Offline ready" status indicator.

Shares implementation with `PrivacyStatusPill` using `.offline` style. May be a typealias or variant.

---

## 3. PensieveOrb

**Purpose**: Central animated orb that reflects app state.

| Property | Type | Default |
|----------|------|---------|
| `state` | `.idle` / `.listening` / `.thinking` / `.speaking` / `.saved` | `.idle` |
| `audioLevel` | Float (0–1) | 0 |
| `reduceMotion` | Bool | System setting |

**States**:
| State | Visual |
|-------|--------|
| `.idle` | Breathing scale 1.0→1.06, 7s cycle |
| `.listening` | Amplitude-responsive pulse |
| `.thinking` | Concentric ripple rings |
| `.speaking` | Gentle horizontal sway |
| `.saved` | Brief glow expansion 600ms |

**Design**:
- Size: 160×160pt / 160×160dp
- Gradient: Radial `accentViolet` → `accentLavender` → transparent
- Slow 15s hue rotation
- Reduce Motion: static gradient, no animation

**iOS**: `struct PensieveOrb: View` using `TimelineView` and `Canvas`
**Android**: `@Composable fun PensieveOrb(state: OrbState, audioLevel: Float)` using `InfiniteTransition`

---

## 4. HoldToSpeakButton

**Purpose**: Primary voice interaction control.

| Property | Type | Default |
|----------|------|---------|
| `mode` | `.holdToSpeak` / `.tapToToggle` | `.holdToSpeak` |
| `isRecording` | Bool | false |
| `onStart` | () -> Void | Required |
| `onStop` | () -> Void | Required |

**States**:
| State | Label | Visual |
|-------|-------|--------|
| Ready | "Hold to Speak" / "Tap to Start" | Filled mic icon, `accentLavender` |
| Recording | "Release to finish" / "Tap to Stop" | Pulsing, `accentViolet` |
| Disabled | "Microphone unavailable" | Dimmed, `textMuted` |

**Design**:
- Size: 72×72pt / 72×72dp (minimum touch target exceeded)
- Shape: Circle
- Haptic: Light impact on start, medium on stop

**iOS**: `struct HoldToSpeakButton: View` with `LongPressGesture` / `TapGesture`
**Android**: `@Composable fun HoldToSpeakButton(...)` with `pointerInput` modifier

---

## 5. LiveTranscriptPanel

**Purpose**: Shows real-time transcription during recording.

| Property | Type | Default |
|----------|------|---------|
| `text` | String | "" |
| `isActive` | Bool | false |
| `confidence` | Float? | nil |

**States**:
| State | Visual |
|-------|--------|
| Hidden | Collapsed (0 height) |
| Active | Bottom sheet with streaming text |
| Low confidence | Text + subtle warning badge |

**Design**:
- Position: Bottom sheet, 28px top radius
- Background: `surfacePrimary`
- Text: `textPrimary`, `body` / `bodyLarge`
- Max height: 30% of screen
- Smooth text update (not character-by-character flicker)

**iOS**: `struct LiveTranscriptPanel: View`
**Android**: `@Composable fun LiveTranscriptPanel(text: String, isActive: Boolean)`

---

## 6. MemoryCard

**Purpose**: Displays a memory entry in the vault list.

| Property | Type | Default |
|----------|------|---------|
| `memory` | MemoryCard (model) | Required |
| `onTap` | () -> Void | Required |
| `showImportance` | Bool | true |

**Content**:
- Date (formatted)
- Title (1 line)
- Summary (2 lines max)
- Emotion/topic chips (max 3 visible)
- Importance dot (if score ≥ 7)

**Design**:
- Background: `surfaceElevated`
- Shape: `20px` radius
- Padding: `spacingM`
- Title: `headline` / `titleLarge`
- Summary: `callout` / `bodyMedium`, `textSecondary`
- Date: `footnote` / `labelMedium`, `textMuted`

**iOS**: `struct MemoryCardView: View`
**Android**: `@Composable fun MemoryCard(memory: MemoryCardModel, onTap: () -> Unit)`

---

## 7. MemoryChip

**Purpose**: Compact tag/emotion label.

| Property | Type | Default |
|----------|------|---------|
| `text` | String | Required |
| `style` | `.emotion` / `.topic` / `.person` / `.goal` | `.topic` |

**Design**:
- Background: `memoryChipBackground`
- Text: `memoryChipText`, `footnote` / `labelMedium`
- Shape: `12px` radius
- Padding: `spacingS` horizontal, `spacingXS` vertical

**iOS**: `struct MemoryChip: View`
**Android**: `@Composable fun MemoryChip(text: String, style: ChipStyle)`

---

## 8. ImportanceMarker

**Purpose**: Subtle amber dot indicating important memory.

| Property | Type | Default |
|----------|------|---------|
| `importance` | Int (1–10) | Required |
| `threshold` | Int | 7 |

**Design**:
- Visible only when `importance >= threshold`
- Color: `accentAmber`
- Size: 8×8pt / 8×8dp circle
- Position: Top-right of memory card

**iOS**: `struct ImportanceMarker: View`
**Android**: `@Composable fun ImportanceMarker(importance: Int)`

---

## 9. RecallQuestionCard

**Purpose**: Suggested question button in Recall tab.

| Property | Type | Default |
|----------|------|---------|
| `question` | String | Required |
| `onTap` | () -> Void | Required |

**Design**:
- Background: `surfaceSecondary`
- Text: `textPrimary`, `body` / `bodyLarge`
- Shape: `20px` radius
- Leading icon: Subtle question mark or search icon
- Padding: `spacingM`

**iOS**: `struct RecallQuestionCard: View`
**Android**: `@Composable fun RecallQuestionCard(question: String, onTap: () -> Unit)`

---

## 10. RecallEvidenceCard

**Purpose**: Shows a memory evidence item in recall results.

| Property | Type | Default |
|----------|------|---------|
| `date` | String | Required |
| `summary` | String | Required |
| `onTap` | () -> Void | Required |
| `index` | Int | Required |

**Design**:
- Background: `surfaceElevated`
- Leading: Index number in `accentLavender` circle
- Date: `footnote` / `labelMedium`, `textMuted`
- Summary: `body` / `bodyLarge`, `textPrimary`
- Shape: `20px` radius

**iOS**: `struct RecallEvidenceCard: View`
**Android**: `@Composable fun RecallEvidenceCard(index: Int, date: String, summary: String, onTap: () -> Unit)`

---

## 11. VaultFilterChip

**Purpose**: Compact filter toggle in Vault tab.

| Property | Type | Default |
|----------|------|---------|
| `label` | String | Required |
| `isSelected` | Bool | false |
| `onTap` | () -> Void | Required |

**Design**:
- Background: `surfaceSecondary` (unselected) / `accentViolet` at 20% (selected)
- Text: `textSecondary` (unselected) / `accentLavender` (selected)
- Shape: `12px` radius
- Font: `footnote` / `labelLarge`

**iOS**: `struct VaultFilterChip: View`
**Android**: `@Composable fun VaultFilterChip(label: String, isSelected: Boolean, onTap: () -> Unit)`

---

## 12. EmptyVaultState

**Purpose**: Full-screen empty state for Vault tab.

| Property | Type | Default |
|----------|------|---------|
| `title` | String | "Your vault is waiting." |
| `subtitle` | String | "The moments you choose to save will appear here." |
| `ctaText` | String | "Talk to me" |
| `onCTA` | () -> Void | Required |

**Design**:
- Center-aligned vertically
- Subtle illustration or small static orb
- Title: `title` / `headlineMedium`, `textPrimary`
- Subtitle: `body` / `bodyLarge`, `textSecondary`
- CTA: Pill button, `accentLavender`

**iOS**: `struct EmptyVaultState: View`
**Android**: `@Composable fun EmptyVaultState(onCTA: () -> Unit)`

---

## 13. SecureActionSheet

**Purpose**: Confirmation dialog for destructive actions.

| Property | Type | Default |
|----------|------|---------|
| `title` | String | Required |
| `message` | String | Required |
| `destructiveLabel` | String | "Delete" |
| `cancelLabel` | String | "Cancel" |
| `onConfirm` | () -> Void | Required |
| `onCancel` | () -> Void | Required |

**Design**:
- Standard bottom sheet or alert dialog
- Destructive button: `accentRed` text (not background) until confirmed
- Cancel button: `textSecondary`
- Background: `surfacePrimary`

**iOS**: `struct SecureActionSheet: ViewModifier` using `.confirmationDialog`
**Android**: `@Composable fun SecureActionSheet(...)` using `AlertDialog`

---

## 14. BackupStatusCard

**Purpose**: Shows backup export/import status.

| Property | Type | Default |
|----------|------|---------|
| `status` | `.idle` / `.encrypting` / `.complete` / `.error` | `.idle` |
| `progress` | Float? | nil |
| `fileName` | String? | nil |

**Design**:
- Background: `surfaceElevated`
- Progress bar: `accentLavender` fill
- Status text: contextual
- Shape: `20px` radius

**iOS**: `struct BackupStatusCard: View`
**Android**: `@Composable fun BackupStatusCard(status: BackupStatus, progress: Float?)`

---

## 15. OfflineBrainPackCard

**Purpose**: Shows an offline AI model pack with download/status.

| Property | Type | Default |
|----------|------|---------|
| `title` | String | Required |
| `description` | String | Required |
| `size` | String | Required |
| `status` | `.available` / `.downloading` / `.ready` / `.insufficient_storage` | `.available` |
| `progress` | Float? | nil |
| `onDownload` | () -> Void | Required |
| `onDelete` | () -> Void | Required |

**Design**:
- Background: `surfaceElevated`
- Title: `headline` / `titleLarge`
- Description: `callout` / `bodyMedium`, `textSecondary`
- Size: `footnote` / `labelMedium`, `textMuted`
- Status badge: Contextual color
- Shape: `20px` radius

**iOS**: `struct OfflineBrainPackCard: View`
**Android**: `@Composable fun OfflineBrainPackCard(...)`
