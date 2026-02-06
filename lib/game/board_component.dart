import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import 'board_state.dart';

/// Tile background colors by value (light purple → deep blue progression).
Color colorForValue(int value) {
  const colors = [
    Color(0xFFD1C4E9), // 0 empty
    Color(0xFFD1C4E9), // 2
    Color(0xFFB39DDB), // 4
    Color(0xFF9575CD), // 8
    Color(0xFF7E57C2), // 16
    Color(0xFF673AB7), // 32
    Color(0xFF5E35B1), // 64
    Color(0xFF5349AB), // 128
    Color(0xFF3949AB), // 256
    Color(0xFF303F9F), // 512
    Color(0xFF283593), // 1024
    Color(0xFF1A237E), // 2048
  ];
  if (value <= 0) return colors[0];
  final v = value.clamp(2, 8192);
  final log = v.bitLength - 1;
  final index = (log + 1).clamp(0, colors.length - 1);
  return colors[index];
}

/// Draws the 2048 grid and tiles; reads from [BoardState] each frame.
class BoardComponent extends Component {
  BoardComponent(this.boardState);

  final BoardState boardState;

  static const double padding = 12;
  static const double gap = 8;
  static const double spawnAnimDuration = 0.12;

  int? _spawnAnimRow;
  int? _spawnAnimCol;
  double _spawnAnimT = 1.0;
  int? _lastConsumedSpawnRow;
  int? _lastConsumedSpawnCol;

  @override
  void update(double dt) {
    final r = boardState.lastSpawnedRow;
    final c = boardState.lastSpawnedCol;
    if (r == null || c == null) {
      _lastConsumedSpawnRow = null;
      _lastConsumedSpawnCol = null;
    } else if (_spawnAnimT >= 1.0 && (r != _lastConsumedSpawnRow || c != _lastConsumedSpawnCol)) {
      _lastConsumedSpawnRow = r;
      _lastConsumedSpawnCol = c;
      _spawnAnimRow = r;
      _spawnAnimCol = c;
      _spawnAnimT = 0.0;
    }
    if (_spawnAnimT < 1.0) {
      _spawnAnimT = (_spawnAnimT + dt / spawnAnimDuration).clamp(0.0, 1.0);
      if (_spawnAnimT >= 1.0) {
        _spawnAnimRow = null;
        _spawnAnimCol = null;
      }
    }
  }

  @override
  void render(Canvas canvas) {
    final game = parent;
    final size = game is FlameGame ? game.size : Vector2.zero();
    if (size.x <= 0 || size.y <= 0) return;

    final side = size.x < size.y ? size.x : size.y;
    final boardSide = side - padding * 2;
    final cellSide = (boardSide - gap * (boardState.size + 1)) / boardState.size;
    final topLeft = Offset(
      (size.x - boardSide) / 2,
      (size.y - boardSide) / 2,
    );

    _drawGrid(canvas, topLeft, cellSide);
    _drawTiles(canvas, topLeft, cellSide);
  }

  void _drawGrid(Canvas canvas, Offset topLeft, double cellSide) {
    final paint = Paint()
      ..color = const Color(0xFFE1D5F1)
      ..style = PaintingStyle.fill;
    final border = Paint()
      ..color = const Color(0xFFB39DDB)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    for (int r = 0; r < boardState.size; r++) {
      for (int c = 0; c < boardState.size; c++) {
        final x = topLeft.dx + gap + c * (cellSide + gap);
        final y = topLeft.dy + gap + r * (cellSide + gap);
        final rect = RRect.fromRectAndRadius(
          Rect.fromLTWH(x, y, cellSide, cellSide),
          const Radius.circular(6),
        );
        canvas.drawRRect(rect, paint);
        canvas.drawRRect(rect, border);
      }
    }
  }

  void _drawTiles(Canvas canvas, Offset topLeft, double cellSide) {
    final grid = boardState.grid;
    for (int r = 0; r < boardState.size; r++) {
      for (int c = 0; c < boardState.size; c++) {
        final value = grid[r][c];
        if (value == 0) continue;
        final x = topLeft.dx + gap + c * (cellSide + gap);
        final y = topLeft.dy + gap + r * (cellSide + gap);
        final cellCenter = Offset(x + cellSide / 2, y + cellSide / 2);
        final isSpawning = _spawnAnimRow == r && _spawnAnimCol == c && _spawnAnimT < 1.0;
        final scale = isSpawning ? 0.4 + 0.6 * _spawnAnimT : 1.0;

        if (isSpawning) {
          canvas.save();
          canvas.translate(cellCenter.dx, cellCenter.dy);
          canvas.scale(scale);
          canvas.translate(-cellCenter.dx, -cellCenter.dy);
        }

        final rect = RRect.fromRectAndRadius(
          Rect.fromLTWH(x + 2, y + 2, cellSide - 4, cellSide - 4),
          const Radius.circular(4),
        );
        canvas.drawRRect(rect, Paint()..color = colorForValue(value));

        final text = value.toString();
        final textPainter = TextPainter(
          text: TextSpan(
            text: text,
            style: TextStyle(
              color: value <= 4 ? const Color(0xFF3F51B5) : const Color(0xFFFFFFFF),
              fontSize: cellSide * 0.4,
              fontWeight: FontWeight.bold,
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout(maxWidth: cellSide - 8);
        textPainter.paint(
          canvas,
          Offset(
            x + (cellSide - textPainter.width) / 2,
            y + (cellSide - textPainter.height) / 2,
          ),
        );

        if (isSpawning) canvas.restore();
      }
    }
  }
}
