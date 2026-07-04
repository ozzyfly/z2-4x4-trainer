#!/usr/bin/env bash
# Archive the iOS app and export an App Store .ipa — or, with --upload, hand the
# archive straight to App Store Connect. Fully headless using an App Store
# Connect API key (no Xcode account needed).
#
# Create the key: App Store Connect → Users and Access → Integrations →
#   App Store Connect API → generate (role: App Manager). Download the .p8 ONCE.
#
# Required env:
#   DEVELOPMENT_TEAM   Apple Team ID (e.g. 2NXQLV6CJH)
#   ASC_KEY_ID         API Key ID (10 chars)
#   ASC_ISSUER_ID      API Issuer ID (UUID)
#   ASC_KEY_PATH       path to the AuthKey_XXXX.p8 file (keep OUTSIDE the repo)
# Optional env:
#   BUILD_NUMBER       overrides the auto build number (default: git commit count,
#                      so every commit yields a unique, monotonically increasing
#                      CFBundleVersion — no manual project.yml bumps).
#
# Usage:
#   …env… scripts/archive-and-export.sh            # archive + export build/export/*.ipa
#   …env… scripts/archive-and-export.sh --upload   # archive + upload to ASC (TestFlight)
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

# Monotonic build number from the commit count — uploading the same commit twice
# reuses the number (ASC rejects duplicates), a new commit always increments.
BUILD_NUMBER="${BUILD_NUMBER:-$(git rev-list --count HEAD)}"
echo "▶︎ Build number: ${BUILD_NUMBER}"

AUTH=(-authenticationKeyPath "$ASC_KEY_PATH"
      -authenticationKeyID "$ASC_KEY_ID"
      -authenticationKeyIssuerID "$ASC_ISSUER_ID"
      -allowProvisioningUpdates)

xcodegen generate

# ExportOptions with the team ID filled in. destination=upload sends the archive
# straight to App Store Connect (validates server-side) — the modern replacement
# for the deprecated `altool --validate-app/--upload-app` pair.
if [ "${1:-}" = "--upload" ]; then
  DESTINATION="upload"
else
  DESTINATION="export"
fi
sed -e "s/YOUR_TEAM_ID/${DEVELOPMENT_TEAM}/" \
    -e "s/<string>export<\/string>/<string>${DESTINATION}<\/string>/" \
    docs/app-store/ExportOptions.plist > ExportOptions.plist

echo "▶︎ Archiving ${SCHEME} (Release)…"
xcodebuild archive \
  -project Z24x4Trainer.xcodeproj \
  -scheme "${SCHEME}" \
  -configuration Release \
  -destination 'generic/platform=iOS' \
  -archivePath "${ARCHIVE}" \
  DEVELOPMENT_TEAM="${DEVELOPMENT_TEAM}" \
  CURRENT_PROJECT_VERSION="${BUILD_NUMBER}" \
  "${AUTH[@]}"

if [ "$DESTINATION" = "upload" ]; then
  echo "▶︎ Uploading to App Store Connect…"
  xcodebuild -exportArchive \
    -archivePath "${ARCHIVE}" \
    -exportOptionsPlist ExportOptions.plist \
    "${AUTH[@]}"
  echo "✓ Uploaded build ${BUILD_NUMBER}. Check App Store Connect → TestFlight (processing takes a few minutes)."
else
  echo "▶︎ Exporting App Store .ipa…"
  xcodebuild -exportArchive \
    -archivePath "${ARCHIVE}" \
    -exportOptionsPlist ExportOptions.plist \
    -exportPath "${EXPORT_DIR}" \
    "${AUTH[@]}"
  echo "✓ Exported: ${IPA}"
  echo "Next: re-run with --upload, or upload ${IPA} via Xcode Organizer."
fi
