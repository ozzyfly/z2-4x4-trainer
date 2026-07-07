# App Store Listing Metadata — Z2/4×4 Trainer (v1.0 draft)

Copy these fields into App Store Connect. Character limits noted; counts verified for
the limited fields. Edit to taste, but keep within the limits.

---

## App Name (max 30 chars)

```
Z2/4×4 Trainer
```
(14 chars.)

> Note: the "×" is the multiplication sign U+00D7, matching the project's display name.
> If a field rejects it, use `Z2/4x4 Trainer` (lowercase x).

---

## Subtitle (max 30 chars)

```
Zone 2 & 4×4 cardio coach
```
(25 chars. Alternative within limit: `Zone 2 + Norwegian 4×4 plan` = 27.)

---

## Promotional Text (max 170 chars; editable any time without a new build)

```
Train smarter, not just harder. Get daily Zone 2 and Norwegian 4×4 workouts based on your real heart rate — 100% on your device, no account, nothing uploaded.
```
(155 chars.)

---

## Description (max 4000 chars)

```
Z2/4×4 Trainer turns the two most effective endurance methods — easy Zone 2 base work and high-intensity Norwegian 4×4 intervals — into a simple daily plan built around YOUR heart rate.

WHAT YOU GET
• Daily and weekly Zone 2 prescriptions at 60–70% of your max heart rate to build your aerobic base.
• Norwegian 4×4 sessions: four 4-minute intervals at 85–95% of max heart rate, with 3-minute recoveries — the protocol used to boost VO2 max.
• Weekly health-maintenance and weight-loss targets to keep you consistent.
• Personalized zones from your max heart rate (220 − age), which you can override if you know your true max.

WORKS WITH APPLE HEALTH
• Pull in your heart rate, resting heart rate, active energy, body weight, and past workouts — or enter everything manually. Your choice.
• Completed Zone 2 and 4×4 workouts are saved back to Apple Health so all your training lives in one place.

IPHONE + APPLE WATCH
• Plan and review on iPhone; train with your zones on your wrist.

PRIVATE BY DESIGN
• 100% on-device. No account, no sign-up, no server.
• Nothing you enter or that we read from Apple Health ever leaves your device.
• No ads, no analytics, no tracking, no third-party SDKs.
• Your Health data is never used for advertising — ever.

WHO IT'S FOR
• Runners, cyclists, rowers, and anyone doing cardio who wants structure instead of guesswork.
• Beginners building a base and experienced athletes adding VO2-max work.

FREE + AN OPTIONAL ONE-TIME UPGRADE
• Everything above is free: guided workouts on iPhone and Apple Watch, plans, zones, Apple Health sync.
• One optional one-time purchase (Pro) unlocks the deeper coaching analysis: full readiness breakdown, overtraining guard, adaptive weekly progression, VO2-max trend, and CSV/JSON export. No subscription.

Z2/4×4 Trainer is a fitness and training tool, not a medical device. It does not diagnose, treat, or prevent any disease. Talk to a healthcare professional before starting a new exercise program.
```

---

## Keywords (max 100 chars, comma-separated, no spaces after commas to save room)

Recommended final (95 chars):
```
vo2 max,heart rate,interval,hiit,norwegian,endurance,running,cycling,aerobic,base,fitness,zones
```

> Why these: Apple already indexes every word in the app **name** ("Z2/4×4 Trainer")
> and **subtitle** ("Zone 2 & 4×4 cardio coach") — so `zone`, `2`, `4x4`, `cardio`,
> `coach`, `trainer` are free and repeating them in the keyword field wastes limit.
> Spend the 100 chars on terms users actually search that aren't in the name:
> `vo2 max`, `hiit`, `norwegian`, `aerobic base`, sport names.
>
> Tips: don't use plurals AND singulars; no spaces needed after commas (Apple
> ignores them but they waste limit); keywords can be changed with every new
> version — revisit after checking search performance in App Store Connect →
> Analytics once live.

---

## Category

- **Primary category:** Health & Fitness
- **Secondary category (optional):** Sports

---

## Support URL (required) — placeholder

```
https://logolo.ca/z24x4/support
```
A simple page describing the app with a contact email works. A `mailto:ozzyfly@logolo.ca`
landing page or a GitHub Pages page is acceptable. **Replace with a real, reachable URL
before submitting.**

## Marketing URL (optional) — placeholder

```
https://logolo.ca/z24x4
```

## Privacy Policy URL (required for HealthKit) — placeholder

```
https://<your-username>.github.io/z24x4/privacy
```
Publish `docs/app-store/PRIVACY_POLICY.md` via GitHub Pages (or any host) and use that
real URL. **Must load or the app will be rejected.**

---

## Age Rating questionnaire answers (expected result: 4+)

Answer **None / No** to all content questions for this app:

- Cartoon or Fantasy Violence: **None**
- Realistic Violence: **None**
- Sexual Content or Nudity: **None**
- Profanity or Crude Humor: **None**
- Alcohol, Tobacco, or Drug Use or References: **None**
- Mature/Suggestive Themes: **None**
- Horror/Fear Themes: **None**
- Medical/Treatment Information: **None** (the app gives fitness guidance, not medical
  diagnosis/treatment — but if App Store Connect asks specifically about
  "Health/Fitness" topics, answer truthfully; it should still resolve to 4+/no
  restriction)
- Gambling, Contests: **No**
- Unrestricted Web Access: **No**
- Made for Kids: **No** (this is a general-audience fitness app, not in the Kids
  category)

**Expected age rating: 4+.**

---

## App Review Information

- **Sign-in required?** No (no account).
- **Demo account:** Not applicable.
- **Contact:** ozzyfly@logolo.ca
- **Notes:** See the HealthKit review notes in
  `docs/app-store/SUBMISSION_CHECKLIST.md` (section 10). Paste them here.

---

## "What's New in This Version" — v1.0 (max 4000 chars)

```
Welcome to Z2/4×4 Trainer 1.0!

• Daily and weekly Zone 2 workouts (60–70% max heart rate) to build your aerobic base.
• Norwegian 4×4 interval sessions (4 × 4 min at 85–95% max HR, 3 min recovery) for VO2-max gains.
• Weekly health-maintenance and weight-loss targets.
• Personalized zones from your age-based max heart rate, with manual override.
• Apple Health integration: read heart rate, resting HR, active energy, weight, and workouts, and save completed sessions back to Health.
• iPhone + Apple Watch.
• 100% on-device and private — no account, no servers, no tracking.

Thanks for training with us. Questions or feedback? Email ozzyfly@logolo.ca.
```

---

## Pricing / Availability (set in App Store Connect)

- **Price:** Free (suggested for v1.0) — adjust as you wish.
- **Availability:** All territories, or limit as desired.
