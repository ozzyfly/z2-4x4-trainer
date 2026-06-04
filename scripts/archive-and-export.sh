#!/usr/bin/env bash
# Archive the iOS app, export an App Store .ipa, and (optionally) upload it —
# fully headless using an App Store Connect API key (no Xcode account needed).
#
# Create the key: App Store Connect → Users and Access → Integrations →
#   App Store Connect API → generate (role: App Manager). Download the .p8 ONCE.
#
# Required env:
#   DEVELOPMENT_TEAM   Apple Team ID (e.g. HF6XYU9Y2N)
#   ASC_KEY_ID         API Key ID (10 chars)
#   ASC_ISSUER_ID      API Issuer ID (UUID)
#   ASC_KEY_PATH       path to the AuthKey_XXXX.p8 file (keep OUTSIDE the repo)
#
# Usage:
#   DEVELOPMENT_TEAM=HF6XYU9Y2N ASC_KEY_ID=ABC123 ASC_ISSUER_ID=uuid \
#     ASC_KEY_PATH=~/keys/AuthKey_ABC123.p8 scripts/archive-and-export.sh           # archive + export
#   …same env… scripts/archive-and-export.sh --upload                               # also upload to ASC
set -euo pipefail
cd "$(dirname "$0")/.."

: "${DEVELOPMENT_TEAM:?Set DEVELOPMENT_TEAM=<your Apple Team ID>}"
: "${ASC_KEY_ID:?Set ASC_KEY_ID=<App Store Connect API Key ID>}"
: "${ASC_ISSUER_ID:?Set ASC_ISSUER_ID=<App Store Connect API Issuer ID>}"
: "${ASC_KEY_PATH:?Set ASC_KEY_PATH=<path to AuthKey_XXXX.p8>}"
[ -f "$ASC_KEY_PATH" ] || { echo "API key not found: $ASC_KEY_PATH" >&2; exit 1; }

SCHEME="Z24x4Trainer"
ARCHIVE="build/Z24x4Trainer.xcarchive"
EXPORT_DIR="build/export"
IPA="${EXPORT_DIR}/${SCHEME}.ipa"

AUTH=(-authenticationKeyPath "$ASC_KEY_PATH"
      -authenticationKeyID "$ASC_KEY_ID"
      -authenticationKeyIssuerID "$ASC_ISSUER_ID"
      -allowProvisioningUpdates)

xcodegen generate

# ExportOptions with the team ID filled in.
sed "s/YOUR_TEAM_ID/${DEVELOPMENT_TEAM}/" docs/app-store/ExportOptions.plist > ExportOptions.plist

echo "▶︎ Archiving ${SCHEME} (Release)…"
xcodebuild archive \
  -project Z24x4Trainer.xcodeproj \
  -scheme "${SCHEME}" \
  -configuration Release \
  -destination 'generic/platform=iOS' \
  -archivePath "${ARCHIVE}" \
  DEVELOPMENT_TEAM="${DEVELOPMENT_TEAM}" \
  "${AUTH[@]}"

echo "▶︎ Exporting App Store .ipa…"
xcodebuild -exportArchive \
  -archivePath "${ARCHIVE}" \
  -exportOptionsPlist ExportOptions.plist \
  -exportPath "${EXPORT_DIR}" \
  "${AUTH[@]}"

echo "✓ Exported: ${IPA}"

if [ "${1:-}" = "--upload" ]; then
  # altool locates the key by ID in a known dir; place a copy there.
  KEYDIR="$HOME/.appstoreconnect/private_keys"
  mkdir -p "$KEYDIR"
  cp "$ASC_KEY_PATH" "$KEYDIR/AuthKey_${ASC_KEY_ID}.p8"
  echo "▶︎ Validating…"
  xcrun altool --validate-app -f "${IPA}" -t ios \
    --apiKey "${ASC_KEY_ID}" --apiIssuer "${ASC_ISSUER_ID}"
  echo "▶︎ Uploading to App Store Connect…"
  xcrun altool --upload-app -f "${IPA}" -t ios \
    --apiKey "${ASC_KEY_ID}" --apiIssuer "${ASC_ISSUER_ID}"
  echo "✓ Uploaded. Check App Store Connect → TestFlight (processing takes a few minutes)."
else
  echo "Next: re-run with --upload, or upload ${IPA} via Xcode Organizer."
fi
