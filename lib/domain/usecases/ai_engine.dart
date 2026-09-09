import 'dart:math';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../models/game_models.dart';

/// A single move proposed by the AI.
class AiMove extends Equatable {
  final String from;
  final String to;

  const AiMove(this.from, this.to);

  @override
  List<Object?> get props => [from, to];
}

/// Board-game move AI for single-player mode.
///
/// Heuristic evaluation (with [Difficulty] tuning):
/// - winning move: occupy a node that completes one of the player's lines
/// - blocking move: occupy a node the opponent would use to win next turn
/// - positional: control the center, prefer nodes closer to the centre
class AiEngine {
  const AiEngine();

  static const int winScore = 100000;
  static const int blockScore = 50000;
  static const int centerScore = 500;

  /// Returns the best move for [aiPlayer] on the given [occupied] board.
  Option<AiMove> bestMove(
    Map<String, String?> occupied,
    Player aiPlayer,
    Difficulty difficulty,
  ) {
    final moves = _legalMoves(occupied, aiPlayer);
    if (moves.isEmpty) return const None();

    switch (difficulty) {
      case Difficulty.easy:
        return Some(moves[Random().nextInt(moves.length)]);

      case Difficulty.medium:
        return Some(_pickMedium(occupied, moves, aiPlayer));

      case Difficulty.hard:
        return Some(_best(occupied, moves, aiPlayer));
    }
  }

  /// All `(from → to)` one-step legal moves for [player]'s pieces.
  List<AiMove> _legalMoves(Map<String, String?> occupied, Player player) {
    final moves = <AiMove>[];
    occupied.forEach((from, owner) {
      if (owner != player.name) return;
      final node = boardNodes[from];
      if (node == null) return;
      for (final to in node.links) {
        if (occupied[to] == null) moves.add(AiMove(from, to));
      }
    });
    return moves;
  }

  Map<String, String?> _apply(AiMove move, Map<String, String?> occupied) {
    final next = Map<String, String?>.from(occupied);
    next[move.to] = next[move.from];
    next[move.from] = null;
    return next;
  }

  AiMove _pickMedium(
    Map<String, String?> occupied,
    List<AiMove> moves,
    Player aiPlayer,
  ) {
    // 25% random keeps medium beatable, otherwise use the greedy evaluation.
    if (Random().nextInt(100) < 25) {
      return moves[Random().nextInt(moves.length)];
    }
    return _best(occupied, moves, aiPlayer);
  }

  AiMove _best(Map<String, String?> occupied, List<AiMove> moves, Player aiPlayer) {
    final opponent = aiPlayer.opponent;
    int bestScore = -1;
    AiMove? best;

    for (final move in moves) {
      final after = _apply(move, occupied);
      int score = 0;

      // 1) This move completes one of our lines → take the win.
      if (_winsFor(after, aiPlayer)) {
        score = AiEngine.winScore;
      } else if (occupied[move.to] == null &&
          _winsIfOpponentPlays(occupied, move.to, opponent)) {
        // 2) The opponent can win next turn by moving into the node we're
        //    about to occupy - blocking it takes priority.
        score = AiEngine.blockScore;
      } else {
        // 3) Positional play: centre control + proximity to centre.
        if (move.to == 'C') {
          score += AiEngine.centerScore;
        } else {
          final target = boardNodes[move.to]!;
          final c = boardNodes['C']!;
          final dist = sqrt(pow(target.x - c.x, 2) + pow(target.y - c.y, 2));
          score += (AiEngine.centerScore - dist / 10).floor();
        }
        // Prefer moving a piece closer to the opponent's pieces - it creates
        // more possible future threats.
        final targetNode = boardNodes[move.to];
        if (targetNode != null) {
          final oppAdjacent =
              targetNode.links.where((n) => occupied[n] == opponent.name).length;
          score += 25 * oppAdjacent;
        }
      }

      if (score > bestScore) {
        bestScore = score;
        best = move;
      }
    }
    return best ?? moves.first;
  }

  /// True if setting [target] to an [opponent] piece completes one of their
  /// win lines (i.e. the opponent can win immediately by occupying it).
  bool _winsIfOpponentPlays(
    Map<String, String?> occupied,
    String target,
    Player opponent,
  ) {
    final probe = Map<String, String?>.from(occupied);
    probe[target] = opponent.name;
    return _winsFor(probe, opponent);
  }

  bool _winsFor(Map<String, String?> occupied, Player player) {
    for (final line in winLines) {
      if (line.every((n) => occupied[n] == player.name)) return true;
    }
    return false;
  }
}