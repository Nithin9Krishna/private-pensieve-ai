# Design System — Private Pensieve AI

> Single source of truth for all visual design tokens.
> Both iOS (SwiftUI) and Android (Jetpack Compose) implementations must reference this document.

---

## 1. Color System

### 1.1 Dark Mode (Primary)

| Token | Hex | Usage |
|-------|-----|-------|
| `background` | `#0B0F14` | Root screen background |
| `surfacePrimary` | `#121923` | Main content surfaces |
| `surfaceSecondary` | `#182230` | Secondary panels, sidebars |
| `surfaceElevated` | `#1E2A38` | Cards, elevated containers |
| `textPrimary` | `#F6F7FB` | Headings, primary labels |
| `textSecondary` | `#AAB5C4` | Supporting text, subtitles |
| `textMuted` | `#7B8797` | Hints, timestamps, metadata |
| `border` | `#2B3A4A` | Dividers, card borders |

### 1.2 Accent Colors

| Token | Hex | Usage |
|-------|-----|-------|
| `accentLavender` | `#A78BFA` | Primary accent, orb glow, active states |
| `accentViolet` | `#7C5CFC` | Orb center, focused interactive elements |
| `accentBlue` | `#63B3ED` | Links, informational badges |
| `accentTeal` | `#5ED6C9` | Success states, online/ready indicators |
| `accentAmber` | `#F6C667` | Important memories, favorites |
| `accentRed` | `#F87171` | Destructive actions **only at confirmation** |

### 1.3 Light Mode (Secondary — V2)

| Token | Hex | Usage |
|-------|-----|-------|
| `background` | `#F8F9FC` | Root screen background |
| `surfacePrimary` | `#FFFFFF` | Main content surfaces |
| `surfaceSecondary` | `#F0F2F7` | Secondary panels |
| `surfaceElevated` | `#FFFFFF` | Cards (with shadow) |
| `textPrimary` | `#1A1D23` | Headings |
| `textSecondary` | `#5A6478` | Supporting text |
| `textMuted` | `#8E96A4` | Hints |
| `border` | `#E2E6ED` | Dividers |

Accent colors remain the same in light mode.

### 1.4 Gradient Rules

- Gradients must be subtle and low-opacity (max 30% opacity endpoints).
- Orb gradient: radial from `accentViolet` center → `accentLavender` → transparent edge.
- Background ambient gradient: vertical from `#0B0F14` → `#121923`, optional.
- Never use neon, saturated rainbow, or aggressive linear gradients.

### 1.5 Semantic Colors

| Token | Resolves To |
|-------|-------------|
| `privacyBadgeBackground` | `surfaceSecondary` |
| `privacyBadgeText` | `accentTeal` |
| `offlineBadgeBackground` | `surfaceSecondary` |
| `offlineBadgeText` | `accentBlue` |
| `memoryChipBackground` | `surfaceElevated` |
| `memoryChipText` | `textSecondary` |
| `importanceDot` | `accentAmber` |
| `destructiveText` | `accentRed` |
| `destructiveBackground` | `accentRed` at 12% opacity |

---

## 2. Typography

### 2.1 iOS — SF Pro

| Style | Size | Weight | Line Height | Usage |
|-------|------|--------|-------------|-------|
| `heroTitle` | 34pt | Bold | 41pt | Welcome screen, onboarding titles |
| `largeTitle` | 28pt | Bold | 34pt | Screen titles |
| `title` | 22pt | Semibold | 28pt | Section headers, memory titles |
| `headline` | 17pt | Semibold | 22pt | Card titles, emphasized labels |
| `body` | 17pt | Regular | 22pt | Primary content, transcripts |
| `callout` | 16pt | Regular | 21pt | Supporting text |
| `subheadline` | 15pt | Regular | 20pt | Metadata, timestamps |
| `footnote` | 13pt | Regular | 18pt | Muted labels, chip text |
| `caption` | 12pt | Regular | 16pt | Badges, status pills |

All sizes must support Dynamic Type. Use `@ScaledMetric` for custom spacing.

### 2.2 Android — Material 3

| Style | Size | Weight | Line Height | Usage |
|-------|------|--------|-------------|-------|
| `displayMedium` | 34sp | Bold | 41sp | Welcome screen, onboarding titles |
| `headlineLarge` | 28sp | Bold | 34sp | Screen titles |
| `headlineMedium` | 22sp | Medium | 28sp | Section headers |
| `titleLarge` | 20sp | Medium | 26sp | Card titles |
| `bodyLarge` | 16sp | Regular | 24sp | Primary content |
| `bodyMedium` | 14sp | Regular | 20sp | Supporting text |
| `labelLarge` | 14sp | Medium | 20sp | Buttons, chips |
| `labelMedium` | 12sp | Medium | 16sp | Badges, status pills |
| `labelSmall` | 11sp | Medium | 16sp | Muted metadata |

Accessibility font scaling must be enabled. Use `sp` units exclusively.

### 2.3 Typography Tone

- Large, calm, sparse.
- Avoid long paragraphs in UI.
- Prefer one strong sentence and one supporting sentence.
- Use sentence case for buttons and labels.
- Use title case only for screen titles.

---

## 3. Shape System

