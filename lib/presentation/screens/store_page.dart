import 'package:flutter/material.dart';

import '../../core/audio/sfx.dart';
import '../../core/constants/strings.dart';
import '../../core/theme/palette.dart';
import '../../domain/game/game_enums.dart';
import '../controllers/app_state.dart';
import '../widgets/chunky_button.dart';
import '../widgets/chunky_card.dart';
import '../widgets/chunky_icon_button.dart';
import '../widgets/coin_badge.dart';
import '../widgets/gradient_bg.dart';
import '../widgets/guti_view.dart';
import '../widgets/painters.dart';

class StorePage extends StatelessWidget {
  const StorePage({super.key});

  static const themeCosts = [0, 100, 200, 350, 500];
  static const shapeCosts = [0, 150, 300];

  @override
  Widget build(BuildContext context) {
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
                          Expanded(
                            child: Center(
                              child: Text(
                                tr('store').toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ),
                          ),
                          // Points badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              gradient: const LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [Color(0xFFFFD54F), Color(0xFFFFA000)],
                              ),
                              boxShadow: const [
                                BoxShadow(
                                    color: Color(0xFFC57A0A),
                                    offset: Offset(0, 3.5)),
                              ],
                            ),
                            child: Row(
                              children: [
                                const CoinStack(width: 24),
                                const SizedBox(width: 5),
                                Text(
                                  fmtNum(app.points),
                                  style: const TextStyle(
                                    color: Color(0xFF5D3600),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),

                      // Daily Bonus 3D Card
                      Chunky3DCard(
                        bg: const Color(0xFFFFF9E6),
                        edge: const Color(0xFFE2AE38),
                        child: Row(
                          children: [
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: const Color(0xFFFFE082),
                                border: Border.all(
                                    color: const Color(0xFFFFB300), width: 2),
                              ),
                              child: const Center(
                                child:
                                    Text('🎁', style: TextStyle(fontSize: 26)),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    tr('dailyBonus'),
                                    style: const TextStyle(
                                      color: Color(0xFF5D3600),
                                      fontSize: 16,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                  Text(
                                    tr('bonusInfo'),
                                    style: const TextStyle(
                                      color: Color(0xFF8D6E23),
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            ChunkyButton(
                              label: app.canClaimDailyBonus
                                  ? tr('claim')
                                  : tr('claimed'),
                              top: app.canClaimDailyBonus
                                  ? const Color(0xFFFFD54F)
                                  : const Color(0xFFCFD8DC),
                              bottom: app.canClaimDailyBonus
                                  ? const Color(0xFFFFA000)
                                  : const Color(0xFF90A4AE),
                              edge: app.canClaimDailyBonus
                                  ? const Color(0xFFC57A0A)
                                  : const Color(0xFF607D8B),
                              height: 44,
                              fontSize: 14,
                              onTap: app.canClaimDailyBonus
                                  ? () {
                                      app.claimDailyBonus(100);
                                      Sfx.play('win');
                                      toast(context, '+100 ${tr('pt')}!');
                                    }
                                  : () {},
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Themes Section
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          tr('themes'),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      for (var i = 0; i < Pal.themes.length; i++) ...[
                        _themeCard(context, i),
                        const SizedBox(height: 10),
                      ],
                      const SizedBox(height: 16),

                      // Guti Shapes Section
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          tr('shapes'),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      for (final s in GutiShape.values) ...[
                        _shapeCard(context, s),
                        const SizedBox(height: 10),
                      ],
                      const SizedBox(height: 16),

                      // Coin Colors Section
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          tr('coinColors'),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      for (var i = 0; i < kCoinColors.length; i++) ...[
                        _coinCard(context, i),
                        const SizedBox(height: 10),
                      ],
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

  Widget _themeCard(BuildContext context, int i) {
    final t = Pal.themes[i];
    final cost = themeCosts[i];
    final unlocked = app.themeUnlocked(i);
    final active = app.themeIndex == i;

    return Chunky3DCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [t.bg1, t.bg2],
              ),
              border: Border.all(color: t.me, width: 2),
            ),
            child: Center(
              child: Guti(color: t.me, size: 22),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tr('th$i'),
                  style: const TextStyle(
                    color: Color(0xFF28185C),
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  cost == 0 ? tr('free') : '$cost ${tr('pt')}',
                  style: TextStyle(
                    color: cost == 0 ? Pal.greenDark : const Color(0xFFFFA000),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          if (active)
            ChunkyButton(
              label: tr('equipped'),
              top: const Color(0xFF9CF2A3),
              bottom: const Color(0xFF4FCB62),
              edge: const Color(0xFF2E9E43),
              height: 44,
              fontSize: 13,
              onTap: () {},
            )
          else if (unlocked)
            ChunkyButton(
              label: tr('equip'),
              top: const Color(0xFFA567FF),
              bottom: const Color(0xFF7430E0),
              edge: const Color(0xFF4B1D9C),
              height: 44,
              fontSize: 13,
              onTap: () {
                app.set(() => app.themeIndex = i);
                Sfx.play('click');
              },
            )
          else
            ChunkyButton(
              label: '${tr('buy')} $cost PT',
              top: app.points >= cost
                  ? const Color(0xFFFFD54F)
                  : const Color(0xFFCFD8DC),
              bottom: app.points >= cost
                  ? const Color(0xFFFFA000)
                  : const Color(0xFF90A4AE),
              edge: app.points >= cost
                  ? const Color(0xFFC57A0A)
                  : const Color(0xFF607D8B),
              height: 44,
              fontSize: 13,
              onTap: () {
                if (app.points >= cost) {
                  app.buyTheme(i, cost);
                  Sfx.play('win');
                  toast(context, tr('purchased'));
                } else {
                  toast(context, tr('notEnoughPt'));
                }
              },
            ),
        ],
      ),
    );
  }

  Widget _shapeCard(BuildContext context, GutiShape s) {
    final cost = shapeCosts[s.index];
    final unlocked = app.shapeUnlocked(s);
    final active = app.shape == s;

    return Chunky3DCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: const Color(0xFFF1EDFC),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Guti(color: pal.me, size: 32, shape: s),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tr('sh${s.index}'),
                  style: const TextStyle(
                    color: Color(0xFF28185C),
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  cost == 0 ? tr('free') : '$cost ${tr('pt')}',
                  style: TextStyle(
                    color: cost == 0 ? Pal.greenDark : const Color(0xFFFFA000),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          if (active)
            ChunkyButton(
              label: tr('equipped'),
              top: const Color(0xFF9CF2A3),
              bottom: const Color(0xFF4FCB62),
              edge: const Color(0xFF2E9E43),
              height: 44,
              fontSize: 13,
              onTap: () {},
            )
          else if (unlocked)
            ChunkyButton(
              label: tr('equip'),
              top: const Color(0xFFA567FF),
              bottom: const Color(0xFF7430E0),
              edge: const Color(0xFF4B1D9C),
              height: 44,
              fontSize: 13,
              onTap: () {
                app.set(() => app.shape = s);
                Sfx.play('click');
              },
            )
          else
            ChunkyButton(
              label: '${tr('buy')} $cost PT',
              top: app.points >= cost
                  ? const Color(0xFFFFD54F)
                  : const Color(0xFFCFD8DC),
              bottom: app.points >= cost
                  ? const Color(0xFFFFA000)
                  : const Color(0xFF90A4AE),
              edge: app.points >= cost
                  ? const Color(0xFFC57A0A)
                  : const Color(0xFF607D8B),
              height: 44,
              fontSize: 13,
              onTap: () {
                if (app.points >= cost) {
                  app.buyShape(s, cost);
                  Sfx.play('win');
                  toast(context, tr('purchased'));
                } else {
                  toast(context, tr('notEnoughPt'));
                }
              },
            ),
        ],
      ),
    );
  }

  Widget _coinCard(BuildContext context, int i) {
    final opt = kCoinColors[i];
    final cost = opt.price;
    final unlocked = app.isCoinUnlocked(i);
    final active = app.coinColorIndex == i;

    return Chunky3DCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: const Color(0xFFF1EDFC),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: opt.primary.withAlpha(80), width: 1.5),
            ),
            child: Guti(color: opt.primary, size: 30, shape: app.shape),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  opt.name,
                  style: const TextStyle(
                    color: Color(0xFF28185C),
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  cost == 0 ? tr('free') : '$cost ${tr('pt')}',
                  style: TextStyle(
                    color: cost == 0 ? Pal.greenDark : const Color(0xFFFFA000),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          if (active)
            ChunkyButton(
              label: tr('equipped'),
              top: const Color(0xFF9CF2A3),
              bottom: const Color(0xFF4FCB62),
              edge: const Color(0xFF2E9E43),
              height: 44,
              fontSize: 13,
              onTap: () {},
            )
          else if (unlocked)
            ChunkyButton(
              label: tr('equip'),
              top: const Color(0xFFA567FF),
              bottom: const Color(0xFF7430E0),
              edge: const Color(0xFF4B1D9C),
              height: 44,
              fontSize: 13,
              onTap: () {
                app.set(() => app.coinColorIndex = i);
                Sfx.play('click');
              },
            )
          else
            ChunkyButton(
              label: '${tr('buy')} $cost PT',
              top: app.points >= cost
                  ? const Color(0xFFFFD54F)
                  : const Color(0xFFCFD8DC),
              bottom: app.points >= cost
                  ? const Color(0xFFFFA000)
                  : const Color(0xFF90A4AE),
              edge: app.points >= cost
                  ? const Color(0xFFC57A0A)
                  : const Color(0xFF607D8B),
              height: 44,
              fontSize: 13,
              onTap: () {
                if (app.points >= cost) {
                  final ok = app.buyCoin(i);
                  if (ok) {
                    Sfx.play('win');
                    toast(context, tr('purchased'));
                  }
                } else {
                  Sfx.play('lose');
                  toast(context, tr('notEnoughPt'));
                }
              },
            ),
        ],
      ),
    );
  }
}

