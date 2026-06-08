## 1. IntervalRow 非色彩訊號

- [x] 1.1 滿足需求「Interval rows convey kind without color」：在 `App/Views/WorkoutDetailView.swift` 的 `IntervalRow` 於色條旁加 `interval.kind.glyph`（來自 SharedCore `IntervalKind+UI`）的小 `Image(systemName:)`，使間歇類型以形狀＋色彩表達；符號加 `accessibilityHidden(true)`（kind 已在既有 a11y label）。

## 2. ShareCard 無障礙與穩健

- [x] 2.1 滿足需求「Share card is accessible」：在 `App/Views/ShareCard.swift` 對整張卡片加 `accessibilityElement(children: .combine)` 與摘要 `accessibilityLabel`（含本週分鐘、次數、連續週）。
- [x] 2.2 滿足需求「Title fits the card」：對 ShareCard 標題（`Z2/4×4 Trainer`）加 `lineLimit(1)` 與 `minimumScaleFactor(0.8)`，避免於固定寬度版面溢出/換行。

## 3. History 圖表軸與單位

- [x] 3.1 滿足需求「Charts label their axes and units」：在 `App/Views/HistoryView.swift` 三張圖表（訓練分鐘、VO2 max、體重）各加 `chartYAxis { AxisMarks(position: .leading) }` 顯示 Y 軸刻度，並於各圖上方加單位 caption（minutes / VO2 max ml·kg⁻¹·min⁻¹ / kg）。
- [x] 3.2 滿足需求「Zone colors are not reused for non-zone metrics」：將體重趨勢圖 LineMark/PointMark 的 `HRZone.zone2.color` 改為 `Theme.accent`。

## 4. 驗證

- [x] 4.1 以 `xcodebuild` 編譯 iOS target（`Z24x4Trainer` scheme，iPhone 17 Pro simulator）成功；`SharedCore` 測試仍綠（58/58）；確認未改顏色值（間歇/區間 token）、未動 watch/domain；以模擬器確認 IntervalRow 有符號、ShareCard VoiceOver 念摘要、三圖有 Y 軸與單位、體重圖為 accent 色。
