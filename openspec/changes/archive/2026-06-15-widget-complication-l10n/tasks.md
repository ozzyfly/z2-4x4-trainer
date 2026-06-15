# Tasks

## 1. Widgets extension

- [x] 1.1 WatchComplications/Z24x4Widgets.swift 的 `String`-回傳顯示輔助（`SessionType.widgetTitle`、`ReadinessLabel.widgetTitle`）改以 `String(localized:)` 回傳；以 `Text(_:)` 直接顯示的字面值（"This week"、"minutes"、"No streak yet"、"No score yet"、"Rest"、"Rest day"、"Today"）維持字面值（會查 extension catalog）。`Text("\(weeks)-week streak")`、`Text("\(value) · \(label.widgetTitle)")` 等插值維持，使其產生對應 catalog key。完成條件：iOS build 綠。（路徑註：檔案實為 Widgets/Z24x4Widgets.swift）（驗證需求：Helper-produced display text localizes）
- [x] 1.2 新增 Widgets/Localizable.xcstrings（sourceLanguage en），收錄 Widgets 全部使用者可見 key：configurationDisplayName/description（"Today & Week"／"Today's session and this week's progress."／"Streak"／"Your current weekly training streak."／"Readiness"／"Today's readiness score and recommendation."）、"Today"、"This week"、"minutes"、"min"、"Rest"、"Rest day"、"No streak yet"、"No score yet"、"%lld-week streak"（含 en/es 複數變體：en one「1-week streak」、es one「Racha de 1 semana」/other「Racha de %lld semanas」）、"Zone 2"、"Norwegian 4×4"、"Go hard"、"Steady"、"Take it easy"。每 key 補 zh-Hant/es/ja，沿用 App catalog 術語。project.yml 將該檔加入 Z24x4Widgets target 的 sources，執行 xcodegen generate。完成條件：iOS build 綠；catalog 0 needs_review（驗證需求：App extensions localize their own bundle strings / No needs-review entries remain）
- [x] 1.3 以 -AppleLanguages "(es)" 啟動含 widget 的模擬器（或 widget 預覽），確認 Today&Week／Streak／Readiness widget 標題、placeholder、單位顯示西文。完成條件：截圖顯示三 widget 西文（驗證需求：Widget strings localize）

## 2. WatchComplications extension

- [x] 2.1 WatchComplications/Z24x4WatchComplications.swift 的 `String`-回傳顯示輔助（session `title`、readiness `title`/`recommendation`、其餘以 switch 回 "Zone 2"/"Go hard" 等者）改以 `String(localized:)` 回傳；`widgetLabel`/`Text` 內含數字的插值（"\($0)-week streak"、"\($0) wk streak"、"Readiness \($0)"）維持插值以產生 catalog key。完成條件：watch build 綠。（驗證需求：Helper-produced display text localizes）
- [x] 2.2 新增 WatchComplications/Localizable.xcstrings（sourceLanguage en），收錄 complication 全部使用者可見 key：configurationDisplayName/description（"Next session"／"Your next Zone 2 or 4×4 session."／"Readiness"／"Today's readiness score synced from your iPhone."／"Streak"／"Your current weekly training streak."）、"Zone 2"、"Rest"、"Go hard"、"Steady"、"Take it easy"、"No streak yet"、"%lld-week streak"（en/es 複數同 1.2）、"%lld wk streak"、"Readiness %lld"、"Readiness —"。每 key 補 zh-Hant/es/ja。project.yml 將該檔加入 Z24x4WatchComplications target 的 sources，執行 xcodegen generate。完成條件：watch build 綠；catalog 0 needs_review（驗證需求：App extensions localize their own bundle strings / No needs-review entries remain）
- [x] 2.3 以 -AppleLanguages "(ja)" 在 watch 模擬器加入 complication（或預覽），確認 Next session／Readiness／Streak 文案與 widgetLabel 顯示日文。完成條件：截圖顯示日文（驗證需求：Complication strings localize）

## 3. 驗證

- [x] 3.1 四個 catalog（App、SharedCore、Widgets、WatchComplications）皆 0 needs_review（沿用既有 audit 腳本，擴充路徑清單）；`xcodebuild` iOS scheme build 與 watch scheme build 皆綠；es 複數規格 Example 三列成立（widget streak 1→「Racha de 1 semana」、3→「Racha de 3 semanas」、en 1→「1-week streak」）。結果記入 PROGRESS.md。
