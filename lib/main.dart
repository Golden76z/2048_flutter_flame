import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'audio/audio_manager.dart';
import 'game/board_state.dart';
import 'game/direction.dart';
import 'game/flutter_2048_game.dart';
import 'top_scores.dart';

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
      seedColor: Colors.indigo,
      brightness: Brightness.light,
    );

    return MaterialApp(
      title: '2048',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: colorScheme,
        scaffoldBackgroundColor: const Color(0xFFEDE7F6),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF5E35B1),
          foregroundColor: Colors.white,
          centerTitle: true,
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
          iconTheme: IconThemeData(color: Colors.white),
        ),
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<int> _topScores = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadScores();
  }

  Future<void> _loadScores() async {
    final scores = await TopScores.getTopScores();
    if (mounted) setState(() {
      _topScores = scores;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF252542),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                '2048',
                style: TextStyle(
                  fontSize: 56,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              if (!_loading && _topScores.isNotEmpty) ...[
                const SizedBox(height: 24),
                Text(
                  _topScores.asMap().entries.map((e) => '${e.key + 1}. ${e.value}').join('  ·  '),
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.white70,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
              const SizedBox(height: 48),
              FilledButton.icon(
                onPressed: () async {
                  await Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const GamePage(),
                    ),
                  );
                  _loadScores();
                },
                icon: const Icon(Icons.play_arrow, size: 28),
                label: const Text('Play', style: TextStyle(fontSize: 20)),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF7C4DFF),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                  minimumSize: const Size(200, 48),
                ),
              ),
            ],
          ),
        ),
      ),
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

            return Stack(
              children: [
                Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Text(
                        'Score: ${board.score}',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF3F51B5),
                        ),
                      ),
                    ),
                    Expanded(
                      child: LayoutBuilder(
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
                                child: GestureDetector(
                                  onPanStart: _onPanStart,
                                  onPanUpdate: _onPanUpdate,
                                  onPanEnd: _onPanEnd,
                                  child: GameWidget(
                                    game: game,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
                if (showWinLoseOverlay && !_paused)
                  Positioned.fill(
                    child: Material(
                      color: Colors.black.withValues(alpha: 0.5),
                      child: _OverlayCard(
                        title: winLoseTitle,
                        subtitle: winLoseSubtitle,
                        children: [
                          _overlayButton(
                            onPressed: () {
                              TopScores.addScore(game.boardState.score);
                              game.restart();
                            },
                            icon: Icons.refresh,
                            label: 'Restart',
                            filled: true,
                          ),
                        ],
                      ),
                    ),
                  ),
                if (_paused)
                  Positioned.fill(
                    child: Material(
                      color: Colors.black.withValues(alpha: 0.5),
                      child: _OverlayCard(
                        title: 'Paused',
                        subtitle: 'Resume or change settings.',
                        children: [
                          _overlayButton(
                            onPressed: () => setState(() => _paused = false),
                            icon: Icons.play_arrow,
                            label: 'Resume',
                            filled: true,
                          ),
                          const SizedBox(height: 8),
                          ListenableBuilder(
                            listenable: audioManager,
                            builder: (context, _) {
                              return _overlayButton(
                                onPressed: () {
                                  audioManager.muted = !audioManager.muted;
                                },
                                icon: audioManager.muted
                                    ? Icons.volume_off
                                    : Icons.volume_up,
                                label: audioManager.muted ? 'Unmute' : 'Mute',
                                filled: true,
                                accent: true,
                              );
                            },
                          ),
                          const SizedBox(height: 8),
                          _overlayButton(
                            onPressed: () {
                              TopScores.addScore(game.boardState.score);
                              game.restart();
                              setState(() => _paused = false);
                            },
                            icon: Icons.refresh,
                            label: 'New game',
                            filled: false,
                          ),
                          const SizedBox(height: 8),
                          _overlayButton(
                            onPressed: () {
                              TopScores.addScore(game.boardState.score);
                              Navigator.of(context).pop();
                            },
                            icon: Icons.home,
                            label: 'Main menu',
                            filled: false,
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  static const double _overlayButtonWidth = 220;
  static const BorderRadius _overlayButtonRadius = BorderRadius.all(Radius.circular(6));

  Widget _overlayButton({
    required VoidCallback onPressed,
    required IconData icon,
    required String label,
    required bool filled,
    bool accent = false,
  }) {
    if (filled) {
      return SizedBox(
        width: _overlayButtonWidth,
        child: FilledButton.icon(
          onPressed: onPressed,
          icon: Icon(icon),
          label: Text(label),
          style: FilledButton.styleFrom(
            backgroundColor: accent ? const Color(0xFF7986CB) : const Color(0xFF5E35B1),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: _overlayButtonRadius),
          ),
        ),
      );
    }
    return SizedBox(
      width: _overlayButtonWidth,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(label),
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFF3F51B5),
          side: const BorderSide(color: Color(0xFF5E35B1)),
          shape: RoundedRectangleBorder(borderRadius: _overlayButtonRadius),
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
          color: const Color(0xFFE8E0F5),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: const Color(0xFF5E35B1),
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
                color: Color(0xFF3F51B5),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF5C6BC0),
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
