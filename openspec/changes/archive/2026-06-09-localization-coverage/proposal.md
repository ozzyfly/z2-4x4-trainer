## Summary

補上 `localization` 首輪未涵蓋的 App 端「函式回傳/插值字串」本地化，消除 zh-Hant 下 Today 等畫面仍顯示英文的缺口。

## Motivation

`localization` 建好 String Catalog 並本地化核心 chrome，但截圖顯示 zh-Hant 下仍有英文：readiness 標題（Go hard/Steady/Take it easy）、coach 提示、本週摘要、`SessionType.displayName`、「Recover well.」。原因是這些為函式回傳的 `String` 或插值字串，走 `Text(String)` 不會自動本地化。本變更以 `String(localized:)` 顯式本地化並補進 catalog。

## Proposed Solution

- `App/Views/TodayView.swift`：`readinessTitle`、`coachingTip`、`weekSummary`、`SessionType.displayName` 改用 `String(localized:)`（插值用 catalog 格式鍵）。
- 「Recover well.」literal 加入 catalog（`TodayView`、`WorkoutDetailView`）。
- `App/Localizable.xcstrings`：為上述字串加 zh-Hant（translated）與 es/ja（needs_review）。

## Non-Goals

- 不本地化 SharedCore 動態字串（readiness recommendation 等屬 package，需另以 bundle 處理）。
- 不改 es/ja 既有草稿品質保證（待母語審閱）。
- 不改版面或行為。

## Impact

- Affected specs: `localization`（MODIFIED：覆蓋率擴及 App 端函式回傳/插值字串）
- Affected code:
  - Modified:
    - App/Views/TodayView.swift
    - App/Views/WorkoutDetailView.swift
    - App/Localizable.xcstrings
  - New: (none)
  - Removed: (none)
