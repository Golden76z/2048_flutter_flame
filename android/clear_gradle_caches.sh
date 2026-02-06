#!/usr/bin/env bash
# Cleans Gradle/Kotlin caches that can cause "NoSuchFileException" for
# Flutter's gradle plugin Kotlin compiler session (.salive) files.
# Run from project root: bash android/clear_gradle_caches.sh

set -euo pipefail
cd "$(dirname "$0")/.."

echo "Stopping Gradle daemons..."
(cd android && ./gradlew --stop 2>/dev/null) || true

echo "Cleaning Flutter build..."
flutter clean

echo "Removing project Android .gradle and build dirs..."
rm -rf android/.gradle android/app/build android/build build

echo "Removing Flutter SDK Gradle plugin cache (fixes :gradle:compileKotlin .salive error)..."
FLUTTER_SDK="${FLUTTER_ROOT:-}"
if [ -z "$FLUTTER_SDK" ]; then
  FLUTTER_SDK=$(flutter sdk-path 2>/dev/null || true)
fi
if [ -z "$FLUTTER_SDK" ] || [ ! -d "$FLUTTER_SDK" ]; then
  for d in /usr/lib/flutter "$HOME/flutter" "$HOME/development/flutter"; do
    if [ -d "$d/packages/flutter_tools/gradle" ]; then
      FLUTTER_SDK=$d
      break
    fi
  done
fi
RM_TARGET="${FLUTTER_SDK}/packages/flutter_tools/gradle/.gradle"
if [ -d "$RM_TARGET" ]; then
  if rm -rf "$RM_TARGET" 2>/dev/null; then
    echo "  Removed: $RM_TARGET"
  else
    echo "  Could not remove (permission denied). Run:"
    echo "  sudo rm -rf $RM_TARGET"
  fi
else
  echo "  (nothing to remove at $RM_TARGET)"
fi

echo "Done. Run: flutter pub get && flutter run"
