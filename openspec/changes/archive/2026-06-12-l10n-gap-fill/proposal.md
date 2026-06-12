## Problem

es/ja 已全數標為 translated（ux-polish 完成），但模擬器抽查仍看到多處英文：Settings/Onboarding 的「Age」「Max HR」「Resting HR」「Rate」原文直出、活動量選單顯示 raw value（moderate 等）、History 圖表的「Minutes per day」「Latest …」與星期縮寫（Mon–Sun）寫死、Today 的 ZoneChip 標題（Zone 2、4×4 hard）未經 catalog，且 es 出現「Racha de 1 semanas」單複數錯誤。

## Root Cause

- App/DesignSystem/AccessibleControls.swift 的 `AccessibleStepper.title` 型別為 `String`，`Text(title)` 對變數不做 catalog 查表，即使 key 已存在也不會翻譯。
- `ActivityLevel` 沒有 display name，App/Views/SettingsView.swift 與 App/Views/OnboardingView.swift 直接顯示 `rawValue`。
- App/Views/HistoryView.swift 的 `weekdayLabels` 是寫死的英文陣列；`chartCaption("Minutes per day")`、VO2 caption 與「Latest …」摘要走 `String` 參數，不會查表。
- App/Views/TodayView.swift 的 `ZoneChip(title:)` 傳英文字面值。
- App/Localizable.xcstrings 的 `%lld-week streak` 等含數字 key 沒有 plural variation，es 的 1 仍套複數字串。

## Proposed Solution

- `AccessibleStepper.title` 改型別為 `LocalizedStringKey`（呼叫端字面值維持不變即自動查表）；補「Age」等缺漏 key 與 zh-Hant/es/ja 翻譯。
- 在 App 層（App/Views/SettingsView.swift 旁的共用處，比照 `SessionType.displayName`）新增 `ActivityLevel.displayName`，五個 case 走 `String(localized:)`；兩個 picker 改用它；補五個 key 與翻譯。
- HistoryView：星期縮寫改用 `Calendar.current.shortWeekdaySymbols` 重排為週一起始（免 catalog）；「Minutes per day」、VO2 caption、「Latest %@」與 a11y 摘要改走 `String(localized:)` 並補 key。
- TodayView：ZoneChip 標題改 `String(localized: "Zone 2")` / `String(localized: "4×4 hard")`，補「4×4 hard」key（「Zone 2」key 已存在）。
- App/Localizable.xcstrings：`%lld-week streak` 的 es 加 plural variation（one：Racha de 1 semana；other：Racha de %lld semanas）；en 加 one：1-week streak（既有行為不變）。

## Non-Goals

- 不重排或重審既有 es/ja 全量譯文（ux-polish 已完成審閱）。
- 不處理 Watch 端與 widget 端字串（已各自走 catalog）。
- 不引入第三方 l10n 工具或改變 String Catalog 工作流程。
- 不把 `ActivityLevel.displayName` 放進 SharedCore（SharedCore catalog 僅存領域字串；UI 顯示名留在 App 層，比照 `SessionType.displayName`）。

## Success Criteria

- 模擬器以 -AppleLanguages "(es)" 與 "(ja)" 啟動：Settings 的 Age/Max HR/Rate 列、活動量選單、History 圖表 caption 與星期縮寫、Today ZoneChip 全部顯示對應語言。
- es 的 streak 卡在 1 週時顯示「Racha de 1 semana」。
- 兩個 String Catalog 仍為 0 needs_review；`xcodebuild` iOS scheme build 綠。

## Impact

- Affected specs: `localization`（modified）
- Affected code:
  - Modified: App/DesignSystem/AccessibleControls.swift, App/Views/SettingsView.swift, App/Views/OnboardingView.swift, App/Views/HistoryView.swift, App/Views/TodayView.swift, App/Localizable.xcstrings
  - New: (none)
  - Removed: (none)
