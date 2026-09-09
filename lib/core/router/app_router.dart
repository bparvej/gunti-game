import 'package:go_router/go_router.dart';
import '../di/service_locator.dart';
import '../../presentation/cubits/settings/settings_cubit.dart';
import '../../presentation/screens/home/home_menu.dart';
import '../../presentation/screens/home/game_screen.dart';
import '../../presentation/screens/settings/settings_screen.dart';
import '../../presentation/screens/history/history_screen.dart';
import '../../presentation/screens/howtoplay/how_to_play_screen.dart';
import '../../presentation/screens/onboarding/onboarding_screen.dart';

final router = GoRouter(
  initialLocation: '/',
  refreshListenable: sl<SettingsRouterRefresh>(),
  redirect: (context, state) {
    final settings = sl<SettingsCubit>().state;
    if (!settings.loaded) return null;
    final onboarded = settings.settings.hasOnboarded;
    final path = state.uri.path;
    if (!onboarded && path != '/onboarding') return '/onboarding';
    if (onboarded && path == '/onboarding') return '/';
    return null;
  },
  routes: [
    GoRoute(
      path: '/',
      builder: (_, _) => const HomeMenuScreen(),
    ),
    GoRoute(
      path: '/game',
      builder: (_, state) => GameScreen(params: state.uri.queryParameters),
    ),
    GoRoute(
      path: '/history',
      builder: (_, _) => const HistoryScreen(),
    ),
    GoRoute(
      path: '/settings',
      builder: (_, _) => const SettingsScreen(),
    ),
    GoRoute(
      path: '/how-to-play',
      builder: (_, _) => const HowToPlayScreen(),
    ),
    GoRoute(
      path: '/onboarding',
      builder: (_, _) => const OnboardingScreen(),
    ),
  ],
);