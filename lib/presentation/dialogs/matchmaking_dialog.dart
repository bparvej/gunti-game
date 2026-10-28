import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../../core/audio/sfx.dart';
import '../../core/constants/strings.dart';
import '../../core/theme/palette.dart';
import '../controllers/app_state.dart';
import '../controllers/game_controller.dart';
import '../widgets/avatar_view.dart';
import '../widgets/chunky_button.dart';
import '../widgets/chunky_icon_button.dart';
import '../widgets/painters.dart';

class OnlineOpponentInfo {
  final String name;
  final int avatarIndex;
  final String ping;
  final int rating;

  const OnlineOpponentInfo({
    required this.name,
    required this.avatarIndex,
    required this.ping,
    required this.rating,
  });

  factory OnlineOpponentInfo.random() {
    final rng = math.Random();
    final name = kOnlineOpponents[rng.nextInt(kOnlineOpponents.length)];
    final avatarIndex = rng.nextInt(kAvatars.length);
    final ping = '${24 + rng.nextInt(28)} ms';
    final rating = 1250 + rng.nextInt(250);
    return OnlineOpponentInfo(
      name: name,
      avatarIndex: avatarIndex,
      ping: ping,
      rating: rating,
    );
  }
}

class MatchmakingDialog extends StatefulWidget {
  final void Function(OnlineOpponentInfo opponent) onMatchFound;
  final VoidCallback? onCancel;

  const MatchmakingDialog({
    super.key,
    required this.onMatchFound,
    this.onCancel,
  });