| Element | Radius | Notes |
|---------|--------|-------|
| Memory card | 20px | Consistent across platforms |
| Elevated card | 24px | Detail views, review panels |
| Button (pill) | Full height / 2 | Fully rounded ends |
| Button (rounded rect) | 14px | Secondary actions |
| Bottom sheet | 28px (top corners) | Standard sheet presentation |
| Chip / badge | 12px | Filter chips, emotion tags |
| Input field | 16px | Search, text input |
| Status pill | 10px | Privacy/offline badges |
| Orb container | Circular | — |
| Tab bar | 0px (flat) | Blended with background |

### Sharp edges
- Use only for subtle horizontal dividers (1px `border` color).
- Never use sharp corners on interactive elements.

---

## 4. Spacing & Layout

| Token | Value | Usage |
|-------|-------|-------|
| `spacingXS` | 4pt / 4dp | Tight internal padding |
| `spacingS` | 8pt / 8dp | Chip padding, badge padding |
| `spacingM` | 16pt / 16dp | Standard content padding |
| `spacingL` | 24pt / 24dp | Section spacing |
| `spacingXL` | 32pt / 32dp | Screen-level padding |
| `spacingXXL` | 48pt / 48dp | Hero element spacing |

### Touch Targets
| Platform | Minimum | Recommended |
|----------|---------|-------------|
| iOS | 44 × 44 pt | 48 × 48 pt |
| Android | 48 × 48 dp | 48 × 48 dp |

---

## 5. Motion System

### 5.1 Orb Animations

| State | Animation | Duration | Easing |
|-------|-----------|----------|--------|
| **Idle** | Scale breathing: `1.0` → `1.06` → `1.0` | 7s total (3.5s each direction) | ease-in-out |
| **Listening** | Scale pulse: `1.0 + clamp(rms × 0.15, 0, 0.12)` | Continuous, 20fps update | linear interpolation |
| **Thinking** | Concentric ring ripple: 3 rings at 0°/120°/240° phase | 2s period | ease-out |
| **Speaking** | Gentle horizontal sway: ±2pt | Synced with TTS output | ease-in-out |
| **Saved** | Brief glow expansion then fade: scale `1.0` → `1.15` → `1.0` | 600ms | ease-out |

### 5.2 Orb Gradient
- Radial gradient: `accentViolet` center → `accentLavender` → transparent edge.
- Slow hue rotation: 15s full cycle.
- Use `TimelineView` (iOS) / `InfiniteTransition` (Android).

### 5.3 Transitions

| Transition | Duration | Easing |
|------------|----------|--------|
| Screen push/pop | 250ms | ease-out |
| Bottom sheet present | 200ms | ease-out |
| Card appear | 180ms | ease-out |
| Chip/badge fade-in | 150ms | ease-in-out |
| Staggered list items | 50ms stagger + 180ms each | ease-out |
| Delete confirmation | 200ms | ease-in |

### 5.4 Reduce Motion
When `Reduce Motion` is enabled:
- Replace orb animations with static gradient
- Replace transitions with cross-dissolve (150ms)
- Disable staggered animations
- Keep functional feedback (save confirmation) as color change only

---

## 6. Iconography

| Icon | Context | Style |
|------|---------|-------|
| Microphone | Talk tab, recording control | SF Symbols (iOS) / Material Icons (Android), filled |
| Shield/Lock | Vault tab, privacy | Outlined |
| Search/Brain | Recall tab | Outlined |
| Eye/Privacy | Privacy tab | Outlined |
| Star | Favorite memory | Filled when active |
| Trash | Delete action | Outlined, `accentRed` only at confirmation |
| Export | Backup export | Outlined |
| Checkmark | Save confirmation | Filled, `accentTeal` |
| Edit/Pencil | Transcript edit | Outlined |
| Clock | Timeline, timestamps | Outlined |

Use platform-native icon systems. Do not import custom icon fonts.

---

## 7. Accessibility Tokens

| Feature | iOS | Android |
|---------|-----|---------|
| Dynamic text | Dynamic Type + `@ScaledMetric` | `sp` units + font scaling |
| Screen reader | VoiceOver labels on all controls | TalkBack `contentDescription` on all controls |
| High contrast | `accessibilityContrast` trait | High contrast theme variant |
| Reduce motion | `UIAccessibility.isReduceMotionEnabled` | `Settings.Global.ANIMATOR_DURATION_SCALE` |
| Minimum contrast ratio | 4.5:1 for body text, 3:1 for large text | Same |

---

## 8. Platform Implementation Notes

### iOS (SwiftUI)
```swift
// Color tokens
extension Color {
    static let pensieveBackground = Color(hex: "0B0F14")
    static let pensieveSurfacePrimary = Color(hex: "121923")
    // ... etc
}

// Shape tokens
struct PensieveShape {
    static let card = RoundedRectangle(cornerRadius: 20)
    static let elevatedCard = RoundedRectangle(cornerRadius: 24)
    static let chip = RoundedRectangle(cornerRadius: 12)
    static let bottomSheet = UnevenRoundedRectangle(topLeadingRadius: 28, topTrailingRadius: 28)
}
```

### Android (Jetpack Compose)
```kotlin
// Color tokens
object PensieveColors {
    val background = Color(0xFF0B0F14)
    val surfacePrimary = Color(0xFF121923)
    // ... etc
}

// Shape tokens
val PensieveShapes = Shapes(
    medium = RoundedCornerShape(20.dp),  // cards
    large = RoundedCornerShape(24.dp),   // elevated
    small = RoundedCornerShape(12.dp),   // chips
)
```
