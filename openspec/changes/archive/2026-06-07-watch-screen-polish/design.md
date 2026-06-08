## Context

watchOS 即時訓練畫面（`Watch/LiveWorkoutView.swift`、`Watch/WorkoutListView.swift`）round-2 未涵蓋。`shared-visual-tokens` 已把區間色/glyph 放入 `SharedCore`（watch 可 import）。本變更為 watch 畫面補無障礙與可用性，並小幅擴充 `WorkoutSessionManager` 曝露 session 起始時間以算經過時間。watchOS SDK 26.5 + simulator 已安裝，可編譯驗證。

## Goals / Non-Goals

**Goals:**

- VoiceOver 標籤（心率/區間/間歇/清單列）。
- Dynamic Type（心率、倒數改可縮放字級）。
- 區間 glyph（非色彩訊號）＋在區間指示。
- 跨區間觸覺。
- Zone 2 經過時間。

**Non-Goals:**

- 不改訓練/HealthKit 收集邏輯（除曝露 `startDate`）。
- 不改顏色值、SharedCore token、iOS、domain。
- 不做 complication。

## Decisions

- **採用 SharedCore token**：`HRZone.glyph` 加到 `zoneLabel`；膠囊色塊 `accessibilityHidden(true)`，狀態由 glyph＋名稱表達。
- **Dynamic Type**：心率 `.system(size:56…)` 改 `.system(.largeTitle, design:.rounded).weight(.bold)`；倒數 `.system(size:28…)` 改 `.system(.title, design:.rounded).weight(.heavy)`；保留 `monospacedDigit()`。
- **在區間指示**：依 `manager.targetRange?.contains(manager.currentHR)` 顯示 `checkmark.circle.fill`（在區間）/`exclamationmark.circle.fill`（偏離），附 VoiceOver 標籤；targetRange 為 nil 時不顯示。
- **觸覺**：`LiveWorkoutView` 加 `.onChange(of: manager.currentZone)`，新舊不同且新非 nil 時 `WKInterfaceDevice.current().play(.notification)`。
- **經過時間**：`WorkoutSessionManager` 新增 `@MainActor private(set) var startDate: Date?`，於 `start(kind:)` 設定；view 以 `TimelineView(.periodic(from:…, by:1))` 或 1 秒 timer 顯示 `mm:ss`，僅非結構化（Zone 2）顯示。

## Implementation Contract

**Behavior（可觀察）：**

- VoiceOver 聚焦心率念「Heart rate, N beats per minute」；聚焦 zoneLabel 念區間名；聚焦 interval banner 念 kind＋倒數；清單列念 workout 名。
- 大 watch 字級下心率與倒數不裁切。
- zoneLabel 顯示 `HRZone.glyph`＋名稱，色塊 decorative。
- 在區間時顯示 check glyph、偏離時 exclamation glyph，並對 VoiceOver 曝露「In zone」/「Out of zone」；無 targetRange 時不顯示。
- session 中 `currentZone` 改變即播 `.notification` 觸覺。
- Zone 2 session 顯示 `mm:ss` 經過時間並每秒更新；4×4 不顯示（其用間歇倒數）。

**Interface / 形狀：**

- `WorkoutSessionManager` 新增 `@MainActor private(set) var startDate: Date?`，於 `start(kind:)` 內設為 session 起始 `Date()`（與 `session.startActivity`/`beginCollection` 同一時間）。
- `Watch/LiveWorkoutView.swift`、`Watch/WorkoutListView.swift` 僅調整呈現與無障礙修飾。

**Failure modes：**

- `startDate` 為 nil（尚未 start）→ 不顯示經過時間，不崩潰。
- `WKInterfaceDevice` 僅 watchOS 可用 → 觸覺呼叫在 watch target 內，無需條件編譯（檔案僅編進 watch）。

**Acceptance criteria：**

- `xcodebuild` 編譯 watch target（`Z24x4TrainerWatch` scheme、watchOS 26.5 simulator）成功。
- iOS target 仍編譯成功；`SharedCore` 測試仍綠（未動 domain）。
- 以 watch simulator + Accessibility Inspector 驗證 VoiceOver 標籤、Dynamic Type 不裁切、zone glyph、在區間指示、Zone 2 經過時間；以模擬區間變化確認觸覺呼叫路徑（模擬器無實體觸覺，確認程式路徑與不崩潰）。

**Scope boundaries：**

- In scope：三個 `Watch/*` 檔的呈現/無障礙修改；`WorkoutSessionManager` 曝露 `startDate`。
- Out of scope：HK 收集邏輯、顏色值、SharedCore、iOS、complication。

## Risks / Trade-offs

- **模擬器無法驗證實體觸覺**：只能確認程式路徑與不崩潰；實機觸覺須使用者驗證。
- **每秒更新經過時間**：以 `TimelineView(.periodic)` 限縮在 Zone 2 畫面，耗能可忽略。
