# Privacy Policy — Z2/4×4 Trainer

**Last updated: June 3, 2026**

Z2/4×4 Trainer ("the App") is a cardio training app for iPhone and Apple Watch that
prescribes daily and weekly Zone 2 and Norwegian 4×4 workouts and weekly
health-maintenance / weight-loss targets. This policy explains how the App handles
your information.

**Short version: The App is local-only. Everything stays on your device. We do not
have a server, we do not collect your data, and nothing you enter or that the App
reads from Apple Health is transmitted off your device or shared with anyone.**

---

## Who we are

- App: **Z2/4×4 Trainer**
- Developer contact: **ozzyfly@logolo.ca**

We are the developer of the App. We do not operate any online service, account system,
or backend on your behalf.

---

## What information the App uses

The App works entirely on your device. Depending on your choices, it uses:

1. **Information you enter manually**, such as your age (to calculate maximum heart
   rate), an optional maximum-heart-rate override, body weight, and workout details.
2. **Health data you choose to share via Apple Health (HealthKit)**, which the App can
   **read**:
   - Heart rate
   - Resting heart rate
   - Active energy (calories burned)
   - Body mass (weight)
   - Workouts
3. **Workouts the App writes back to Apple Health (HealthKit write):**
   - Completed Zone 2 and Norwegian 4×4 workouts.

The App only requests the Health data types listed above, and only after you grant
permission in Apple's standard Health permission screen. You can change or revoke this
access at any time in **Settings → Health → Data Access & Devices** (or
**Privacy & Security → Health**) on your iPhone.

---

## How your information is used

- All calculations — your training zones (Zone 2 = 60–70% of max heart rate; Norwegian
  4×4 intervals at 85–95% of max heart rate), your maximum heart rate (220 − age, or
  your override), and your weekly targets — happen **entirely on your device**.
- Health data is used **only** to power these features inside the App.
- Workouts are saved back to Apple Health **only** so your training appears alongside
  your other health records.

---

## What we do NOT do

- We do **not** collect, transmit, upload, or back up your data to any server. There is
  no server.
- We do **not** require an account, login, or registration.
- We do **not** sell, rent, trade, or share your data with any third party.
- We do **not** use any third-party analytics, tracking, advertising, or crash-
  reporting SDKs.
- We do **not** use your Health data — or any other data — for advertising or
  marketing, ever.
- We do **not** track you across apps or websites.

Apple's HealthKit framework prohibits using Health data for advertising or sharing it
with third parties, and the App fully complies.

---

## Data storage and security

- Your data is stored locally on your device using Apple's on-device storage
  (SwiftData) and Apple Health.
- Data may be included in your **personal device backups** (iCloud Backup or encrypted
  local backups) if you have those enabled — this is controlled by Apple and your
  device settings, not by us, and those backups are protected by Apple's security.
- Because nothing is transmitted off the device, there is no online database for an
  attacker to breach.

---

## Deleting your data

- **Health data:** managing or deleting Health records is done in the Apple Health app
  and in **Settings → Privacy & Security → Health**.
- **All App data:** simply **delete the App** from your device. This removes the App's
  locally stored data. (Workouts you previously wrote to Apple Health remain in Apple
  Health until you delete them there — they belong to you.)

---

## Children's privacy

The App is intended for a general audience and does not knowingly collect data from
anyone, including children. Because the App collects no data and has no server, no
personal information is gathered regardless of the user's age.

---

## Medical disclaimer

The App is a fitness and training tool, not a medical device. It does not diagnose,
treat, cure, or prevent any disease. Consult a qualified healthcare professional before
beginning any exercise program.

---

## Changes to this policy

If this policy changes, we will update the "Last updated" date above and post the new
version at the same URL where you found this policy.

---

## Contact

Questions about your privacy or this policy? Email **ozzyfly@logolo.ca**.

---

> **Note for the developer:** Apple requires that this privacy policy be available at a
> **public, hosted URL** that you enter in App Store Connect — a Markdown file in the
> repo is not sufficient. The simplest free option is **GitHub Pages**: publish this
> document (as `privacy.html` or rendered Markdown) in a public repository and enable
> Pages to get a URL such as `https://<your-username>.github.io/<repo>/privacy`. Enter
> that URL in App Store Connect under **App Information → Privacy Policy URL**. HealthKit
> apps are commonly rejected when this URL is missing or does not load.
