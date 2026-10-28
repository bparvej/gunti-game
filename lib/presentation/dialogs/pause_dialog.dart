import 'package:flutter/material.dart';

import '../../core/constants/strings.dart';
import '../../core/theme/palette.dart';
import '../../domain/game/game_enums.dart';
import '../controllers/game_controller.dart';
import '../widgets/chunky_button.dart';
import '../widgets/painters.dart';

class PauseDialog extends StatelessWidget {
  final GameController controller;
  final VoidCallback onResume;
  final VoidCallback onRestart;
  final VoidCallback onExit;

  const PauseDialog({
    super.key,
    required this.controller,
    required this.onResume,
    required this.onRestart,
    required this.onExit,
  });

  Widget _outlined(String t, double size, Color fill, Color stroke) {
    final base = TextStyle(
        fontSize: size, fontWeight: FontWeight.w900, letterSpacing: 1.2);
    return Stack(
      children: [
        Text(t,
            style: base.copyWith(
                foreground: Paint()
                  ..style = PaintingStyle.stroke
                  ..strokeWidth = 4
                  ..strokeJoin = StrokeJoin.round
                  ..color = stroke)),
        Text(t, style: base.copyWith(color: fill)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    const w = 320.0;
    const col = RibbonColors(
      Color(0xFF9D8CFF),
      Color(0xFF6A4FE0),
      Color(0xFF4B35B5),
      Color(0xFF3B2A99),
    );

    final modeLabel = controller.mode == Mode.vsComputer
        ? '${tr('vsComputer')} · ${diffName(controller.difficulty)}'
        : controller.mode == Mode.online
            ? tr('onlineMatch')
            : tr('twoPlayers');

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        onResume();
      },
      child: Material(
        type: MaterialType.transparency,
        child: SizedBox(
          width: w,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // White card
              Container(
                margin: const EdgeInsets.only(top: 40),
                padding: const EdgeInsets.fromLTRB(20, 52, 20, 24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: const [
                    BoxShadow(color: Color(0xFFB9A8EC), offset: Offset(0, 7)),
                    BoxShadow(
                      color: Color(0x33000000),
                      blurRadius: 24,
                      offset: Offset(0, 14),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      modeLabel,
                      style: const TextStyle(
                        color: Color(0xFF5CB6E8),
                        fontSize: 12,
                        letterSpacing: 1.2,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 14),
                    // Info chips: Moves & Time
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1EDFC),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.touch_app_rounded,
                                    size: 15, color: Color(0xFF6A4FE0)),
                                const SizedBox(width: 4),
                                Flexible(
                                  child: Text(
                                    '${tr('moves')}: ${controller.state.ply + 1}',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Color(0xFF28185C),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1EDFC),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.timer_outlined,
                                    size: 15, color: Color(0xFF6A4FE0)),
                                const SizedBox(width: 4),
                                Flexible(
                                  child: Text(
                                    fmtTime(controller.elapsed),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Color(0xFF28185C),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 22),
                    // Continue button
                    ChunkyButton(
                      label: tr('resume'),
                      icon: Icons.play_arrow_rounded,
                      top: const Color(0xFFA567FF),
                      bottom: const Color(0xFF7430E0),
                      edge: const Color(0xFF4B1D9C),
                      height: 52,
                      onTap: onResume,
                    ),
                    const SizedBox(height: 12),
                    // Restart button
                    ChunkyButton(
                      label: tr('restartGame'),
                      icon: Icons.refresh_rounded,
                      top: const Color(0xFFFFA53C),
                      bottom: const Color(0xFFE26D14),
                      edge: const Color(0xFFB54C00),
                      height: 50,
                      onTap: onRestart,
                    ),
                    const SizedBox(height: 12),
                    // Exit to Lobby button
                    ChunkyButton(
                      label: tr('exitGame'),
                      icon: Icons.home_rounded,
                      top: const Color(0xFFFF6584),
                      bottom: const Color(0xFFD62B52),
                      edge: const Color(0xFF9E1534),
                      height: 50,
                      onTap: onExit,
                    ),
                  ],
                ),
              ),
              // Ribbon
              Positioned(
                left: 0,
                top: 8,
                width: w,
                height: 80,
                child: CustomPaint(painter: RibbonPainter(col)),
              ),
              Positioned(
                left: 34,
                top: 8,
                width: w - 68,
                height: 62,
                child: Center(
                  child: _outlined(tr('paused').toUpperCase(), 20, Colors.white,
                      col.outline),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

