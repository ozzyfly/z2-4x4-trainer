# Tasks — app-store-submission

參考 `docs/app-store/`：`SUBMISSION_CHECKLIST.md`、`PRIVACY_POLICY.md`、`APP_PRIVACY_LABEL.md`、`METADATA.md`。

## 1. 帳號與簽章 (Requirement: Distributable signed build)

- [x] 1.1 加入 Apple Developer Program（$99/年），於 portal 註冊 App ID `ca.logolo.z24x4.Z24x4Trainer` 並啟用 HealthKit capability。
  行為：開發者團隊下存在啟用 HealthKit 的 App ID。驗證：Apple Developer portal 顯示該 App ID 與 capability。
- [x] 1.2 在 Xcode 開啟 automatic signing，產生 `Z24x4Trainer` 的 distribution archive 並上傳 App Store Connect。
  行為：archive 通過驗證並上傳，無簽章/capability 錯誤。驗證：對應 spec 場景「Archive uploads to App Store Connect」，App Store Connect 出現該 build。

## 2. 隱私合規 (Requirement: Privacy compliance for HealthKit)

- [x] 2.1 將 `docs/app-store/PRIVACY_POLICY.md` 發佈到公開 URL（GitHub Pages），記錄該網址。
  行為：隱私權政策網址可公開開啟。驗證：對應 spec 場景「Privacy policy is reachable」，瀏覽器開啟網址成功載入。
- [x] 2.2 依 `docs/app-store/APP_PRIVACY_LABEL.md` 填寫 App Privacy 問卷（全部 Data Not Collected）。
  行為：隱私標籤與 local-only 行為一致。驗證：對應 spec 場景「Privacy label matches behavior」，App Store Connect 隱私區塊內容相符。

## 3. 上架資產 (Requirement: Release metadata and assets present)

- [x] 3.1 以最終美術取代 `App/Assets.xcassets/AppIcon.appiconset` 的 1024² 佔位圖示。
  行為：App icon 為正式美術（非佔位）。驗證：`sips -g pixelWidth -g pixelHeight` 為 1024×1024 且 hasAlpha=no，並非佔位漸層。
- [x] 3.2 擷取 iPhone 6.9"/6.5" 截圖；依 `docs/app-store/METADATA.md` 填入名稱/副標/描述/關鍵字/分類。
  行為：上架頁面資訊完整、截圖齊備。驗證：對應 spec 場景「Listing is complete」，App Store Connect 必填欄位皆綠。

## 4. 測試與送審 (Requirement: TestFlight build passes before submission)

- [x] 4.1 建立 TestFlight 內部測試，安裝後完成一次 Zone 2 與一次 4×4，確認記錄與 Today/Week/History 更新且不崩潰。
  行為：TestFlight build 可完成端到端訓練流程。驗證：對應 spec 場景「Internal TestFlight run」，實機觀察兩筆 session 與統計更新。
- [x] 4.2 送出審查，附上 HealthKit 使用說明的 review notes（取自 `SUBMISSION_CHECKLIST.md`）。
  行為：app 進入「Waiting for Review」。驗證：App Store Connect 狀態顯示已送審。
