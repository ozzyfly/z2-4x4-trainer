## Context

App 目前全英文。提案要採 String Catalog、抽出 UI 字串、提供 zh-Hant/es/ja 翻譯（含 App Store listing）。SwiftUI 的 `Text("字面")`、`Label("字面", systemImage:)`、`.navigationTitle("字面")` 走 `LocalizedStringKey` 多載，建置時可自 String Catalog 自動本地化；但 `SectionHeader(_ title: String)` 內部以 `Text(title: String)` 顯示，走 `String` 多載、不會本地化。約 39 個 `Text` 字面外加 tab/title/section header。

## Goals / Non-Goals

**Goals:**

- 建立 String Catalog（`App/Localizable.xcstrings`，source `en`），讓核心可見介面（tab、畫面標題、主要動作、section header）可本地化。
- 提供 zh-Hant 完整翻譯（開發者母語、最高價值）；es/ja 提供草稿並標 `needs_review`。
- 以 `-AppleLanguages` 切換語言驗證生效。

**Non-Goals:**

- 不在本輪做窮舉式每一字串 × 3 語言的人工翻譯（基礎建好後可增量補；es/ja 需母語審閱）。
- 不做 RTL；日期/數字沿用系統 locale 格式。
- 不做 App Store Connect listing 本地化（需 Apple 帳號，屬已知 blocker）。

## Decisions

- **`SectionHeader` 改吃 `LocalizedStringKey`**：`init(_ title: LocalizedStringKey)`，內部 `Text(title)` 即走本地化多載；呼叫端傳字面自動成 key，免改。
- **String Catalog 直接編寫**：`App/Localizable.xcstrings`（JSON），收錄核心 chrome 字串；zh-Hant `state: translated`、es/ja `state: needs_review`（誠實標示待審）。
- **語言註冊**：catalog 內含的語言於建置時編入；以 `-AppleLanguages "(zh-Hant)"` 啟動引數驗證。必要時於 app target 設 `INFOPLIST_KEY_CFBundleLocalizations` 列出 en/zh-Hant/es/ja。
- **動態資料字串**（如 `SessionType.displayName`、zone 名）暫不在本輪本地化（屬 SharedCore，且多為專有名詞 Zone 2 / Norwegian 4×4）；列為增量。

## Implementation Contract

**Behavior（可觀察）：**

- 以 `-AppleLanguages "(zh-Hant)"` 啟動，tab 列、各畫面標題、主要按鈕、section header 顯示繁體中文（如 Today→今天、Settings→設定、Start workout→開始訓練）。
- 英文（預設）與 es/ja 啟動時，未翻譯字串回退英文來源、不崩潰。
- `Localizable.xcstrings` 為合法 String Catalog，建置時編譯成各語言。

**Interface / 形狀：**

- 新檔 `App/Localizable.xcstrings`：`sourceLanguage en`，核心 chrome 字串 + zh-Hant/es/ja localizations。
- `App/DesignSystem/Components.swift`：`SectionHeader` 簽章改 `LocalizedStringKey`。
- 受影響呼叫端：所有 `SectionHeader("…")`（傳字面，免改）。

**Failure modes：**

- 缺翻譯 → 回退英文 source；不崩潰。
- catalog JSON 格式錯 → 建置失敗即現；以合法格式避免。

**Acceptance criteria：**

- `xcodebuild` 編譯 iOS（`Z24x4Trainer`）成功；`SharedCore` 測試仍綠。
- 模擬器以 `-AppleLanguages "(zh-Hant)"` 啟動，Today/Settings 等核心 chrome 顯示中文（截圖驗證）。
- 預設英文啟動 UI 不變。

**Scope boundaries：**

- In scope：String Catalog 核心 chrome 字串 + zh-Hant 完整 / es-ja 草稿；`SectionHeader` 本地化；語言註冊與驗證。
- Out of scope：窮舉全字串、SharedCore 動態字串、ASC store metadata、RTL。

## Risks / Trade-offs

- **es/ja 由我提供草稿**：標 `needs_review`，需母語審閱；不宣稱完成品質。
- **本輪只涵蓋核心 chrome**：完整覆蓋為增量；基礎（catalog + LocalizedStringKey）就位後補譯成本低。
