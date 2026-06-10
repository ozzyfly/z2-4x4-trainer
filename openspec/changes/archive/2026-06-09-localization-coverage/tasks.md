## 1. App 字串改用 String(localized:)

- [x] 1.1 滿足情境「Function-produced strings localize」：在 `App/Views/TodayView.swift` 將 `readinessTitle`（Go hard/Steady/Take it easy）、`coachingTip`（三句）、`SessionType.displayName`（Zone 2/Norwegian 4×4/Rest）改用 `String(localized:)`。
- [x] 1.2 在 `App/Views/TodayView.swift` 將 `weekSummary` 改用 `String(localized:)` 並以插值帶入 zone2/hard 數與分鐘（catalog 以對應格式鍵收錄）。
- [x] 1.3 將「Recover well.」於 `App/Views/TodayView.swift` 與 `App/Views/WorkoutDetailView.swift` 確認為可本地化 `Text` 字面（已是 `Text("…")`，僅需 catalog 收錄）。

## 2. Catalog 翻譯

- [x] 2.1 滿足需求「String Catalog drives UI localization」：在 `App/Localizable.xcstrings` 為第 1 節所有字串（含 `weekSummary` 格式鍵與「Recover well.」）加 zh-Hant（`translated`）與 es/ja（`needs_review`）。

## 3. 驗證

- [x] 3.1 `xcodegen generate` 後 `xcodebuild` 編譯 iOS 成功；`SharedCore` 測試仍綠；以模擬器 `-AppleLanguages "(zh-Hant)"` 啟動 Today，確認 readiness 標題、coach 提示、本週摘要、休息日字幕、session 名稱顯示繁中（截圖）；英文預設不變。
