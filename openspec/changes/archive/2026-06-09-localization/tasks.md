## 1. 本地化基礎

- [x] 1.1 滿足需求「Section headers are localizable」：在 `App/DesignSystem/Components.swift` 將 `SectionHeader.init(_ title: String)` 改為 `init(_ title: LocalizedStringKey)`、儲存 `LocalizedStringKey` 並以 `Text(title)` 顯示（走本地化多載）；確認既有 `SectionHeader("…")` 呼叫端（傳字面）免改仍編譯。
- [x] 1.2 滿足需求「String Catalog drives UI localization」：新增 `App/Localizable.xcstrings`（合法 String Catalog，`sourceLanguage: en`），收錄核心 chrome 字串（5 個 tab 標籤、各畫面 `navigationTitle`、主要按鈕如 Start workout/Log a workout/Get started/Connect Apple Health/Start guided session/End、主要 section header 如 Readiness/Your coach/Today's session/Your zones/Daily target/This week's plan/Weekly target/Badges/Profile/Heart rate/Zones/Goal/Reminders/Apple Health）。

## 2. 翻譯

- [x] 2.1 滿足需求「Traditional Chinese is provided」：於 `Localizable.xcstrings` 為第 1.2 節所有核心字串加 `zh-Hant` 翻譯，`state: translated`。
- [x] 2.2 滿足需求「Additional languages registered with safe fallback」：於 `Localizable.xcstrings` 為同一組字串加 `es` 與 `ja` 翻譯，`state: needs_review`（草稿，待母語審閱）。

## 3. 註冊與驗證

- [x] 3.1 確保 app 支援 en/zh-Hant/es/ja：必要時於 `project.yml` 的 `Z24x4Trainer` 設 `INFOPLIST_KEY_CFBundleLocalizations` 列出四語言；`xcodegen generate` 後以 `xcodebuild` 編譯 iOS 成功、`SharedCore` 測試仍綠。
- [x] 3.2 滿足需求「zh-Hant shows translated chrome」與「Missing translation falls back」：於 iOS simulator 以 `-AppleLanguages "(zh-Hant)"` 啟動，截圖確認 tab/標題/主要按鈕/section header 顯示繁中；以預設英文啟動確認 UI 不變、未翻譯字串回退英文。