  static Future<void> show(
    BuildContext context, {
    required void Function(OnlineOpponentInfo opponent) onMatchFound,
  }) {
    return showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'matchmaking',
      barrierColor: const Color(0xB3120A2E),
      transitionDuration: const Duration(milliseconds: 320),
      pageBuilder: (ctx, a1, a2) => Center(
        child: MatchmakingDialog(
          onMatchFound: (opp) {
            Navigator.of(ctx).pop();
            onMatchFound(opp);
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

  @override
  State<MatchmakingDialog> createState() => _MatchmakingDialogState();
}

class _MatchmakingDialogState extends State<MatchmakingDialog>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseCtrl;
  Timer? _searchTimer;
  Timer? _matchTimer;
  Timer? _launchTimer;

  int _searchSeconds = 0;
  bool _found = false;
  OnlineOpponentInfo? _opponent;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();

    _searchTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      setState(() => _searchSeconds++);
    });

    // Simulate online matchmaking lookup (~1.8s)
    _matchTimer = Timer(const Duration(milliseconds: 1850), () {
      if (!mounted) return;
      final opp = OnlineOpponentInfo.random();
      Sfx.play('win');
      setState(() {
        _found = true;
        _opponent = opp;
      });

      // Brief transition showing "Match Found! VS opponent" before launching game
      _launchTimer = Timer(const Duration(milliseconds: 1200), () {
        if (!mounted) return;
        widget.onMatchFound(opp);
      });
    });
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    _searchTimer?.cancel();
    _matchTimer?.cancel();
    _launchTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const searchingRibbon = RibbonColors(
      Color(0xFFFFA000),
      Color(0xFFFF6F00),
      Color(0xFFE65100),
      Color(0xFF8D2E00),
    );

    const foundRibbon = RibbonColors(
      Color(0xFF81C784),
      Color(0xFF388E3C),
      Color(0xFF2E7D32),
      Color(0xFF1B5E20),
    );

    final ribbon = _found ? foundRibbon : searchingRibbon;
    final ribbonTitle = _found
        ? tr('matchFound').toUpperCase()
        : tr('playOnline').toUpperCase();

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 390),
        child: Container(
          decoration: BoxDecoration(
            color: pal.card,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: fade(Colors.black, .45),
                blurRadius: 28,
                offset: const Offset(0, 12),
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
                        ribbonTitle,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          letterSpacing: 1.2,
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
                    if (!_found)
                      Positioned(
                        right: 12,
                        top: 10,
                        child: ChunkyIconButton(
                          icon: Icons.close_rounded,
                          size: 34,
                          top: const Color(0xFFFF6584),
                          bottom: const Color(0xFFD62B52),
                          edge: const Color(0xFF9E1534),
                          onTap: () {
                            widget.onCancel?.call();
                            Navigator.of(context).pop();
                          },
                        ),
                      ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.fromLTRB(22, 12, 22, 24),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: _found ? _buildFoundView() : _buildSearchingView(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchingView() {
    return Column(
      key: const ValueKey('searching_view'),
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 10),
        // Radar pulse with player avatar at center
        SizedBox(
          width: 170,
          height: 170,
          child: Stack(
            alignment: Alignment.center,
            children: [
              AnimatedBuilder(
                animation: _pulseCtrl,
                builder: (context, _) {
                  return CustomPaint(
                    size: const Size(170, 170),
                    painter: _RadarPulsePainter(progress: _pulseCtrl.value),
                  );
                },
              ),
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: fade(Pal.gold, .35),
                      blurRadius: 18,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: AvatarView(
                  avatarIndex: app.avatarIndex,
                  size: 72,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),
        Text(
          app.displayName,
          style: TextStyle(
            color: pal.text,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 4),

        // Rating and server ping badge
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: pal.soft,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.star_rounded, color: Pal.gold, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    '${tr('rating')}: ${1300 + app.points ~/ 10}',
                    style: TextStyle(
                      color: pal.text,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: fade(const Color(0xFF4CAF50), .15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.circle, color: Color(0xFF4CAF50), size: 8),
                  SizedBox(width: 5),
                  Text(
                    '32 ms',
                    style: TextStyle(
                      color: Color(0xFF2E7D32),
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 20),

        // Status & search timer
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            color: pal.soft,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: pal.border, width: 1.2),
          ),
          child: Column(
            children: [
              Text(
                tr('findingOpponent'),
                style: TextStyle(
                  color: pal.text,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '00:${_searchSeconds.toString().padLeft(2, '0')}',
                style: TextStyle(
                  color: pal.sub,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // Cancel button
        ChunkyButton(
          label: tr('cancelMatchmaking'),
          icon: Icons.close_rounded,
          height: 48,
          fontSize: 14,
          top: const Color(0xFFFF8A80),
          bottom: const Color(0xFFE53935),
          edge: const Color(0xFFC62828),
          onTap: () {
            widget.onCancel?.call();
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }

  Widget _buildFoundView() {
    final opp = _opponent!;
    return Column(
      key: const ValueKey('found_view'),
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 12),
        // VS Matchup row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // User side
            Expanded(
              child: Column(
                children: [
                  AvatarView(avatarIndex: app.avatarIndex, size: 68),
                  const SizedBox(height: 8),
                  Text(
                    app.displayName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: pal.text,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '★ ${1300 + app.points ~/ 10}',
                    style: const TextStyle(
                      color: Pal.gold,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),

            // VS Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFF9800), Color(0xFFE65100)],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x66E65100),
                    blurRadius: 10,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: const Text(
                'VS',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.5,
                ),
              ),
            ),

            // Opponent side
            Expanded(
              child: Column(
                children: [
                  AvatarView(avatarIndex: opp.avatarIndex, size: 68),
                  const SizedBox(height: 8),
                  Text(
                    opp.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: pal.text,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '★ ${opp.rating}',
                    style: const TextStyle(
                      color: Pal.gold,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 22),

        // Playing against callout
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            color: fade(const Color(0xFF4CAF50), .12),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFF4CAF50),
              width: 1.5,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.sports_esports_rounded,
                  color: Color(0xFF2E7D32), size: 20),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  tr('playingAgainst', {'n': opp.name}),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF2E7D32),
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 14),
        const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation(Pal.greenDark),
              ),
            ),
            SizedBox(width: 8),
            Text(
              'Starting match…',
              style: TextStyle(
                color: Pal.greenDark,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _RadarPulsePainter extends CustomPainter {
  final double progress;

  _RadarPulsePainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = size.width / 2;

    for (int i = 0; i < 3; i++) {
      final p = (progress + (i * 0.33)) % 1.0;
      final radius = 36 + (maxRadius - 36) * p;
      final opacity = (1.0 - p).clamp(0.0, 1.0) * 0.45;

      final paint = Paint()
        ..color = const Color(0xFFFFA000).withValues(alpha: opacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;

      canvas.drawCircle(center, radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _RadarPulsePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
