import 'package:equatable/equatable.dart';

enum Player { red, blue }

enum GutuShape { circle, square, bar, lalBadshah }

enum GameStatus { ongoing, redWin, blueWin }

enum GameMode { singlePlayer, twoPlayers }

enum Difficulty { easy, medium, hard }

extension PlayerX on Player {
  Player get opponent => this == Player.red ? Player.blue : Player.red;

  String get name {
    switch (this) {
      case Player.red:
        return 'red';
      case Player.blue:
        return 'blue';
    }
  }

  static Player fromName(String s) {
    return s == 'blue' ? Player.blue : Player.red;
  }
}

class BoardNode extends Equatable {
  final String key;
  final double x;
  final double y;
  final List<String> links;

  const BoardNode({
    required this.key,
    required this.x,
    required this.y,
    required this.links,
  });

  @override
  List<Object?> get props => [key, x, y, links];
}

class GameStatsData extends Equatable {
  final int redWins;
  final int blueWins;
  final int totalGames;
  final int movesInLastGame;
  final double averageMoves;
  final Player? lastWinner;
  final int draws;

  const GameStatsData({
    required this.redWins,
    required this.blueWins,
    required this.totalGames,
    required this.movesInLastGame,
    required this.averageMoves,
    this.lastWinner,
    this.draws = 0,
  });

  const GameStatsData.empty()
      : redWins = 0,
        blueWins = 0,
        totalGames = 0,
        movesInLastGame = 0,
        averageMoves = 0,
        lastWinner = null,
        draws = 0;

  GameStatsData copyWith({
    int? redWins,
    int? blueWins,
    int? totalGames,
    int? movesInLastGame,
    double? averageMoves,
    Player? lastWinner,
    int? draws,
  }) {
    return GameStatsData(
      redWins: redWins ?? this.redWins,
      blueWins: blueWins ?? this.blueWins,
      totalGames: totalGames ?? this.totalGames,
      movesInLastGame: movesInLastGame ?? this.movesInLastGame,
      averageMoves: averageMoves ?? this.averageMoves,
      lastWinner: lastWinner ?? this.lastWinner,
      draws: draws ?? this.draws,
    );
  }

  @override
  List<Object?> get props => [
        redWins,
        blueWins,
        totalGames,
        movesInLastGame,
        averageMoves,
        lastWinner,
        draws,
      ];
}

class MoveRecord extends Equatable {
  final Player player;
  final String from;
  final String to;
  final int moveNumber;

  const MoveRecord({
    required this.player,
    required this.from,
    required this.to,
    required this.moveNumber,
  });

  Map<String, dynamic> toMap() => {
        'player': player.name,
        'from': from,
        'to': to,
        'moveNumber': moveNumber,
      };

  factory MoveRecord.fromMap(Map<String, dynamic> m) => MoveRecord(
        player: PlayerX.fromName(m['player'] as String),
        from: m['from'] as String,
        to: m['to'] as String,
        moveNumber: m['moveNumber'] as int,
      );

  @override
  List<Object?> get props => [player, from, to, moveNumber];
}

/// Serialisable snapshot of an in-progress game (for continue/resume).
class GameSnapshot extends Equatable {
  final Map<String, String?> occupied;
  final Player currentTurn;
  final int moveCount;
  final List<MoveRecord> moveHistory;
  final GameMode mode;
  final Player humanSide;
  final Difficulty difficulty;

  const GameSnapshot({
    required this.occupied,
    required this.currentTurn,
    required this.moveCount,
    required this.moveHistory,
    required this.mode,
    required this.humanSide,
    required this.difficulty,
  });

  Map<String, dynamic> toMap() {
    final occ = <String, String?>{};
    boardNodes.forEach((key, _) => occ[key] = occupied[key]);
    return {
      'occupied': {
        for (final e in occ.entries)
          if (e.value != null) e.key: e.value,
      },
      'currentTurn': currentTurn.name,
      'moveCount': moveCount,
      'moveHistory': moveHistory.map((m) => m.toMap()).toList(),
      'mode': mode.name,
      'humanSide': humanSide.name,
      'difficulty': difficulty.name,
    };
  }

