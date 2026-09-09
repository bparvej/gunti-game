import '../models/game_models.dart';

abstract class StatsRepository {
  Future<GameStatsData> load();
  Future<void> save(GameStatsData stats);
}