## Context

`widgets-complication` 提案（roadmap）要：Home/Lock 小工具顯示今日課表與本週進度、watch complication 顯示下一次課表，並以 App Group 快照讓小工具免啟動 app 即可讀取。domain 型別（`TrainingPlan`、`TargetsCalculator`、`PlannedSession`、`WeeklyTargets`、`SessionType`）皆 `Codable`/`Sendable`，且 round-3 已把 `HRZone`/`IntervalKind` 的色彩/glyph token 放進 `SharedCore`，小工具與 complication 可直接 import 採用。專案以 xcodegen 管理（`project.yml`）。目前無 App Group。

## Goals / Non-Goals

**Goals:**

- iOS WidgetKit extension：Home（systemSmall/systemMedium）＋ Lock（accessoryRectangular/accessoryCircular）小工具，顯示今日課表與本週訓練分鐘進度，點擊深連回 app。
- watch complication（accessoryCircular/accessoryCorner）顯示下一次課表。
- App（iOS）以 App Group 共享快照，內容變動時觸發 `WidgetCenter` 重載。

**Non-Goals:**

- 無互動式小工具（除深連點擊）、小工具內無實時計時器。
- 不在 watch 端用 App Group（complication 直接以 `SharedCore` 計算下一課表，免跨裝置共享）。
- 不改既有畫面行為、不改 domain 邏輯。

## Decisions

- **快照型別放 `SharedCore`**：新增 `WidgetSnapshot`（`Codable`/`Sendable`）：今日 `SessionType`、今日分鐘、本週已完成/目標分鐘、本週 hard 已完成/目標、`generatedAt`；附 `placeholder`。
- **快照儲存放 `SharedCore`**：`WidgetSnapshotStore`，以 `FileManager.containerURL(forSecurityApplicationGroupIdentifier:)` 讀寫 App Group 內 JSON；app 與 iOS widget extension 共用。App Group id：`group.ca.logolo.z24x4`。
- **App 端寫入**：新增 `WidgetSnapshotWriter`（App），由 `ProfileRecord` + 本週 `WorkoutLog` 算出快照並寫入、呼叫 `WidgetCenter.shared.reloadAllTimelines()`；於 app 進入前景、記錄訓練後、onboarding 完成後觸發。
- **iOS widget extension**：新增 target `Z24x4Widgets`（app-extension、iOS），依賴 `SharedCore`；`TimelineProvider` 讀 `WidgetSnapshotStore`；4 個 widget family 視圖；`widgetURL` 深連 `z24x4://today`。app 端處理該 URL 切到 Today。
- **watch complication**：新增 watchOS widget extension target `Z24x4WatchComplications`，依賴 `SharedCore`；provider 直接以 `TrainingPlan.weekly(for:)`（預設 goal）算「下一次非休息課表」；accessoryCircular 顯示 session glyph、accessoryCorner 顯示型別＋分鐘。
- **entitlements**：iOS app 與 iOS widget extension 加 App Group entitlement（同一 group）；watch complication 不需 App Group。
- **App Group 範圍**：模擬器可用（Xcode 管理）；實機/TestFlight 需 Apple Developer 帳號（目前未有，屬已知 blocker）——本變更以模擬器 build/verify 為準。

## Implementation Contract

**Behavior（可觀察）：**

- Home systemSmall 顯示今日課表（型別＋分鐘或「Rest」）；systemMedium 另顯示本週進度（已完成/目標分鐘）。
- Lock accessoryCircular 顯示本週進度環；accessoryRectangular 顯示今日課表一行。
- 點擊任一 iOS 小工具 → 開 app 並停在 Today。
- watch complication（圓形/角落）顯示下一次非休息課表。
- 記錄一次訓練後，小工具於下次時間軸重載反映新的本週進度。

**Interface / 形狀：**

- `SharedCore`：`public struct WidgetSnapshot: Codable, Sendable`（欄位如上）＋ `public static let placeholder`；`public enum WidgetSnapshotStore`（`static func read() -> WidgetSnapshot?`、`static func write(_:)`，App Group id 常數）。
- App：`WidgetSnapshotWriter.update(context:)`（讀 SwiftData 算快照、寫入、重載）；`Z24x4TrainerApp` 在 `.onChange(of: scenePhase)` active 時呼叫；`ManualEntryView.save()`/`PhoneSessionReceiver` 插入後呼叫；`RootView` 處理 `onOpenURL`。
- `project.yml`：新增 `Z24x4Widgets`（type `app-extension`、platform iOS、sources `Widgets/`、依賴 SharedCore、App Group entitlement）與 `Z24x4WatchComplications`（type `app-extension`、platform watchOS、sources `WatchComplications/`、依賴 SharedCore），並把兩者列為對應 app 的 embedded extension。

**Failure modes：**

- App Group 容器不可得（未設 entitlement）→ `WidgetSnapshotStore.read` 回 nil，widget 顯示 `placeholder`，不崩潰。
- 無 profile（未 onboarding）→ writer 不寫，widget 顯示 placeholder。

**Acceptance criteria：**

- `xcodegen generate` 後 `xcodebuild` 編譯 app＋`Z24x4Widgets`（iOS simulator）成功；watch app＋`Z24x4WatchComplications`（watchOS simulator）成功。
- `SharedCore` 測試仍綠；新增 `WidgetSnapshot` 編解碼往返測試通過。
- 模擬器加入 Home/Lock 小工具顯示今日課表與本週進度；watch face 加 complication 顯示下一課表；點擊小工具開 app 到 Today。

**Scope boundaries：**

- In scope：`SharedCore` 快照型別/儲存＋測試；App 寫入與深連；兩個 extension target 與其視圖；`project.yml`／entitlements。
- Out of scope：互動式小工具、widget 內計時器、watch 端 App Group、device/TestFlight 簽章（帳號 blocker）。

## Risks / Trade-offs

- **新增兩個 extension target ＋ App Group**：xcodegen／entitlements 設定面大，且 App Group 在實機需付費帳號；以模擬器驗證、device 留待帳號就緒。
- **watch complication 用預設 goal**：watch 尚無同步 profile，complication 以預設 plan 計算下一課表；待 watch-phone profile 同步後可再精準化（另案）。
- **快照新鮮度**：依 `WidgetCenter` 重載與時間軸；非實時，符合 Non-Goal。
