# App Store Submission Checklist — Z2/4×4 Trainer

A beginner-friendly, ordered path from "I have an app on my Mac" to "submitted for
review." Follow the steps top to bottom. Items in **bold** are required by Apple
and will block submission if missing.

App facts you'll reuse:
- App name: **Z2/4×4 Trainer**
- Bundle ID: **`ca.logolo.z24x4.Z24x4Trainer`**
- Platforms: iPhone + Apple Watch (companion)
- Category: **Health & Fitness**
- Uses HealthKit: **Yes** (read + write)
- Data leaves device: **No** (fully local / on-device)
- Contact: ozzyfly@logolo.ca

---

## 0. Before you start (one-time setup)

- [ ] You have a Mac with a recent **Xcode** installed (App Store → Xcode).
- [ ] You have a physical **iPhone** to test on (HealthKit cannot be fully tested in
      Simulator; an Apple Watch is helpful but TestFlight on iPhone alone is fine to start).
- [ ] You have an **Apple ID** you control (use a long-term one — this becomes your
      developer identity).

---

## 1. Enroll in the Apple Developer Program ($99/year) — REQUIRED

You cannot upload to App Store Connect or use TestFlight without this.

- [ ] Go to <https://developer.apple.com/programs/> and click **Enroll**.
- [ ] Sign in with your Apple ID. Turn on **two-factor authentication** if prompted
      (required).
- [ ] Enroll as an **Individual** (simplest for a solo beginner) unless you have a
      registered company / D-U-N-S number, in which case choose **Organization**.
- [ ] Pay the **$99 USD/year** fee.
- [ ] Wait for approval. Individual enrollment is often minutes to ~48 hours;
      occasionally Apple asks for ID verification.

> You can write code and run on your own device for free, but **submitting requires
> the paid program.**

---

## 2. App ID + HealthKit capability in the Developer portal

Modern Xcode can do most of this automatically (see step 3). If you want to (or need
to) do it manually:

- [ ] Go to <https://developer.apple.com/account> → **Certificates, Identifiers &
      Profiles** → **Identifiers**.
- [ ] Register a new **App ID** with bundle ID **`ca.logolo.z24x4.Z24x4Trainer`**
      (this must match `PRODUCT_BUNDLE_IDENTIFIER` in the project exactly).
- [ ] Under **Capabilities**, enable **HealthKit**.
- [ ] The app's `Z24x4Trainer.entitlements` already declares
      `com.apple.developer.healthkit = true` — the portal capability must match it.

> The Apple Watch companion app, if it ships as a separate target, needs its **own**
> App ID (usually `ca.logolo.z24x4.Z24x4Trainer.watchkitapp` or similar). Confirm the
> watch target's bundle ID in your project and register it too.

---

## 3. Signing & provisioning (let Xcode do it)

**What a provisioning profile is (plain English):** a file that ties together (1) your
developer identity (certificate), (2) the App ID, and (3) which devices/capabilities
are allowed. It's Apple's way of saying "this build is really from you and is allowed
to do these things." You rarely create it by hand anymore.

- [ ] In Xcode, open the project → select the **Z24x4Trainer** target → **Signing &
      Capabilities** tab.
- [ ] Check **Automatically manage signing**. ✅ (Recommended for beginners — Xcode
      creates the certificate and provisioning profile for you.)
- [ ] In **Team**, pick the team that appeared after your enrollment.
- [ ] Confirm the **HealthKit** capability is listed here. If not, click
      **+ Capability** and add **HealthKit**.
- [ ] Repeat for the **Watch** target (same team, automatic signing).
- [ ] Fix any red signing errors before continuing (usually "team not selected" or
      "bundle ID already taken" — pick a unique one).

---

## 4. App icon & version

- [ ] App icon is in `App/Assets.xcassets/AppIcon.appiconset` (a single 1024×1024 PNG
      with **no alpha/transparency** — iOS rejects transparent icons).
      A placeholder is already provided; replace it with final artwork before release.
