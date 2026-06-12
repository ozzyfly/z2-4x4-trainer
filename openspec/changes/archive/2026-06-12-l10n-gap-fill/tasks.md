# Tasks

## 1. 元件與顯示名

- [x] 1.1 App/DesignSystem/AccessibleControls.swift：`AccessibleStepper.title` 型別由 `String` 改為 `LocalizedStringKey`（呼叫端字面值不需改）；a11y label 若以 title 組字串，改用對應的本地化值。App/Localizable.xcstrings 補「Age」key（zh-Hant：年齡；es：Edad；ja：年齢）。完成條件：iOS build 綠；-AppleLanguages "(ja)" 啟動 Settings，Age 列顯示「年齢」（驗證需求：Runtime string-catalog lookup for dynamic UI text / Stepper titles localize）。
- [x] 1.2 App/Views/TodayView.swift 既有 `SessionType.displayName` 擴充旁新增 `ActivityLevel.displayName`（五 case 走 String(localized:)：Sedentary／Light／Moderate／Active／Very active）；App/Views/SettingsView.swift 與 App/Views/OnboardingView.swift 的活動量 Picker 改用 displayName。catalog 補五 key（zh-Hant：久坐／輕度／中等／活躍／非常活躍；es：Sedentario／Ligero／Moderado／Activo／Muy activo；ja：座りがち／軽い／中程度／活発／非常に活発）。完成條件：iOS build 綠；es 啟動 Settings 活動量選單顯示西文（驗證需求：Activity levels show display names）。

## 2. History 圖表

- [x] 2.1 App/Views/HistoryView.swift：`weekdayLabels` 改由 `Calendar.current.shortWeekdaySymbols` 取得並重排為週一起始（保持 DayMinutes id 0=Mon 對應不變）；「Minutes per day」、VO2 caption「VO2 max (ml·kg⁻¹·min⁻¹)」、「Latest %@」與 trend a11y 摘要（improved/declined）改走 String(localized:) 並補 key 與 zh-Hant/es/ja 翻譯。完成條件：iOS build 綠；es 啟動 History 圖表 caption 與星期縮寫為西文（驗證需求：Chart text localizes）。

## 3. Today 與複數

- [x] 3.1 App/Views/TodayView.swift：`ZoneChip(title:)` 兩處改 `String(localized: "Zone 2")`／`String(localized: "4×4 hard")`；catalog 補「4×4 hard」key（zh-Hant：4×4 高強度；es：4×4 intenso；ja：4×4 ハード）。完成條件：es 啟動 Today 區間 chip 顯示「Zona 2」「4×4 intenso」（驗證需求：Zone chips localize）。
- [x] 3.2 App/Localizable.xcstrings：「%lld-week streak」加 plural variations — en one「1-week streak」／other「%lld-week streak」；es one「Racha de 1 semana」／other「Racha de %lld semanas」（zh-Hant/ja 無複數區分、維持單一字串）。完成條件：規格 Example 表三列成立 — es 1→「Racha de 1 semana」、es 3→「Racha de 3 semanas」、en 1→「1-week streak」；以 -AppleLanguages "(es)" 啟動（streak 為 1 的種子資料）截圖驗證（驗證需求：Plural-aware streak strings / Spanish singular streak）。

## 4. 驗證

- [x] 4.1 兩個 String Catalog 仍 0 needs_review（沿用既有 audit 腳本檢查）；`xcodebuild` iOS scheme build 綠；-AppleLanguages "(es)" 與 "(ja)" 各截圖 Settings（Age/活動量）、History（caption/星期）、Today（ZoneChip、streak 卡）確認全部本地化。結果記入 PROGRESS.md。
