# Z2/4×4 Trainer

iPhone + Apple Watch cardio coach. Prescribes daily/weekly **Zone 2** and **Norwegian 4×4**
training and tells you how much to train to maintain health or lose weight. Inputs come from
manual entry or Apple Health. Local-only — no account, no server.

## Status
See [`PROGRESS.md`](./PROGRESS.md).

## Architecture
- **SharedCore** — pure-Swift domain (training math, targets, energy). No UI / no HealthKit. Unit-tested.
- **iOS app** (SwiftUI, SwiftData) — onboarding, today/week targets, workout detail, history, settings.
- **watchOS app** — live workout: real-time HR, zone, 4×4 interval engine + haptics.

## Build
```sh
# domain core (runs on Mac, no simulator)
cd SharedCore && swift test

# app projects (after `xcodegen` + simulator runtime installed)
xcodegen generate
```

## Project management
Specs + progress tracked in **Spectra** (Mac). Cross-device monitoring via this repo's
`PROGRESS.md` on GitHub app / claude.ai/code web.
