import 'package:flutter/material.dart';

import '../../core/constants/strings.dart';
import '../../core/theme/palette.dart';
import '../../domain/game/game_enums.dart';
import '../controllers/app_state.dart';
import '../dialogs/game_setup_modal.dart';
import '../dialogs/matchmaking_dialog.dart';
import '../widgets/chunky_button.dart';
import '../widgets/guti_view.dart';
import '../widgets/hand_drag_anim.dart';
import '../widgets/home_hero.dart';
import '../widgets/home_top_bar.dart';
import '../widgets/painters.dart';
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
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
    builder: (_) => Padding(
      padding: const EdgeInsets.fromLTRB(22, 16, 22, 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 44,
              height: 5,
              decoration: BoxDecoration(
                color: pal.sub.withAlpha(60),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Pal.green.withAlpha(40),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.help_rounded,
                    color: Pal.greenDark, size: 22),
              ),
              const SizedBox(width: 10),
              Text(
                tr('howToPlay'),
                style: TextStyle(
                  color: pal.text,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Animated Demonstration Mini Board
          Container(
            height: 175,
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: pal.soft,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: pal.border, width: 1.4),
            ),
            child: LayoutBuilder(builder: (ctx, constraints) {
              final size = constraints.maxHeight - 16;
              final pad = size * 0.16;
              final step = (size - pad * 2) / 2;
              final d = step * 0.58;
              Offset demoPos(int r, int c) => Offset(
                    constraints.maxWidth / 2 - size / 2 + pad + c * step,
                    8 + pad + r * step,
                  );
              return Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned(
                    left: constraints.maxWidth / 2 - size / 2,
                    top: 8,
                    width: size,
                    height: size,
                    child: CustomPaint(
                      painter: LinesPainter(pad, step, pal.line),
                    ),
                  ),
                  // Opponent pieces at top row (0, 1, 2)
                  Positioned(
                    left: demoPos(0, 0).dx - d / 2,
                    top: demoPos(0, 0).dy - d / 2,
                    child: Guti(color: app.opponentCoinColor, size: d),
                  ),
                  Positioned(
                    left: demoPos(0, 1).dx - d / 2,
                    top: demoPos(0, 1).dy - d / 2,
                    child: Guti(color: app.opponentCoinColor, size: d),
                  ),
                  Positioned(
                    left: demoPos(0, 2).dx - d / 2,
                    top: demoPos(0, 2).dy - d / 2,
                    child: Guti(color: app.opponentCoinColor, size: d),
                  ),
                  // Player pieces at bottom row corners (6, 8)
                  Positioned(
                    left: demoPos(2, 0).dx - d / 2,
                    top: demoPos(2, 0).dy - d / 2,
                    child: Guti(color: app.playerCoinColor, size: d),
                  ),
                  Positioned(
                    left: demoPos(2, 2).dx - d / 2,
                    top: demoPos(2, 2).dy - d / 2,
                    child: Guti(color: app.playerCoinColor, size: d),
                  ),
                  // Player coin at 7 (2, 1) being dragged to center 4 (1, 1)
                  Positioned(
                    left: demoPos(2, 1).dx - d / 2,
                    top: demoPos(2, 1).dy - d / 2,
                    child: Opacity(
                      opacity: 0.35,
                      child: Guti(color: app.playerCoinColor, size: d),
                    ),
                  ),
                  // Animated Hand Dragging demonstration
                  HandDragAnim(
                    from: demoPos(2, 1),
                    to: demoPos(1, 1),
                    coinSize: d,
                    coinColor: app.playerCoinColor,
                    label: tr('dragToMove'),
                    isHint: false,
                  ),
                ],
              );
            }),
          ),
          const SizedBox(height: 14),
          Text(
            tr('howText'),
            style: TextStyle(
              color: pal.text,
              fontSize: 13,
              height: 1.5,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 18),
          ChunkyButton(
            label: tr('close'),
            top: const Color(0xFF9CF2A3),
            bottom: const Color(0xFF4FCB62),
            edge: const Color(0xFF2E9E43),
            height: 50,
            fontSize: 15,
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
