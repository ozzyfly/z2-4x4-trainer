## 1. Manager 曝露起始時間

- [x] 1.1 滿足需求「Elapsed time for open-ended sessions」（前置）：在 `Watch/WorkoutSessionManager.swift` 新增 `@MainActor private(set) var startDate: Date?`，於 `start(kind:)` 內設為 session 起始 `Date()`（與 `session.startActivity`/`beginCollection` 同一時間）。

## 2. LiveWorkoutView 無障礙與可用性

- [x] 2.1 滿足需求「Live screen exposes VoiceOver labels」：在 `Watch/LiveWorkoutView.swift` 為心率加 `accessibilityLabel("Heart rate")`＋`accessibilityValue("N beats per minute")`；為 zoneLabel 加區間名 label；為 IntervalBanner 加 kind＋倒數 label。
- [x] 2.2 滿足需求「Live screen supports Dynamic Type」：將心率 `.system(size:56…)` 改 `.system(.largeTitle, design:.rounded).weight(.bold)`、倒數 `.system(size:28…)` 改 `.system(.title, design:.rounded).weight(.heavy)`，保留 `monospacedDigit()`。
- [x] 2.3 滿足需求「Zone shown without color alone」：在 zoneLabel 以 `HStack` 加 `Image(systemName: zone.glyph)`（來自 SharedCore），色塊膠囊維持，整個 zoneLabel 對 VoiceOver 以區間名表達、glyph/色塊 `accessibilityHidden`。
- [x] 2.4 滿足需求「In-zone status feedback」：依 `manager.targetRange?.contains(manager.currentHR)` 顯示 `checkmark.circle.fill`（在區間）/`exclamationmark.circle.fill`（偏離），附 `accessibilityLabel`「In zone」/「Out of zone」；`targetRange` 為 nil 時不顯示。
- [x] 2.5 滿足需求「Zone-change haptic」：在 `LiveWorkoutView` 加 `.onChange(of: manager.currentZone)`，當新舊區間不同且新值非 nil 時呼叫 `WKInterfaceDevice.current().play(.notification)`（需 `import WatchKit`）。
- [x] 2.6 滿足需求「Elapsed time for open-ended sessions」：在非結構化（`kind.isStructured == false`）時，以 `TimelineView(.periodic(from:…, by:1))` 依 `manager.startDate` 顯示 `mm:ss` 經過時間；`startDate` 為 nil 時不顯示。

## 3. WorkoutListView 無障礙

- [x] 3.1 滿足需求「Live screen exposes VoiceOver labels」（清單列）：在 `Watch/WorkoutListView.swift` 的 `WorkoutRow` 加 `accessibilityElement(children: .ignore)`＋`accessibilityLabel("\(kind.title) workout")`，圖示 `accessibilityHidden(true)`。

## 4. 驗證

- [x] 4.1 以 `xcodebuild` 編譯 watch target（`Z24x4TrainerWatch` scheme、watchOS 26.5 simulator）成功；iOS target 仍成功；`SharedCore` 測試仍綠（58/58）。
- [x] 4.2 以 watch simulator/Accessibility Inspector 驗證：心率/區間/間歇/清單列 VoiceOver 標籤；大字級心率與倒數不裁切；zone glyph 顯示；在區間指示切換；Zone 2 顯示每秒更新的經過時間；確認 `onChange` 觸覺路徑不崩潰（模擬器無實體觸覺）。
