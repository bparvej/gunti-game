import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:bangla_guti/core/storage/store.dart';
import 'package:bangla_guti/core/theme/palette.dart';
import 'package:bangla_guti/domain/game/game_enums.dart';
import 'package:bangla_guti/domain/game/game_models.dart';
import 'package:bangla_guti/domain/game/rules.dart';
import 'package:bangla_guti/presentation/controllers/app_state.dart';
import 'package:bangla_guti/presentation/controllers/game_controller.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await Store.init();
    app.load();
  });

  group('Pre-placed Board & Win Rules', () {
    test('GState.initial() has P2 at top [0,1,2] and P1 at bottom [6,7,8]', () {
      final s = GState.initial();
      expect(s.b, [2, 2, 2, 0, 0, 0, 1, 1, 1]);
      expect(s.turn, 1);
      expect(s.p1, 3);
      expect(s.p2, 3);
      expect(s.ply, 0);
    });

    test('Starting lines do NOT trigger win for their starting player', () {
      // P1 starting line [6, 7, 8] is not a win for P1
      final b1 = [0, 0, 0, 0, 0, 0, 1, 1, 1];
      expect(Rules.winLine(b1), isNull);
      expect(Rules.winner(b1), 0);

      // P2 starting line [0, 1, 2] is not a win for P2
      final b2 = [2, 2, 2, 0, 0, 0, 0, 0, 0];
      expect(Rules.winLine(b2), isNull);
      expect(Rules.winner(b2), 0);

      // Initial state has both starting lines populated -> no winner
      final bStart = [2, 2, 2, 0, 0, 0, 1, 1, 1];
      expect(Rules.winLine(bStart), isNull);
      expect(Rules.winner(bStart), 0);
    });

    test('Opponent occupying player starting line IS a win', () {
      // P2 occupying [6, 7, 8] (P1 starting line) -> P2 wins!
      final b1 = [0, 0, 0, 0, 0, 0, 2, 2, 2];
      expect(Rules.winLine(b1), [6, 7, 8]);
      expect(Rules.winner(b1), 2);

      // P1 occupying [0, 1, 2] (P2 starting line) -> P1 wins!
      final b2 = [1, 1, 1, 0, 0, 0, 0, 0, 0];
      expect(Rules.winLine(b2), [0, 1, 2]);
      expect(Rules.winner(b2), 1);
    });

    test('Middle row, vertical, and diagonal lines are valid wins', () {
      // Middle row [3, 4, 5]
      final bMid = [0, 0, 0, 1, 1, 1, 0, 0, 0];
      expect(Rules.winLine(bMid), [3, 4, 5]);
      expect(Rules.winner(bMid), 1);

      // Diagonal [0, 4, 8]
      final bDiag = [2, 0, 0, 0, 2, 0, 0, 0, 2];
      expect(Rules.winLine(bDiag), [0, 4, 8]);
      expect(Rules.winner(bDiag), 2);

      // Column [1, 4, 7]
      final bCol = [0, 1, 0, 0, 1, 0, 0, 1, 0];
      expect(Rules.winLine(bCol), [1, 4, 7]);
      expect(Rules.winner(bCol), 1);
    });

    test('legalMoves only generates moves from owned nodes to empty adjacent nodes', () {
      final s = GState.initial();
      final moves = Rules.legalMoves(s);
      expect(moves, isNotEmpty);
      for (final m in moves) {
        expect(m.from, inInclusiveRange(6, 8)); // P1 pieces
        expect(s.b[m.to], 0); // target empty
        expect(Rules.adj[m.from], contains(m.to));
      }
    });
  });

  group('GameController & Hint & Auto Timer', () {
    test('GameController initializes with 6 pre-placed pieces', () {
      final c = GameController(mode: Mode.vsComputer, difficulty: Difficulty.easy);
      expect(c.pcs, hasLength(6));
      expect(c.pcs.where((p) => p.player == 1).map((p) => p.node).toSet(), {6, 7, 8});
      expect(c.pcs.where((p) => p.player == 2).map((p) => p.node).toSet(), {0, 1, 2});
      c.dispose();
    });

    test('computeHint and clearHint set and clear hintMove', () {
      final c = GameController(mode: Mode.twoPlayer, difficulty: Difficulty.medium);
      expect(c.hintMove, isNull);
      c.computeHint();
      expect(c.hintMove, isNotNull);
      expect(c.hintMove!.from, inInclusiveRange(6, 8));
      c.clearHint();
      expect(c.hintMove, isNull);
      c.dispose();
    });

    test('cancelAutoTimer resets idleLeft and clears auto mode', () {
      final c = GameController(mode: Mode.twoPlayer, difficulty: Difficulty.easy);
      c.idleLeft = 3;
      expect(c.isAutoWarning, isTrue);
      c.cancelAutoTimer();
      expect(c.idleLeft, GameController.idleLimit);
      expect(c.isAutoWarning, isFalse);
      c.dispose();
    });
  });

  group('Avatar Economy & Pricing', () {
    test('Bengal Tiger is free (0 PT), others cost PT', () {
      expect(kAvatars[0].id, 'tiger');
      expect(kAvatars[0].price, 0);
      for (var i = 1; i < kAvatars.length; i++) {
        expect(kAvatars[i].price, greaterThan(0));
      }
    });

    test('Purchasing avatar deducts PT and saves unlocked state', () {
      app.points = 250;
      app.unlockedAvatars.clear();
      app.unlockedAvatars.add(0);

      // Try buying Royal King (index 1, price 100)
      final bought = app.buyAvatar(1);
      expect(bought, isTrue);
      expect(app.points, 150);
      expect(app.avatarIndex, 1);
      expect(app.isAvatarUnlocked(1), isTrue);

      // Try buying Fire Dragon (index 9, price 300) with insufficient points (150)
      final boughtDragon = app.buyAvatar(9);
      expect(boughtDragon, isFalse);
      expect(app.points, 150);
      expect(app.avatarIndex, 1);
      expect(app.isAvatarUnlocked(9), isFalse);
    });
  });

  group('Coin Color Economy & Pricing', () {
    test('Purple is free (0 PT), others cost specific PT', () {
      expect(kCoinColors[0].name, 'Purple');
      expect(kCoinColors[0].price, 0);
      expect(kCoinColors[1].name, 'Royal Blue');
      expect(kCoinColors[1].price, 150);
      expect(kCoinColors[2].name, 'Emerald Green');
      expect(kCoinColors[2].price, 250);
      expect(kCoinColors[3].name, 'Sunset Gold');
      expect(kCoinColors[3].price, 350);
      expect(kCoinColors[4].name, 'Ruby Red');
      expect(kCoinColors[4].price, 500);
    });

    test('isCoinUnlocked returns true for 0 and false for unpurchased', () {
      app.unlockedCoins.clear();
      app.unlockedCoins.add(0);
      expect(app.isCoinUnlocked(0), isTrue);
      expect(app.isCoinUnlocked(1), isFalse);
      expect(app.isCoinUnlocked(2), isFalse);
      expect(app.isCoinUnlocked(3), isFalse);
      expect(app.isCoinUnlocked(4), isFalse);
    });

    test('Purchasing coin deducts PT, unlocks, and equips coin', () {
      app.points = 400;
      app.unlockedCoins.clear();
      app.unlockedCoins.add(0);
      app.coinColorIndex = 0;

      // Buy Royal Blue (150 PT)
      final boughtBlue = app.buyCoin(1);
      expect(boughtBlue, isTrue);
      expect(app.points, 250);
      expect(app.coinColorIndex, 1);
      expect(app.isCoinUnlocked(1), isTrue);

      // Try buying Ruby Red (500 PT) with remaining 250 PT -> should fail
      final boughtRed = app.buyCoin(4);
      expect(boughtRed, isFalse);
      expect(app.points, 250);
      expect(app.coinColorIndex, 1);
      expect(app.isCoinUnlocked(4), isFalse);

      // Buying already unlocked coin equips without deduction
      final equipBlueAgain = app.buyCoin(1);
      expect(equipBlueAgain, isTrue);
      expect(app.points, 250);
      expect(app.coinColorIndex, 1);
    });

    test('load() restores unlockedCoins and falls back to 0 if locked coin saved', () {
      Store.write('{"coinColor": 4, "unlockedCoins": [0]}');
      app.unlockedCoins.clear();
      app.unlockedCoins.add(0);
      app.load();
      // Since Ruby Red is not in unlockedCoins, fallback to 0
      expect(app.coinColorIndex, 0);
      expect(app.unlockedCoins.contains(0), isTrue);
    });

    test('load() keeps coinColorIndex when it is in unlockedCoins', () {
      Store.write('{"coinColor": 2, "unlockedCoins": [0, 2]}');
      app.load();
      expect(app.coinColorIndex, 2);
      expect(app.isCoinUnlocked(2), isTrue);
    });
  });

  group('Play Online Mode & Controller', () {
    test('GameController online mode assigns opponent name, avatar, ping, rating', () {
      final c = GameController(
        mode: Mode.online,
        difficulty: Difficulty.medium,
      );
      expect(c.mode, Mode.online);
      expect(kOnlineOpponents, contains(c.p2Name));
      expect(c.opponentAvatarIndex, inInclusiveRange(0, kAvatars.length - 1));
      expect(c.opponentPing, contains('ms'));
      expect(c.opponentRating, greaterThanOrEqualTo(1200));
      expect(c.isComputer(2), isTrue);
      expect(c.isComputer(1), isFalse);
      expect(c.canUndo, isFalse);
      c.dispose();
    });

    test('GameController restore preserves online opponent properties', () {
      final c1 = GameController(
        mode: Mode.online,
        difficulty: Difficulty.hard,
        opponentName: 'Shakib99',
        opponentAvatarIndex: 3,
        opponentPing: '28 ms',
        opponentRating: 1450,
      );
      final json = c1.toJson();
      c1.dispose();

      final c2 = GameController.restore(json);
      expect(c2.mode, Mode.online);
      expect(c2.p2Name, 'Shakib99');
      expect(c2.opponentAvatarIndex, 3);
      expect(c2.opponentPing, '28 ms');
      expect(c2.opponentRating, 1450);
      c2.dispose();
    });
  });
}
