#!/usr/bin/env bash
set -euo pipefail

PROJECT_NAME="flutter_2048_flame"
ORG="com.Golden76z.flutter2048"
PLATFORMS="android,ios"

echo "== 2048 Flutter + Flame project initializer =="
echo "Project name: ${PROJECT_NAME}"
echo "Org/bundle  : ${ORG}"
echo "Platforms    : ${PLATFORMS}"
echo

if ! command -v flutter >/dev/null 2>&1; then
  echo "Error: flutter is not installed or not in PATH."
  echo "Please install Flutter and try again."
  exit 1
fi
echo

if [ -f "pubspec.yaml" ]; then
  echo "Existing Flutter project detected (pubspec.yaml present)."
  echo "Skipping 'flutter create' and only ensuring dependencies are added."
else
  echo "No Flutter project detected in this directory."
  echo "== Creating Flutter project in current directory =="
  flutter create . \
    --project-name "${PROJECT_NAME}" \
    --org "${ORG}" \
    --platforms "${PLATFORMS}"
fi

echo
echo "== Adding Flame and audio dependencies =="
flutter pub add flame
flutter pub add flame_audio

echo
echo "== Done =="
echo "Next steps:"
echo "  1) Open this directory in your editor (Cursor)."
echo "  2) Run: flutter pub get"
echo "  3) Run the app on Android or iOS: flutter run"
echo
echo "Later we will:"
echo "  - Implement the Flame game loop and 2048 mechanics."
echo "  - Apply the yellow/red theme and audio as per PROJECT_PLAN.md."

