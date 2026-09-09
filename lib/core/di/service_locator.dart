import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import '../../data/datasources/local_data_source.dart';
import '../../data/repositories/game_history_repository_impl.dart';
import '../../data/repositories/game_session_repository_impl.dart';
import '../../data/repositories/settings_repository_impl.dart';
import '../../data/repositories/stats_repository_impl.dart';
import '../../domain/repositories/game_history_repository.dart';
import '../../domain/repositories/game_session_repository.dart';
import '../../domain/repositories/settings_repository.dart';
import '../../domain/repositories/stats_repository.dart';
import '../../domain/usecases/ai_engine.dart';
import '../../domain/usecases/game_engine.dart';
import '../../domain/usecases/stats_usecase.dart';
import '../../presentation/cubits/game/game_cubit.dart';
import '../../presentation/cubits/history/history_cubit.dart';
import '../../presentation/cubits/settings/settings_cubit.dart';
import '../../presentation/cubits/stats/stats_cubit.dart';
import '../utils/audio_helper.dart';
import '../utils/haptics_helper.dart';

final sl = GetIt.instance;

/// Notifies go_router whenever settings load/change so the onboarding
/// redirect re-evaluates.
class SettingsRouterRefresh extends ChangeNotifier {
  SettingsRouterRefresh() {
    sl<SettingsCubit>().stream.listen((_) => notifyListeners());
  }
}

Future<void> initServiceLocator() async {
  sl.registerLazySingleton<LocalDataSource>(LocalDataSource.new);
  sl.registerLazySingleton<SettingsRepository>(
    () => SettingsRepositoryImpl(sl()),
  );
  sl.registerLazySingleton<StatsRepository>(() => StatsRepositoryImpl(sl()));
  sl.registerLazySingleton<GameSessionRepository>(
    () => GameSessionRepositoryImpl(sl()),
  );
  sl.registerLazySingleton<GameHistoryRepository>(
    () => GameHistoryRepositoryImpl(sl()),
  );
  sl.registerLazySingleton(GameEngine.new);
  sl.registerLazySingleton<AiEngine>(() => const AiEngine());
  sl.registerLazySingleton(() => StatsUseCase(sl()));
  sl.registerLazySingleton(AudioHelper.new);
  sl.registerLazySingleton(HapticsHelper.new);
  sl.registerLazySingleton<SettingsCubit>(
    () => SettingsCubit(
      repo: sl<SettingsRepository>(),
      audio: sl<AudioHelper>(),
      haptics: sl<HapticsHelper>(),
    ),
  );
  sl.registerLazySingleton<GameCubit>(
    () => GameCubit(
      engine: sl<GameEngine>(),
      aiEngine: sl<AiEngine>(),
      statsUseCase: sl<StatsUseCase>(),
      audio: sl<AudioHelper>(),
      haptics: sl<HapticsHelper>(),
      sessionRepository: sl<GameSessionRepository>(),
      historyRepository: sl<GameHistoryRepository>(),
    ),
  );
  sl.registerLazySingleton<StatsCubit>(() => StatsCubit(useCase: sl<StatsUseCase>()));
  sl.registerLazySingleton<HistoryCubit>(
    () => HistoryCubit(repository: sl<GameHistoryRepository>()),
  );
  sl.registerLazySingleton<SettingsRouterRefresh>(SettingsRouterRefresh.new);
}