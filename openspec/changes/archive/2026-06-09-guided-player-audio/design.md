## Context

無 Apple Watch 的使用者無法取得引導式間歇體驗。提案要做 iPhone 端引導播放器：實時倒數、間歇進度、轉換觸覺、語音提示（`AVSpeechSynthesizer`），由 `Norwegian4x4.build` 驅動。`Watch/IntervalEngine` 已有 watch 版引擎邏輯（timer、currentIndex、secondsRemaining、轉換觸覺），但屬 Watch target。`IntervalKind.displayName` 目前定義在 `Watch/IntervalEngine.swift`（Watch only）。SharedCore 已有 `Norwegian4x4`、`HRZoneCalculator`、`IntervalKind+UI`（color/glyph）。

## Goals / Non-Goals

**Goals:**

- iPhone 引導 4×4：大倒數、目前/下一段、進度、轉換 `.sensoryFeedback` 觸覺、轉換語音提示。
- iPhone 引導 Zone 2（開放式）：經過時間＋起始與週期語音提示。
- 由 `WorkoutDetailView` 進入；播放期間音訊在背景仍可發聲（playback session）。

**Non-Goals:**

- 無背景 GPS/配速。音訊 session 處理從簡（playback + duckOthers）。
- 不改 watch 行為（除把 `IntervalKind.displayName` 移到 SharedCore 共用）。
- 不改 domain 計算。

## Decisions

- **`IntervalKind.displayName` 移到 `SharedCore/IntervalKind+UI.swift`**，自 `Watch/IntervalEngine.swift` 移除（避免兩個 module 同名成員在 Watch target 產生歧義）；phone 引擎與 watch 共用。
- **新增純函式 + 測試**：`SharedCore` 加 `GuidedCue`（依 `IntervalKind` 與「進入/完成」回傳語音字串），可測；phone 引擎與 watch 皆可用。
- **`GuidedSessionEngine`（App）**：鏡像 `Watch/IntervalEngine` 的 timer/索引/倒數邏輯（`Norwegian4x4.build` 提供 intervals）；新增 `speechTrigger`/`hapticTrigger`（`@Observable`），轉換時更新以驅動 `.sensoryFeedback` 與 `AVSpeechSynthesizer.speak`；Zone 2 模式為單段開放式經過計時＋週期提示。
- **`GuidedPlayerView`（App）**：顯示大倒數/經過、目前段（kind glyph＋名稱＋目標 HR）、下一段、整體進度；`.sensoryFeedback(trigger:)` 觸覺；播放/結束控制。
- **音訊**：啟動時 `AVAudioSession` 設 `.playback` + `.duckOthers`，使語音蓋過音樂；結束時還原。
- **進入點**：`WorkoutDetailView` 於 4×4 與 Zone 2 內容加「Start guided session」`PrimaryButton`，導航至 `GuidedPlayerView(type:calc:)`。

## Implementation Contract

**Behavior（可觀察）：**

- 4×4：播放器自 warmup 起每秒倒數，到 0 進下一段；進入每段時發觸覺並念該段提示（如「Hard. Four minutes.」/「Recover.」）；全部完成念「Session complete」並停。
- Zone 2：顯示經過時間（mm:ss），起始念「Zone 2. Keep it conversational.」，之後每 5 分鐘重念一次提示。
- 目前段顯示 kind glyph（`IntervalKind.glyph`）＋ `displayName` ＋目標 HR 範圍；顯示下一段名稱；顯示整體進度（第 n/總段 或經過/總時長）。
- 「End」停止 timer、停止語音、還原 audio session、返回。
- 從 `WorkoutDetailView` 的「Start guided session」可進入。

**Interface / 形狀：**

- `SharedCore`：`IntervalKind.displayName`（移入 `IntervalKind+UI`）；`enum GuidedCue { static func text(entering: IntervalKind) -> String; static let zone2Reminder: String; static let finished: String }`。
- `App/GuidedSessionEngine.swift`：`@Observable @MainActor final class`，`init(type:calc:)`；`start()`/`stop()`；曝露 `currentInterval`、`secondsRemaining`/`elapsedSec`、`isFinished`、`progressText`、`hapticTrigger`、`speechText`（最近一次提示）。
- `App/Views/GuidedPlayerView.swift`：`init(type: SessionType, calc: HRZoneCalculator)`。
- `App/Views/WorkoutDetailView.swift`：加導航按鈕。

**Failure modes：**

- 語音不可用/靜音 → 仍顯示視覺與觸覺，不崩潰。
- Zone 2 無 intervals → 引擎走開放式計時分支，不誤入索引邏輯。
- 離開畫面（dismiss）→ `stop()` 於 `onDisappear` 呼叫，timer/語音/audio session 清理。

**Acceptance criteria：**

- `xcodebuild` 編譯 iOS（`Z24x4Trainer`）成功；watch（`Z24x4TrainerWatch`）仍成功（displayName 移動後）。
- `SharedCore` 測試含新增 `GuidedCue` 文字測試通過。
- 模擬器自 WorkoutDetail 進入 4×4 引導：倒數遞減、段轉換、完成；Zone 2 顯示經過時間。（語音/觸覺於模擬器確認程式路徑與不崩潰；實機聽感留待使用者。）

**Scope boundaries：**

- In scope：`SharedCore` displayName 移動 + `GuidedCue` + 測試；`App` 引擎、播放器視圖、進入點、audio session。
- Out of scope：背景 GPS/配速、watch UI 行為、domain 計算、device 簽章。

## Risks / Trade-offs

- **模擬器無法驗證語音聽感/觸覺**：只驗程式路徑與視覺；實機留待使用者。
- **鏡像 watch 引擎造成 tick 邏輯重複**：可接受；以共用 `GuidedCue` 純函式與（未來）抽共用 timeline 緩解，本案不重構 watch 引擎。
