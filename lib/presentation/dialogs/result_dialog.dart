import 'package:flutter/material.dart';

import '../../core/constants/strings.dart';
import '../../core/theme/palette.dart';
import '../../domain/game/game_enums.dart';
import '../../domain/game/game_models.dart';
import '../controllers/app_state.dart';
import '../widgets/chunky_button.dart';
import '../widgets/coin_badge.dart';
import '../widgets/painters.dart';

class ResultDialog extends StatefulWidget {
  final GameResult result;
  final VoidCallback onOk;
  final VoidCallback onAgain;
  final VoidCallback? onReplay;
  const ResultDialog(
      {super.key,
      required this.result,
      required this.onOk,
      required this.onAgain,
      this.onReplay});

  @override
  State<ResultDialog> createState() => _ResultDialogState();
}

class _ResultDialogState extends State<ResultDialog>
    with TickerProviderStateMixin {
  late final AnimationController _a;
  late final AnimationController _spin;

  @override
  void initState() {
    super.initState();
    _a = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1800))
      ..forward();
    _spin =
        AnimationController(vsync: this, duration: const Duration(seconds: 24))
          ..repeat();
  }

  @override
  void dispose() {
    _a.dispose();
    _spin.dispose();
    super.dispose();
  }

  GameResult get r => widget.result;

  int get _stars => r.stars;

  RibbonColors get _colors {
    if (r.outcome == Outcome.draw) {
      return const RibbonColors(
          Color(0xFF9D8CFF), Color(0xFF6A4FE0), Color(0xFF4B35B5), Color(0xFF3B2A99));
    }
    if ((r.mode == Mode.vsComputer || r.mode == Mode.online) &&
        r.outcome == Outcome.p2) {
      return const RibbonColors(
          Color(0xFFFF9A8F), Color(0xFFE04B4B), Color(0xFFB03030), Color(0xFF9C2626));
    }
    return const RibbonColors(
        Color(0xFFFF7BC0), Color(0xFFE23E9C), Color(0xFFB52A7A), Color(0xFF9C1F66));
  }

  String get _title {
    if (r.outcome == Outcome.draw) return tr('draw').toUpperCase();
    if ((r.mode == Mode.vsComputer || r.mode == Mode.online) &&
        r.outcome == Outcome.p2) {
      return tr('defeat').toUpperCase();
    }
    return tr('victory').toUpperCase();
  }

  String get _label {
    if (r.mode == Mode.twoPlayer) {
      if (r.outcome == Outcome.p1) return r.p1Name;
      if (r.outcome == Outcome.p2) return r.p2Name;
      return tr('twoPlayers');
    }
    if (r.mode == Mode.online) {
      return tr('onlineMatch').toUpperCase();
    }
    return diffName(r.difficulty).toUpperCase();
  }

  Widget _outlined(String t, double size, Color fill, Color stroke) {
    final base = TextStyle(
        fontSize: size, fontWeight: FontWeight.w900, letterSpacing: 1.2);
    return Stack(
      children: [
        Text(t,
            style: base.copyWith(
                foreground: Paint()
                  ..style = PaintingStyle.stroke
                  ..strokeWidth = 5
                  ..strokeJoin = StrokeJoin.round
                  ..color = stroke)),
        Text(t, style: base.copyWith(color: fill)),
      ],
    );
  }

  Widget _star(int i, double size, double angle) {
    final anim = CurvedAnimation(
      parent: _a,
      curve: Interval(.10 + i * .14, .45 + i * .14, curve: Curves.easeOutBack),
    );
    return AnimatedBuilder(
      animation: anim,
      builder: (context, child) => Transform.rotate(
        angle: angle,
        child: Transform.scale(
          scale: anim.value.clamp(0.0, 1.3).toDouble(),
          child: CustomPaint(
            size: Size(size, size),
            painter: StarPainter(lit: i < _stars),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const w = 320.0;
    final col = _colors;
    final total = app.points;
    final prev = total - r.points;
    final count = CurvedAnimation(
        parent: _a, curve: const Interval(.35, .85, curve: Curves.easeOut));

    return Material(
      type: MaterialType.transparency,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: w,
            height: 372,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // sun rays
                Positioned(
                  left: -160,
                  top: -130,
                  width: 640,
                  height: 400,
                  child: IgnorePointer(
                    child: RotationTransition(
                      turns: _spin,
                      child: CustomPaint(painter: RaysPainter()),
                    ),
                  ),
                ),
                // stars (behind the ribbon)
                Positioned(left: 57, top: 24, child: _star(0, 62, -.28)),
                Positioned(left: 201, top: 24, child: _star(2, 62, .28)),
                Positioned(left: 118, top: 2, child: _star(1, 84, 0)),
                // white card
                Positioned(
                  left: 22,
                  right: 22,
                  top: 92,
                  height: 244,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: const [
                        BoxShadow(
                            color: Color(0xFFB9A8EC), offset: Offset(0, 7)),
                        BoxShadow(
                            color: Color(0x33000000),
                            blurRadius: 24,
                            offset: Offset(0, 14)),
                      ],
                    ),
                  ),
                ),
                // ribbon
                Positioned(
                  left: 0,
                  top: 62,
                  width: w,
                  height: 80,
                  child: CustomPaint(painter: RibbonPainter(col)),
                ),
                Positioned(
                  left: 34,
                  top: 62,
                  width: w - 68,
                  height: 62,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('$_label · ${tr('moves').toUpperCase()} ${r.moves}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              color: fade(Colors.white, .85),
                              fontSize: 11,
                              letterSpacing: 1.6,
                              fontWeight: FontWeight.w800)),
                      _outlined(_title, 27, Colors.white, col.outline),
                    ],
                  ),
                ),
                // score + reward
                Positioned(
                  left: 22,
                  right: 22,
                  top: 148,
                  child: Column(
                    children: [
                      const Text('SCORE',
                          style: TextStyle(
                              color: Color(0xFF5CB6E8),
                              fontSize: 12,
                              letterSpacing: 1.4,
                              fontWeight: FontWeight.w900)),
                      const SizedBox(height: 6),
                      Container(
                        width: 200,
                        height: 50,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: const Color(0xFFD2F5FF),
                          borderRadius: BorderRadius.circular(26),
                          border: Border.all(
                              color: const Color(0xFFB4E9F8), width: 2),
                        ),
                        child: AnimatedBuilder(
                          animation: count,
                          builder: (context, child) {
                            final shown =
                                (prev + (total - prev) * count.value).round();
                            return Text(fmtNum(shown),
                                style: const TextStyle(
                                    color: Color(0xFF2B8DD6),
                                    fontSize: 27,
                                    letterSpacing: 1,
                                    fontWeight: FontWeight.w900));
                          },
                        ),
                      ),
                      const SizedBox(height: 18),
                      const Text('REWARD',
                          style: TextStyle(
                              color: Color(0xFF5CB6E8),
                              fontSize: 12,
                              letterSpacing: 1.4,
                              fontWeight: FontWeight.w900)),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const CoinStack(width: 46),
                          const SizedBox(width: 10),
                          Text('${r.points}',
                              style: const TextStyle(
                                  color: Color(0xFF2B8DD6),
                                  fontSize: 27,
                                  fontWeight: FontWeight.w900)),
                        ],
                      ),
                    ],
                  ),
                ),
                // OK button
                Positioned(
                  top: 312,
                  left: (w - 140) / 2,
                  width: 140,
                  height: 56,
                  child: GestureDetector(
                    onTap: widget.onOk,
                    child: Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(28),
                        gradient: const LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Color(0xFFA567FF), Color(0xFF7430E0)],
                        ),
                        boxShadow: const [
                          BoxShadow(
                              color: Color(0xFF4B1D9C), offset: Offset(0, 5)),
                          BoxShadow(
                              color: Color(0x40000000),
                              blurRadius: 12,
                              offset: Offset(0, 10)),
                        ],
                      ),
                      child: Text(tr('ok'),
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 23,
                              fontWeight: FontWeight.w900)),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (r.unlocks.isNotEmpty) ...[
            const SizedBox(height: 18),
            Container(
              width: 300,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: fade(Colors.black, .30),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Pal.gold, width: 1.5),
              ),
              child: Column(
                children: [
                  Text('🔓 ${tr('unlocked')}',
                      style: const TextStyle(
                          color: Pal.gold,
                          fontSize: 14,
                          fontWeight: FontWeight.w900)),
                  for (final u in r.unlocks)
                    Padding(
                      padding: const EdgeInsets.only(top: 3),
                      child: Text(u,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w700)),
                    ),
                ],
              ),
            ),
          ],
          if (widget.onReplay != null) ...[
            const SizedBox(height: 18),
            SizedBox(
              width: 220,
              child: ChunkyButton(
                label: tr('replayMatch'),
                icon: Icons.replay_rounded,
                top: const Color(0xFF4AC3FF),
                bottom: const Color(0xFF0C82DF),
                edge: const Color(0xFF095CA0),
                height: 48,
                fontSize: 15,
                onTap: widget.onReplay!,
              ),
            ),
          ],
          const SizedBox(height: 16),
          GestureDetector(
            onTap: widget.onAgain,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: fade(Colors.white, .18),
                borderRadius: BorderRadius.circular(22),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.refresh_rounded,
                      color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                  Text(tr('playAgain'),
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w700)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
