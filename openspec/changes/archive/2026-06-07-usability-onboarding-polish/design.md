## Context

`design-system-a11y` 提供 `SecondaryButton` 與按壓動效/haptic。本變更採用它並修掉 UX 稽核發現的可用性與首次體驗摩擦。涉及 8 個畫面檔，純 UI 層（驗證、呈現、行動呼籲），不動 domain。前置：`design-system-a11y`（為了 `SecondaryButton`）。

## Goals / Non-Goals

**Goals:**

- 阻擋無效輸入（onboarding 體重/身高、manual entry 能量/未來日期）。
- 讓空狀態可行動、休息日卡 affordance 一致、必填警語顯眼、Health 顯示同步範圍。
- 次要動作統一用 `SecondaryButton`。
- onboarding 加用途說明、條件欄位動效、降術語。

**Non-Goals:**

- 不改無障礙基礎/設計系統元件實作。
- 不動 `SharedCore`、HealthKit、persistence 邏輯。
- 不新增畫面/功能、不改導覽結構。

## Decisions

- **驗證以停用送出 + 即時過濾達成**：onboarding 用 `disabled(weightKg <= 0 || heightCm <= 0)`；manual entry 能量以 `onChange` 過濾為 digits、`DatePicker(... in: ...Date.now)` 限制過去。
- **休息日卡**：採「非互動外觀」路線（移除 chevron/可點暗示），比新增「休息日說明」畫面更省、符合 Non-Goal（不新增畫面）。
- **空狀態 CTA**：History/StreakBanner 空狀態加 `SecondaryButton`（或 `PrimaryButton`）導向記錄/連結 Health 的既有動作。
- **Karvonen 警語**：升為 `Theme.warning` token + `.subheadline` 權重（token 由 `design-system-a11y` 提供）。
- **Health 同步範圍**：於「已連線」下以靜態文字列出類別（Workouts、Active energy、Heart rate、VO2 max、Body weight）。
- **動效**：條件欄位 `if` 包進 `withAnimation` 或加 `.transition`。

## Implementation Contract

**Behavior（可觀察）：**

- Onboarding：體重或身高 ≤0/空 → 「Get started」停用、不建檔；兩者皆正值 → 啟用、點擊建檔。畫面顯示一段用途說明；減重速率欄位以動效出現；標題副文以效益導向改寫（仍含 Zone 2 / 4×4 方法名）。
- ManualEntry：能量欄位只留數字；空 → `activeEnergyKcal` 存 nil（非 0）；日期 picker 無法選未來；按鈕字與「記錄訓練」意圖一致。
- 休息日卡（Today/Week/WorkoutDetail）：呈現為非互動（無 chevron/可點暗示），與其無導覽行為一致。
- History 無資料 → 顯示可點 CTA（記錄訓練／連結 Health）；StreakBanner 無連續 → 顯示可點「記錄訓練」CTA。
- Settings：選 Karvonen 但無靜息心率 → 警語以 `Theme.warning` 顯眼樣式；減重 rate 欄位動效出現；Apple Health 已連線 → 列出同步類別。
- Today「Log a workout」等次要動作 → 用 `SecondaryButton` 呈現。

**Interface / 形狀：**

- 不新增公開型別；`ManualEntryView.save()` 維持以 `Int(energy)` 取值（過濾後仍 nil-safe）。
- `DatePicker` 改帶 `in:` 範圍上界為當下。
- 受影響 View：`OnboardingView`、`ManualEntryView`、`TodayView`、`WeekView`、`WorkoutDetailView`、`HistoryView`、`StreakBanner`、`SettingsView`。

**Failure modes：**

- 使用者貼上非數字能量 → 過濾後留空或僅數字，不存無效值。
- 體重/身高欄位被清空 → 送出停用而非存 0；不崩潰。

**Acceptance criteria：**

- `xcodebuild` 編譯 iOS target 成功；`SharedCore` 測試仍綠。
- 模擬器驗證：清空體重→送出鈕灰；能量打「abc」→ 不留；日期 picker 無未來；History/Streak 空狀態 CTA 可點並導向動作；Settings Karvonen 警語顯眼、Health 列同步項；Today 次要鈕為 `SecondaryButton` 樣式；條件欄位有動效。

**Scope boundaries：**

- In scope：上列 8 個 `App/Views/*` 的 UI 層驗證與呈現修改、`SecondaryButton` 採用。
- Out of scope：design-system 元件實作、無障礙屬性（另案）、domain/persistence 邏輯。

## Risks / Trade-offs

- **與 `accessibility-pass` 共改 Settings/Onboarding/Today/History/Week**：多檔重疊——須順序 apply（建議基礎→accessibility-pass→本案，或本案→accessibility-pass，擇一固定）；同檔不同區段可平行，否則序列化避免衝突。
- **休息日改非互動而非加說明頁**：少了潛在「休息建議」內容，換取不擴張範圍；日後想加說明頁可另開變更。
- **限制過去日期**：若有人要預先記錄當天稍晚的訓練，上界為當下可能略嚴；以「completed workout」語意取捨，接受。
