#!/usr/bin/env bash
# Fixes "NoSuchFileException: .../flutter_tools/gradle/.gradle/kotlin/sessions/....salive"
# when Flutter is installed system-wide (e.g. /usr/lib/flutter) and that path is read-only.
# Run once (may need sudo).

set -euo pipefail

get_flutter_sdk() {
  if [ -n "${FLUTTER_ROOT:-}" ]; then
    echo "$FLUTTER_ROOT"
    return
  fi
  flutter sdk-path 2>/dev/null || true
}

FLUTTER_SDK=$(get_flutter_sdk)
if [ -z "$FLUTTER_SDK" ] || [ ! -d "$FLUTTER_SDK" ]; then
  [ -d /usr/lib/flutter ] && FLUTTER_SDK=/usr/lib/flutter
fi

if [ -z "$FLUTTER_SDK" ] || [ ! -d "$FLUTTER_SDK/packages/flutter_tools/gradle" ]; then
  echo "Could not find Flutter SDK (with packages/flutter_tools/gradle). Set FLUTTER_ROOT or install Flutter."
  exit 1
fi

TARGET="$FLUTTER_SDK/packages/flutter_tools/gradle"
echo "Flutter SDK gradle plugin path: $TARGET"
echo ""
echo "To fix the .salive build error, this path must be writable by your user."
echo "Run one of the following (choose the minimal one you prefer):"
echo ""
echo "  # Option A: Make only the gradle plugin build dir writable (minimal)"
echo "  sudo chown -R \$(whoami):\$(whoami) \"$TARGET\""
echo ""
echo "  # Option B: Make the whole Flutter SDK writable (if you manage Flutter yourself)"
echo "  sudo chown -R \$(whoami):\$(whoami) \"$FLUTTER_SDK\""
echo ""
echo "After running one of the above, run: flutter clean && flutter pub get && flutter run"
