## Why

watchOS 螢幕在 round-2 完全未涵蓋。稽核發現多項無障礙與可用性缺口：實時心率/區間/間歇皆無 VoiceOver 標籤；心率與倒數用固定 `.system(size:)` 字級、Large Text 會裁切；訓練區間僅以膠囊顏色表達（色盲不可辨）；無「是否在目標區間」回饋；跨區間無觸覺提示；Zone 2 開放式訓練無經過時間。`shared-visual-tokens` 已把區間色與 glyph 放進 `SharedCore`，watch 可直接採用。

## What Changes

- watch 即時畫面（`Watch/LiveWorkoutView.swift`）採用 `SharedCore` 的 `HRZone.glyph`，在區間膠囊加符號，使區間以形狀＋色彩表達。
- 為心率、區間、間歇 banner、訓練清單列加 VoiceOver `accessibilityLabel`/`accessibilityValue`。
- 將固定字級（心率 56pt、倒數 28pt）改為可隨 Dynamic Type 縮放的文字樣式。
- 新增「在區間/偏離」指示符號，依 `targetRange.contains(currentHR)` 切換。
- 跨區間時播放觸覺（`WKInterfaceDevice.play`）。
- Zone 2（非結構化）訓練顯示經過時間，需在 `WorkoutSessionManager` 曝露 session 起始時間。

## Non-Goals

- 不改 watch 的訓練/HealthKit 收集邏輯（`start`/`finishAndSave`/HK delegate 不動，除新增曝露 `startDate`）。
- 不改顏色值、不改 SharedCore token。
- 不改 iOS、domain、persistence。
- 不做手錶錶面 complication（屬另一史詩 `widgets-complication`）。

## Capabilities

### New Capabilities

- `watch-workout-ui`: watchOS 即時訓練畫面的無障礙與可用性需求（VoiceOver、Dynamic Type、非色彩區間訊號、在區間回饋、區間觸覺、Zone 2 經過時間）。

### Modified Capabilities

(none)

## Impact

- Affected specs: `watch-workout-ui`（NEW）
- Affected code:
  - Modified:
    - Watch/LiveWorkoutView.swift
    - Watch/WorkoutListView.swift
    - Watch/WorkoutSessionManager.swift
  - New: (none)
  - Removed: (none)
