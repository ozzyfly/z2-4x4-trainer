## Why

The app is functional on iPhone (Phases 0–3) but cannot reach users until it is signed,
reviewed, and published. App Store review additionally requires release assets and a hosted
privacy policy that do not exist yet. This change takes the app from "builds locally" to
"submitted for review."

## What Changes

- Replace the placeholder 1024² app icon in `App/Assets.xcassets/AppIcon.appiconset` with final artwork.
- Host the existing `docs/app-store/PRIVACY_POLICY.md` at a public URL (GitHub Pages) and record that URL.
- Enroll in the Apple Developer Program and register the App ID with the HealthKit capability.
- Configure automatic signing and produce a distributable archive of `Z24x4Trainer`.
- Capture required screenshots (iPhone 6.9"/6.5"; Apple Watch once the watch build runs).
- Create the App Store Connect record, fill metadata from `docs/app-store/METADATA.md`, answer the
  App Privacy questionnaire from `docs/app-store/APP_PRIVACY_LABEL.md`.
- Run a TestFlight internal test, then submit for review with HealthKit review notes.

## Non-Goals

- Paid tiers, subscriptions, or in-app purchases.
- Android / web versions.
- Marketing site beyond the required privacy-policy page.

## Capabilities

### New Capabilities

- `app-store-release`: the iOS app is signed, compliant, and submitted to the App Store with all
  required metadata, privacy disclosures, and a passing TestFlight build.

### Modified Capabilities

<!-- none -->

## Impact

- Assets/config: `App/Assets.xcassets/AppIcon.appiconset` (final icon), `project.yml`
  (`MARKETING_VERSION`/`CURRENT_PROJECT_VERSION` as needed), App Store Connect (external).
- External accounts: Apple Developer Program ($99/yr), App Store Connect, a public privacy-policy URL.
- No app logic changes beyond icon + version bump.
- Depends on the developer account; most steps are performed by the developer in Apple's portals.
