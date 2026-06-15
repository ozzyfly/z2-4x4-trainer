## Problem

`l10n-gap-fill` 完成 App target 全量在地化（zh-Hant/es/ja，0 needs_review），但 Widgets 與 WatchComplications 兩個 app-extension target 的使用者可見字串仍為英文。兩個 extension 各有自己的 bundle，App/Localizable.xcstrings 不會涵蓋它們。實際缺口分兩類：(1) `Text("Streak")`、`configurationDisplayName("Readiness")` 等字面值對應的是 extension bundle，但 extension 沒有 Localizable.xcstrings，所以查無翻譯顯示英文；(2) `widgetTitle`/`title`/`recommendation` 等 `String`-回傳輔助函式（如 Widgets 的 `SessionType.widgetTitle` 回 "Zone 2"）被 `Text(_:)` 直接顯示——`Text(String)` 不查表，即使有 catalog 也照樣英文。

## Root Cause

- 兩個 extension target 在 project.yml 沒有納入任何 String Catalog 資源，且 `knownRegions` 雖在 project 層宣告，extension 內無 .xcstrings 可供查表。
- Widget/complication 內多個顯示名走 `String`-回傳 switch（widgetTitle、complication 的 title/recommendation），以 `Text(helperResult)` 呈現，繞過 catalog（與 l10n-gap-fill 在 App 端修正的 `Text(String)` 問題同源）。

## Proposed Solution

- 新增 `Widgets/Localizable.xcstrings` 與 `WatchComplications/Localizable.xcstrings`，各含該 extension 的使用者可見字串，翻譯 zh-Hant/es/ja（沿用 App catalog 既有術語：Zone 2→Zona 2／ゾーン2、4×4、Readiness→Preparación／コンディション、streak→racha／連続）。在 project.yml 將兩檔加入對應 target 的 sources。
- extension 內 `String`-回傳顯示名輔助函式改以 `String(localized:)` 回傳（widgetTitle、complication title、readiness recommendation/title）；含數字者（如 "%lld-week streak"、"Readiness %lld"）改走 catalog 並比照 App 端加 es 複數。
- `configurationDisplayName`/`.description`（型別本即 `LocalizedStringKey`）字面值保持不變即會查 extension catalog；確認對應 key 都在新 catalog。
- 不改 App/SharedCore catalog；不改 widget 視覺/版面；不改 SharedCore 的 HRZone+UI displayName（屬 App 在地化層，extension 自帶 catalog）。

## Non-Goals

- 不在 SharedCore 放這些 UI 字串（維持 App-/extension-層在地化的既有分工）。
- 不調整 widget/complication 的版面、字級或視覺 token。
- 不處理實機 widget gallery 截圖驗證（模擬器 widget 預覽即可）。
- 不新增語系（維持 en/zh-Hant/es/ja）。

## Success Criteria

- 模擬器以 -AppleLanguages "(es)" 與 "(ja)" 加入 widget：Today&Week／Streak／Readiness widget 的標題、placeholder（No streak yet／No score yet／Rest day）、數值單位（min）與 configurationDisplayName/description 皆顯示對應語言。
- watch complications 同樣以 es/ja 顯示 Next session／Readiness／Streak 文案與 widgetLabel。
- 三個 catalog（App、SharedCore、兩個 extension）皆 0 needs_review；`xcodebuild` iOS scheme 與 watch scheme build 皆綠。

## Impact

- Affected specs: `localization`（modified）
- Affected code:
  - New: Widgets/Localizable.xcstrings, WatchComplications/Localizable.xcstrings
  - Modified: Widgets/Z24x4Widgets.swift, WatchComplications/Z24x4WatchComplications.swift, project.yml
  - Removed: (none)
