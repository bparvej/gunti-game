import 'package:flutter/material.dart';

import '../../core/constants/strings.dart';
import '../../core/theme/palette.dart';
import '../../domain/game/game_models.dart';
import '../controllers/app_state.dart';
import '../widgets/avatar_view.dart';
import '../widgets/chunky_icon_button.dart';
import '../widgets/gradient_bg.dart';

class LeaderboardPage extends StatelessWidget {
  const LeaderboardPage({super.key});

  Widget _podium(LeaderEntry e, int rank, double h) {
    final label = e.isYou ? app.displayName : e.name;
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 32,
            child: rank == 1
                ? const Text('👑', style: TextStyle(fontSize: 28))
                : null,
          ),
          AvatarView(
            avatarIndex: e.avatarIndex,
            size: 58,
            withCrown: false,
          ),
          const SizedBox(height: 6),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            height: h,
            margin: const EdgeInsets.symmetric(horizontal: 5),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: rank == 1
                    ? [const Color(0xFFFFD54F), const Color(0xFFFFA000)]
                    : rank == 2
                        ? [const Color(0xFFECEFF1), const Color(0xFFB0BEC5)]
                        : [const Color(0xFFFFCC80), const Color(0xFFD84315)],
              ),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(18)),
              boxShadow: const [
                BoxShadow(
                    color: Color(0x33000000),
                    offset: Offset(0, 4),
                    blurRadius: 6),
              ],
            ),
            child: Column(
              children: [
                const SizedBox(height: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: fade(Colors.black, .35),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${e.points} ${tr('pt')}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      '$rank',
                      style: TextStyle(
                        color: fade(Colors.white, .9),
                        fontSize: 38,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return appBuilder((context) {
      final list = app.board();
      final myRank = app.rank;

      return Scaffold(
        backgroundColor: pal.bg1,
        body: GradientBg(
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 30),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 480),
                  child: Column(
                    children: [
                      // Top Bar with 3D Back button
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
                          Expanded(
                            child: Center(
                              child: Text(
                                tr('leaderboard').toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ),
                          ),
                          // Rank badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: fade(Colors.black, .3),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Pal.gold, width: 1.5),
                            ),
                            child: Text(
                              '${tr('rank')}: #$myRank',
                              style: const TextStyle(
                                color: Pal.gold,
                                fontSize: 13,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),

                      // Podium (Top 3)
                      if (list.length >= 3)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              _podium(list[1], 2, 118),
                              _podium(list[0], 1, 150),
                              _podium(list[2], 3, 96),
                            ],
                          ),
                        ),
                      const SizedBox(height: 10),

                      // List of other ranks
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
                        decoration: BoxDecoration(
                          color: pal.card,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: const [
                            BoxShadow(
                                color: Color(0xFFB9A8EC),
                                offset: Offset(0, 6)),
                          ],
                        ),
                        child: Column(
                          children: [
                            for (var i = 3; i < list.length; i++)
                              Container(
                                margin:
                                    const EdgeInsets.symmetric(vertical: 4),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: list[i].isYou
                                      ? pal.greenFill
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(16),
                                  border: list[i].isYou
                                      ? Border.all(
                                          color: Pal.green, width: 2)
                                      : null,
                                ),
                                child: Row(
                                  children: [
                                    SizedBox(
                                      width: 28,
                                      child: Text(
                                        '${i + 1}',
                                        style: TextStyle(
                                          color: list[i].isYou
                                              ? Pal.greenDark
                                              : pal.sub,
                                          fontWeight: FontWeight.w900,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                    AvatarView(
                                        avatarIndex: list[i].avatarIndex,
                                        size: 38),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        list[i].isYou
                                            ? tr('you').toUpperCase()
                                            : list[i].name,
                                        style: TextStyle(
                                          color: pal.text,
                                          fontWeight: FontWeight.w800,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: pal.soft,
                                        borderRadius:
                                            BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        '${list[i].points} ${tr('pt')}',
                                        style: TextStyle(
                                          color: pal.text,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
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

