import 'package:flutter/material.dart';

enum Player { red, blue }

extension PlayerExtension on Player {
  String get label => switch (this) {
    Player.red => 'RED',
    Player.blue => 'BLUE',
  };

  Color get color => switch (this) {
    Player.red => const Color(0xFFFF5252),
    Player.blue => const Color(0xFF1565C0),
  };

  Player get opponent => switch (this) {
    Player.red => Player.blue,
    Player.blue => Player.red,
  };
}

class BoardNode {
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
}

class Board {
  static const nodes = <String, BoardNode>{
    'C': BoardNode(
      key: 'C', x: 300, y: 300,
      links: ['T', 'B', 'L', 'R', 'TL', 'TR', 'BL', 'BR'],
    ),
    'T': BoardNode(
      key: 'T', x: 300, y: 100,
      links: ['C', 'TL', 'TR'],
    ),
    'B': BoardNode(
      key: 'B', x: 300, y: 500,
      links: ['C', 'BL', 'BR'],
    ),
    'L': BoardNode(
      key: 'L', x: 100, y: 300,
      links: ['C', 'TL', 'BL'],
    ),
    'R': BoardNode(
      key: 'R', x: 500, y: 300,
      links: ['C', 'TR', 'BR'],
    ),
    'TL': BoardNode(
      key: 'TL', x: 100, y: 100,
      links: ['T', 'L', 'C'],
    ),
    'TR': BoardNode(
      key: 'TR', x: 500, y: 100,
      links: ['T', 'R', 'C'],
    ),
    'BL': BoardNode(
      key: 'BL', x: 100, y: 500,
      links: ['B', 'L', 'C'],
    ),
    'BR': BoardNode(
      key: 'BR', x: 500, y: 500,
      links: ['B', 'R', 'C'],
    ),
  };

  static const winningLines = <List<String>>[
    ['T', 'C', 'B'],
    ['TL', 'L', 'BL'],
    ['TR', 'R', 'BR'],
    ['L', 'C', 'R'],
    ['TL', 'T', 'TR'],
    ['BL', 'B', 'BR'],
    ['TL', 'C', 'BR'],
    ['TR', 'C', 'BL'],
  ];

  static const startingPositions = <Player, List<String>>{
    Player.red: ['T', 'TL', 'TR'],
    Player.blue: ['B', 'BL', 'BR'],
  };

  static const double boardWidth = 600;
  static const double boardHeight = 600;

  static BoardNode? getNode(String key) => nodes[key];

  static List<String> getValidMoves(String fromNode, Map<String, dynamic> occupied) {
    final node = nodes[fromNode];
    if (node == null) return [];
    return node.links.where((target) => !occupied.containsKey(target)).toList();
  }

  static bool checkWin(Map<String, Player> occupied) {
    for (final line in winningLines) {
      final owners = line.map((nodeKey) => occupied[nodeKey]).toSet();
      if (owners.length == 1 && owners.first != null) {
        return true;
      }
    }
    return false;
  }

  static Player? getWinner(Map<String, Player> occupied) {
    for (final line in winningLines) {
      final owners = line.map((nodeKey) => occupied[nodeKey]).toSet();
      if (owners.length == 1 && owners.first != null) {
        return owners.first;
      }
    }
    return null;
  }
}

class GutiPiece {
  String nodeKey;
  final Player owner;
  Color? _color;

  GutiPiece({
    required this.nodeKey,
    required this.owner,
    this._color,
  });

  Color get color => _color ?? owner.color;

  set color(Color value) => _color = value;

  GutiPiece copyWith({String? nodeKey, Player? owner, Color? color}) {
    return GutiPiece(
      nodeKey: nodeKey ?? this.nodeKey,
      owner: owner ?? this.owner,
      color: color ?? _color,
    );
  }
}

class MoveRecord {
  final Player player;
  final String from;
  final String to;
  final int moveNumber;

  MoveRecord({
    required this.player,
    required this.from,
    required this.to,
    required this.moveNumber,
  });
}

class GameStats {
  int redWins;
  int blueWins;
  int totalGames;
  int movesInLastGame;
  double averageMoves;
  Player? lastWinner;

  GameStats({
    this.redWins = 0,
    this.blueWins = 0,
    this.totalGames = 0,
    this.movesInLastGame = 0,
    this.averageMoves = 0,
    this.lastWinner,
  });

  Map<String, dynamic> toJson() => {
    'redWins': redWins,
    'blueWins': blueWins,
    'totalGames': totalGames,
    'movesInLastGame': movesInLastGame,
    'averageMoves': averageMoves,
    'lastWinner': lastWinner?.name,
  };

  factory GameStats.fromJson(Map<String, dynamic> json) => GameStats(
    redWins: json['redWins'] ?? 0,
    blueWins: json['blueWins'] ?? 0,
    totalGames: json['totalGames'] ?? 0,
    movesInLastGame: json['movesInLastGame'] ?? 0,
    averageMoves: (json['averageMoves'] ?? 0).toDouble(),
    lastWinner: json['lastWinner'] != null
        ? Player.values.firstWhere((e) => e.name == json['lastWinner'], orElse: () => Player.red)
        : null,
  );
}
