## Summary

讓所有 iOS 畫面採用 `design-system-a11y` 的無障礙基礎，消除 UX 稽核發現的具體無障礙缺陷（Reduce Motion、Stepper 語意、僅靠色彩的狀態、圖表 VoiceOver、表單欄位標籤、Dynamic Type、命中區）。

## Motivation

UX 稽核（4 個 agent，橫跨全部畫面）發現一批可驗證的無障礙缺陷，全部屬「畫面採用基礎元件」層級，與 `design-system-a11y`（基礎）分離以便平行化：

- 慶祝動畫不檢查 Reduce Motion，違反 WCAG 與 Apple 指南。
- Settings/Onboarding 的 Stepper 念成混在一句、無 hint。
- readiness、History 趨勢、HR 區間僅以色彩表達狀態，色盲/低視力無法辨別。
- History 圖表對 VoiceOver 不可讀。
- Onboarding/ManualEntry 的體重/身高/能量 TextField 缺 accessibilityLabel。
- 固定寬度/高度（WeekView 星期欄、圖表）在大字級下裁切。
- 部分命中區 <44pt（TargetBar 勾、徽章格）。
- 鎖定徽章狀態靠 opacity 疊色，辨識度差。

本變更只改呈現與無障礙屬性，不改資料、流程、導覽。依賴 `design-system-a11y` 已提供的 token 與元件。

## Proposed Solution

依畫面採用基礎：

- **Celebration**：以 motion helper 包裝 `ConfettiBurst` 與淡出動畫，Reduce Motion 開啟時即時切換、不播動畫。
- **Settings、Onboarding**：以 `AccessibleStepper` 取代手刻 Stepper。
- **狀態色 + 符號**：readiness 改用 `Theme` 狀態 token 並加 glyph/文字；History 趨勢加 ▲▼ 與 +/− 號；zone chip 在 label 補區間文字（色塊標 `accessibilityHidden`）。
- **History 圖表**：為 Swift Charts 加 `accessibilityLabel`/`accessibilityValue`（或可讀的數值摘要），使 VoiceOver 可逐日讀出分鐘數。
- **表單欄位**：為體重/身高/能量 TextField 與日期 picker 加 `accessibilityLabel`/`accessibilityHint`。
- **Dynamic Type**：移除 WeekView 星期欄固定寬度（改自然排版 + `minimumScaleFactor`）；History 圖表高度隨字級縮放（下限/上限）。
- **命中區 ≥44pt**：TargetBar 完成勾、AchievementsView 徽章格以 `contentShape` + `minHeight`。
- **鎖定徽章**：移除過度 opacity 疊色，靠鎖頭 glyph + 對比達標表達鎖定。

## Non-Goals

- 不改任何畫面的資料、流程或導覽（純無障礙/呈現）。
- 不新增 `design-system` 元件或 token（屬 `design-system-a11y`）。
- 不做可用性/onboarding 內容改版（屬 `usability-onboarding-polish`）。
- 不改 `SharedCore/`、HealthKit、persistence。

## Alternatives Considered

- **與基礎合併成一個大變更**：被否決——難平行化、難 review。
- **僅修高嚴重項**：被否決——同類缺陷散落多畫面，分批會留不一致殘缺。

## Impact

- Affected specs: `design-system`（MODIFIED：強化 Accessibility 需求，新增各畫面採用情境）
- Affected code:
  - Modified:
    - App/Views/Celebration.swift
    - App/Views/TodayView.swift
    - App/Views/HistoryView.swift
    - App/Views/SettingsView.swift
    - App/Views/OnboardingView.swift
    - App/Views/ManualEntryView.swift
    - App/Views/WeekView.swift
    - App/Views/AchievementsView.swift
    - App/DesignSystem/Components.swift
  - New: (none)
  - Removed: (none)
