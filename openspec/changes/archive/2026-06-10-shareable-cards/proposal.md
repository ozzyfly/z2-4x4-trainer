## Why

A polished share image of a completed workout or weekly summary spreads the app organically.

## What Changes

- Render a branded summary card (SwiftUI → image via `ImageRenderer`) for a workout or the week,
  with a system share sheet.

## Non-Goals
- No social accounts/integrations beyond the share sheet.

## Capabilities
### New Capabilities
- `shareable-cards`: generate and share a branded workout/week summary image.
### Modified Capabilities
<!-- none -->

## Impact
- `App`: a card view + `ImageRenderer` + `ShareLink`. Reuses design system + `ActivityAggregator`. **Roadmap (Round 2).**
