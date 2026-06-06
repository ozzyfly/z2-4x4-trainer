# Tasks — ui-ux-refresh

## 1. 設計系統 (Requirement: Shared design system)

- [x] 1.1 建立 `App/DesignSystem/`：`Theme.swift`（adaptive 色彩 + AccentColor、間距/圓角/字級 tokens）、`ZoneStyle.swift`（HRZone→色/標籤）、元件 `Card`/`SectionHeader`/`TargetBar`/`PrimaryButton`/`ZoneChip`；於 `App/Assets.xcassets` 新增 AccentColor（light+dark）。
  行為：其他畫面可直接使用這些元件與色彩。驗證：`xcodebuild` 成功；TodayView 套用後於 sim 顯示卡片式樣式。

## 2. 重新設計畫面 (Requirement: Shared design system; Behavior preserved)

- [x] 2.1 `TodayView` 改為 hero 版面（日期標頭、session 卡片、zone chips、動畫每日 `TargetBar`、Start/Log CTA），行為不變。
  行為：Today 呈現卡片式 hero 且資料正確。驗證：`-seedProfile -seedWorkouts` 截圖 light+dark。
- [x] 2.2 `WeekView`（每日卡片、rest 日淡化、每週 `TargetBar`、hard chip）、`WorkoutDetailView`（說明卡片、4×4 間歇依 `IntervalKind` 上色）、`HistoryView`（圖表卡片、空狀態）。
  行為：三畫面卡片化、資料不變。驗證：各畫面截圖 light+dark。
- [x] 2.3 `OnboardingView`（歡迎標頭 + 卡片 + accent CTA）、`SettingsView`（分組卡片、Connect Health accent 按鈕/已連線徽章）、`ManualEntryView`（美化表單）、共用列 `SessionRow`/`ZoneRow`/`IntervalRow`、Watch 輕度美化沿用 `ZoneStyle`。
  行為：流程不變。驗證：Onboarding/Settings 截圖；watch target 仍可建置。

## 3. 動態與無障礙 (Requirement: Motion and haptics; Accessibility)

- [x] 3.1 動畫（`TargetBar` 填充、轉場）+ `.sensoryFeedback`（存訓練、連 Health、達標）；Dynamic Type 用系統字級、VoiceOver 標籤、雙模式對比。
  行為：達標/儲存有回饋；放大字級不破版。驗證：開大字級 + VoiceOver 巡覽主要畫面。

## 4. 整合與驗證 (Requirement: Correct in light and dark; Behavior preserved)

- [x] 4.1 整合所有變更，`xcodegen generate` + build；每畫面 light+dark 截圖；`swift test` 35 綠；watch build 綠；receiver 測試綠。
  行為：全 app 一致樣式且無回歸。驗證：對應 spec 場景「Light and dark both legible」「Flows still work after restyle」。
