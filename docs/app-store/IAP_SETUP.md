# Pro Lifetime IAP — App Store Connect setup

The code ships gated behind one non-consumable. Local testing works today via
`Z24x4.storekit` (attached to the run scheme); the real product needs one-time
ASC setup before the paywall can charge anyone.

App facts:
- Product ID: **`ca.logolo.z24x4.pro.lifetime`** (must match `ProStore.productID`)
- Type: **Non-Consumable**, Family Sharing **on**
- Reference name: Pro Lifetime
- Price: **Tier for US$14.99** (set regional prices from the US anchor)
- Grandfathering: first launch before **2026-08-01** is Pro free forever
  (`ProStore.grandfatherCutoff`) — the v1.0 launch cohort. Adjust the constant
  before shipping if the paywall release slips.

## Steps

1. App Store Connect → My Apps → Z2/4×4 Trainer → **Monetization → In-App
   Purchases** → “+” → Non-Consumable.
2. Product ID exactly `ca.logolo.z24x4.pro.lifetime`; reference name Pro Lifetime.
3. Pricing: US$14.99 anchor; review the auto-generated regional prices.
4. Localizations (display name ≤30 chars / description ≤45 chars):
   - en-US: `Z2/4×4 Pro (Lifetime)` / `Readiness, overtraining guard, coaching, export.`
   - zh-Hant: `Z2/4×4 Pro（買斷）` / `完整 readiness、過度訓練防護、教練、匯出。`
   - es / ja: mirror the paywall strings in `App/Localizable.xcstrings`.
5. Review screenshot: capture the paywall (Settings → Unlock Pro) on a 6.9"
   simulator; upload under the IAP’s App Review Information.
6. Turn **Family Sharing** on (matches `Z24x4.storekit`).
7. Submit the IAP **with the app version** (first IAP must ride an app review).
8. After approval, sanity-check a real purchase on TestFlight (sandbox account),
   including **Restore purchase**.

## Review-guideline checklist (3.1.1 / 3.1.2)

- [x] Explicit Restore button on the paywall.
- [x] Price shown from `Product.displayPrice` (never hardcoded).
- [x] No external purchase links.
- [x] Free tier remains fully functional (workouts, plans, zones, sync).
- [x] App description: "FREE + AN OPTIONAL ONE-TIME UPGRADE" section added to
      `METADATA.md` (2026-07-06) — copy into ASC with the next metadata update.
- [x] Privacy policy: "In-app purchases" section added to both
      `PRIVACY_POLICY.md` and the hosted `privacy-policy.html` (2026-07-06) —
      push to publish via GitHub Pages.

## Testing locally (no ASC needed)

- Run scheme already points at `Z24x4.storekit` — purchase flows work in the
  simulator immediately; manage/refund via Xcode → Debug → StoreKit →
  Manage Transactions.
- `-pro` launch argument force-unlocks (UI tests / screenshots).
- Unit tests: `ProGrandfatherTests` covers the launch-cohort rule.
