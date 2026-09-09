import 'package:flutter_test/flutter_test.dart';
import 'package:dartz/dartz.dart';

import 'package:bangla_guti/domain/models/game_models.dart';
import 'package:bangla_guti/domain/usecases/ai_engine.dart';

void main() {
  const ai = AiEngine();

  Map<String, String?> occupied() => {
        'T': 'red', 'TL': 'red', 'TR': 'red',
        'B': 'blue', 'BL': 'blue', 'BR': 'blue',
        'C': null, 'L': null, 'R': null,
      };

  group('AiEngine bestMove', () {
    test('easy difficulty returns a legal move', () {
      for (var i = 0; i < 20; i++) {
        final move = ai.bestMove(occupied(), Player.blue, Difficulty.easy);
        expect(move.isSome(), isTrue);
        move.fold(() {}, (m) {
          expect(occupied()[m.from], 'blue');
          expect(occupied()[m.to], isNull);
        });
      }
    });

    test('hard difficulty takes an immediate winning move', () {
      // BLUE has TL + L; moving C -> BL ('BL' is adjacent to C) completes
      // the TL-L-BL line and wins immediately.
      final board = {
        'TL': 'blue', 'L': 'blue', 'C': 'blue',
        'T': 'red', 'TR': 'red', 'BR': 'red',
        'B': null, 'BL': null, 'R': null,
      };
      final move = ai.bestMove(board, Player.blue, Difficulty.hard);
      expect(move.isSome(), isTrue);
      move.fold(() {}, (m) {
        expect(m.from, 'C');
        expect(m.to, 'BL');
      });
    });

    test('hard difficulty blocks an imminent opponent win', () {
      // RED has T + TR + C. RED wins next turn by moving C -> TL (completing
      // TL-T-TR). BLUE holds L, which is adjacent to TL, and must block.
      final board = {
        'T': 'red', 'TR': 'red', 'C': 'red',
        'B': 'blue', 'BL': 'blue', 'L': 'blue',
        'TL': null, 'R': null, 'BR': null,
      };
      final move = ai.bestMove(board, Player.blue, Difficulty.hard);
      expect(move.isSome(), isTrue);
      move.fold(() {}, (m) {
        expect(m.to, 'TL', reason: 'blue should occupy TL to block red win');
      });
    });

    test('returns None when the AI has no legal moves', () {
      // Every node occupied -> no empty target anywhere answers a legal move.
      final board = {
        'T': 'blue', 'TL': 'red', 'BL': 'blue',
        'B': 'blue', 'BR': 'red', 'C': 'red',
        'L': 'red', 'R': 'blue', 'TR': 'blue',
      };
      expect(ai.bestMove(board, Player.blue, Difficulty.hard), none());
    });

    test('never moves onto an occupied node (hard)', () {
      final board = {
        'T': 'red', 'C': 'red', 'TL': 'red',
        'B': 'blue', 'BL': 'blue', 'TR': 'blue',
        'BR': null, 'L': null, 'R': null,
      };
      for (var i = 0; i < 25; i++) {
        final move = ai.bestMove(board, Player.red, Difficulty.hard);
        move.fold(() {}, (m) {
          expect(board[m.to], isNull);
        });
      }
    });
  });
}