import '../models/game_models.dart';

/// Persists an in-progress game so it can be continued later.
abstract class GameSessionRepository {
  Future<GameSnapshot?> load();

  Future<void> save(GameSnapshot snapshot);

  Future<void> clear();
}