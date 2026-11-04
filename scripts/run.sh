#!/bin/bash
# Builds and launches First Chapter on the booted simulator.
# Optional: asks once for a DeepSeek API key and keeps it in a gitignored file.
set -e
cd "$(dirname "$0")/.."
SECRETS=FirstChapter/Secrets.plist
if [ ! -f "$SECRETS" ]; then
  read -r -s -p "DeepSeek API key (press Enter to skip): " KEY; echo
  if [ -n "$KEY" ]; then
    /usr/libexec/PlistBuddy -c "Add :DEEPSEEK_API_KEY string $KEY" "$SECRETS" >/dev/null
  fi
fi
SIM=$(xcrun simctl list devices booted | grep -E 'iPhone' | head -1 | sed -E 's/.*\(([0-9A-F-]{36})\).*/\1/')
xcodebuild -project FirstChapter.xcodeproj -scheme FirstChapter -destination "platform=iOS Simulator,id=$SIM" -derivedDataPath build build -quiet
xcrun simctl install "$SIM" build/Build/Products/Debug-iphonesimulator/FirstChapter.app
xcrun simctl terminate "$SIM" com.tonybi.firstchapter 2>/dev/null || true
xcrun simctl launch "$SIM" com.tonybi.firstchapter
