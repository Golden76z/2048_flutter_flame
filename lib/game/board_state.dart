import 'dart:math';

import 'package:flutter/foundation.dart';

import 'direction.dart';

/// Pure 2048 game state and rules (no UI).
///
/// Grid is 4x4; 0 means empty. Tiles are powers of 2.
class BoardState extends ChangeNotifier {
  BoardState({
    int size = 4,
    Random? random,
    /// For tests: start with this grid (no spawn). Must be [size][size].
    List<List<int>>? initialGrid,
  })  : _size = size,
        _random = random ?? Random(),
        _grid = List.generate(size, (_) => List.filled(size, 0)),
        _score = 0,
        _hasWon = false {
    if (initialGrid != null) {
      for (int r = 0; r < size && r < initialGrid.length; r++) {
        for (int c = 0; c < size && c < initialGrid[r].length; c++) {
          _grid[r][c] = initialGrid[r][c];
        }
      }
    } else {
      _spawnTile();
      _spawnTile();
    }
  }

  final int _size;
  final Random _random;
  final List<List<int>> _grid;
  int _score;
  bool _hasWon;
  int? _lastSpawnedRow;
  int? _lastSpawnedCol;

  static const int defaultSize = 4;
  static const int winValue = 2048;

  int get size => _size;
  int get score => _score;
  bool get hasWon => _hasWon;

  /// Last spawned cell (for spawn animation). Cleared at start of next move or reset.
  int? get lastSpawnedRow => _lastSpawnedRow;
  int? get lastSpawnedCol => _lastSpawnedCol;

  /// Current grid: [row][col], 0 = empty.
  List<List<int>> get grid =>
      _grid.map((row) => row.toList()).toList();

  /// Whether no move can change the board (game over).
  bool get isGameOver => !_canMove();

  /// Returns true if a move was made (board or score changed).
  bool move(Direction direction) {
    _lastSpawnedRow = null;
    _lastSpawnedCol = null;
    final previous = _gridToString();
    _applyMove(direction);
    final changed = _gridToString() != previous;
    if (changed) {
      _spawnTile();
      notifyListeners();
    }
    return changed;
  }

  void _applyMove(Direction direction) {
    switch (direction) {
      case Direction.left:
        for (int r = 0; r < _size; r++) {
          _mergeRow(r, leftToRight: true);
        }
        break;
      case Direction.right:
        for (int r = 0; r < _size; r++) {
          _mergeRow(r, leftToRight: false);
        }
        break;
      case Direction.up:
        for (int c = 0; c < _size; c++) {
          _mergeCol(c, topToBottom: true);
        }
        break;
      case Direction.down:
        for (int c = 0; c < _size; c++) {
          _mergeCol(c, topToBottom: false);
        }
        break;
    }
  }

  void _mergeRow(int row, {required bool leftToRight}) {
    var values = List<int>.from(_grid[row].where((v) => v != 0));
    if (values.isEmpty) return;
    if (!leftToRight) values = values.reversed.toList();
    var merged = _mergeLine(values);
    if (!leftToRight) merged = merged.reversed.toList();
    if (leftToRight) {
      for (int i = 0; i < _size; i++) {
        _grid[row][i] = i < merged.length ? merged[i] : 0;
      }
    } else {
      // Right-align: zeros on the left, merged tiles on the right.
      final pad = _size - merged.length;
      for (int i = 0; i < _size; i++) {
        _grid[row][i] = i < pad ? 0 : merged[i - pad];
      }
    }
  }

  void _mergeCol(int col, {required bool topToBottom}) {
    var values = <int>[];
    for (int r = 0; r < _size; r++) {
      final v = _grid[r][col];
      if (v != 0) values.add(v);
    }
    if (values.isEmpty) return;
    if (!topToBottom) values = values.reversed.toList();
    var merged = _mergeLine(values);
    if (!topToBottom) merged = merged.reversed.toList();
    if (topToBottom) {
      for (int r = 0; r < _size; r++) {
        _grid[r][col] = r < merged.length ? merged[r] : 0;
      }
    } else {
      // Bottom-align: zeros on top, merged tiles at bottom.
      final pad = _size - merged.length;
      for (int r = 0; r < _size; r++) {
        _grid[r][col] = r < pad ? 0 : merged[r - pad];
      }
    }
  }

  /// Merge adjacent equal values toward the start of the list; add score.
  List<int> _mergeLine(List<int> line) {
    if (line.isEmpty) return [];
    final result = <int>[];
    int i = 0;
    while (i < line.length) {
      if (i + 1 < line.length && line[i] == line[i + 1]) {
        final merged = line[i] * 2;
        result.add(merged);
        _score += merged;
        if (merged >= winValue) {
          _hasWon = true;
        }
        i += 2;
      } else {
        result.add(line[i]);
        i += 1;
      }
    }
    return result;
  }

  bool _canMove() {
    for (int r = 0; r < _size; r++) {
      for (int c = 0; c < _size; c++) {
        if (_grid[r][c] == 0) return true;
        if (c + 1 < _size && _grid[r][c] == _grid[r][c + 1]) return true;
        if (r + 1 < _size && _grid[r][c] == _grid[r + 1][c]) return true;
      }
    }
    return false;
  }

  void _spawnTile() {
    final empty = <List<int>>[];
    for (int r = 0; r < _size; r++) {
      for (int c = 0; c < _size; c++) {
        if (_grid[r][c] == 0) empty.add([r, c]);
      }
    }
    if (empty.isEmpty) return;
    final pos = empty[_random.nextInt(empty.length)];
    _grid[pos[0]][pos[1]] = _random.nextDouble() < 0.9 ? 2 : 4;
    _lastSpawnedRow = pos[0];
    _lastSpawnedCol = pos[1];
  }

  String _gridToString() {
    return _grid.map((row) => row.join(',')).join('|');
  }

  /// Start a new game (same size).
  void reset() {
    _lastSpawnedRow = null;
    _lastSpawnedCol = null;
    for (int r = 0; r < _size; r++) {
      for (int c = 0; c < _size; c++) {
        _grid[r][c] = 0;
      }
    }
    _score = 0;
    _hasWon = false;
    _spawnTile();
    _spawnTile();
    notifyListeners();
  }
}
