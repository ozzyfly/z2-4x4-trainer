## Summary

完成全 App 主要畫面與 SharedCore 來源字串的本地化，補齊 `localization`/`localization-coverage` 後仍英文的約 80 個使用者可見字串。

## Motivation

3 個盤點 agent 發現 Week/Settings/History/Achievements/StreakBanner/ShareCard/Onboarding/ManualEntry/WorkoutDetail/GuidedPlayer 仍有大量英文：多為 Category A（字面，只需 catalog 鍵即自動本地化）、部分 Category B（函式回傳/插值，需 `String(localized:)`）。另有 SharedCore 來源（Achievement 標題/說明、readiness recommendation）需以 package 本地化。

## Proposed Solution

- App 端：Category B 字串以 `String(localized:)` 包裝；Category A 字面維持原樣，靠 catalog 鍵自動本地化。
- 於 `App/Localizable.xcstrings` 為所有上述字串加 zh-Hant（translated）與 es/ja（needs_review），去重共用鍵。
- SharedCore：`Package.swift` 加 `defaultLocalization: "en"`、新增 package String Catalog，`Achievement` 與 `Readiness` recommendation 改 `String(localized:bundle: .module)`。
- 平行 agent 各負責不相交的畫面叢集（只改 .swift 的 B 字串並回傳 catalog 片段）；catalog 由中央單一寫入合併。

## Non-Goals

- 不做窮舉 plural variation 表（中文無複數；es/ja 從簡）。
- es/ja 維持草稿（needs_review），待母語審閱。
- 不做 ASC store metadata（帳號 blocker）、不做 RTL。

## Impact

- Affected specs: `localization`（MODIFIED：覆蓋率擴及全主要畫面與 SharedCore 來源字串）
- Affected code:
  - Modified:
    - App/Views/WeekView.swift
    - App/Views/SettingsView.swift
    - App/Views/HistoryView.swift
    - App/Views/AchievementsView.swift
    - App/Views/StreakBanner.swift
    - App/Views/ShareCard.swift
    - App/Views/OnboardingView.swift
    - App/Views/ManualEntryView.swift
    - App/Views/WorkoutDetailView.swift
    - App/Views/GuidedPlayerView.swift
    - App/Localizable.xcstrings
    - SharedCore/Package.swift
    - SharedCore/Sources/SharedCore/Achievement.swift
    - SharedCore/Sources/SharedCore/Readiness.swift
  - New:
    - SharedCore/Sources/SharedCore/Localizable.xcstrings
  - Removed: (none)
