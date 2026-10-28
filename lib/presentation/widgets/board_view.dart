import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../../core/theme/palette.dart';
import '../../domain/game/game_enums.dart';
import '../controllers/app_state.dart';
import '../controllers/game_controller.dart';
import 'guti_view.dart';
import 'painters.dart';

/// Board view with sliding pieces, touch handling, hint highlight,
/// and first-time gameplay guidance.
class BoardView extends StatelessWidget {
  final GameController c;
  BoardView({super.key, GameController? c, GameController? controller})
      : c = c ?? controller!;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, box) {
      final s = math.min(box.maxWidth, box.maxHeight);
      final pad = s * .12;
      final step = (s - pad * 2) / 2;
      final d = step * .52; // guti diameter
      final hit = step * .84;

      Offset pos(int i) {
        final r = i ~/ 3;
        final col = i % 3;
        return Offset(pad + col * step, pad + r * step);
      }

      final targets = c.targets;
      final pickNode = (c.selected != null && targets.isNotEmpty)
          ? targets[c.pick.clamp(0, targets.length - 1)]
          : -1;

      final isFirstTime = !app.hasSeenTutorial &&
          c.outcome == Outcome.none &&
          c.state.turn == 1 &&
          c.state.ply == 0;

      return RepaintBoundary(
        child: SizedBox(
          width: s,
          height: s,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // board lines
              Positioned.fill(
                child: RepaintBoundary(
                  child: CustomPaint(
                    isComplex: true,
                    willChange: false,
                    painter: LinesPainter(pad, step, pal.line),
                  ),
                ),
              ),
              // touch targets + empty-point markers
              for (var i = 0; i < 9; i++)
                Positioned(
                  left: pos(i).dx - hit / 2,
                  top: pos(i).dy - hit / 2,
                  width: hit,
                  height: hit,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      c.tap(i);
                      if (isFirstTime && c.state.ply > 0) {
                        app.set(() => app.hasSeenTutorial = true);
                      }
                    },
                    child: Center(
                      child: _marker(
                        c.state.b[i] == 0,
                        targets.contains(i),
                        i == pickNode,
                        c.hintMove != null && c.hintMove!.to == i,
                        d,
                      ),
                    ),
                  ),
                ),
              // pieces – slide (300ms) when their node changes
              for (final pc in c.pcs)
                AnimatedPositioned(
                  key: ValueKey('pc${pc.id}'),
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOutCubic,
                  left: pos(pc.node).dx - d / 2,
                  top: pos(pc.node).dy - d / 2,
                  width: d,
                  height: d,
                  child: RepaintBoundary(
                    child: IgnorePointer(
                      child: TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0, end: 1),
                        duration: const Duration(milliseconds: 380),
                        curve: Curves.easeOutBack,
                        builder: (context, v, child) =>
                            Transform.scale(scale: v, child: child),
                        child: Guti(
                          color: pc.player == 1
                              ? (c.p1Color ?? pal.me)
                              : (c.p2Color ?? pal.opp),
                          size: d,
                          ring: (c.hintMove != null && c.hintMove!.from == pc.node) ||
                              c.selected == pc.node ||
                              (c.winLine?.contains(pc.node) ?? false),
                          ringColor: (c.winLine?.contains(pc.node) ?? false)
                              ? Pal.gold
                              : (c.hintMove != null && c.hintMove!.from == pc.node)
                                  ? const Color(0xFFFFD54F)
                                  : Pal.green,
                        ),
                      ),
                    ),
                  ),
                ),
              // First time how-to-play guidance overlay
              if (isFirstTime)
                _buildTutorialPointer(pos, d),
            ],
          ),
        ),
      );
    });
  }

  Widget _marker(
    bool empty,
    bool isTarget,
    bool picked,
    bool isHintTarget,
    double d,
  ) {
    if (!empty) return const SizedBox.shrink();
    if (isHintTarget) {
      return Container(
        width: d * .82,
        height: d * .82,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: fade(const Color(0xFFFFD54F), .4),
          border: Border.all(color: const Color(0xFFFFA000), width: 3.5),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFFD54F).withAlpha(160),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: const Center(
          child: Icon(
            Icons.arrow_downward_rounded,
            color: Color(0xFFE65100),
            size: 22,
          ),
        ),
      );
    }
    if (isTarget) {
      final s = picked ? d * .86 : d * .6;
      return AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        width: s,
        height: s,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: fade(Pal.green, picked ? .75 : .35),
          border: Border.all(color: Pal.greenDark, width: picked ? 4 : 3),
        ),
      );
    }
    return Container(
      width: d * .26,
      height: d * .26,
      decoration: BoxDecoration(color: pal.line, shape: BoxShape.circle),
    );
  }

  Widget _buildTutorialPointer(Offset Function(int i) pos, double d) {
    final targetNode = c.selected == null ? 7 : 4;
    final p = pos(targetNode);
    final text = c.selected == null
        ? '1. Tap coin to select'
        : '2. Tap center to move';

    return Positioned(
      left: p.dx - 80,
      top: p.dy - (c.selected == null ? 72 : 68),
      width: 160,
      child: RepaintBoundary(
        child: IgnorePointer(
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: const Duration(milliseconds: 600),
            curve: Curves.elasticOut,
            builder: (context, val, child) =>
                Transform.scale(scale: val, child: child),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2E1B6B),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: const Color(0xFFFFD54F), width: 1.6),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x66000000),
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Text(
                    text,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const Icon(
                  Icons.arrow_drop_down_rounded,
                  color: Color(0xFFFFD54F),
                  size: 26,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
