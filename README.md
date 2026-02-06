# flutter_2048_flame

A 2048 game built with Flutter & Flame, themed with warm yellow/red tones. Play with swipes or arrow keys; supports Android and iOS in portrait.

## Features

- **2048 gameplay** – 4×4 grid, slide and merge tiles, score, win at 2048, game over when stuck
- **Yellow/red theme** – Tile colors from light yellow to deep red; warm UI
- **Portrait-first** – Responsive layout with SafeArea; board capped at 400px
- **Audio** – Move/merge SFX and optional BGM; mute toggle (persisted)
- **Pause overlay** – Resume, mute, new game
- **Win/lose overlays** – Restart from “You win!” or “Game over”

## Setup

### Prerequisites

- [Flutter](https://flutter.dev) SDK (stable)
- Android Studio / Xcode for device or emulator

### First-time init (empty repo)

If the project was cloned without running Flutter create:

```bash
chmod +x init_flutter_2048_flame.sh
./init_flutter_2048_flame.sh
```

The script creates the Flutter app (name `flutter_2048_flame`, org `com.Golden76z.flutter2048`), enables Android and iOS, and adds `flame` and `flame_audio`. If `pubspec.yaml` already exists, it only adds dependencies.

### Run

```bash
flutter pub get
flutter run
```

Pick a device (e.g. `M2007J3SG` or an emulator) when prompted. For a specific device:

```bash
flutter run -d <device_id>
```

### Tests

```bash
flutter test
```

## Platform notes

- **Android & iOS** – Primary targets; portrait orientation is preferred.
- **Audio assets** – Optional. Add `move.mp3`, `merge.mp3`, and `bgm.mp3` under `assets/audio/` (see `assets/audio/README.md`). The app runs without them; mute toggle still works.
- **Gradle (Android)** – The project uses Gradle 8.13. If you see a Java version error, ensure JDK 17+ is installed.

### Android: “NoSuchFileException” for `.salive` (system Flutter)

If Flutter is installed system-wide (e.g. `/usr/lib/flutter`) and the build fails with:

```text
Execution failed for task ':gradle:compileKotlin'
> java.nio.file.NoSuchFileException: .../flutter_tools/gradle/.gradle/kotlin/sessions/....salive
```

make the Flutter Gradle plugin directory writable once:

```bash
sudo chown -R $(whoami):$(whoami) /usr/lib/flutter/packages/flutter_tools/gradle
```

Then run `flutter clean && flutter pub get && flutter run` again.

To print the exact path for your setup:

```bash
bash android/fix_flutter_gradle_permissions.sh
```

## Project layout

- `lib/main.dart` – App entry, theme, game page, pan gesture, overlays
- `lib/game/` – Flame game, board state (logic), board component (drawing), direction
- `lib/audio/` – Audio manager (SFX, BGM, mute, persistence)
- `test/` – Unit tests for board logic; widget smoke test

Roadmap and tasks: **PROJECT_PLAN.md**.
