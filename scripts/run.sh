#!/bin/bash
# Build and launch on an already booted iPhone simulator. No API key required.
set -euo pipefail
cd "$(dirname "$0")/.."
SIM=$(xcrun simctl list devices booted -j | python3 -c 'import json,sys; print(next((d["udid"] for ds in json.load(sys.stdin)["devices"].values() for d in ds if d["state"] == "Booted" and "iPhone" in d["name"]), ""))')
if [ -z "$SIM" ]; then
  echo "Boot an iPhone simulator in Xcode or Simulator, then run this command again." >&2
  exit 1
fi
xcodebuild -project FirstChapter.xcodeproj -scheme FirstChapter -destination "platform=iOS Simulator,id=$SIM" -derivedDataPath build CODE_SIGNING_ALLOWED=NO build -quiet
xcrun simctl install "$SIM" build/Build/Products/Debug-iphonesimulator/FirstChapter.app
xcrun simctl terminate "$SIM" com.tonybi.firstchapter 2>/dev/null || true
xcrun simctl launch "$SIM" com.tonybi.firstchapter
