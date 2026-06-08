## Summary

修掉 UX 稽核發現的可用性與首次體驗摩擦：表單驗證、空狀態行動呼籲、互動回饋一致性、onboarding 的「為何詢問」說明與條件欄位動效，並採用 `design-system-a11y` 的 `SecondaryButton`。

## Motivation

UX 稽核（4 個 agent）發現一批可用性缺口，與無障礙、設計系統基礎分離以便平行化：

- Onboarding 體重/身高若被清空可存成 0；無欄位用途說明；減重速率欄位瞬間出現無動效；標題術語重（"Zone 2"/"Norwegian 4×4"）。
- ManualEntry 能量欄位接受非數字並靜默存為「無能量」；按鈕字「Save」與標題「Log workout」不一致；日期可選未來。
- Today/Week/WorkoutDetail 的休息日卡看似可點實則不可，破壞心智模型。
- History 與 StreakBanner 空狀態無可點的行動呼籲。
- Settings 的 Karvonen「需要靜息心率」警語被弱化、易忽略；減重 rate 欄位瞬間出現；Apple Health「已連線」未列同步範圍。
- 主要/次要動作視覺階層不清（次要動作用 NavigationLink + Card 拼湊）；`PrimaryButton` 按壓回饋偏弱。

本變更改善可用性與首次體驗，依賴 `design-system-a11y` 的 `SecondaryButton`。

## Proposed Solution

- **Onboarding**：當體重或身高 ≤0 時停用「Get started」；新增一段「為何詢問」說明卡（用於計算個人心率區間）；以動效顯示/隱藏減重速率欄位；標題副文以效益導向改寫、保留方法名。
- **ManualEntry**：能量欄位即時過濾為數字；placeholder 改為更清楚的可選說明；按鈕字改與意圖一致；`DatePicker` 限制為過去日期並加 hint。
- **休息日卡一致性**：Today/Week/WorkoutDetail 的休息日卡以非互動外觀（去除可點暗示）或提供明確「休息日說明」目的地，使可點與不可點一致。
- **空狀態 CTA**：History 與 StreakBanner 空狀態提供可點按鈕（記錄訓練／連結 Health）。
- **Settings**：Karvonen 警語升級為顯眼樣式（醒目色 + 權重）；減重 rate 欄位以動效出現；Apple Health「已連線」下列出同步資料項目。
- **互動一致性**：Today「Log a workout」等次要動作改用 `SecondaryButton`；`PrimaryButton` 按壓改 spring + 加 `.sensoryFeedback`（於 `design-system-a11y` 已含 haptic 則沿用）。

## Non-Goals

- 不改無障礙基礎或 design-system 元件實作（屬 `design-system-a11y` 與 `accessibility-pass`）。
- 不改 `SharedCore/`、HealthKit、persistence 邏輯（只調 UI 層的驗證與呈現）。
- 不新增畫面或功能、不改導覽結構。

## Alternatives Considered

- **與 `accessibility-pass` 合併**：被否決——兩者目標不同（WCAG 正確性 vs 可用性流暢度），分開可平行、可分批驗收。
- **不做表單驗證、僅提示**：被否決——靜默存無效資料是 #1 可用性風險，需以停用送出/即時過濾阻擋。

## Impact

- Affected specs: `usability`（NEW）
- Affected code:
  - Modified:
    - App/Views/OnboardingView.swift
    - App/Views/ManualEntryView.swift
    - App/Views/TodayView.swift
    - App/Views/WeekView.swift
    - App/Views/WorkoutDetailView.swift
    - App/Views/HistoryView.swift
    - App/Views/StreakBanner.swift
    - App/Views/SettingsView.swift
  - New: (none)
  - Removed: (none)
