#!/usr/bin/env python3
"""Push App Store listing text to App Store Connect via the API.

Sets app name + subtitle + privacy-policy URL (appInfoLocalizations) and
description + keywords + promotional text + support/marketing URLs
(appStoreVersionLocalizations) for the editable 1.0 version.

Run with the system python (working SSL); HTTP goes through curl so it does not
depend on python's CA bundle. Reads ASC_KEY_ID/ASC_ISSUER_ID/ASC_KEY_PATH from env.
Mints the JWT via scripts/asc_jwt.py (needs the `cryptography`-capable python3).
"""
import json
import subprocess
import sys

BID = "ca.logolo.z24x4.Z24x4Trainer"
LOCALE = "en-US"
API = "https://api.appstoreconnect.apple.com"

NAME = "Z2/4×4 Trainer"
SUBTITLE = "Zone 2 & 4×4 cardio coach"
PRIVACY_URL = "https://ozzyfly.github.io/z2-4x4-trainer/privacy-policy.html"
SUPPORT_URL = "https://logolo.ca/z24x4/support"
MARKETING_URL = "https://logolo.ca/z24x4"
KEYWORDS = ("zone 2,4x4,norwegian,VO2 max,heart rate,cardio,interval,"
            "HIIT,endurance,running,cycling,fitness")
PROMO = ("Train smarter, not just harder. Get daily Zone 2 and Norwegian 4×4 workouts "
         "based on your real heart rate — 100% on your device, no account, nothing uploaded.")
DESCRIPTION = """Z2/4×4 Trainer turns the two most effective endurance methods — easy Zone 2 base work and high-intensity Norwegian 4×4 intervals — into a simple daily plan built around YOUR heart rate.

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

Z2/4×4 Trainer is a fitness and training tool, not a medical device. It does not diagnose, treat, or prevent any disease. Talk to a healthcare professional before starting a new exercise program."""


def token():
    return subprocess.run(["python3", "scripts/asc_jwt.py"],
                          capture_output=True, text=True, check=True).stdout.strip()


def curl(method, path, tok, body=None):
    cmd = ["curl", "-s", "-X", method, f"{API}{path}",
           "-H", f"Authorization: Bearer {tok}"]
    if body is not None:
        cmd += ["-H", "Content-Type: application/json", "--data-binary", json.dumps(body)]
    out = subprocess.run(cmd, capture_output=True, text=True).stdout
    try:
        return json.loads(out) if out.strip() else {}
    except json.JSONDecodeError:
        return {"_raw": out}


def patch(path, tok, typ, rid, attrs):
    body = {"data": {"type": typ, "id": rid, "attributes": attrs}}
    r = curl("PATCH", path, tok, body)
    ok = "data" in r
    print(f"  PATCH {path} -> {'ok' if ok else 'ERR ' + json.dumps(r.get('errors', r))[:300]}")
    return ok


def loc_for(items, locale):
    for it in items:
        if it["attributes"].get("locale") == locale:
            return it
    return items[0] if items else None


def main():
    tok = token()
    apps = curl("GET", f"/v1/apps?filter%5BbundleId%5D={BID}", tok).get("data", [])
    if not apps:
        print("App not found for bundle id", BID); sys.exit(1)
    app_id = apps[0]["id"]
    print("app id:", app_id, "name:", apps[0]["attributes"].get("name"))

    # --- App Info localization: name, subtitle, privacy URL ---
    appinfos = curl("GET", f"/v1/apps/{app_id}/appInfos", tok).get("data", [])
    appinfo_id = appinfos[0]["id"]
    locs = curl("GET", f"/v1/appInfos/{appinfo_id}/appInfoLocalizations", tok).get("data", [])
    loc = loc_for(locs, LOCALE)
    print("appInfoLocalization:", loc["attributes"].get("locale"), loc["id"])
    patch(f"/v1/appInfoLocalizations/{loc['id']}", tok, "appInfoLocalizations", loc["id"],
          {"name": NAME, "subtitle": SUBTITLE})
    # privacy URL may live on the same resource; tolerate rejection.
    patch(f"/v1/appInfoLocalizations/{loc['id']}", tok, "appInfoLocalizations", loc["id"],
          {"privacyPolicyUrl": PRIVACY_URL})

    # --- Version localization: description, keywords, promo, URLs ---
    versions = curl("GET", f"/v1/apps/{app_id}/appStoreVersions?limit=5", tok).get("data", [])
    if not versions:
        print("No app store version found"); sys.exit(1)
    ver = versions[0]
    print("version:", ver["attributes"].get("versionString"), ver["attributes"].get("appStoreState"))
    vlocs = curl("GET", f"/v1/appStoreVersions/{ver['id']}/appStoreVersionLocalizations", tok).get("data", [])
    vloc = loc_for(vlocs, LOCALE)
    print("versionLocalization:", vloc["attributes"].get("locale"), vloc["id"])
    patch(f"/v1/appStoreVersionLocalizations/{vloc['id']}", tok,
          "appStoreVersionLocalizations", vloc["id"],
          {"description": DESCRIPTION, "keywords": KEYWORDS, "promotionalText": PROMO,
           "supportUrl": SUPPORT_URL, "marketingUrl": MARKETING_URL})
    print("done.")


if __name__ == "__main__":
    main()