  factory GameSnapshot.fromMap(Map<String, dynamic> m) {
    final rawOcc = (m['occupied'] as Map).cast<String, String>();
    final occ = <String, String?>{};
    boardNodes.forEach((key, _) => occ[key] = rawOcc[key]);
    return GameSnapshot(
      occupied: occ,
      currentTurn: PlayerX.fromName(m['currentTurn'] as String),
      moveCount: m['moveCount'] as int,
      moveHistory: (m['moveHistory'] as List)
          .map((e) => MoveRecord.fromMap((e as Map).cast<String, dynamic>()))
          .toList(),
      mode: GameMode.values.firstWhere((v) => v.name == m['mode']),
      humanSide: PlayerX.fromName(m['humanSide'] as String),
      difficulty: Difficulty.values.firstWhere((v) => v.name == m['difficulty']),
    );
  }

  @override
  List<Object?> get props => [
        occupied,
        currentTurn,
        moveCount,
        moveHistory,
        mode,
        humanSide,
        difficulty,
      ];
}

/// A finished game recorded to history.
class GameHistoryEntry extends Equatable {
  final String id;
  final DateTime playedAt;
  final GameMode mode;
  final Player? winner;
  final int moveCount;
  final Difficulty difficulty;

  const GameHistoryEntry({
    required this.id,
    required this.playedAt,
    required this.mode,
    required this.winner,
    required this.moveCount,
    required this.difficulty,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'playedAt': playedAt.millisecondsSinceEpoch,
        'mode': mode.name,
        'winner': winner?.name,
        'moveCount': moveCount,
        'difficulty': difficulty.name,
      };

  factory GameHistoryEntry.fromMap(Map<String, dynamic> m) => GameHistoryEntry(
        id: m['id'] as String,
        playedAt: DateTime.fromMillisecondsSinceEpoch(m['playedAt'] as int),
        mode: GameMode.values.firstWhere((v) => v.name == m['mode']),
        winner: m['winner'] == null ? null : PlayerX.fromName(m['winner'] as String),
        moveCount: m['moveCount'] as int,
        difficulty: Difficulty.values.firstWhere((v) => v.name == m['difficulty']),
      );

  @override
  List<Object?> get props => [id, playedAt, mode, winner, moveCount, difficulty];
}

const Map<String, BoardNode> boardNodes = {
  'C': BoardNode(key: 'C', x: 300, y: 300, links: ['T', 'B', 'L', 'R', 'TL', 'TR', 'BL', 'BR']),
  'T': BoardNode(key: 'T', x: 300, y: 100, links: ['C', 'TL', 'TR']),
  'B': BoardNode(key: 'B', x: 300, y: 500, links: ['C', 'BL', 'BR']),
  'L': BoardNode(key: 'L', x: 100, y: 300, links: ['C', 'TL', 'BL']),
  'R': BoardNode(key: 'R', x: 500, y: 300, links: ['C', 'TR', 'BR']),
  'TL': BoardNode(key: 'TL', x: 100, y: 100, links: ['T', 'L', 'C']),
  'TR': BoardNode(key: 'TR', x: 500, y: 100, links: ['T', 'R', 'C']),
  'BL': BoardNode(key: 'BL', x: 100, y: 500, links: ['B', 'L', 'C']),
  'BR': BoardNode(key: 'BR', x: 500, y: 500, links: ['B', 'R', 'C']),
};

const List<List<String>> winLines = [
  ['T', 'C', 'B'],
  ['TL', 'L', 'BL'],
  ['TR', 'R', 'BR'],
  ['L', 'C', 'R'],
  ['TL', 'T', 'TR'],
  ['BL', 'B', 'BR'],
  ['TL', 'C', 'BR'],
  ['TR', 'C', 'BL'],
];

/// Default starting positions: node key -> owner ('red' / 'blue').
const Map<String, String> initialGutis = {
  'T': 'red',
  'TL': 'red',
  'TR': 'red',
  'B': 'blue',
  'BL': 'blue',
  'BR': 'blue',
};

Map<String, String?> initialOccupiedMap() {
  return {
    'T': 'red',
    'TL': 'red',
    'TR': 'red',
    'B': 'blue',
    'BL': 'blue',
    'BR': 'blue',
    'C': null,
    'L': null,
    'R': null,
  };
}