import 'package:equatable/equatable.dart';

enum Player { red, blue }

enum GutuShape { circle, square, bar, lalBadshah }

enum GameStatus { ongoing, redWin, blueWin }

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

  const GameStatsData({
    required this.redWins,
    required this.blueWins,
    required this.totalGames,
    required this.movesInLastGame,
    required this.averageMoves,
    this.lastWinner,
  });

  const GameStatsData.empty()
      : redWins = 0,
        blueWins = 0,
        totalGames = 0,
        movesInLastGame = 0,
        averageMoves = 0,
        lastWinner = null;

  @override
  List<Object?> get props => [
        redWins,
        blueWins,
        totalGames,
        movesInLastGame,
        averageMoves,
        lastWinner,
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

  @override
  List<Object?> get props => [player, from, to, moveNumber];
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