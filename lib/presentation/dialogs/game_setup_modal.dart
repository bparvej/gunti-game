import 'package:flutter/material.dart';

import '../../core/audio/sfx.dart';
import '../../core/constants/strings.dart';
import '../../core/theme/palette.dart';
import '../../domain/game/game_enums.dart';
import '../controllers/app_state.dart';
import '../widgets/chunky_button.dart';
import '../widgets/chunky_icon_button.dart';
import '../widgets/guti_view.dart';
import '../widgets/painters.dart';

class GameSetupModal extends StatefulWidget {
  final void Function(Difficulty difficulty, Color p1Color, Color p2Color) onConfirm;

  const GameSetupModal({
    super.key,
    required this.onConfirm,
  });

  @override
  State<GameSetupModal> createState() => _GameSetupModalState();
}

class _GameSetupModalState extends State<GameSetupModal> {
  late Difficulty _diff;
  late int _colorIdx;

  @override
  void initState() {
    super.initState();
    app.addListener(_onAppChanged);
    _diff = app.difficulty;
    _colorIdx = app.coinColorIndex.clamp(0, kCoinColors.length - 1);
    if (!app.isCoinUnlocked(_colorIdx)) {
      _colorIdx = 0;
    }
  }

  void _onAppChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    app.removeListener(_onAppChanged);
    super.dispose();
  }

  void _onCoinTap(int idx, CoinColorOption item, bool isUnlocked) {
    app.haptic();
    if (isUnlocked) {
      setState(() => _colorIdx = idx);
      return;
    }

    if (app.points >= item.price) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: pal.card,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Row(
            children: [
              Guti(color: item.primary, size: 26, shape: app.shape),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  '${tr('buy')} ${item.name}',
                  style: TextStyle(
                    color: pal.text,
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
          content: Text(
            'Unlock ${item.name} coin color for ${item.price} PT?',
            style: TextStyle(color: pal.sub, fontSize: 14),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(
                tr('cancel'),
                style: TextStyle(color: pal.sub, fontWeight: FontWeight.w700),
              ),
            ),
            ChunkyButton(
              label: '${tr('buy')} ${item.price} PT',
              top: const Color(0xFFFFD54F),
              bottom: const Color(0xFFFFA000),
              edge: const Color(0xFFC57A0A),
              height: 42,
              fontSize: 13,
              onTap: () {
                Navigator.of(ctx).pop();
                final ok = app.buyCoin(idx);
                if (ok) {
                  Sfx.play('win');
                  setState(() => _colorIdx = idx);
                  toast(context, tr('purchased'));
                }
              },
            ),
          ],
        ),
      );
    } else {
      Sfx.play('lose');
      toast(context, '${tr('notEnoughPt')} (${item.price} PT)');
    }
  }

  Widget _diffTile(Difficulty d, int stars) {
    final sel = _diff == d;
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          app.haptic();
          setState(() => _diff = d);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: sel ? Colors.white : fade(Colors.white, .14),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: sel ? Pal.green : fade(Colors.white, .28),
              width: sel ? 2.5 : 1.2,
            ),
            boxShadow: sel
                ? [
                    const BoxShadow(
                      color: Color(0x332E9E43),
                      blurRadius: 8,
                      offset: Offset(0, 3),
                    )
                  ]
                : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  3,
                  (i) => Icon(
                    Icons.star_rounded,
                    size: 16,
                    color: i < stars
                        ? Pal.gold
                        : (sel ? const Color(0xFFC7BEDE) : fade(Colors.white, .35)),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                diffName(d),
                style: TextStyle(
                  color: sel ? pal.text : Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const ribbon = RibbonColors(
      Color(0xFFFFA000),
      Color(0xFFFF6F00),
      Color(0xFFE65100),
      Color(0xFF8D2E00),
    );

    final opt = kCoinColors[_colorIdx];

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Container(
          decoration: BoxDecoration(
            color: pal.card,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: fade(Colors.black, .4),
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 3D Ribbon Header
              SizedBox(
                height: 64,
                width: double.infinity,
                child: Stack(
                  alignment: Alignment.center,
                  clipBehavior: Clip.none,
                  children: [
                    CustomPaint(
                      size: const Size(260, 48),
                      painter: RibbonPainter(ribbon),
                    ),
                    Positioned(
                      top: 12,
                      child: Text(
                        tr('vsComputerSetup').toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          letterSpacing: 1.2,
                          fontWeight: FontWeight.w900,
                          shadows: [
                            Shadow(color: Color(0x66000000), offset: Offset(0, 2), blurRadius: 4),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      right: 12,
                      top: 10,
                      child: ChunkyIconButton(
                        icon: Icons.close_rounded,
                        size: 34,
                        top: const Color(0xFFFF6584),
                        bottom: const Color(0xFFD62B52),
                        edge: const Color(0xFF9E1534),
                        onTap: () => Navigator.of(context).pop(),
                      ),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Coin color section title
                    Text(
                      tr('coinColor'),
                      style: TextStyle(
                        color: pal.text,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Color palette circles
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                      decoration: BoxDecoration(
                        color: pal.soft,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: pal.border, width: 1.2),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: List.generate(kCoinColors.length, (idx) {
                              final item = kCoinColors[idx];
                              final isUnlocked = app.isCoinUnlocked(idx);
                              final isSel = idx == _colorIdx;
                              return GestureDetector(
                                onTap: () => _onCoinTap(idx, item, isUnlocked),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 180),
                                  padding: const EdgeInsets.all(3),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: isSel ? Pal.green : Colors.transparent,
                                      width: isSel ? 3 : 1,
                                    ),
                                    boxShadow: isSel
                                        ? [
                                            BoxShadow(
                                              color: item.primary.withAlpha(120),
                                              blurRadius: 8,
                                              offset: const Offset(0, 2),
                                            ),
                                          ]
                                        : null,
                                  ),
                                  child: Stack(
                                    alignment: Alignment.center,
                                    clipBehavior: Clip.none,
                                    children: [
                                      Guti(
                                        color: isUnlocked ? item.primary : item.primary.withAlpha(140),
                                        size: 34,
                                        shape: app.shape,
                                      ),
                                      if (!isUnlocked) ...[
                                        Container(
                                          width: 34,
                                          height: 34,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Colors.black.withAlpha(130),
                                          ),
                                          child: const Icon(
                                            Icons.lock_rounded,
                                            size: 16,
                                            color: Colors.white,
                                          ),
                                        ),
                                        Positioned(
                                          bottom: -5,
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                            decoration: BoxDecoration(
                                              color: app.points >= item.price
                                                  ? const Color(0xFFFFD54F)
                                                  : const Color(0xFFCFD8DC),
                                              borderRadius: BorderRadius.circular(6),
                                              border: Border.all(
                                                color: app.points >= item.price
                                                    ? const Color(0xFFC57A0A)
                                                    : const Color(0xFF90A4AE),
                                                width: 0.8,
                                              ),
                                            ),
                                            child: Text(
                                              '${item.price}P',
                                              style: TextStyle(
                                                fontSize: 8,
                                                fontWeight: FontWeight.w900,
                                                color: app.points >= item.price
                                                    ? const Color(0xFF5D3600)
                                                    : const Color(0xFF455A64),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              );
                            }),
                          ),
                          const SizedBox(height: 12),
                          // Live Match preview
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Guti(color: opt.primary, size: 22, shape: app.shape),
                                const SizedBox(width: 6),
                                Text(
                                  '${tr('you')}: ${opt.name}',
                                  style: TextStyle(
                                    color: pal.text,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Text('vs', style: TextStyle(color: pal.sub, fontSize: 11, fontWeight: FontWeight.w700)),
                                const SizedBox(width: 14),
                                Guti(color: opt.opponentColor, size: 22, shape: app.shape),
                                const SizedBox(width: 6),
                                Text(
                                  tr('computer'),
                                  style: TextStyle(
                                    color: pal.sub,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Difficulty section
                    Text(
                      tr('difficulty'),
                      style: TextStyle(
                        color: pal.text,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),

                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: pal.primary.withAlpha(200),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Row(
                        children: [
                          _diffTile(Difficulty.easy, 1),
                          const SizedBox(width: 6),
                          _diffTile(Difficulty.medium, 2),
                          const SizedBox(width: 6),
                          _diffTile(Difficulty.hard, 3),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Start Game ChunkyButton (standard height 64)
                    ChunkyButton(
                      label: tr('startGame'),
                      icon: Icons.play_arrow_rounded,
                      top: const Color(0xFF9CF2A3),
                      bottom: const Color(0xFF4FCB62),
                      edge: const Color(0xFF2E9E43),
                      height: 64,
                      onTap: () {
                        app.haptic();
                        if (!app.isCoinUnlocked(_colorIdx)) {
                          _colorIdx = 0;
                        }
                        app.set(() {
                          app.difficulty = _diff;
                          app.coinColorIndex = _colorIdx;
                        });
                        Navigator.of(context).pop();
                        widget.onConfirm(_diff, opt.primary, opt.opponentColor);
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
