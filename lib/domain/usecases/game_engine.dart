import 'package:dartz/dartz.dart';

import '../models/game_models.dart';

/// Pure Bangla Guti game rules, ported from the TypeScript source.
/// No framework / Flutter dependencies.
class GameEngine {
  const GameEngine();

  /// Returns [nodeKey] if it holds the [currentTurn] player's piece and the
  /// game has not ended, otherwise null.
  String? selectGuti(
    Map<String, String?> occupied,
    String nodeKey,
    Player currentTurn,
    bool gameEnded,
  ) {
    if (gameEnded) return null;
    if (occupied[nodeKey] != currentTurn.name) return null;
    return nodeKey;
  }

  /// Adjacent empty nodes a piece at [from] can legally move to (1 step only).
  List<String> getAvailableTargets(String from, Map<String, String?> occupied) {
    final node = boardNodes[from];
    if (node == null) return const [];
    return node.links
        .where((target) => occupied[target] == null)
        .toList(growable: false);
  }

  /// Applies a one-step move for the piece at [from] to empty adjacent [to].
  /// Returns the new occupied map, or an error message string.
  Either<String, Map<String, String?>> tryMove(
    String from,
    String to,
    Map<String, String?> occupied,
  ) {
    if (!occupied.containsKey(from)) {
      return Left('No guti at $from to move');
    }

    final node = boardNodes[from];
    if (node == null) {
      return Left('Unknown node $from');
    }

    if (!node.links.contains(to)) {
      return Left('$to is not adjacent to $from');
    }

    if (occupied[to] != null) {
      return Left('$to is already occupied');
    }

    final next = Map<String, String?>.from(occupied);
    next[to] = next[from];
    next[from] = null;
    return Right(next);
  }

  /// Some(winner) when one player's 3 gutis occupy all 3 nodes of a win line,
  /// otherwise None(). Callers should only evaluate after moveCount > 3.
  Option<Player> checkWin(Map<String, String?> occupied) {
    for (final line in winLines) {
      final owner = playerAtNode(line.first, occupied);
      if (owner == null) continue;
      final complete = line.every((node) => playerAtNode(node, occupied) == owner);
      if (complete) return Some(owner);
    }
    return const None();
  }

  /// Reverts the last move: returns the restored occupied map, the undone
  /// [MoveRecord], and the player whose turn it reverts to, or null if there
  /// is nothing to undo.
  (Map<String, String?>, MoveRecord, Player)? undoLast(
    List<MoveRecord> history,
    Map<String, String?> occupied,
  ) {
    if (history.isEmpty) return null;

    final last = history.last;
    final piece = occupied[last.to];
    if (piece == null) return null;

    final next = Map<String, String?>.from(occupied);
    next[last.to] = null;
    next[last.from] = piece;

    return (next, last, last.player);
  }

  /// The owner of the piece on [key], or null when the node is empty.
  Player? playerAtNode(String key, Map<String, String?> occupied) {
    final owner = occupied[key];
    if (owner == null) return null;
    for (final player in Player.values) {
      if (player.name == owner) return player;
    }
    return null;
  }
}