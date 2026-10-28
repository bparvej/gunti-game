import 'package:flutter/material.dart';

import '../../core/constants/strings.dart';
import '../../core/theme/palette.dart';
import '../../domain/game/game_enums.dart';
import '../controllers/app_state.dart';
import '../widgets/chunky_card.dart';
import '../widgets/chunky_icon_button.dart';
import '../widgets/gradient_bg.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  Widget _statChip(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: pal.soft,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: pal.border, width: 1.2),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 16,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: pal.sub,
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return appBuilder((context) {
      final history = app.history;

      return Scaffold(
        backgroundColor: pal.bg1,
        body: GradientBg(
          child: SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
                  child: Column(
                    children: [
                      // Top Bar
                      Row(
                        children: [
                          ChunkyIconButton(
                            icon: Icons.arrow_back_rounded,
                            size: 44,
                            top: const Color(0xFFA567FF),
                            bottom: const Color(0xFF7430E0),
                            edge: const Color(0xFF4B1D9C),
                            onTap: () => Navigator.of(context).pop(),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Text(
                              tr('matchHistory'),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                                shadows: [
                                  Shadow(
                                    color: Color(0x66000000),
                                    offset: Offset(0, 2),
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          if (history.isNotEmpty)
                            ChunkyIconButton(
                              icon: Icons.delete_outline_rounded,
                              size: 40,
                              top: const Color(0xFFFF8A65),
                              bottom: const Color(0xFFE64A19),
                              edge: const Color(0xFFBF360C),
                              tooltip: tr('clearHistory'),
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                    backgroundColor: pal.card,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(22),
                                    ),
                                    title: Text(
                                      tr('clearHistory'),
                                      style: TextStyle(
                                        color: pal.text,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    content: Text(
                                      tr('clearConfirm'),
                                      style: TextStyle(color: pal.sub),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.of(ctx).pop(),
                                        child: Text(
                                          tr('cancel'),
                                          style: TextStyle(
                                            color: pal.sub,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          app.clearHistory();
                                          Navigator.of(ctx).pop();
                                        },
                                        child: Text(
                                          tr('clear'),
                                          style: const TextStyle(
                                            color: Color(0xFFE53935),
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Stat strip summary
                      Row(
                        children: [
                          _statChip(tr('games'), '${app.wins + app.losses + app.draws}', pal.text),
                          const SizedBox(width: 8),
                          _statChip(tr('wins'), '${app.wins}', Pal.greenDark),
                          const SizedBox(width: 8),
                          _statChip(tr('loss'), '${app.losses}', const Color(0xFFE53935)),
                          const SizedBox(width: 8),
                          _statChip(tr('draw'), '${app.draws}', const Color(0xFFFFA000)),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // History list or Empty state
                      Expanded(
                        child: history.isEmpty
                            ? Center(
                                child: Chunky3DCard(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(
                                          Icons.sports_esports_rounded,
                                          size: 56,
                                          color: Color(0xFFA567FF),
                                        ),
                                        const SizedBox(height: 14),
                                        Text(
                                          tr('noHistory'),
                                          style: TextStyle(
                                            color: pal.text,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          tr('noGames'),
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color: pal.sub,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              )
                            : ListView.separated(
                                itemCount: history.length,
                                separatorBuilder: (context, index) => const SizedBox(height: 10),
                                itemBuilder: (context, index) {
                                  final r = history[index];
                                  final isWin = r.kind == ResultKind.win;
                                  final isLoss = r.kind == ResultKind.loss;

                                  final badgeColor = isWin
                                      ? const Color(0xFF4FCB62)
                                      : isLoss
                                          ? const Color(0xFFEF5350)
                                          : const Color(0xFFFFA726);

                                  final badgeLabel = isWin
                                      ? tr('win')
                                      : isLoss
                                          ? tr('loss')
                                          : tr('draw');

                                  final modeLabel = r.mode == Mode.vsComputer
                                      ? '${tr('vsComputer')} (${diffName(r.difficulty)})'
                                      : r.mode == Mode.online
                                          ? tr('onlineMatch')
                                          : tr('twoPlayers');

                                  return Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                    decoration: BoxDecoration(
                                      color: pal.card,
                                      borderRadius: BorderRadius.circular(18),
                                      border: Border.all(color: pal.border, width: 1.4),
                                      boxShadow: [
                                        BoxShadow(
                                          color: fade(Colors.black, .08),
                                          blurRadius: 6,
                                          offset: const Offset(0, 3),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      children: [
                                        // Badge
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                          decoration: BoxDecoration(
                                            color: badgeColor.withAlpha(35),
                                            borderRadius: BorderRadius.circular(12),
                                            border: Border.all(color: badgeColor, width: 1.5),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                isWin
                                                    ? Icons.emoji_events_rounded
                                                    : isLoss
                                                        ? Icons.close_rounded
                                                        : Icons.handshake_rounded,
                                                size: 16,
                                                color: badgeColor,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                badgeLabel.toUpperCase(),
                                                style: TextStyle(
                                                  color: badgeColor,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w900,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 14),

                                        // Details
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                modeLabel,
                                                style: TextStyle(
                                                  color: pal.text,
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w800,
                                                ),
                                              ),
                                              const SizedBox(height: 3),
                                              Text(
                                                '${tr('moves')}: ${r.moves}  ·  ${tr('time')}: ${fmtTime(r.seconds)}',
                                                style: TextStyle(
                                                  color: pal.sub,
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),

                                        // Points
                                        if (r.points > 0)
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: Pal.gold.withAlpha(40),
                                              borderRadius: BorderRadius.circular(10),
                                              border: Border.all(color: Pal.gold, width: 1.2),
                                            ),
                                            child: Text(
                                              '+${r.points} pt',
                                              style: const TextStyle(
                                                color: Color(0xFFB27B00),
                                                fontSize: 12,
                                                fontWeight: FontWeight.w900,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    });
  }
}
