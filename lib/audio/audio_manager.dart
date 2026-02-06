import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Manages game audio: move/merge SFX, optional BGM, and mute.
/// Paths are relative to [FlameAudio]'s default assets/audio/ directory.
class AudioManager extends ChangeNotifier {
  AudioManager({SharedPreferences? prefs}) : _prefs = prefs {
    _loadMuted();
  }

  static const String _mutedKey = '2048_audio_muted';
  static const String moveSfx = 'move.mp3';
  static const String mergeSfx = 'merge.mp3';
  static const String bgmTrack = 'bgm.mp3';

  SharedPreferences? _prefs;
  bool _muted = false;

  bool get muted => _muted;
  set muted(bool value) {
    if (_muted == value) return;
    _muted = value;
    _saveMuted();
    if (_muted) {
      stopBgm();
    }
    notifyListeners();
  }

  Future<void> _loadMuted() async {
    _prefs ??= await SharedPreferences.getInstance();
    _muted = _prefs!.getBool(_mutedKey) ?? false;
  }

  void _saveMuted() {
    _prefs?.setBool(_mutedKey, _muted);
  }

  /// Call once at startup (e.g. from game or main) to reduce first-play delay.
  /// Preloads SFX and loads saved mute state. Call once at startup.
  Future<void> preload() async {
    await _loadMuted();
    try {
      await FlameAudio.audioCache.loadAll([moveSfx, mergeSfx, bgmTrack]);
    } catch (_) {
      // Assets may be missing; play calls will no-op or throw, we catch there too.
    }
  }

  void playMove() {
    if (_muted) return;
    _playSafely(() async {
      try {
        await FlameAudio.play(moveSfx, volume: 0.5);
      } catch (_) {}
    });
  }

  void playMerge() {
    if (_muted) return;
    _playSafely(() async {
      try {
        await FlameAudio.play(mergeSfx, volume: 0.6);
      } catch (_) {}
    });
  }

  void startBgm() {
    if (_muted) return;
    _playSafely(() async {
      try {
        await FlameAudio.bgm.play(bgmTrack, volume: 0.3);
      } catch (_) {}
    });
  }

  void stopBgm() {
    FlameAudio.bgm.stop().catchError((_) {});
  }

  static void _playSafely(Future<void> Function() play) {
    play();
  }
}