- [ ] Set the marketing version (currently `0.1.0` in `project.yml`). For your first
      public release use **`1.0`** and build number **`1`**.

---

## 5. Required screenshots

You upload these in App Store Connect (step 7). Take them on a real device or in the
Simulator. As of 2024–2025 Apple accepts a single large iPhone size that scales to
others, but to be safe capture both large sizes.

**iPhone (required — at least one set):**
- [ ] **6.9"** display (e.g. iPhone 16 Pro Max / 15 Pro Max): **1320 × 2868** portrait
      (or 2868 × 1320 landscape).
- [ ] **6.5"** display (e.g. iPhone 11 Pro Max / XS Max): **1242 × 2688** portrait
      (or 2688 × 1242). *Often optional if the 6.9" set is provided, but include it to
      avoid surprises.*

**Apple Watch (required if you ship a Watch app):**
- [ ] Provide screenshots for the Watch sizes you support. Common required sizes:
  - Series 10 / Ultra (**45 mm/49 mm class**): **410 × 502** or **416 × 496**.
  - Provide at least one Watch size matching the largest device family you support.

Tips:
- 1–10 screenshots per device. The first 1–3 matter most.
- No transparency, correct exact pixel dimensions, RGB, PNG or JPEG.
- Show the Zone 2 prescription, the 4×4 workout screen, and weekly targets.

---

## 6. Privacy policy hosted at a public URL — REQUIRED for HealthKit apps

- [ ] Take `docs/app-store/PRIVACY_POLICY.md`, convert it to a hosted web page.
- [ ] Easiest free option: **GitHub Pages**. Put the policy in a public repo's
      `/docs` folder or a `gh-pages` branch and enable Pages → you get a URL like
      `https://<user>.github.io/<repo>/privacy`.
- [ ] Keep that **Privacy Policy URL** handy — App Store Connect requires it, and
      HealthKit apps are rejected without a working one.

---

## 7. Create the App Store Connect record + metadata

- [ ] Go to <https://appstoreconnect.apple.com> → **My Apps** → **+** → **New App**.
- [ ] Platform: **iOS**. Name: **Z2/4×4 Trainer**. Primary language: English.
- [ ] Bundle ID: pick **`ca.logolo.z24x4.Z24x4Trainer`** from the dropdown (it appears
      after step 2/3).
