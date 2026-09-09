import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../core/constants/app_strings.dart';
import '../core/di/service_locator.dart';
import '../core/theme/app_theme.dart';
import '../core/router/app_router.dart';
import '../core/utils/audio_helper.dart';
import '../core/utils/haptics_helper.dart';
import 'cubits/game/game_cubit.dart';
import 'cubits/settings/settings_cubit.dart';
import 'cubits/settings/settings_state.dart';
import 'cubits/stats/stats_cubit.dart';
import '../domain/usecases/game_engine.dart';
import '../domain/usecases/stats_usecase.dart';
import '../domain/repositories/settings_repository.dart';

class BanglaGutiApp extends StatelessWidget {
  const BanglaGutiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => GameCubit(
            engine: sl<GameEngine>(),
            statsUseCase: sl<StatsUseCase>(),
            audio: sl<AudioHelper>(),
            haptics: sl<HapticsHelper>(),
          ),
        ),
        BlocProvider(
          create: (_) => SettingsCubit(
            repo: sl<SettingsRepository>(),
            audio: sl<AudioHelper>(),
            haptics: sl<HapticsHelper>(),
          )..load(),
        ),
        BlocProvider(
          create: (_) => StatsCubit(useCase: sl<StatsUseCase>())..load(),
        ),
      ],
      child: BlocBuilder<SettingsCubit, SettingsState>(
        builder: (context, state) {
          final isBangla = state.settings.isBangla;
          return MaterialApp.router(
            title: isBangla ? AppStrings.bn['appName']! : AppStrings.en['appName']!,
            theme: state.settings.isDarkMode ? AppTheme.dark : AppTheme.light,
            routerConfig: router,
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}
