import 'package:flutter/material.dart';

import 'controllers/app_state.dart';
import 'screens/home_page.dart';
import 'screens/welcome_screen.dart';
import 'widgets/shell.dart';

// Domain
export '../domain/game/game_enums.dart';
export '../domain/game/game_models.dart';
export '../domain/game/rules.dart';
export '../domain/game/ai.dart';

// Core
export '../core/constants/strings.dart';
export '../core/theme/palette.dart';
export '../core/storage/store.dart';
export '../core/audio/sfx.dart';

// Controllers
export 'controllers/app_state.dart';
export 'controllers/game_controller.dart';

// Widgets
export 'widgets/avatar_view.dart';
export 'widgets/board_view.dart';
export 'widgets/chunky_button.dart';
export 'widgets/chunky_card.dart';
export 'widgets/chunky_icon_button.dart';
export 'widgets/chunky_toggle.dart';
export 'widgets/coin_badge.dart';
export 'widgets/gradient_bg.dart';
export 'widgets/guti_view.dart';
export 'widgets/home_hero.dart';
export 'widgets/home_top_bar.dart';
export 'widgets/level_bar.dart';
export 'widgets/painters.dart';
export 'widgets/shell.dart';

// Dialogs
export 'dialogs/avatar_picker_sheet.dart';
export 'dialogs/game_setup_modal.dart';
export 'dialogs/pause_dialog.dart';
export 'dialogs/result_dialog.dart';

// Screens
export 'screens/game_screen.dart';
export 'screens/history_page.dart';
export 'screens/home_page.dart';
export 'screens/leaderboard_page.dart';
export 'screens/profile_page.dart';
export 'screens/replay_screen.dart';
export 'screens/settings_page.dart';
export 'screens/store_page.dart';
export 'screens/welcome_screen.dart';

// ════════════════════════════════════════════════════════════════
//  App Root
// ════════════════════════════════════════════════════════════════

class BanglaGutiApp extends StatelessWidget {
  const BanglaGutiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bangla Guti',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF7B3FE4)),
      ),
      home: const Root(),
    );
  }
}

class Root extends StatelessWidget {
  const Root({super.key});

  @override
  Widget build(BuildContext context) => appBuilder(
      (_) => app.onboarded ? const Shell() : const WelcomeScreen());
}
