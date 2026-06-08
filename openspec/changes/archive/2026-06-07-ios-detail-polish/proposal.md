## Summary

修掉 round-3 稽核發現、round-2 未涵蓋的 iOS 細節：IntervalRow 僅靠色彩的間歇條、ShareCard 無無障礙與標題溢出風險、History 圖表缺軸標籤、體重圖借用區間色。

## Motivation

Round-2 處理了主要畫面，但稽核發現以下未動之處：

- `App/Views/WorkoutDetailView.swift` 的 `IntervalRow`：左側 4pt 色條（warmup/hard/recovery/cooldown）是純色彩訊號，色盲使用者無法分辨。
- `App/Views/ShareCard.swift`：以 `ImageRenderer` 輸出的卡片無任何無障礙標籤；標題 `Z2/4×4 Trainer` 無 `lineLimit`/`minimumScaleFactor`，極端情況有溢出風險。
- `App/Views/HistoryView.swift`：三張圖表無 Y 軸刻度標籤與單位說明，glance 時不知數值/單位；體重趨勢圖用 `HRZone.zone2.color`（綠）表達體重，語意與 HR 區間色混淆。

本變更採用 `shared-visual-tokens` 已提供的 `IntervalKind.glyph` 作為非色彩訊號。

## Proposed Solution

- **IntervalRow**：在色條旁加 `IntervalKind.glyph`（來自 SharedCore）的小符號，使間歇類型以「形狀＋色彩」表達；色條保留、符號 `accessibilityHidden`（kind 文字已在 a11y label）。
- **ShareCard**：對整張卡片加 `accessibilityElement(children: .combine)` 與摘要 label（本週分鐘/次數/連續週）；標題加 `lineLimit(1)` + `minimumScaleFactor(0.8)` 防溢出。
- **History 圖表**：三張圖各加 `chartYAxis { AxisMarks(...) }` 顯示 Y 軸刻度，並於圖上方加單位 caption（minutes / VO2 max ml·kg⁻¹·min⁻¹ / kg）；體重圖線色由 `HRZone.zone2.color` 改 `Theme.accent`，避免區間色語意混淆。

## Non-Goals

- 不改圖表的資料、互動或既有 per-bar VoiceOver（round-2 已加）。
- 不改間歇/區間顏色值、不改 SharedCore token。
- 不動 watch、domain、persistence。

## Alternatives Considered

- **IntervalRow 只加文字不加符號**：被否決——色條已是視覺主訊號，加符號最小且與 token glyph 一致。
- **體重圖新增專屬色 token**：被否決——直接用既有 `Theme.accent` 即可區隔，無需新 token。

## Impact

- Affected specs: `design-system`（MODIFIED：間歇條提供非色彩 glyph、ShareCard 無障礙、圖表軸標籤）
- Affected code:
  - Modified:
    - App/Views/WorkoutDetailView.swift
    - App/Views/ShareCard.swift
    - App/Views/HistoryView.swift
  - New: (none)
  - Removed: (none)
