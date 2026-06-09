## Why

Users without an Apple Watch can't get the guided interval experience. An on-iPhone player makes
the full Zone 2 / 4×4 session usable for everyone.

## What Changes

- An iPhone **guided session player**: live countdown, interval progress, haptics on transitions,
  and spoken **audio cues** (AVSpeechSynthesizer) — driven by `Norwegian4x4.build`.

## Non-Goals
- No background GPS/pace. Audio-session handling kept simple.

## Capabilities
### New Capabilities
- `guided-player-audio`: a phone-based guided workout player with countdown, haptics, and voice cues.
### Modified Capabilities
<!-- none -->

## Impact
- `App`: a player view + a phone interval engine (mirror `Watch/IntervalEngine`), `AVSpeechSynthesizer`,
  `.sensoryFeedback`. Reuses `Norwegian4x4`, `HRZoneCalculator`. **Roadmap (Round 2).**
