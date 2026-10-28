import 'package:flutter/material.dart';

import '../../core/constants/strings.dart';
import '../../core/theme/palette.dart';
import '../controllers/app_state.dart';
import '../screens/leaderboard_page.dart';
import '../screens/profile_page.dart';
import 'avatar_view.dart';
import 'coin_badge.dart';
import 'level_bar.dart';

// ════════════════════════════════════════════════════════════════
//  Home Top Bar: User profile info, level progress & coin badge
// ════════════════════════════════════════════════════════════════

class HomeTopBar extends StatelessWidget {
  final VoidCallback? onProfileTap;
  final VoidCallback? onCoinsTap;

  const HomeTopBar({
    super.key,
    this.onProfileTap,
    this.onCoinsTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Profile: Avatar, name, level (tappable -> ProfilePage)
        Expanded(
          child: GestureDetector(
            key: const ValueKey('home_profile_btn'),
            behavior: HitTestBehavior.opaque,
            onTap: onProfileTap ??
                () {
                  app.haptic();
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const ProfilePage()),
                  );
                },
            child: Row(
              children: [
                AvatarView(avatarIndex: app.avatarIndex, size: 48),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        app.displayName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          Text(
                            '${tr('level')} ${app.level}',
                            style: TextStyle(
                              color: fade(Colors.white, .85),
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(width: 6),
                          SizedBox(
                            width: 65,
                            child: LevelBar(
                              value: app.levelProgress,
                              height: 7,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),

        // 3D Coin Badge (tappable -> LeaderboardPage)
        CoinBadge(
          key: const ValueKey('home_coin_badge'),
          points: app.points,
          onTap: onCoinsTap ??
              () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const LeaderboardPage()),
                  ),
        ),
      ],
    );
  }
}

