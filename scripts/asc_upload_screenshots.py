#!/usr/bin/env python3
"""Upload iPhone screenshots to the App Store Connect 1.0 version localization.

Reserve → PUT bytes to the pre-signed upload operations → commit with md5 checksum.
Reads ASC_KEY_ID/ASC_ISSUER_ID/ASC_KEY_PATH from env; HTTP via curl; JWT via asc_jwt.py.

Usage: python3 scripts/asc_upload_screenshots.py APP_IPHONE_67 docs/app-store/screenshots/*.png
"""
import glob
import hashlib
import json
import os
import subprocess
import sys
import tempfile

API = "https://api.appstoreconnect.apple.com"
APP_BUNDLE = "ca.logolo.z24x4.Z24x4Trainer"


def token():
    return subprocess.run(["python3", "scripts/asc_jwt.py"],
                          capture_output=True, text=True, check=True).stdout.strip()


def curl(method, path_or_url, tok=None, body=None, headers=None, data_file=None):
    url = path_or_url if path_or_url.startswith("http") else API + path_or_url
    cmd = ["curl", "-s", "-X", method, url]
    if tok:
        cmd += ["-H", f"Authorization: Bearer {tok}"]
    for h in (headers or []):
        cmd += ["-H", f"{h['name']}: {h['value']}"]
    if body is not None:
        cmd += ["-H", "Content-Type: application/json", "--data-binary", json.dumps(body)]
    if data_file is not None:
        cmd += ["--data-binary", "@" + data_file]
    out = subprocess.run(cmd, capture_output=True, text=True).stdout
    return out


def jget(s):
    try:
        return json.loads(s) if s.strip() else {}
    except json.JSONDecodeError:
        return {"_raw": s[:300]}


def main():
    display_type = sys.argv[1]
    files = []
    for pat in sys.argv[2:]:
        files += sorted(glob.glob(pat))
    tok = token()

    app = jget(curl("GET", f"/v1/apps?filter%5BbundleId%5D={APP_BUNDLE}", tok))["data"][0]["id"]
    ver = jget(curl("GET", f"/v1/apps/{app}/appStoreVersions?limit=1", tok))["data"][0]["id"]
    vlocs = jget(curl("GET", f"/v1/appStoreVersions/{ver}/appStoreVersionLocalizations", tok))["data"]
    vloc = next((v for v in vlocs if v["attributes"]["locale"] == "en-US"), vlocs[0])["id"]
    print("version localization:", vloc)

    # Reuse an existing set for this display type, else create one.
    sets = jget(curl("GET", f"/v1/appStoreVersionLocalizations/{vloc}/appScreenshotSets", tok)).get("data", [])
    sset = next((s for s in sets if s["attributes"]["screenshotDisplayType"] == display_type), None)
    if sset:
        set_id = sset["id"]
        print("reusing screenshot set:", set_id)
    else:
        body = {"data": {"type": "appScreenshotSets",
                         "attributes": {"screenshotDisplayType": display_type},
                         "relationships": {"appStoreVersionLocalization": {
                             "data": {"type": "appStoreVersionLocalizations", "id": vloc}}}}}
        r = jget(curl("POST", "/v1/appScreenshotSets", tok, body=body))
        if "data" not in r:
            print("set create ERR:", json.dumps(r.get("errors", r))[:400]); sys.exit(1)
        set_id = r["data"]["id"]
        print("created screenshot set:", set_id)

    for path in files:
        data = open(path, "rb").read()
        name = os.path.basename(path)
        # 1. reserve
        body = {"data": {"type": "appScreenshots",
                         "attributes": {"fileName": name, "fileSize": len(data)},
                         "relationships": {"appScreenshotSet": {
                             "data": {"type": "appScreenshotSets", "id": set_id}}}}}
        r = jget(curl("POST", "/v1/appScreenshots", tok, body=body))
        if "data" not in r:
            print(f"  {name}: reserve ERR", json.dumps(r.get("errors", r))[:300]); continue
        sid = r["data"]["id"]
        ops = r["data"]["attributes"]["uploadOperations"]
        # 2. PUT each operation's byte range
        for op in ops:
            chunk = data[op["offset"]:op["offset"] + op["length"]]
            with tempfile.NamedTemporaryFile(delete=False) as tf:
                tf.write(chunk); tmp = tf.name
            curl(op["method"], op["url"], headers=op.get("requestHeaders"), data_file=tmp)
            os.unlink(tmp)
        # 3. commit
        md5 = hashlib.md5(data).hexdigest()
        body = {"data": {"type": "appScreenshots", "id": sid,
                         "attributes": {"uploaded": True, "sourceFileChecksum": md5}}}
        r = jget(curl("PATCH", f"/v1/appScreenshots/{sid}", tok, body=body))
        state = r.get("data", {}).get("attributes", {}).get("assetDeliveryState", {})
        print(f"  {name}: committed ({len(data)} bytes) ->",
              "ok" if "data" in r else json.dumps(r.get("errors", r))[:200], state.get("state", ""))


if __name__ == "__main__":
    main()
