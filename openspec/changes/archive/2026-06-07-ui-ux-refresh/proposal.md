## Why

The shipped screens use default SwiftUI `Form`/`List` styling — functional but plain and
inconsistent. Before the next release the app needs a cohesive, polished look that feels like a
real fitness product, in both light and dark mode.

## What Changes

- Add a shared **design system** (`App/DesignSystem/`): adaptive theme + accent color, reusable
  `Card`, `SectionHeader`, `TargetBar`, `PrimaryButton`, `ZoneChip`, and a unified `HRZone` color map.
- Restyle every iOS screen (Today, Week, Workout detail, History, Settings, Onboarding, manual entry)
  to the card-led, minimal look using those components — **behavior and data wiring unchanged**.
- Add tasteful motion (animated progress fills, transitions) and haptics (`.sensoryFeedback`) on key
  actions; ensure Dynamic Type + VoiceOver + contrast hold up in light and dark.
- Light visual polish to the Watch screens reusing the shared zone styling.

## Non-Goals

- No navigation/flow redesign, no new screens or features.
- No domain/logic changes (SharedCore untouched; 35 tests stay green).
- Not touching the build currently in App Store review — this targets the next version.

## Capabilities

### New Capabilities

- `design-system`: a reusable visual language (theme, components, motion, accessibility) that all
  screens adopt for a consistent, polished, light/dark-correct UI.

### Modified Capabilities

<!-- none: no spec-level behavior changes; this is presentation only -->

## Impact

- New: `App/DesignSystem/*`, an `AccentColor` set in `App/Assets.xcassets`.
- Edited: all `App/Views/*` (presentation only), minor `Watch/*` styling.
- Untouched: `SharedCore/`, `project.yml` (sources are globbed), `Tests/`, persistence/HealthKit logic.
- Verified on the iOS 26.5 simulator in light + dark; no regressions to onboarding→tabs, manual entry, Connect Health.
