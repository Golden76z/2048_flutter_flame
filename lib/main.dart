import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'game/flutter_2048_game.dart';

void main() {
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

class GamePage extends StatelessWidget {
  const GamePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('2048'),
      ),
      body: Center(
        child: AspectRatio(
          aspectRatio: 1,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: GameWidget(
              game: Flutter2048Game(),
            ),
          ),
        ),
      ),
    );
  }
}

