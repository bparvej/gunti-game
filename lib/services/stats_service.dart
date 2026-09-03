import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/board.dart';

class StatsService {
  static const String _storageKey = 'gunti-game-stats';

  GameStats stats = GameStats();

  StatsService() {
    loadStats();
  }

  Future<void> loadStats() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_storageKey);
      if (raw != null) {
        final json = jsonDecode(raw) as Map<String, dynamic>;
        stats = GameStats.fromJson(json);
      }
    } catch (_) {
      stats = GameStats();
    }
  }

  Future<void> saveStats() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_storageKey, jsonEncode(stats.toJson()));
    } catch (_) {}
  }

  void recordWin(Player winner, int moveCount) {
    stats.totalGames++;
    stats.movesInLastGame = moveCount;
    stats.lastWinner = winner;
    if (winner == Player.red) {
      stats.redWins++;
    } else {
      stats.blueWins++;
    }
    _updateAverageMoves(moveCount);
    saveStats();
  }

  void _updateAverageMoves(int moveCount) {
    if (stats.totalGames > 0) {
      final total = stats.averageMoves * (stats.totalGames - 1) + moveCount;
      stats.averageMoves = (total / stats.totalGames).roundToDouble();
    }
  }

  void resetStats() {
    stats = GameStats();
    saveStats();
  }

  GameStats getStats() => GameStats(
    redWins: stats.redWins,
    blueWins: stats.blueWins,
    totalGames: stats.totalGames,
    movesInLastGame: stats.movesInLastGame,
    averageMoves: stats.averageMoves,
    lastWinner: stats.lastWinner,
  );
}
