## Why

The app is English-only. The developer is Chinese-speaking and the market is global — localizing
multiplies reach.

## What Changes

- Adopt a **String Catalog** (`.xcstrings`), extract all UI strings, and provide **Traditional
  Chinese (zh-Hant)**, **Spanish (es)**, and **Japanese (ja)** translations. Localize the App Store
  listing too.

## Non-Goals
- No right-to-left languages this round. Date/number formatting via system locale (already mostly fine).

## Capabilities
### New Capabilities
- `localization`: full UI + store-listing localization for zh-Hant, es, ja.
### Modified Capabilities
<!-- none -->

## Impact
- All `App/Views/*` strings → catalog keys; `Localizable.xcstrings`; ASC localized metadata.
  **Roadmap (Round 3 — do last to avoid re-translating churn.)**
