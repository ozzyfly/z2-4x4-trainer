# App Privacy "Nutrition Label" Answers — Z2/4×4 Trainer

This document tells you exactly how to answer the **App Privacy** questionnaire in
App Store Connect (the "privacy nutrition label" shown on the App Store product page).

**Bottom line for this app: select "Data Not Collected."**

"Collect" in Apple's definition means transmitting data **off the device**. Z2/4×4
Trainer is fully local: it reads/writes Apple Health on-device and stores everything
on-device only. Nothing is transmitted to us or any third party, so by Apple's
definition **no data is "collected."**

---

## Step-by-step answers in App Store Connect

App Store Connect → your app → **App Privacy** → **Get Started / Edit**.

### Q: "Do you or your third-party partners collect data from this app?"
**Answer: No — select "No, we do not collect data from this app."**

Choosing this gives your App Store page the **"Data Not Collected"** label and ends the
questionnaire. This is correct because:

- The App has **no server / backend** — there is nowhere to send data.
- The App uses **no third-party SDKs** (no analytics, ads, attribution, or crash
  reporting).
- All Health data stays on the device; it is read from and written to Apple Health
  locally.

> Reminder: this label must match real behavior. If you ever add an SDK or any network
> feature that sends data off-device, you must revisit and update this label.

---

## Why each Health data type is NOT "collected" (for your records / review notes)

Even though the App **accesses** these Apple Health types, accessing them on-device is
**not** "collecting" them under Apple's privacy-label definition, because they are never
transmitted off the device. Justification for each type the App touches:

| Health type (HealthKit) | Access | Purpose | Leaves device? | Collected? |
|---|---|---|---|---|
| Heart rate | Read | Measure effort vs. training zones (Zone 2, 4×4 intervals) | No | No |
| Resting heart rate | Read | Inform health-maintenance targets / recovery context | No | No |
| Active energy (calories) | Read | Weekly energy / weight-loss targets | No | No |
| Body mass (weight) | Read | Weight-loss / maintenance targets | No | No |
| Workouts | Read | Show recent training, avoid double-counting | No | No |
| Workouts | Write | Save completed Zone 2 / 4×4 sessions to Apple Health | No (stays in Apple Health on device) | No |

The corresponding Info.plist usage strings (already set in the project) are:
- **NSHealthShareUsageDescription:** "Reads your heart rate, workouts, active energy,
  resting heart rate and body weight to calculate your training zones and weekly
  targets."
- **NSHealthUpdateUsageDescription:** "Saves your Zone 2 and Norwegian 4×4 workouts to
  Apple Health."

---

## Tracking question

If asked about **tracking** (linking data to third-party data for advertising or
sharing with data brokers):

**Answer: No tracking.** The App does not track users, does not use the
AppTrackingTransparency / IDFA framework, and contains no advertising or analytics.

---

## If App Store Connect still forces per-type questions

Some flows ask follow-ups before accepting "No." If you are ever pushed to declare a
data type anyway, answer truthfully for each Health type:

- **Data Use:** "App Functionality" only (never "Third-Party Advertising," "Developer's
  Advertising or Marketing," or "Analytics").
- **Linked to the user's identity:** No.
- **Used for tracking:** No.

But the correct and expected outcome for this app is **"No, we do not collect data" →
"Data Not Collected."**
