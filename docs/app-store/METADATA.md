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

## "What's New in This Version" — v1.0.2 (max 4000 chars each)

Paste each into its matching App Store Connect localization. English is the
primary; the other seven mirror it.

### en-US

```
New in 1.0.2:

• Training guide — a new section under Settings explaining why Zone 2 and the Norwegian 4×4 work, and what this app does differently.
• Your call on hard days — when low readiness reduces a 4×4 to three intervals, you can now choose to run the full session anyway, on both iPhone and Apple Watch.
• More accurate history — a reduced 4×4 now logs its real duration instead of the full session's, so your weekly minutes and streaks reflect what you actually did.
• Redeem an App Store code for Pro from the upgrade screen.

Questions or feedback? Email ozzyfly@logolo.ca.
```

### de-DE

```
Neu in 1.0.2:

• Trainingsleitfaden — ein neuer Bereich in den Einstellungen, der erklärt, warum Zone 2 und das norwegische 4×4 wirken und was diese App anders macht.
• Du entscheidest an harten Tagen — wenn niedrige Bereitschaft ein 4×4 auf drei Intervalle reduziert, kannst du jetzt trotzdem die volle Einheit wählen, auf iPhone und Apple Watch.
• Genauerer Verlauf — ein reduziertes 4×4 wird jetzt mit seiner tatsächlichen Dauer statt der vollen protokolliert, sodass deine Wochenminuten und Serien widerspiegeln, was du wirklich getan hast.
• Löse einen App-Store-Code für Pro direkt im Upgrade-Bereich ein.

Fragen oder Feedback? E-Mail an ozzyfly@logolo.ca.
```

### es-ES

```
Novedades en 1.0.2:

• Guía de entrenamiento — una nueva sección en Ajustes que explica por qué funcionan la Zona 2 y el 4×4 noruego, y qué hace diferente esta app.
• Tú decides en los días duros — cuando una preparación baja reduce un 4×4 a tres intervalos, ahora puedes elegir hacer la sesión completa de todos modos, en iPhone y Apple Watch.
• Historial más preciso — un 4×4 reducido ahora registra su duración real en lugar de la de la sesión completa, así tus minutos semanales y tus rachas reflejan lo que de verdad hiciste.
• Canjea un código del App Store para Pro desde la pantalla de mejora.

¿Preguntas o comentarios? Escribe a ozzyfly@logolo.ca.
```

### fr-FR

```
Nouveautés de la version 1.0.2 :

• Guide d'entraînement — une nouvelle section dans les Réglages qui explique pourquoi la Zone 2 et le 4×4 norvégien fonctionnent, et ce que cette appli fait différemment.
• À toi de décider les jours difficiles — lorsqu'une forme basse réduit un 4×4 à trois intervalles, tu peux désormais choisir de faire quand même la séance complète, sur iPhone et Apple Watch.
• Historique plus précis — un 4×4 réduit enregistre maintenant sa durée réelle au lieu de celle de la séance complète, pour que tes minutes hebdomadaires et tes séries reflètent ce que tu as vraiment fait.
• Utilise un code App Store pour Pro depuis l'écran de mise à niveau.

Des questions ou des remarques ? Écris à ozzyfly@logolo.ca.
```

### ja

```
1.0.2の新機能:

• トレーニングガイド — 設定内の新しいセクションで、ゾーン2とノルウェー式4×4がなぜ効くのか、このアプリが何を変えているのかを解説します。
• きつい日はあなたが決める — レディネスが低く4×4が3インターバルに短縮された場合でも、フルセッションを選べるようになりました（iPhoneとApple Watchの両方）。
• より正確な履歴 — 短縮版4×4がフルセッションではなく実際の時間で記録されるようになり、週の運動時間や連続記録が実際に行った内容を反映します。
• アップグレード画面からApp Storeコードを使ってProを利用できます。

ご質問やご意見は ozzyfly@logolo.ca までお寄せください。
```

### ko

```
1.0.2의 새로운 기능:

• 트레이닝 가이드 — 존2와 노르웨이식 4×4가 왜 효과적인지, 이 앱이 무엇을 다르게 하는지 설명하는 새 섹션이 설정에 추가되었습니다.
• 힘든 날의 선택은 당신에게 — 준비도가 낮아 4×4가 3회로 축소되어도 이제 전체 세션을 진행하도록 선택할 수 있습니다(iPhone과 Apple Watch 모두).
• 더 정확한 기록 — 축소된 4×4가 전체 세션이 아닌 실제 시간으로 기록되므로, 주간 운동 시간과 연속 기록이 실제로 한 운동을 반영합니다.
• 업그레이드 화면에서 App Store 코드로 Pro를 사용할 수 있습니다.

문의나 의견은 ozzyfly@logolo.ca 로 보내주세요.
```

### pt-BR

```
Novidades na 1.0.2:

• Guia de treino — uma nova seção nos Ajustes explicando por que a Zona 2 e o 4×4 norueguês funcionam, e o que este app faz de diferente.
• A decisão é sua nos dias difíceis — quando a prontidão baixa reduz um 4×4 a três intervalos, agora você pode escolher fazer a sessão completa mesmo assim, no iPhone e no Apple Watch.
• Histórico mais preciso — um 4×4 reduzido agora registra sua duração real em vez da sessão completa, então seus minutos semanais e sequências refletem o que você realmente fez.
• Resgate um código da App Store para o Pro na tela de upgrade.

Dúvidas ou sugestões? Escreva para ozzyfly@logolo.ca.
```

### zh-Hant

```
1.0.2 新增內容：

• 訓練指南 — 設定裡新增一個章節，說明 Zone 2 與挪威式 4×4 為什麼有效，以及這個 app 做了哪些不一樣的事。
• 高強度日由你決定 — 當 Readiness 偏低把 4×4 減為三趟時，現在你可以選擇還是做完整課表，iPhone 與 Apple Watch 都支援。
• 更準確的紀錄 — 減量版 4×4 現在會記錄實際時長，而不是完整課表的時長，讓每週訓練分鐘數與連續紀錄反映你真正做的量。
• 可在升級畫面用 App Store 代碼兌換 Pro。

有問題或建議？請寄到 ozzyfly@logolo.ca。
```

---

## Pricing / Availability (set in App Store Connect)

- **Price:** Free (suggested for v1.0) — adjust as you wish.
- **Availability:** All territories, or limit as desired.
