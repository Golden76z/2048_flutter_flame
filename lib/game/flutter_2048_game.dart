import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../audio/audio_manager.dart';
import 'board_component.dart';
import 'board_state.dart';
import 'direction.dart';

/// Core Flame game for the 2048 experience.
///
/// Holds pure [BoardState] and a [BoardComponent] for rendering.
/// Input: [move] (call from UI or keyboard) and arrow keys via [KeyboardEvents].
class Flutter2048Game extends FlameGame with KeyboardEvents {
  Flutter2048Game({AudioManager? audioManager})
      : _boardState = BoardState(),
        _audio = audioManager;

  final BoardState _boardState;
  final AudioManager? _audio;

  BoardState get boardState => _boardState;

  @override
  Color backgroundColor() => const Color(0xFFEDE7F6);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    add(BoardComponent(_boardState));
    _audio?.startBgm();
  }

  /// Apply a move (e.g. from swipe in the UI). No-op if game over.
  void move(Direction direction) {
    if (_boardState.isGameOver) return;
    final scoreBefore = _boardState.score;
    final changed = _boardState.move(direction);
    final audio = _audio;
    if (changed && audio != null) {
      if (_boardState.score > scoreBefore) {
        audio.playMerge();
      } else {
        audio.playMove();
      }
    }
  }

  /// Start a new game.
  void restart() {
    _boardState.reset();
  }

  @override
  KeyEventResult onKeyEvent(
    KeyEvent event,
    Set<LogicalKeyboardKey> keysPressed,
  ) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;
    if (_boardState.isGameOver) return KeyEventResult.ignored;

    Direction? direction;
    if (keysPressed.contains(LogicalKeyboardKey.arrowUp)) {
      direction = Direction.up;
    } else if (keysPressed.contains(LogicalKeyboardKey.arrowDown)) {
      direction = Direction.down;
    } else if (keysPressed.contains(LogicalKeyboardKey.arrowLeft)) {
      direction = Direction.left;
    } else if (keysPressed.contains(LogicalKeyboardKey.arrowRight)) {
      direction = Direction.right;
    }
    if (direction != null) {
      move(direction);
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }
}
