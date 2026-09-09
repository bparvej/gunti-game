import 'package:go_router/go_router.dart';
import '../../presentation/screens/home/game_screen.dart';
import '../../presentation/screens/settings/settings_screen.dart';
import '../../presentation/screens/howtoplay/how_to_play_screen.dart';

final router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (_, _) => const GameScreen(),
    ),
    GoRoute(
      path: '/settings',
      builder: (_, _) => const SettingsScreen(),
    ),
    GoRoute(
      path: '/how-to-play',
      builder: (_, _) => const HowToPlayScreen(),
    ),
  ],
);