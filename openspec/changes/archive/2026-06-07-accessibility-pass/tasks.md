## 1. Reduce Motion

- [x] 1.1 滿足情境「Celebration respects Reduce Motion」：在 `App/Views/Celebration.swift` 以 `design-system-a11y` 的 motion helper 包裝 `ConfettiBurst` 與淡出動畫；Reduce Motion 開啟時直接到最終態、不播 confetti/動畫，關閉時照舊；以模擬器開關 Reduce Motion 各驗一次。

## 2. AccessibleStepper 採用

- [x] 2.1 滿足情境「Steppers announce label and value」：在 `App/Views/SettingsView.swift` 將年齡/最大心率/自訂區間上下限/減重速率等手刻 Stepper 換成 `AccessibleStepper`；以 Accessibility Inspector 確認念「<label>, <value>」並有加/減動作。
- [x] 2.2 在 `App/Views/OnboardingView.swift` 將年齡/減重速率 Stepper 換成 `AccessibleStepper`；同上驗證。

## 3. 狀態色 + 非色彩訊號

- [x] 3.1 滿足情境「Status is distinguishable without color」：在 `App/Views/TodayView.swift` 將 readiness 顏色改吃 `Theme` 狀態 token，並在指示加 glyph/文字表達狀態；色塊 `accessibilityHidden(true)`，狀態併入 VoiceOver label。
- [x] 3.2 在 `App/Views/HistoryView.swift` 將 fitness 趨勢 delta 改為「▲ +x.x」/「▼ −x.x」（正負號 + 三角 glyph）並吃 `success`/`danger` token；VoiceOver 念「improved by x.x」/「declined by x.x」。
- [x] 3.3 在 zone chip（`App/DesignSystem/Components.swift` 的 `ZoneChip` 或其採用處）的 accessibility label 補區間文字、色塊 `accessibilityHidden(true)`，使色盲可辨。

## 4. 圖表 VoiceOver

- [x] 4.1 滿足情境「History chart is readable by VoiceOver」：在 `App/Views/HistoryView.swift` 為週訓練分鐘 Swift Charts 加 `accessibilityLabel` 與逐日 `accessibilityValue` 摘要（有資料時），使 VoiceOver 念出每日分鐘；空狀態不套用。

## 5. 表單欄位 label

- [x] 5.1 滿足情境「Form fields are labelled」：在 `App/Views/OnboardingView.swift` 與 `App/Views/ManualEntryView.swift` 為體重/身高/能量 TextField 及日期 picker 加 `accessibilityLabel`（如「Weight in kilograms」）與必要 `accessibilityHint`。

## 6. Dynamic Type

- [x] 6.1 滿足情境「Large type and VoiceOver」：在 `App/Views/WeekView.swift` 移除星期欄固定 `width`，改自然排版 + `minimumScaleFactor(0.8)`；在 `App/Views/HistoryView.swift` 將圖表高度改隨字級縮放（`@ScaledMetric` 或字級比例，設下限/上限）；以 Dynamic Type XL + Larger Accessibility Fonts 確認不裁切/不重疊。

## 7. 命中區與鎖定態

- [x] 7.1 滿足情境「Tap targets meet minimum size」：在 `App/DesignSystem/Components.swift` 的 `TargetBar` 完成勾與 `App/Views/AchievementsView.swift` 徽章格以 `.frame(minHeight: 44)` + `.contentShape(Rectangle())` 將命中區擴至 ≥44pt（不改視覺尺寸）。
- [x] 7.2 滿足情境「Locked badges are distinguishable」：在 `App/Views/AchievementsView.swift` 移除鎖定卡過度 opacity 疊色，改以鎖頭 glyph（對比達標）表達鎖定；以對比工具確認鎖頭對背景 ≥4.5:1。

## 8. 驗證

- [x] 8.1 以 `xcodebuild` 編譯 iOS target 成功；`SharedCore` 測試仍綠；逐項以 Accessibility Inspector/模擬器驗證第 1–7 節的可觀察行為；確認未改任何畫面的資料、流程、導覽。
