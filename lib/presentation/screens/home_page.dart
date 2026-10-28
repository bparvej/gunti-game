import 'package:flutter/material.dart';

import '../../core/constants/strings.dart';
import '../../core/theme/palette.dart';
import '../../domain/game/game_enums.dart';
import '../controllers/app_state.dart';
import '../dialogs/game_setup_modal.dart';
import '../dialogs/matchmaking_dialog.dart';
import '../widgets/chunky_button.dart';
import '../widgets/home_hero.dart';
import '../widgets/home_top_bar.dart';
import 'game_screen.dart';
import 'history_page.dart';
import 'settings_page.dart';
import 'store_page.dart';

export '../widgets/home_hero.dart';
export '../widgets/home_top_bar.dart';
export '../widgets/shell.dart';

// ════════════════════════════════════════════════════════════════
//  Home Navigation Helpers
// ════════════════════════════════════════════════════════════════

void startGame(
  BuildContext context,
  Mode mode,
  Difficulty d, {
  Color? p1Color,
  Color? p2Color,
  String? opponentName,
  int? opponentAvatarIndex,
  String? opponentPing,
  int? opponentRating,
}) {
  app.clearSession();
  Navigator.of(context).push(MaterialPageRoute(
    builder: (_) => GameScreen(
      mode: mode,
      difficulty: d,
      p1Color: p1Color,
      p2Color: p2Color,
      opponentName: opponentName,
      opponentAvatarIndex: opponentAvatarIndex,
      opponentPing: opponentPing,
      opponentRating: opponentRating,
    ),
  ));
}

void showOnlineMatchmaking(BuildContext context) {
  MatchmakingDialog.show(
    context,
    onMatchFound: (opponent) {
      startGame(
        context,
        Mode.online,
        app.difficulty,
        p1Color: app.playerCoinColor,
        p2Color: app.opponentCoinColor,
        opponentName: opponent.name,
        opponentAvatarIndex: opponent.avatarIndex,
        opponentPing: opponent.ping,
        opponentRating: opponent.rating,
      );
    },
  );
}

void resumeGame(BuildContext context) {
  if (!app.hasActiveSession) return;
  Navigator.of(context).push(MaterialPageRoute(
    builder: (_) => GameScreen(
      savedSession: app.activeSession,
      p1Color: app.playerCoinColor,
      p2Color: app.opponentCoinColor,
    ),
  ));
}

void showHowTo(BuildContext context) {
  showModalBottomSheet(
    context: context,
    backgroundColor: pal.card,
    shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(26))),
    builder: (_) => Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(tr('howToPlay'),
              style: TextStyle(
                  color: pal.text, fontSize: 22, fontWeight: FontWeight.w800)),
          const SizedBox(height: 14),
          Text(tr('howText'),
              style: TextStyle(color: pal.text, fontSize: 15, height: 1.55)),
          const SizedBox(height: 22),
          ChunkyButton(
            label: tr('close'),
            top: const Color(0xFF9CF2A3),
            bottom: const Color(0xFF4FCB62),
            edge: const Color(0xFF2E9E43),
            height: 52,
            fontSize: 16,
            onTap: () => Navigator.pop(context),
          ),
        ],
      ),
    ),
  );
}

void showVsComputerSetup(BuildContext context) {
  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'match_setup',
    barrierColor: const Color(0xB3120A2E),
    transitionDuration: const Duration(milliseconds: 320),
    pageBuilder: (ctx, a1, a2) => Center(
      child: GameSetupModal(
        onConfirm: (difficulty, p1Color, p2Color) {
          startGame(
            context,
            Mode.vsComputer,
            difficulty,
            p1Color: p1Color,
            p2Color: p2Color,
          );
        },
      ),
    ),
    transitionBuilder: (ctx, anim, _, child) => ScaleTransition(
      scale: CurvedAnimation(
        parent: anim,
        curve: Curves.easeOutBack,
        reverseCurve: Curves.easeIn,
      ),
      child: FadeTransition(opacity: anim, child: child),
    ),
  );
}

