import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'audio/audio_manager.dart';
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
  late final AudioManager audioManager;
  late final Flutter2048Game game;

  Offset? _panStart;
  Offset? _panLast;
  bool _paused = false;

  @override
  void initState() {
    super.initState();
    audioManager = AudioManager();
    audioManager.preload();
    game = Flutter2048Game(audioManager: audioManager);
  }

  void _onPanStart(DragStartDetails details) {
    _panStart = details.globalPosition;
    _panLast = details.globalPosition;
  }

  void _onPanUpdate(DragUpdateDetails details) {
    _panLast = details.globalPosition;
  }

  void _onPanEnd(DragEndDetails details) {
    if (_paused) return;
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
          ListenableBuilder(
            listenable: audioManager,
            builder: (context, _) {
              return IconButton(
                icon: Icon(
                  audioManager.muted ? Icons.volume_off : Icons.volume_up,
                ),
                onPressed: () {
                  audioManager.muted = !audioManager.muted;
                },
                tooltip: audioManager.muted ? 'Unmute' : 'Mute',
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => game.restart(),
            tooltip: 'New game',
          ),
          IconButton(
            icon: Icon(_paused ? Icons.play_arrow : Icons.pause),
            onPressed: () => setState(() => _paused = !_paused),
            tooltip: _paused ? 'Resume' : 'Pause',
          ),
        ],
      ),
      body: SafeArea(
        child: AnimatedBuilder(
          animation: board,
          builder: (context, _) {
            final showWinLoseOverlay = board.hasWon || board.isGameOver;
            final winLoseTitle = board.hasWon ? 'You win!' : 'Game over';
            final winLoseSubtitle = board.hasWon
                ? 'You reached ${BoardState.winValue}. Keep going or restart.'
                : 'No more moves. Try again?';

            return LayoutBuilder(
              builder: (context, constraints) {
                final side = constraints.maxWidth < constraints.maxHeight
                    ? constraints.maxWidth
                    : constraints.maxHeight;
                final boardSize = side.clamp(0.0, 400.0);

                return Center(
                  child: SizedBox(
                    width: boardSize,
                    height: boardSize,
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
                          if (_paused)
                            Positioned.fill(
                              child: _OverlayCard(
                                title: 'Paused',
                                subtitle: 'Resume or change settings.',
                                children: [
                                  FilledButton.icon(
                                    onPressed: () =>
                                        setState(() => _paused = false),
                                    icon: const Icon(Icons.play_arrow),
                                    label: const Text('Resume'),
                                    style: FilledButton.styleFrom(
                                      backgroundColor: const Color(0xFFE06018),
                                      foregroundColor: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  ListenableBuilder(
                                    listenable: audioManager,
                                    builder: (context, _) {
                                      return FilledButton.icon(
                                        onPressed: () {
                                          audioManager.muted =
                                              !audioManager.muted;
                                        },
                                        icon: Icon(audioManager.muted
                                            ? Icons.volume_off
                                            : Icons.volume_up),
                                        label: Text(
                                            audioManager.muted
                                                ? 'Unmute'
                                                : 'Mute'),
                                        style: FilledButton.styleFrom(
                                          backgroundColor:
                                              const Color(0xFFD4B878),
                                          foregroundColor:
                                              const Color(0xFF5C4A2A),
                                        ),
                                      );
                                    },
                                  ),
                                  const SizedBox(height: 8),
                                  OutlinedButton.icon(
                                    onPressed: () {
                                      game.restart();
                                      setState(() => _paused = false);
                                    },
                                    icon: const Icon(Icons.refresh),
                                    label: const Text('New game'),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: const Color(0xFF5C4A2A),
                                      side: const BorderSide(
                                          color: Color(0xFFF0A030)),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          if (showWinLoseOverlay && !_paused)
                            Positioned.fill(
                              child: _OverlayCard(
                                title: winLoseTitle,
                                subtitle: winLoseSubtitle,
                                children: [
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
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _OverlayCard extends StatelessWidget {
  const _OverlayCard({
    required this.title,
    required this.subtitle,
    required this.children,
  });

  final String title;
  final String subtitle;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
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
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }
}
