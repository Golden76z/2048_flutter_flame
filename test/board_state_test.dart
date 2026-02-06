import 'dart:math';

import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_2048_flame/game/board_state.dart';
import 'package:flutter_2048_flame/game/direction.dart';

void main() {
  group('BoardState', () {
    test('starts with two tiles when no initialGrid', () {
      final board = BoardState(random: Random(42));
      final nonZero = board.grid
          .expand((row) => row)
          .where((v) => v != 0)
          .length;
      expect(nonZero, 2);
      expect(board.size, 4);
      expect(board.score, 0);
      expect(board.isGameOver, false);
      expect(board.hasWon, false);
    });

    test('move left merges row and adds score', () {
      final board = BoardState(
        initialGrid: [
          [2, 2, 0, 0],
          [0, 0, 0, 0],
          [0, 0, 0, 0],
          [0, 0, 0, 0],
        ],
      );
      final changed = board.move(Direction.left);
      expect(changed, true);
      expect(board.grid[0][0], 4);
      expect(board.score, 4);
    });

    test('move right merges and right-aligns', () {
      final board = BoardState(
        initialGrid: [
          [0, 0, 2, 2],
          [0, 0, 0, 0],
          [0, 0, 0, 0],
          [0, 0, 0, 0],
        ],
      );
      board.move(Direction.right);
      expect(board.grid[0][3], 4);
      expect(board.score, 4);
    });

    test('move up merges column', () {
      final board = BoardState(
        initialGrid: [
          [2, 0, 0, 0],
          [2, 0, 0, 0],
          [0, 0, 0, 0],
          [0, 0, 0, 0],
        ],
      );
      board.move(Direction.up);
      expect(board.grid[0][0], 4);
      expect(board.score, 4);
    });

    test('move down merges and bottom-aligns', () {
      final board = BoardState(
        initialGrid: [
          [0, 0, 0, 0],
          [0, 0, 0, 0],
          [0, 2, 0, 0],
          [0, 2, 0, 0],
        ],
      );
      board.move(Direction.down);
      expect(board.grid[3][1], 4);
      expect(board.score, 4);
    });

    test('no merge when values differ', () {
      final board = BoardState(
        initialGrid: [
          [2, 4, 0, 0],
          [0, 0, 0, 0],
          [0, 0, 0, 0],
          [0, 0, 0, 0],
        ],
      );
      final scoreBefore = board.score;
      board.move(Direction.left);
      expect(board.grid[0][0], 2);
      expect(board.grid[0][1], 4);
      expect(board.score, scoreBefore);
    });

    test('merge to 2048 sets hasWon', () {
      final board = BoardState(
        initialGrid: [
          [1024, 1024, 0, 0],
          [0, 0, 0, 0],
          [0, 0, 0, 0],
          [0, 0, 0, 0],
        ],
      );
      expect(board.hasWon, false);
      board.move(Direction.left);
      expect(board.grid[0][0], 2048);
      expect(board.hasWon, true);
      expect(board.score, 2048);
    });

    test('full grid with no merges is game over', () {
      final board = BoardState(
        initialGrid: [
          [2, 4, 2, 4],
          [4, 2, 4, 2],
          [2, 4, 2, 4],
          [4, 2, 4, 2],
        ],
      );
      expect(board.isGameOver, true);
      expect(board.move(Direction.left), false);
      expect(board.move(Direction.up), false);
    });

    test('reset clears grid and spawns two tiles', () {
      final board = BoardState(
        initialGrid: [
          [2, 4, 0, 0],
          [0, 0, 0, 0],
          [0, 0, 0, 0],
          [0, 0, 0, 0],
        ],
      );
      board.reset();
      expect(board.score, 0);
      expect(board.hasWon, false);
      final nonZero = board.grid
          .expand((row) => row)
          .where((v) => v != 0)
          .length;
      expect(nonZero, 2);
    });

    test('move returns false when nothing changes', () {
      final board = BoardState(
        initialGrid: [
          [2, 4, 8, 16],
          [0, 0, 0, 0],
          [0, 0, 0, 0],
          [0, 0, 0, 0],
        ],
      );
      final changed = board.move(Direction.left);
      expect(changed, false);
    });
  });
}
