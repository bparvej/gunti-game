import '../models/game_models.dart';
import '../repositories/stats_repository.dart';

/// Application service wrapping [StatsRepository] for win recording and lookup.
class StatsUseCase {
  StatsUseCase(this._repository);

  final StatsRepository _repository;

  Future<GameStatsData> load() => _repository.load();

  Future<GameStatsData> recordWin(Player winner, int moves) async {
    final current = await _repository.load();

    final totalGames = current.totalGames + 1;
    final averageMoves = current.averageMoves == 0
        ? moves.toDouble()
        : ((current.averageMoves * (totalGames - 1)) + moves) / totalGames;

    final updated = GameStatsData(
      redWins: current.redWins + (winner == Player.red ? 1 : 0),
      blueWins: current.blueWins + (winner == Player.blue ? 1 : 0),
      totalGames: totalGames,
      movesInLastGame: moves,
      averageMoves: averageMoves.roundToDouble(),
      lastWinner: winner,
    );

    await _repository.save(updated);
    return updated;
  }

  Future<GameStatsData> reset() async {
    const empty = GameStatsData.empty();
    await _repository.save(empty);
    return empty;
  }
}