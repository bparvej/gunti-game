import 'dart:math' as math;
import 'game_enums.dart';
import 'game_models.dart';
import 'rules.dart';

class Ai {
  static final _rnd = math.Random();
  static const maxPly = 40;

  static Move choose(GState s, Difficulty d) {
    final ms = Rules.moves(s);
    if (ms.isEmpty) return const Move(-1, -1);
    if (d == Difficulty.easy) return ms[_rnd.nextInt(ms.length)];
    final depth = d == Difficulty.medium ? 2 : 6;
    var best = -100000;
    final bestMoves = <Move>[];
    for (final m in ms) {
      final score =
          _search(Rules.apply(s, m), depth - 1, -100000, 100000, s.turn);
      if (score > best) {
        best = score;
        bestMoves
          ..clear()
          ..add(m);
      } else if (score == best) {
        bestMoves.add(m);
      }
    }
    return bestMoves[_rnd.nextInt(bestMoves.length)];
  }

  static Move best(GState s, Difficulty d) => choose(s, d);
  static Move bestMove(GState s, Difficulty d) => choose(s, d);

  static int _search(GState s, int depth, int alpha, int beta, int me) {
    final w = Rules.winner(s.b);
    if (w != 0) return w == me ? 1000 + depth : -1000 - depth;
    if (s.ply >= maxPly) return 0;
    if (depth <= 0) return _eval(s.b, me);
    final ms = Rules.moves(s);
    if (ms.isEmpty) {
      return _search(Rules.pass(s), depth - 1, alpha, beta, me);
    }
    if (s.turn == me) {
      var v = -100000;
      for (final m in ms) {
        v = math.max(
            v, _search(Rules.apply(s, m), depth - 1, alpha, beta, me));
        alpha = math.max(alpha, v);
        if (beta <= alpha) break;
      }
      return v;
    } else {
      var v = 100000;
      for (final m in ms) {
        v = math.min(
            v, _search(Rules.apply(s, m), depth - 1, alpha, beta, me));
        beta = math.min(beta, v);
        if (beta <= alpha) break;
      }
      return v;
    }
  }

  static int _eval(List<int> b, int me) {
    final opp = me == 1 ? 2 : 1;
    var score = 0;
    for (final l in Rules.lines) {
      final isP1Start = (l[0] == 6 && l[1] == 7 && l[2] == 8);
      final isP2Start = (l[0] == 0 && l[1] == 1 && l[2] == 2);
      final meCanWin = !(me == 1 && isP1Start) && !(me == 2 && isP2Start);
      final oppCanWin = !(opp == 1 && isP1Start) && !(opp == 2 && isP2Start);

      var mine = 0, theirs = 0, empty = 0;
      for (final i in l) {
        if (b[i] == me) {
          mine++;
        } else if (b[i] == opp) {
          theirs++;
        } else {
          empty++;
        }
      }
      if (meCanWin && mine == 2 && empty == 1) score += 10;
      if (oppCanWin && theirs == 2 && empty == 1) score -= 10;
    }
    if (b[4] == me) score += 3;
    if (b[4] == opp) score -= 3;
    return score;
  }
}

