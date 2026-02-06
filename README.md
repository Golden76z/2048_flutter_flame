## flutter_2048_flame

A 2048 game built with Flutter & Flame, themed with warm yellow/red tones.

### Initialization / Setup

This repository includes a helper script that can either:
- Create the Flutter project in-place (if one does not exist yet), or
- Detect an existing Flutter project and just ensure Flame + audio dependencies are added.

To run the script:

```bash
cd /home/golden/Desktop/dev/dart/2048_flutter_flame
chmod +x init_flutter_2048_flame.sh
./init_flutter_2048_flame.sh
```

Depending on the current state of the repo, the script will:
- If **no** `pubspec.yaml` is present:
  - Create a Flutter project in the current directory named `flutter_2048_flame`.
  - Configure the organization/bundle ID as `com.Golden76z.flutter2048`.
  - Enable Android and iOS platforms.
- In **both** cases (new or existing project):
  - Add `flame` and `flame_audio` as dependencies.

After initialization:

```bash
flutter pub get
flutter run
```

### Android build: “NoSuchFileException” for `.salive` (system Flutter)

If Flutter is installed system-wide (e.g. `/usr/lib/flutter`) and you see:

```text
Execution failed for task ':gradle:compileKotlin'
> java.nio.file.NoSuchFileException: .../flutter_tools/gradle/.gradle/kotlin/sessions/....salive
```

Gradle needs to write Kotlin compiler cache files inside the Flutter SDK; that path is often read-only. Fix it once by making the Flutter gradle plugin dir writable:

```bash
# Minimal: only the gradle plugin build dir (recommended)
sudo chown -R $(whoami):$(whoami) /usr/lib/flutter/packages/flutter_tools/gradle
```

Then run `flutter clean && flutter pub get && flutter run` again.

To print the exact `chown` command for your Flutter path, run:

```bash
bash android/fix_flutter_gradle_permissions.sh
```

For roadmap and tasks, see `PROJECT_PLAN.md`.
