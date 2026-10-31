import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../../core/audio/sfx.dart';
import '../../core/constants/strings.dart';
import '../../core/theme/palette.dart';
import '../../domain/game/game_enums.dart';
import '../controllers/app_state.dart';
import '../controllers/game_controller.dart';
import 'guti_view.dart';
import 'hand_drag_anim.dart';
import 'painters.dart';

/// Board view with sliding pieces, 1:1 real-time drag-and-drop handling,
/// animated hand drag tutorial, and in-game hint demonstration.
class BoardView extends StatefulWidget {
  final GameController c;

  BoardView({super.key, GameController? c, GameController? controller})
      : c = c ?? controller!;

  @override
  State<BoardView> createState() => _BoardViewState();
}

class _BoardViewState extends State<BoardView> {
  GameController get c => widget.c;

  int? _draggingFrom;
  Offset? _dragPos;
  int? _justDroppedPieceId;

  int? _nodeAt(Offset localPos, Offset Function(int) pos, double hit) {
    int? bestNode;
    double bestDist = double.infinity;
    for (var i = 0; i < 9; i++) {
      final dist = (localPos - pos(i)).distance;
      if (dist < hit * 0.72 && dist < bestDist) {
        bestDist = dist;
        bestNode = i;
      }
    }
    return bestNode;
  }

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
      final isFirstTime = !app.hasSeenTutorial &&
          c.outcome == Outcome.none &&
          c.state.turn == 1 &&
          c.state.ply == 0;

      // Drop target hover detection during drag
      int? hoverTarget;
      if (_draggingFrom != null && _dragPos != null) {
        final hovered = _nodeAt(_dragPos!, pos, hit);
        if (hovered != null && targets.contains(hovered)) {
          hoverTarget = hovered;
        }
      }

