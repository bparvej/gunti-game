import 'package:flutter/material.dart';

import '../../core/constants/strings.dart';
import '../../core/theme/palette.dart';
import '../controllers/app_state.dart';
import '../dialogs/avatar_picker_sheet.dart';
import '../widgets/avatar_view.dart';
import '../widgets/chunky_button.dart';
import '../widgets/chunky_card.dart';
import '../widgets/chunky_icon_button.dart';
import '../widgets/gradient_bg.dart';
import '../widgets/level_bar.dart';
import '../widgets/painters.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  void _showAvatarPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => const AvatarPickerSheet(),
    );
  }

  Widget _statCard(IconData icon, Color color, String value, String label) {
    return Chunky3DCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      margin: EdgeInsets.zero,
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Color.lerp(color, Colors.black, .3)!,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF28185C),
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      color: Color(0xFF756A8F),
                      fontSize: 11,
                      fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _row(Widget a, Widget b) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(
          children: [
            Expanded(child: a),
            const SizedBox(width: 12),
            Expanded(child: b),
          ],
        ),
      );

  Widget _badge(String label, bool done) {
    return Expanded(
      child: Column(
        children: [
          SizedBox(
            width: 52,
            height: 52,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CustomPaint(
                    size: const Size(52, 52),
                    painter: StarPainter(lit: done)),
                if (!done)
                  const Icon(Icons.lock_rounded,
                      size: 16, color: Colors.white),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 2,
            style: TextStyle(
              color: done ? const Color(0xFF28185C) : const Color(0xFF756A8F),
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const ribbon = RibbonColors(
      Color(0xFF9D8CFF),
      Color(0xFF6A4FE0),
      Color(0xFF4B35B5),
      Color(0xFF3B2A99),
    );

    return appBuilder((context) {
      return Scaffold(
        backgroundColor: pal.bg1,
        body: GradientBg(
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 30),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 440),
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
                                tr('profile').toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 44),
                        ],
                      ),
                      const SizedBox(height: 18),

                      // Avatar & Ribbon Card
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: SizedBox(
                          width: 320,
                          height: 180,
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Positioned(
                                left: 116,
                                top: 0,
                                child: GestureDetector(
                                  onTap: () => _showAvatarPicker(context),
                                  child: AvatarView(
                                    avatarIndex: app.avatarIndex,
                                    size: 88,
                                    onTap: () => _showAvatarPicker(context),
                                  ),
                                ),
                              ),
                              Positioned(
                                left: 182,
                                top: -6,
                                child: SizedBox(
                                  width: 46,
                                  height: 46,
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      CustomPaint(
                                        size: const Size(46, 46),
                                        painter: StarPainter(lit: true),
                                      ),
                                      Text(
                                        '${app.level}',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w900,
                                          shadows: [
                                            Shadow(
                                                color: Color(0xFFB85F00),
                                                offset: Offset(0, 1.5)),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Positioned(
                                left: 0,
                                top: 88,
                                width: 320,
                                height: 80,
                                child:
                                    CustomPaint(painter: RibbonPainter(ribbon)),
                              ),
                              Positioned(
                                left: 40,
                                top: 88,
                                width: 240,
                                height: 62,
                                child: Center(
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: outlinedText(
                                      app.displayName.toUpperCase(),
                                      24,
                                      Colors.white,
                                      ribbon.outline,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Change Avatar Button
                      ChunkyButton(
                        label: tr('changeAvatar'),
                        icon: Icons.face_rounded,
                        top: const Color(0xFFFFD54F),
                        bottom: const Color(0xFFFFA000),
                        edge: const Color(0xFFC57A0A),
                        height: 44,
                        onTap: () => _showAvatarPicker(context),
                      ),
                      const SizedBox(height: 16),

                      // Level Card
                      Chunky3DCard(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Text(
                                  '${tr('level')} ${app.level}',
                                  style: const TextStyle(
                                    color: Color(0xFF28185C),
                                    fontSize: 16,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  tr('toNext',
                                      {'n': '${100 - app.points % 100}'}),
                                  style: const TextStyle(
                                    color: Color(0xFF756A8F),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            LevelBar(
                                value: app.levelProgress,
                                height: 14,
                                track: const Color(0xFFEDE7F6)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Stats Grid
                      _row(
                        _statCard(Icons.sports_esports_rounded,
                            const Color(0xFF7C3AED), '${app.games}', tr('games')),
                        _statCard(Icons.emoji_events_rounded,
                            const Color(0xFFF5B83D), '${app.wins}', tr('wins')),
                      ),
                      _row(
                        _statCard(Icons.percent_rounded,
                            const Color(0xFF3B9BE8), '${app.winRate}%', tr('winRate')),
                        _statCard(Icons.local_fire_department_rounded,
                            const Color(0xFFFF7043), '${app.bestStreak}', tr('streak')),
                      ),
                      _row(
                        _statCard(Icons.star_rounded,
                            const Color(0xFFFFB300), '${app.totalStars}', tr('stars')),
                        _statCard(Icons.monetization_on_rounded,
                            const Color(0xFF2BB673), fmtNum(app.points), tr('points')),
                      ),
                      const SizedBox(height: 6),

                      // Achievements Card
                      Chunky3DCard(
                        padding: const EdgeInsets.fromLTRB(14, 16, 14, 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              tr('achievements'),
                              style: const TextStyle(
                                color: Color(0xFF28185C),
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _badge(tr('aFirst'), app.wins >= 1),
                                _badge(tr('aFive'), app.wins >= 5),
                                _badge(tr('aHard'), app.beatHard),
                                _badge(tr('a100'), app.points >= 100),
                              ],
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

