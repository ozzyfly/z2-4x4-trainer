## 1. 共享快照（SharedCore）

- [x] 1.1 滿足需求「Shared widget snapshot」：在 `SharedCore` 新增 `WidgetSnapshot`（`Codable`/`Sendable`：今日 `SessionType`、今日分鐘、本週已完成/目標分鐘、本週 hard 已完成/目標、`generatedAt`）＋ `static let placeholder`。
- [x] 1.2 在 `SharedCore` 新增 `WidgetSnapshotStore`（App Group id 常數 `group.ca.logolo.z24x4`；`read() -> WidgetSnapshot?`、`write(_:)`，以 `containerURL(forSecurityApplicationGroupIdentifier:)` 讀寫 JSON；容器不可得時 read 回 nil、write 靜默 no-op）。
- [x] 1.3 在 `SharedCore/Tests` 新增 `WidgetSnapshot` 編解碼往返測試（encode→decode 相等）。

## 2. App 端寫入與深連

- [x] 2.1 滿足情境「Snapshot updates after logging」：在 `App` 新增 `WidgetSnapshotWriter.update(profile:logs:)`，由 `ProfileRecord` 與本週 `WorkoutLog` 算出 `WidgetSnapshot`（用 `TrainingPlan.weekly(for:)` 與 `TargetsCalculator.weekly`）、寫入 store、呼叫 `WidgetCenter.shared.reloadAllTimelines()`。
- [x] 2.2 在 `App/Z24x4TrainerApp.swift` 於 `scenePhase` 變為 `.active` 時呼叫 writer；在 `App/Views/ManualEntryView.swift` 的 `save()` 與 `App/Sync/PhoneSessionReceiver` 插入後呼叫 writer。
- [x] 2.3 滿足需求「Widget tap opens the app」：在 `App/Views/RootView.swift` 加 `onOpenURL`，`z24x4://today` 將 `MainTabView` 選到 Today（tag 0）。

## 3. iOS widget extension

- [x] 3.1 在 `project.yml` 新增 target `Z24x4Widgets`（type `app-extension`、platform iOS、sources `Widgets/`、依賴 SharedCore、App Group entitlement `group.ca.logolo.z24x4`），並設為 `Z24x4Trainer` 的 embedded extension；app target 亦加同一 App Group entitlement。
- [x] 3.2 滿足需求「Home and Lock widgets」：在 `Widgets/` 新增 `WidgetBundle`＋`TimelineProvider`（讀 `WidgetSnapshotStore`，無快照用 `placeholder`）＋ systemSmall/systemMedium/accessoryRectangular/accessoryCircular 視圖（今日課表、本週分鐘進度），採用 `SharedCore` 的 `SessionType`/token；各 family 設 `widgetURL(z24x4://today)`。

## 4. watch complication extension

- [x] 4.1 在 `project.yml` 新增 target `Z24x4WatchComplications`（type `app-extension`、platform watchOS、sources `WatchComplications/`、依賴 SharedCore），設為 `Z24x4TrainerWatch` 的 embedded extension。
- [x] 4.2 滿足需求「Watch complication shows next session」：在 `WatchComplications/` 新增 `WidgetBundle`＋provider（以 `TrainingPlan.weekly(for:)` 預設 goal 算下一個非休息 `PlannedSession`）＋ accessoryCircular（session glyph）與 accessoryCorner（型別＋分鐘）視圖。

## 5. 驗證

- [x] 5.1 執行 `xcodegen generate` 後，以 `xcodebuild` 編譯 `Z24x4Trainer`（含 `Z24x4Widgets`，iOS simulator）成功；編譯 `Z24x4TrainerWatch`（含 `Z24x4WatchComplications`，watchOS simulator）成功。
- [x] 5.2 `cd SharedCore && swift test` 通過（含新快照往返測試）。
- [x] 5.3 於 iOS simulator 加入 Home（small/medium）與 Lock（rect/circular）小工具，確認顯示今日課表與本週進度、點擊開 app 到 Today；於 watch simulator 錶面加 complication 確認顯示下一課表。
