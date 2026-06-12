## Why

iOS App（Phase 2 範圍的收尾打磨）還有四個粗糙處：第一次使用、還沒有任何紀錄時 Today 畫面顯示空泛內容沒有引導；onboarding 直接跳表單、沒有先說明 App 是什麼；資料模型已有 WorkoutLog.note 欄位但 UI 完全沒接（無法輸入也看不到）；es/ja 兩語系 258 個字串卡在 needs_review 未定稿。

## What Changes

- `TodayView`：無任何 WorkoutLog 時顯示歡迎卡（用 DesignSystem 的 Card 元件），說明今天的課表並提供「開始第一次訓練 / 手動記錄」CTA
- 新增 `App/Views/OnboardingIntroView.swift`：onboarding 第 0 步（App 價值說明 + 三個重點 + 繼續按鈕）；`OnboardingView` 以單行整合接入，維持與 units-export 變更的檔案衝突最小
- 筆記欄：`ManualEntryView` 加 note TextField（接既有 WorkoutLog.note）；顯示面在新檔 `App/Views/RecentWorkoutsSection.swift`（最近紀錄列表：日期、類型、分鐘、note、來源圖示），以單行插入 `HistoryView` — 原規劃「顯示在 WorkoutDetailView」不可行（該畫面是課表說明頁、拿不到 WorkoutLog），改為此方案
- es/ja 翻譯定稿：人工審閱兩個 String Catalog 的 needs_review 條目後改為 translated；必須在本輪所有新字串合併後最後執行

## Non-Goals

- 不重作 onboarding 表單本體（只是前面加一頁）
- 不做完整的紀錄詳情頁；RecentWorkoutsSection 列表即足夠
- 不新增語言；只定稿既有 es/ja
- note 欄不同步到 Watch、不進快照

## Capabilities

### New Capabilities

(none)

### Modified Capabilities

- `usability`: Today 空狀態歡迎卡、onboarding 介紹頁、手動紀錄筆記輸入與最近紀錄顯示
- `localization`: es/ja 由 needs_review 升級為 translated（定稿）

## Impact

- Affected specs: `usability`（modified）、`localization`（modified）
- Affected code:
  - New: App/Views/OnboardingIntroView.swift, App/Views/RecentWorkoutsSection.swift
  - Modified: App/Views/TodayView.swift, App/Views/ManualEntryView.swift, App/Views/OnboardingView.swift, App/Views/HistoryView.swift, App/Localizable.xcstrings, SharedCore/Sources/SharedCore/Localizable.xcstrings
  - Removed: (none)
