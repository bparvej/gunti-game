import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../core/constants/app_strings.dart';
import '../core/di/service_locator.dart';
import '../core/theme/app_theme.dart';
import '../core/router/app_router.dart';
import 'cubits/game/game_cubit.dart';
import 'cubits/history/history_cubit.dart';
import 'cubits/settings/settings_cubit.dart';
import 'cubits/settings/settings_state.dart';
import 'cubits/stats/stats_cubit.dart';

class BanglaGutiApp extends StatelessWidget {
  const BanglaGutiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => sl<GameCubit>()..loadSavedGameFlag()),
        BlocProvider(create: (_) => sl<SettingsCubit>()..load()),
        BlocProvider(create: (_) => sl<StatsCubit>()..load()),
        BlocProvider(create: (_) => sl<HistoryCubit>()..load()),
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