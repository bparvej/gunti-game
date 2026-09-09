import '../../domain/models/game_models.dart';
import '../../domain/repositories/game_session_repository.dart';
import '../datasources/local_data_source.dart';

class GameSessionRepositoryImpl implements GameSessionRepository {
  final LocalDataSource _local;

  GameSessionRepositoryImpl(this._local);

  @override
  Future<GameSnapshot?> load() => _local.loadGameSession();

  @override
  Future<void> save(GameSnapshot snapshot) => _local.saveGameSession(snapshot);

  @override
  Future<void> clear() => _local.clearGameSession();
}