// ════════════════════════════════════════════════════════════════
//  Home Page
// ════════════════════════════════════════════════════════════════

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return appBuilder((context) {
      const double btnHeight = 64.0;

      return SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 36),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(
              children: [
                const HomeTopBar(),
                const SizedBox(height: 16),
                const HomeHero(),
                const SizedBox(height: 22),

                // Continue button if active match exists
                if (app.hasActiveSession) ...[
                  ChunkyButton(
                    label: tr('continueGame'),
                    sub:
                        '${app.activeSession!['mode'] == 1 ? tr('twoPlayers') : app.activeSession!['mode'] == 2 ? tr('onlineMatch') : tr('vsComputer')} · ${tr('moveN', {'n': '${((app.activeSession!['ply'] as num?)?.toInt() ?? 0) + 1}'})}',
                    icon: Icons.play_arrow_rounded,
                    top: const Color(0xFFFFB300),
                    bottom: const Color(0xFFF57C00),
                    edge: const Color(0xFFE65100),
                    height: btnHeight,
                    fontSize: 18,
                    onTap: () => resumeGame(context),
                  ),
                  const SizedBox(height: 14),
                ],

                // Prominent Play Online Button
                ChunkyButton(
                  key: const ValueKey('home_play_online_btn'),
                  label: tr('playOnline'),
                  icon: Icons.public_rounded,
                  top: const Color(0xFFFFB300),
                  bottom: const Color(0xFFF57C00),
                  edge: const Color(0xFFC57A0A),
                  height: btnHeight,
                  fontSize: 18,
                  onTap: () => showOnlineMatchmaking(context),
                ),
                const SizedBox(height: 14),

                // Row 1: Play & 2 Players
                Row(
                  children: [
                    Expanded(
                      child: ChunkyButton(
                        label: tr('play'),
                        icon: Icons.play_arrow_rounded,
                        top: const Color(0xFF9CF2A3),
                        bottom: const Color(0xFF4FCB62),
                        edge: const Color(0xFF2E9E43),
                        height: btnHeight,
                        fontSize: 18,
                        onTap: () => showVsComputerSetup(context),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: ChunkyButton(
                        label: tr('twoPlayers'),
                        icon: Icons.people_alt_rounded,
                        top: const Color(0xFF8BD3FF),
                        bottom: const Color(0xFF3B9BE8),
                        edge: const Color(0xFF2169B3),
                        height: btnHeight,
                        fontSize: 18,
                        onTap: () => startGame(
                          context,
                          Mode.twoPlayer,
                          app.difficulty,
                          p1Color: app.playerCoinColor,
                          p2Color: app.opponentCoinColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Row 2: Settings & How To
                Row(
                  children: [
                    Expanded(
                      child: ChunkyButton(
                        key: const ValueKey('home_settings_btn'),
                        label: tr('settings'),
                        icon: Icons.settings_rounded,
                        top: const Color(0xFFA567FF),
                        bottom: const Color(0xFF7430E0),
                        edge: const Color(0xFF4B1D9C),
                        height: btnHeight,
                        fontSize: 17,
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (_) => const SettingsPage()),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: ChunkyButton(
                        label: tr('howToPlay'),
                        icon: Icons.help_rounded,
                        top: const Color(0xFFFFD866),
                        bottom: const Color(0xFFF5A623),
                        edge: const Color(0xFFC57A0A),
                        height: btnHeight,
                        fontSize: 17,
                        onTap: () => showHowTo(context),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Row 3: History & Store
                Row(
                  children: [
                    Expanded(
                      child: ChunkyButton(
                        key: const ValueKey('home_history_btn'),
                        label: tr('history'),
                        icon: Icons.history_rounded,
                        top: const Color(0xFFFF8A65),
                        bottom: const Color(0xFFE64A19),
                        edge: const Color(0xFFBF360C),
                        height: btnHeight,
                        fontSize: 17,
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (_) => const HistoryPage()),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: ChunkyButton(
                        key: const ValueKey('home_store_btn'),
                        label: tr('store'),
                        icon: Icons.storefront_rounded,
                        top: const Color(0xFFFFD54F),
                        bottom: const Color(0xFFFFA000),
                        edge: const Color(0xFFFF8F00),
                        height: btnHeight,
                        fontSize: 17,
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const StorePage()),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}
