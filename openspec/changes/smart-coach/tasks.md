# Tasks — smart-coach

## 1. 領域 (Requirement: Adaptive plan progression)

- [ ] 1.1 `SharedCore`：`PlanProgression.adjust(base:history:profile:) -> TrainingPlan`（連續達標→加量；漏掉→維持；每 4 週 deload）。Requirement: Adaptive plan progression。
  行為：依歷史回不同量。驗證：Swift Testing 三場景（progress/hold/deload）。
- [ ] 1.2 `FitnessTrend`：彙整 VO2max 樣本（最新值、變化）。Requirement: Fitness trend from VO2max。
  行為：給定樣本回最新+delta。驗證：單元測試樣本序列。

## 2. HealthKit (Requirement: Fitness trend from VO2max)

- [ ] 2.1 `HealthProviding`/`HealthKitService`/`PreviewHealthService` 新增讀取 VO2max 序列（`HKQuantityType(.vo2Max)`）。
  行為：授權後回 VO2max 樣本（sim 為空）。驗證：mock 回 canned 樣本；iOS build 綠。

## 3. UI (Requirement: Coach card; Fitness trend from VO2max)

- [ ] 3.1 `TodayView` 加 **Coach card**（adapted week + 一句提示）。Requirement: Coach card。
  行為：Today 顯示教練卡。驗證：`-seedProfile -seedWorkouts` 截圖 light+dark。
- [ ] 3.2 `HistoryView` 加 **fitness-trend** 圖（VO2max line + 空狀態）。Requirement: Fitness trend from VO2max。
  行為：有資料畫線、無資料空狀態。驗證：mock 樣本截圖；空狀態截圖。
