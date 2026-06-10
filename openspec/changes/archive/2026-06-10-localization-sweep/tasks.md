## 1. App 畫面叢集（平行 agent，只改 .swift 的 Category B、回傳 catalog 片段）

- [x] 1.1 滿足情境「Remaining App screens localize」：`App/Views/WeekView.swift`、`App/Views/SettingsView.swift` 的 Category B 字串包 `String(localized:)`（多為 Category A 字面，免改），回傳全部 A+B 鍵與 zh-Hant/es/ja 草譯。
- [x] 1.2 `App/Views/HistoryView.swift`、`App/Views/AchievementsView.swift`、`App/Views/StreakBanner.swift`、`App/Views/ShareCard.swift` 的 Category B（streak 插值、ShareCard 複數、`textSummary`）包 `String(localized:)`，回傳鍵與草譯。
- [x] 1.3 `App/Views/OnboardingView.swift`、`App/Views/ManualEntryView.swift`、`App/Views/WorkoutDetailView.swift`、`App/Views/GuidedPlayerView.swift` 的 Category B（`rangeText`、duration、"Next: …"）包 `String(localized:)`，回傳鍵與草譯。

## 2. SharedCore 本地化

- [x] 2.1 滿足情境「SharedCore strings localize」：`SharedCore/Package.swift` 加 `defaultLocalization: "en"`；新增 `SharedCore/Sources/SharedCore/Localizable.xcstrings`；`SharedCore/Sources/SharedCore/Achievement.swift` 標題/說明與 `SharedCore/Sources/SharedCore/Readiness.swift` 的 recommendation 改 `String(localized:bundle: .module)`，catalog 含 zh-Hant/es/ja。

## 3. 中央合併（單一寫入）

- [x] 3.1 滿足需求「Function-produced and SharedCore strings localize」：將各 agent 回傳片段合併進 `App/Localizable.xcstrings`，去重共用鍵（如 Weight (kg)、Rate、Activity），審定 zh-Hant、es/ja 維持 `needs_review`。

## 4. 驗證

- [x] 4.1 `xcodebuild` 編譯 iOS（`Z24x4Trainer`）成功；`cd SharedCore && swift test` 仍綠（含 package 本地化資源）。
- [x] 4.2 滿足情境「Untranslated falls back」與「Remaining App screens localize」：模擬器以 `-AppleLanguages "(zh-Hant)"` 啟動，截圖 Week/Settings/History/Onboarding/Achievements 確認繁中；預設英文不變、缺譯回退英文不崩潰。
