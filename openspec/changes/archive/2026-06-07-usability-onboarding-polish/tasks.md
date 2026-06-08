## 1. Onboarding

- [x] 1.1 滿足需求「Onboarding input validation」：在 `App/Views/OnboardingView.swift` 對「Get started」加 `.disabled(weightKg <= 0 || heightCm <= 0)`，使體重或身高非正值時無法建檔；正值時可建檔；模擬器驗證清空體重→鈕灰。
- [x] 1.2 滿足需求「Onboarding explains why it asks」：在輸入欄位前新增簡短說明（指標用於計算個人心率區間）。
- [x] 1.3 滿足需求「Conditional fields animate」：將 `goalSection` 中減重速率欄位的顯示/隱藏包進 `withAnimation`/`.transition`，使其動效出現。
- [x] 1.4 將 header 副文以效益導向改寫（保留 Zone 2 / Norwegian 4×4 方法名），降低首次理解門檻。

## 2. Manual entry

- [x] 2.1 滿足需求「Manual entry rejects non-numeric energy」：在 `App/Views/ManualEntryView.swift` 為能量 TextField 加 `onChange` 過濾為數字；空值時 `save()` 維持以 `Int(energy)` 取得 nil（非 0）；`DatePicker` 加 `in: ...Date.now` 限制不可選未來；模擬器驗證打「abc」不留、無法選未來日。
- [x] 2.2 將能量 placeholder 改為更清楚的可選說明、按鈕字改與「記錄訓練」意圖一致。

## 3. 休息日卡一致性

- [x] 3.1 滿足需求「Rest-day cards do not imply interactivity」：在 `App/Views/TodayView.swift`、`App/Views/WeekView.swift`、`App/Views/WorkoutDetailView.swift` 將休息日卡改為非互動外觀（移除 chevron 等可點暗示），使外觀與其無導覽行為一致。

## 4. 空狀態 CTA

- [x] 4.1 滿足需求「Empty states offer an action」：在 `App/Views/HistoryView.swift` 空狀態加可點 CTA（記錄訓練／連結 Apple Health，導向既有動作）；在 `App/Views/StreakBanner.swift` 無連續時加可點「記錄訓練」CTA。

## 5. Settings

- [x] 5.1 滿足需求「Required-setting warnings are prominent」：在 `App/Views/SettingsView.swift` 將 Karvonen「需要靜息心率」警語升級為 `Theme.warning` 顯眼樣式（醒目色 + `.subheadline` 權重）。
- [x] 5.2 滿足需求「Connected Health shows sync scope」：在 Apple Health「已連線」下以靜態文字列出同步類別（Workouts、Active energy、Heart rate、VO2 max、Body weight）。
- [x] 5.3 將 Settings 中減重 rate 條件欄位包進 `withAnimation`/`.transition`（同 1.3 模式），使其動效出現。

## 6. 互動一致性

- [x] 6.1 滿足需求「Action hierarchy is clear」：在 `App/Views/TodayView.swift` 將「Log a workout」等次要動作改用 `design-system-a11y` 的 `SecondaryButton`，與主要「Start workout」形成清楚階層。

## 7. 驗證

- [x] 7.1 以 `xcodebuild` 編譯 iOS target 成功；`SharedCore` 測試仍綠；逐項以模擬器驗證第 1–6 節可觀察行為；確認未改 domain/persistence/HealthKit 邏輯與導覽結構。
