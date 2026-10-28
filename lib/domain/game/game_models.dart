import 'game_enums.dart';

class GameRecord {
  final ResultKind kind;
  final Mode mode;
  final Difficulty difficulty;
  final int points, moves, seconds, stars;
  const GameRecord(this.kind, this.mode, this.difficulty, this.points,
      this.moves, this.seconds,
      [this.stars = 0]);
}

class LeaderEntry {
  final String name;
  final int points;
  final bool isYou;
  final int avatarIndex;
  const LeaderEntry(this.name, this.points,
      {this.isYou = false, this.avatarIndex = 0});
}

class Move {
  final int from; // -1 = placement
  final int to;
  const Move(this.from, this.to);
}

class GState {
  final List<int> b; // 0 empty, 1 player one, 2 player two
  final int turn;
  final int p1, p2; // gutis placed so far
  final int ply;
  const GState(this.b, this.turn, this.p1, this.p2, this.ply);
  factory GState.initial() =>
      GState([2, 2, 2, 0, 0, 0, 1, 1, 1], 1, 3, 3, 0);
  factory GState.start() => GState.initial();
}

/// A piece on the board (kept separately from [GState] so it can slide).
class Pc {
  final int id;
  final int player;
  int node;
  Pc(this.id, this.player, this.node);
  Pc copy() => Pc(id, player, node);
}

class Snap {
  final GState state;
  final List<Pc> pcs;
  final int nextId;
  const Snap(this.state, this.pcs, this.nextId);
}

class GameResult {
  final Outcome outcome;
  final Mode mode;
  final Difficulty difficulty;
  final int points, moves, seconds, stars;
  final String p1Name, p2Name;
  final List<String> unlocks; // things unlocked by levelling up in this game
  const GameResult(this.outcome, this.mode, this.difficulty, this.points,
      this.moves, this.seconds, this.stars, this.p1Name, this.p2Name,
      [this.unlocks = const []]);
}

