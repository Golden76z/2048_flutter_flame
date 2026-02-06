import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import 'board_state.dart';

/// Tile background colors by value (yellow → red progression).
Color colorForValue(int value) {
  const colors = [
    Color(0xFFF5E6C8), // 0 empty
    Color(0xFFF5E6C8), // 2
    Color(0xFFF8E071), // 4
    Color(0xFFF5C842), // 8
    Color(0xFFF0A030), // 16
    Color(0xFFE88020), // 32
    Color(0xFFE06018), // 64
    Color(0xFFD84010), // 128
    Color(0xFFC83008), // 256
    Color(0xFFB02000), // 512
    Color(0xFF901800), // 1024
    Color(0xFF701000), // 2048
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

    _drawScore(canvas, size, topLeft);
    _drawGrid(canvas, topLeft, cellSide);
    _drawTiles(canvas, topLeft, cellSide);
  }

  void _drawScore(Canvas canvas, Vector2 size, Offset topLeft) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: 'Score: ${boardState.score}',
        style: const TextStyle(
          color: Color(0xFF5C4A2A),
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    textPainter.paint(
      canvas,
      Offset(
        topLeft.dx,
        (topLeft.dy - textPainter.height - 8).clamp(4.0, double.infinity),
      ),
    );
  }

  void _drawGrid(Canvas canvas, Offset topLeft, double cellSide) {
    final paint = Paint()
      ..color = const Color(0xFFE8D4A8)
      ..style = PaintingStyle.fill;
    final border = Paint()
      ..color = const Color(0xFFD4B878)
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
              color: value <= 4 ? const Color(0xFF5C4A2A) : const Color(0xFFFFFFFF),
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
      }
    }
  }
}
