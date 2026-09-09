import '../../domain/models/game_models.dart';
import '../../domain/repositories/game_history_repository.dart';
import '../datasources/local_data_source.dart';

class GameHistoryRepositoryImpl implements GameHistoryRepository {
  final LocalDataSource _local;

  GameHistoryRepositoryImpl(this._local);

  @override
  Future<List<GameHistoryEntry>> load() => _local.loadHistory();

  @override
  Future<void> save(GameHistoryEntry entry) => _local.saveHistoryEntry(entry);

  @override
  Future<void> clear() => _local.clearHistory();
}