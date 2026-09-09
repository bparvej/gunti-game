import '../../domain/models/game_models.dart';
import '../../domain/repositories/stats_repository.dart';
import '../datasources/local_data_source.dart';

class StatsRepositoryImpl implements StatsRepository {
  final LocalDataSource _local;

  StatsRepositoryImpl(this._local);

  @override
  Future<GameStatsData> load() => _local.loadStats();

  @override
  Future<void> save(GameStatsData stats) => _local.saveStats(stats);
}
