import 'package:get_it/get_it.dart';
import '../../data/datasources/local_data_source.dart';
import '../../data/repositories/settings_repository_impl.dart';
import '../../data/repositories/stats_repository_impl.dart';
import '../../domain/repositories/settings_repository.dart';
import '../../domain/repositories/stats_repository.dart';
import '../../domain/usecases/game_engine.dart';
import '../../domain/usecases/stats_usecase.dart';
import '../utils/audio_helper.dart';
import '../utils/haptics_helper.dart';

final sl = GetIt.instance;

Future<void> initServiceLocator() async {
  sl.registerLazySingleton<LocalDataSource>(LocalDataSource.new);
  sl.registerLazySingleton<SettingsRepository>(
    () => SettingsRepositoryImpl(sl()),
  );
  sl.registerLazySingleton<StatsRepository>(() => StatsRepositoryImpl(sl()));
  sl.registerLazySingleton(GameEngine.new);
  sl.registerLazySingleton(() => StatsUseCase(sl()));
  sl.registerLazySingleton(AudioHelper.new);
  sl.registerLazySingleton(HapticsHelper.new);
}