## 1. SharedCore：cue 文字與 displayName 共用

- [x] 1.1 滿足需求「Interval cue text is well-defined」：在 `SharedCore/Sources/SharedCore/IntervalKind+UI.swift` 新增 `public var displayName: String`（Warm Up/Hard/Recovery/Cool Down），並從 `Watch/IntervalEngine.swift` 移除其重複的 `extension IntervalKind { var displayName }`。
- [x] 1.2 在 `SharedCore` 新增 `public enum GuidedCue`：`static func text(entering: IntervalKind) -> String`（如 hard「Hard. Four minutes.」、recovery「Recover.」、warmup「Warm up.」、cooldown「Cool down.」）、`static let zone2Reminder`（「Zone 2. Keep it conversational.」）、`static let finished`（「Session complete.」）；全部非空。
- [x] 1.3 在 `SharedCore/Tests` 新增測試：對每個 `IntervalKind` 與 finished/zone2Reminder，`GuidedCue` 回傳非空字串。

## 2. App：引導引擎

- [x] 2.1 滿足需求「Guided 4×4 player」與「Guided Zone 2 player」：新增 `App/GuidedSessionEngine.swift`（`@Observable @MainActor`，`init(type:calc:)`），4×4 以 `Norwegian4x4.build(using:)` 取 intervals，鏡像 `Watch/IntervalEngine` 的 timer/currentIndex/secondsRemaining/isFinished 推進；Zone 2 為開放式 `elapsedSec` 計時；曝露 `currentInterval`、`secondsRemaining`/`elapsedSec`、`isFinished`、`hapticTrigger`（轉換時遞增）、`lastCue`（最近語音字串）。
- [x] 2.2 滿足需求「Audio plays over other audio」：在引擎以 `AVSpeechSynthesizer` 念 `GuidedCue` 文字；`start()` 設 `AVAudioSession` `.playback` + `.duckOthers` 並 activate，`stop()` deactivate（`notifyOthersOnDeactivation`）；4×4 進入每段時念 `GuidedCue.text(entering:)`、完成念 `finished`；Zone 2 起始與每 5 分鐘念 `zone2Reminder`。

## 3. App：播放器視圖與進入點

- [x] 3.1 滿足需求「Guided 4×4 player」（視覺）：新增 `App/Views/GuidedPlayerView.swift`（`init(type:calc:)`）：顯示大倒數（4×4）或經過時間（Zone 2）、目前段 `IntervalKind.glyph`＋`displayName`＋目標 HR、下一段名稱、整體進度；`.sensoryFeedback(trigger: engine.hapticTrigger)`；播放/End 控制；`onAppear` start、`onDisappear` stop。
- [x] 3.2 滿足需求「Guided player entry point」：在 `App/Views/WorkoutDetailView.swift` 的 Zone 2 與 4×4 內容加「Start guided session」`PrimaryButton`，`NavigationLink` 至 `GuidedPlayerView(type:calc:)`。

## 4. 驗證

- [x] 4.1 以 `xcodebuild` 編譯 iOS（`Z24x4Trainer`）與 watch（`Z24x4TrainerWatch`，確認 displayName 移動後仍 OK）成功；`cd SharedCore && swift test` 通過（含 `GuidedCue` 測試）。
- [x] 4.2 於 iOS simulator 自 WorkoutDetail 進入 4×4 引導，確認倒數遞減、段轉換、完成顯示；進入 Zone 2 引導確認經過時間遞增；確認離開後 timer/語音停止、不崩潰（語音/觸覺聽感留待實機）。
