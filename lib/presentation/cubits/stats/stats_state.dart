import 'package:equatable/equatable.dart';
import '../../../domain/models/game_models.dart';

class StatsState extends Equatable {
  final GameStatsData stats;

  const StatsState({required this.stats});

  factory StatsState.initial() => const StatsState(stats: GameStatsData.empty());

  @override
  List<Object?> get props => [stats];
}