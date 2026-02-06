import 'package:flame/game.dart';
import 'package:flutter/material.dart';

/// Core Flame game for the 2048 experience.
///
/// At this stage, it only provides a warm background and a hook where
/// the board and input handling will be added.
class Flutter2048Game extends FlameGame {
  @override
  Color backgroundColor() => const Color(0xFFFAF3E0); // warm light background

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    // TODO: Add board/tiles components and input handling here.
  }
}

