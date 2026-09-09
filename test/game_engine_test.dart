import 'package:flutter_test/flutter_test.dart';
import 'package:dartz/dartz.dart';

import 'package:bangla_guti/domain/models/game_models.dart';
import 'package:bangla_guti/domain/usecases/game_engine.dart';

void main() {
  const engine = GameEngine();

  group('GameEngine initial board', () {
    test('RED starts at T, TL, TR; BLUE at B, BL, BR; C/L/R empty', () {
      final occupied = initialOccupied();
      expect(occupied['T'], 'red');
      expect(occupied['TL'], 'red');
      expect(occupied['TR'], 'red');
      expect(occupied['B'], 'blue');
      expect(occupied['BL'], 'blue');
      expect(occupied['BR'], 'blue');
      expect(occupied['C'], isNull);
      expect(occupied['L'], isNull);
      expect(occupied['R'], isNull);
    });
  });

  group('selectGuti', () {
    test('can select own guti', () {
      final occupied = initialOccupied();
      expect(engine.selectGuti(occupied, 'T', Player.red, false), 'T');
    });

    test('cannot select opponent guti', () {
      final occupied = initialOccupied();
      expect(engine.selectGuti(occupied, 'B', Player.red, false), isNull);
    });

    test('cannot select empty node', () {
      final occupied = initialOccupied();
      expect(engine.selectGuti(occupied, 'C', Player.red, false), isNull);
    });

    test('cannot select when game ended', () {
      final occupied = initialOccupied();
      expect(engine.selectGuti(occupied, 'T', Player.red, true), isNull);
    });
  });

  group('getAvailableTargets', () {
    test('center C connects to all 8 nodes', () {
      final targets = engine.getAvailableTargets('C', {});
      expect(targets, containsAll(['T', 'B', 'L', 'R', 'TL', 'TR', 'BL', 'BR']));
    });

    test('T connects to C, TL, TR only', () {
      final targets = engine.getAvailableTargets('T', {});
      expect(targets.toSet(), {'C', 'TL', 'TR'});
    });

    test('corners connect to their neighbors', () {
      expect(engine.getAvailableTargets('TL', {}), containsAll(['T', 'L', 'C']));
      expect(engine.getAvailableTargets('BR', {}), containsAll(['B', 'R', 'C']));
    });

    test('blocked nodes excluded (no overlap)', () {
      final occupied = initialOccupied();
      // T's targets C, TL, TR — TL and TR are occupied, only C is free
      expect(engine.getAvailableTargets('T', occupied), ['C']);
    });
  });

  group('tryMove', () {
    test('valid one-step move updates occupied map', () {
      final occupied = initialOccupied();
      final result = engine.tryMove('T', 'C', occupied);
      expect(result.isRight(), isTrue);
      result.fold((_) {}, (next) {
        expect(next['T'], isNull);
        expect(next['C'], 'red');
      });
    });

    test('rejects move to non-adjacent node', () {
      final occupied = initialOccupied();
      final result = engine.tryMove('T', 'R', occupied);
      expect(result.isLeft(), isTrue);
      result.fold((e) => expect(e, contains('not adjacent')), (_) {});
    });

    test('rejects move onto occupied node', () {
      final occupied = initialOccupied();
      final result = engine.tryMove('T', 'TL', occupied);
      expect(result.isLeft(), isTrue);
      result.fold((e) => expect(e, contains('occupied')), (_) {});
    });
  });

  group('checkWin', () {
    test('no winner when lines are incomplete', () {
      final occupied = {
        'T': 'red', 'C': 'blue', 'B': 'blue',
        'TL': 'blue', 'TR': 'blue',
        'BL': 'red', 'BR': 'red',
        'L': null, 'R': null,
      };
      // TL/T/TR is not complete (T=red, TL/TR=blue). BL/B/BR has red,blue,red.
      // Note: the true initial board (T/TL/TR red, B/BL/BR blue) already holds
      // the complete line TL-T-TR; the TS game avoids this by only calling
      // checkWin() once moveCount > 3 (red must vacate a node on move 1).
      expect(engine.checkWin(occupied), none(), reason: 'no line complete');
    });

    test('RED wins on T-C-B line', () {
      final occupied = {
        'T': 'red', 'C': 'red', 'B': 'red',
        'TL': 'blue', 'TR': 'blue', 'BL': 'blue', 'BR': 'blue', 'L': null, 'R': null,
      };
      expect(engine.checkWin(occupied), some(Player.red));
    });

    test('BLUE wins on diagonal TR-C-BL', () {
      final occupied = {
        'TR': 'blue', 'C': 'blue', 'BL': 'blue',
        'T': 'red', 'TL': 'red', 'BR': 'red', 'B': null, 'L': null, 'R': null,
      };
      expect(engine.checkWin(occupied), some(Player.blue));
    });
  });

  group('undoLast', () {
    test('reverts a recorded move', () {
      final occupied = initialOccupied();
      final moved = engine.tryMove('T', 'C', occupied);
      final nextOccupied = moved.getOrElse(() => {});
      final history = [MoveRecord(player: Player.red, from: 'T', to: 'C', moveNumber: 1)];

      final result = engine.undoLast(history, nextOccupied);
      expect(result, isNotNull);
      final (restored, record, turn) = result!;
      expect(record.from, 'T');
      expect(record.to, 'C');
      expect(turn, Player.red);
      expect(restored['T'], 'red');
      expect(restored['C'], isNull);
    });

    test('returns null with empty history', () {
      expect(engine.undoLast([], initialOccupied()), isNull);
    });
  });

  test('win lines list matches the 8 known lines', () {
    expect(winLines, hasLength(8));
    expect(winLines, containsAll([
      ['T', 'C', 'B'],
      ['TL', 'L', 'BL'],
      ['TR', 'R', 'BR'],
      ['L', 'C', 'R'],
      ['TL', 'T', 'TR'],
      ['BL', 'B', 'BR'],
      ['TL', 'C', 'BR'],
      ['TR', 'C', 'BL'],
    ]));
  });
}

Map<String, String?> initialOccupied() => {
      'T': 'red', 'TL': 'red', 'TR': 'red',
      'B': 'blue', 'BL': 'blue', 'BR': 'blue',
      'C': null, 'L': null, 'R': null,
    };