- [ ] SKU: any unique string, e.g. `z24x4-trainer-001`.
- [ ] Fill the listing using `docs/app-store/METADATA.md` (subtitle, description,
      keywords, promotional text, what's new).
- [ ] Category: **Health & Fitness**.
- [ ] Add **screenshots** from step 5.
- [ ] Enter the **Privacy Policy URL** from step 6.
- [ ] Complete the **App Privacy** ("nutrition label") questionnaire using
      `docs/app-store/APP_PRIVACY_LABEL.md` → answer **Data Not Collected**.
- [ ] Complete the **Age Rating** questionnaire (see METADATA.md → expect **4+**).
- [ ] Provide **Support URL** (a simple page or mailto works) and contact email
      `ozzyfly@logolo.ca`.

---

## 8. Upload your build

Pick one:

**Option A — Xcode (simplest):**
- [ ] In Xcode, set the run destination to **Any iOS Device (arm64)**.
- [ ] **Product → Archive.**
- [ ] When the Organizer opens, select the archive → **Distribute App** →
      **App Store Connect** → **Upload** → follow prompts (keep automatic signing).
- [ ] Wait for "Upload Successful," then for the build to finish **processing** in
      App Store Connect (minutes to ~1 hour).

**Option B — Transporter app:** export an `.ipa` from the Organizer, then drag it into
the free **Transporter** app from the Mac App Store and click **Deliver**.

---

## 9. TestFlight internal testing (do this before submitting)

- [ ] In App Store Connect → your app → **TestFlight** tab.
- [ ] Add yourself as an **Internal Tester** (internal testers don't need Beta App
      Review).
- [ ] Install **TestFlight** from the App Store on your iPhone, accept the invite,
      install the build.
- [ ] Verify the **HealthKit permission prompt** appears and the strings read
      correctly, that workouts save to Apple Health, and there are no crashes.

> Internal TestFlight is fast. External testing (other people) requires a short Beta
> App Review — optional for v1.0.

---

## 10. HealthKit review requirements — read carefully

Apple scrutinizes Health apps. Make sure ALL of these are true:

- [ ] **Privacy policy URL** is present and loads (step 6). *Mandatory.*
- [ ] **Usage description strings** are present and clearly explain why you need the
      data. Yours (already in `project.yml`) are:
  - Read: "Reads your heart rate, workouts, active energy, resting heart rate and body
    weight to calculate your training zones and weekly targets."
  - Write: "Saves your Zone 2 and Norwegian 4×4 workouts to Apple Health."
- [ ] You **only request the Health types you use** (heart rate, active energy,
      resting HR, body mass, workouts — read; workouts — write). Don't over-request.
- [ ] **Health/HealthKit data is NEVER used for advertising or marketing**, and is
      not shared with third parties or used in ad targeting. (True here: everything is
      on-device.)
- [ ] The app does **not** store Health data in iCloud or any backend without consent
      (true here: nothing leaves the device).
- [ ] **Review Notes** (App Store Connect → app version → "App Review Information →
      Notes") should say something like:

  > "Z2/4×4 Trainer is a fully local, on-device cardio training app. HealthKit is used
  > to read heart rate, resting heart rate, active energy, body mass, and workouts to
  > compute Zone 2 and Norwegian 4×4 training zones and weekly health targets, and to
  > write completed workouts back to Apple Health. No account is required. No data
  > leaves the device — there is no server, no analytics, and no third-party SDKs.
  > Health data is never used for advertising. To test HealthKit, please grant Health
  > permissions when prompted; sample workouts can be generated manually in the app."

- [ ] Because HealthKit cannot run in the Simulator, ensure your build works on a real
      device (the reviewer tests on hardware).

---

## 11. Submit for review

- [ ] In App Store Connect → app version (e.g. **1.0**) → select your processed
      **build** under "Build".
- [ ] Set **release option** (manual or automatic release after approval).
- [ ] Confirm Export Compliance: this app uses only standard OS encryption (HTTPS/none)
      → typically answer **"No"** to "uses non-exempt encryption." (Double-check; you
      can add `ITSAppUsesNonExemptEncryption=false` to Info.plist to skip the prompt.)
- [ ] Click **Add for Review** → **Submit for Review**.
- [ ] Status moves to **Waiting for Review** → **In Review** → **Pending Developer
      Release** / **Ready for Sale**. First reviews often take 24–48 hours.

---

## 12. Common health-app rejection reasons (avoid these)

- **Missing or broken privacy policy URL.** The #1 HealthKit rejection.
- **Vague usage strings** ("We need access to Health"). Be specific about *what* and
  *why* (yours already are).
- **Requesting Health permissions you don't use**, or requesting them before they're
  needed with no context.
- **Using Health data for advertising/marketing** or sharing it — strictly forbidden.
- **Storing Health data off-device without disclosing it.** (N/A here, but never claim
  you upload — you don't.)
- **App Privacy label that doesn't match behavior** (e.g. label says "no data
  collected" but an analytics SDK is present). Keep it truthful: no SDKs here.
- **Crashes / placeholder content / Lorem ipsum** in the build or screenshots.
- **Medical claims.** Don't claim to diagnose, treat, or prevent disease. Describe it
  as a *training/fitness* tool, not a medical device.
- **Guideline 2.1 (incomplete info):** reviewer couldn't test a feature. Provide clear
  Review Notes and (if applicable) a demo flow for HealthKit.
- **Watch app issues:** Watch screenshots missing, or the Watch app doesn't launch
  independently as expected.

---

When all boxes above are checked, you're ready. Good luck!
