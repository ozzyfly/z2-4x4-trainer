#!/usr/bin/env bash
# Archive the iOS app and export an App Store .ipa, ready for upload.
#
# Prereqs: enrolled Apple Developer account; you are signed into that Apple ID in
# Xcode (Settings → Accounts). Find your Team ID on the portal Membership page.
#
# Usage:
#   DEVELOPMENT_TEAM=ABCDE12345 scripts/archive-and-export.sh
#
# Then upload build/export/Z24x4Trainer.ipa via Xcode Organizer or:
#   xcrun altool --upload-app -f build/export/Z24x4Trainer.ipa -t ios \
#     --apiKey <KEY_ID> --apiIssuer <ISSUER_ID>
set -euo pipefail

cd "$(dirname "$0")/.."

: "${DEVELOPMENT_TEAM:?Set DEVELOPMENT_TEAM=<your Apple Team ID>}"

SCHEME="Z24x4Trainer"
ARCHIVE="build/Z24x4Trainer.xcarchive"
EXPORT_DIR="build/export"

# Regenerate the project from project.yml.
xcodegen generate

# Prepare ExportOptions.plist from the template with the team ID substituted.
sed "s/YOUR_TEAM_ID/${DEVELOPMENT_TEAM}/" docs/app-store/ExportOptions.plist > ExportOptions.plist

echo "▶︎ Archiving ${SCHEME} (Release)…"
xcodebuild archive \
  -project Z24x4Trainer.xcodeproj \
  -scheme "${SCHEME}" \
  -configuration Release \
  -destination 'generic/platform=iOS' \
  -archivePath "${ARCHIVE}" \
  DEVELOPMENT_TEAM="${DEVELOPMENT_TEAM}" \
  -allowProvisioningUpdates

echo "▶︎ Exporting App Store .ipa…"
xcodebuild -exportArchive \
  -archivePath "${ARCHIVE}" \
  -exportOptionsPlist ExportOptions.plist \
  -exportPath "${EXPORT_DIR}" \
  -allowProvisioningUpdates

echo "✓ Done. Upload: ${EXPORT_DIR}/Z24x4Trainer.ipa"