      return RepaintBoundary(
        child: SizedBox(
          width: s,
          height: s,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onPanStart: (details) {
              if (c.outcome != Outcome.none) return;
              final t = c.state.turn;
              if (c.isComputer(t)) return;

              final node = _nodeAt(details.localPosition, pos, hit);
              if (node != null && c.state.b[node] == t) {
                setState(() {
                  _draggingFrom = node;
                  _dragPos = details.localPosition;
                  _justDroppedPieceId = null;
                });
                c.tap(node);
              }
            },
            onPanUpdate: (details) {
              if (_draggingFrom != null) {
                setState(() {
                  _dragPos = details.localPosition;
                });
              }
            },
            onPanEnd: (details) {
              if (_draggingFrom != null && _dragPos != null) {
                final target = _nodeAt(_dragPos!, pos, hit);
                final from = _draggingFrom!;

                // Identify the piece being dragged
                final draggedPc = c.pcs.firstWhere(
                  (p) => p.node == from,
                  orElse: () => c.pcs.first,
                );

                if (target != null && target != from && targets.contains(target)) {
                  // Direct clean drop: piece stays at target, no duplicate slide!
                  setState(() {
                    _justDroppedPieceId = draggedPc.id;
                    _draggingFrom = null;
                    _dragPos = null;
                  });
                  c.tryMove(from, target);
                  Sfx.play('click');
                  if (isFirstTime) {
                    app.set(() => app.hasSeenTutorial = true);
                  }
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) {
                      setState(() => _justDroppedPieceId = null);
                    }
                  });
                } else {
                  // Dropped invalidly: snap smoothly back to origin
                  setState(() {
                    _draggingFrom = null;
                    _dragPos = null;
                  });
                }
              } else {
                setState(() {
                  _draggingFrom = null;
                  _dragPos = null;
                });
              }
            },
            onTapUp: (details) {
              if (c.outcome != Outcome.none) return;
              final node = _nodeAt(details.localPosition, pos, hit);
              if (node != null) {
                setState(() {
                  _justDroppedPieceId = null;
                });
                c.tap(node);
                if (isFirstTime && c.state.ply > 0) {
                  app.set(() => app.hasSeenTutorial = true);
                }
              }
            },
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // 1. Board lines
                Positioned.fill(
                  child: RepaintBoundary(
                    child: CustomPaint(
                      isComplex: true,
                      willChange: false,
                      painter: LinesPainter(pad, step, pal.line),
                    ),
                  ),
                ),

                // 2. Empty-point markers & drop zone highlights
                for (var i = 0; i < 9; i++)
                  Positioned(
                    left: pos(i).dx - hit / 2,
                    top: pos(i).dy - hit / 2,
                    width: hit,
                    height: hit,
                    child: Center(
                      child: _marker(
                        c.state.b[i] == 0,
                        targets.contains(i),
                        hoverTarget == i,
                        c.hintMove != null && c.hintMove!.to == i,
                        d,
                      ),
                    ),
                  ),

                // 3. Pieces – 1:1 real-time drag positioning without double animation!
                for (final pc in c.pcs) ...[
                  Builder(builder: (context) {
                    final isBeingDragged =
                        _draggingFrom == pc.node && _dragPos != null;
                    final isJustDropped = _justDroppedPieceId == pc.id;

                    final left = isBeingDragged
                        ? (_dragPos!.dx - d / 2)
                        : (pos(pc.node).dx - d / 2);
                    final top = isBeingDragged
                        ? (_dragPos!.dy - d / 2)
                        : (pos(pc.node).dy - d / 2);

                    return AnimatedPositioned(
                      key: ValueKey('pc${pc.id}'),
                      // ZERO duration during drag and on drop -> moves exactly once!
                      duration: (isBeingDragged || isJustDropped)
                          ? Duration.zero
                          : const Duration(milliseconds: 280),
                      curve: Curves.easeOutCubic,
                      left: left,
                      top: top,
                      width: d,
                      height: d,
                      child: RepaintBoundary(
                        child: IgnorePointer(
                          child: Transform.scale(
                            scale: isBeingDragged ? 1.14 : 1.0,
                            child: Guti(
                              color: pc.player == 1
                                  ? (c.p1Color ?? pal.me)
                                  : (c.p2Color ?? pal.opp),
                              size: d,
                              ring: isBeingDragged ||
                                  (c.hintMove != null &&
                                      c.hintMove!.from == pc.node) ||
                                  c.selected == pc.node ||
                                  (c.winLine?.contains(pc.node) ?? false),
                              ringColor: (c.winLine?.contains(pc.node) ?? false)
                                  ? Pal.gold
                                  : (c.hintMove != null &&
                                          c.hintMove!.from == pc.node)
                                      ? const Color(0xFFFFD54F)
                                      : Pal.green,
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ],

                // 4. Animated Hand Dragging for First-Time Tutorial
                if (isFirstTime && _draggingFrom == null)
                  HandDragAnim(
                    from: pos(7),
                    to: pos(4),
                    coinSize: d,
                    coinColor: c.p1Color ?? pal.me,
                    label: tr('dragToMove'),
                    isHint: false,
                  ),

                // 5. Animated Hand Dragging for In-Game Best Move Hint
                if (c.hintMove != null && _draggingFrom == null)
                  HandDragAnim(
                    from: pos(c.hintMove!.from),
                    to: pos(c.hintMove!.to),
                    coinSize: d,
                    coinColor: (c.hintMove!.from >= 0 &&
                            c.state.b[c.hintMove!.from] == 1)
                        ? (c.p1Color ?? pal.me)
                        : (c.p2Color ?? pal.opp),
                    label: tr('bestMove'),
                    isHint: true,
                  ),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _marker(
    bool empty,
    bool isTarget,
    bool isHovered,
    bool isHintTarget,
    double d,
  ) {
    if (!empty) return const SizedBox.shrink();
    if (isHintTarget) {
      return Container(
        width: d * .84,
        height: d * .84,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: fade(const Color(0xFFFFD54F), .35),
          border: Border.all(color: const Color(0xFFFFA000), width: 3.0),
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
      final s = isHovered ? d * .94 : d * .68;
      return AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        width: s,
        height: s,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: fade(Pal.green, isHovered ? .8 : .4),
          border: Border.all(color: Pal.greenDark, width: isHovered ? 4.5 : 3),
          boxShadow: isHovered
              ? [
                  BoxShadow(
                    color: Pal.green.withAlpha(180),
                    blurRadius: 12,
                    spreadRadius: 3,
                  ),
                ]
              : null,
        ),
      );
    }
    return Container(
      width: d * .26,
      height: d * .26,
      decoration: BoxDecoration(color: pal.line, shape: BoxShape.circle),
    );
  }
}
