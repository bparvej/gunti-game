import '../models/game_models.dart';

/// Stores finished game records for the history page.
abstract class GameHistoryRepository {
  Future<List<GameHistoryEntry>> load();

  Future<void> save(GameHistoryEntry entry);

  Future<void> clear();
}