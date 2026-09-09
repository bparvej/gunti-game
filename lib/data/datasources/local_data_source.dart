import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/app_settings.dart';
import '../../domain/models/game_models.dart';

class LocalDataSource {
  static const _settingsKey = 'bangla_guti_settings';
  static const _statsKey = 'bangla_guti_stats';

  Future<AppSettings> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_settingsKey);
    if (json == null) return AppSettings.defaults();
    return AppSettings.fromMap(jsonDecode(json));
  }

  Future<void> saveSettings(AppSettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_settingsKey, jsonEncode(settings.toMap()));
  }

  Future<GameStatsData> loadStats() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_statsKey);
    if (json == null) return const GameStatsData.empty();
    final m = jsonDecode(json) as Map<String, dynamic>;
    return GameStatsData(
      redWins: m['redWins'] ?? 0,
      blueWins: m['blueWins'] ?? 0,
      totalGames: m['totalGames'] ?? 0,
      movesInLastGame: m['movesInLastGame'] ?? 0,
      averageMoves: (m['averageMoves'] ?? 0).toDouble(),
      lastWinner: m['lastWinner'] != null
          ? Player.values.firstWhere((p) => p.name == m['lastWinner'])
          : null,
    );
  }

  Future<void> saveStats(GameStatsData stats) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_statsKey, jsonEncode({
      'redWins': stats.redWins,
      'blueWins': stats.blueWins,
      'totalGames': stats.totalGames,
      'movesInLastGame': stats.movesInLastGame,
      'averageMoves': stats.averageMoves,
      'lastWinner': stats.lastWinner?.name,
    }));
  }
}
