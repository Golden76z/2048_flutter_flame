import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'game/board_state.dart';
import 'game/direction.dart';
import 'game/flutter_2048_game.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(const Flutter2048App());
}

class Flutter2048App extends StatelessWidget {
  const Flutter2048App({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: Colors.amber,
      brightness: Brightness.light,
    );

    return MaterialApp(
      title: '2048',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: colorScheme,
        scaffoldBackgroundColor: const Color(0xFFFAF3E0),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFF8C35E),
          foregroundColor: Colors.brown,
          centerTitle: true,
        ),
      ),
      home: const GamePage(),
    );
  }
}

class GamePage extends StatefulWidget {
  const GamePage({super.key});

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  late final Flutter2048Game game;

  Offset? _panStart;
  Offset? _panLast;

  @override
  void initState() {
    super.initState();
    game = Flutter2048Game();
  }

  void _onPanStart(DragStartDetails details) {
    _panStart = details.globalPosition;
    _panLast = details.globalPosition;
  }

  void _onPanUpdate(DragUpdateDetails details) {
    _panLast = details.globalPosition;
  }

  void _onPanEnd(DragEndDetails details) {
    final start = _panStart;
    final end = _panLast;
    _panStart = null;
    _panLast = null;
    if (start == null || end == null) return;

    final dx = end.dx - start.dx;
    final dy = end.dy - start.dy;
    const minDrag = 20.0;
    if (dx.abs() < minDrag && dy.abs() < minDrag) return;

    if (dx.abs() > dy.abs()) {
      game.move(dx > 0 ? Direction.right : Direction.left);
    } else {
      game.move(dy > 0 ? Direction.down : Direction.up);
    }
  }

  @override
  Widget build(BuildContext context) {
    final board = game.boardState;
    return Scaffold(
      appBar: AppBar(
        title: const Text('2048'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => game.restart(),
            tooltip: 'New game',
          ),
        ],
      ),
      body: AnimatedBuilder(
        animation: board,
        builder: (context, _) {
          final showOverlay = board.hasWon || board.isGameOver;
          final title = board.hasWon ? 'You win!' : 'Game over';
          final subtitle = board.hasWon
              ? 'You reached ${BoardState.winValue}. Keep going or restart.'
              : 'No more moves. Try again?';

          return Center(
            child: AspectRatio(
              aspectRatio: 1,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Stack(
                  children: [
                    GestureDetector(
                      onPanStart: _onPanStart,
                      onPanUpdate: _onPanUpdate,
                      onPanEnd: _onPanEnd,
                      child: GameWidget(
                        game: game,
                      ),
                    ),
                    if (showOverlay)
                      Positioned.fill(
                        child: Container(
                          color: Colors.black.withValues(alpha: 0.35),
                          alignment: Alignment.center,
                          child: Container(
                            margin: const EdgeInsets.all(18),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF1D6),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: const Color(0xFFF0A030),
                                width: 2,
                              ),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  title,
                                  style: const TextStyle(
                                    fontSize: 26,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF5C4A2A),
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  subtitle,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Color(0xFF5C4A2A),
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 12),
                                FilledButton(
                                  onPressed: () => game.restart(),
                                  style: FilledButton.styleFrom(
                                    backgroundColor: const Color(0xFFE06018),
                                    foregroundColor: Colors.white,
                                  ),
                                  child: const Text('Restart'),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
