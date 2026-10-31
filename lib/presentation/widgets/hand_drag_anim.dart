import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../../core/theme/palette.dart';
import 'guti_view.dart';

/// Animated hand dragging indicator that guides the player from one node to another.
/// Used for first-time tutorial guidance and in-game best-move hints.
class HandDragAnim extends StatefulWidget {
  final Offset from;
  final Offset to;
  final double coinSize;
  final Color coinColor;
  final String? label;
  final bool isHint;

  const HandDragAnim({
    super.key,
    required this.from,
    required this.to,
    this.coinSize = 44,
    this.coinColor = const Color(0xFF7C3AED),
    this.label,
    this.isHint = false,
  });

  @override
  State<HandDragAnim> createState() => _HandDragAnimState();
}

class _HandDragAnimState extends State<HandDragAnim>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2100),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final from = widget.from;
    final to = widget.to;
    final d = widget.coinSize;
    final accent = widget.isHint ? const Color(0xFFFFD54F) : Pal.green;
    final accentDark = widget.isHint ? const Color(0xFFFFA000) : Pal.greenDark;

    return RepaintBoundary(
      child: IgnorePointer(
        child: AnimatedBuilder(
          animation: _ctrl,
          builder: (context, _) {
            final t = _ctrl.value;

            // Phase timings:
            // 0.00 .. 0.15 : Fade-in & hover over `from`
            // 0.15 .. 0.28 : Touch-down (finger presses coin, start ripple)
            // 0.28 .. 0.72 : Smooth drag along line to `to`
            // 0.72 .. 0.85 : Touch-up at `to` (release, target pulse)
            // 0.85 .. 1.00 : Fade-out & reset pause

            double opacity;
            if (t < 0.12) {
              opacity = (t / 0.12).clamp(0.0, 1.0);
            } else if (t > 0.85) {
              opacity = ((1.0 - t) / 0.15).clamp(0.0, 1.0);
            } else {
              opacity = 1.0;
            }

            // Finger press scale
            double handScale = 1.0;
            if (t >= 0.15 && t < 0.28) {
              final p = (t - 0.15) / 0.13;
              handScale = 1.0 - 0.15 * math.sin(p * math.pi);
            } else if (t >= 0.72 && t < 0.85) {
              final p = (t - 0.72) / 0.13;
              handScale = 0.85 + 0.25 * math.sin(p * math.pi);
            } else if (t >= 0.28 && t < 0.72) {
              handScale = 0.88;
            }

            // Position interpolation
            Offset handPos;
            bool isDragging = false;
            if (t < 0.28) {
              handPos = from;
            } else if (t > 0.72) {
              handPos = to;
            } else {
              final dragProgress = Curves.easeInOutCubic.transform(
                (t - 0.28) / (0.72 - 0.28),
              );
              handPos = Offset.lerp(from, to, dragProgress)!;
              isDragging = true;
            }

            // Drag trail line progress
            final lineProgress = (t < 0.28)
                ? 0.0
                : (t > 0.72)
                    ? 1.0
                    : Curves.easeInOutCubic.transform((t - 0.28) / (0.72 - 0.28));

            return Opacity(
              opacity: opacity,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // 1. Glowing animated path line
                  CustomPaint(
                    size: Size.infinite,
                    painter: _DragTrailPainter(
                      from: from,
                      to: to,
                      progress: lineProgress,
                      color: accent,
                    ),
                  ),

                  // 2. Target destination halo beacon
                  Positioned(
                    left: to.dx - d * 0.45,
                    top: to.dy - d * 0.45,
                    width: d * 0.9,
                    height: d * 0.9,
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: accent.withAlpha((50 + 40 * math.sin(t * math.pi * 3)).toInt().clamp(0, 255)),
                        border: Border.all(
                          color: accentDark,
                          width: 2.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: accent.withAlpha(120),
                            blurRadius: 8,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Icon(
                          Icons.arrow_downward_rounded,
                          size: d * 0.45,
                          color: accentDark,
                        ),
                      ),
                    ),
                  ),

                  // 3. Touch ripple at origin during press-down
                  if (t >= 0.15 && t < 0.50) ...[
                    Positioned(
                      left: from.dx - d * 0.6,
                      top: from.dy - d * 0.6,
                      width: d * 1.2,
                      height: d * 1.2,
                      child: TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0.5, end: 1.2),
                        duration: const Duration(milliseconds: 400),
                        builder: (context, scale, child) {
                          return Transform.scale(
                            scale: scale,
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: accent.withAlpha((180 * (1.2 - scale)).toInt().clamp(0, 255)),
                                  width: 2.5,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],

                  // 4. Ghost dragged coin following the finger
                  if (isDragging) ...[
                    Positioned(
                      left: handPos.dx - d * 0.42,
                      top: handPos.dy - d * 0.42,
                      width: d * 0.84,
                      height: d * 0.84,
                      child: Opacity(
                        opacity: 0.82,
                        child: Transform.scale(
                          scale: 0.92,
                          child: Guti(
                            color: widget.coinColor,
                            size: d * 0.84,
                            ring: true,
                            ringColor: accent,
                          ),
                        ),
                      ),
                    ),
                  ],

                  // 5. Animated Hand Pointer
                  Positioned(
                    left: handPos.dx - 18,
                    top: handPos.dy - 8,
                    child: Transform.scale(
                      scale: handScale,
                      alignment: Alignment.topLeft,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // 3D Styled Hand Pointer
                          Stack(
                            clipBehavior: Clip.none,
                            alignment: Alignment.center,
                            children: [
                              // Fingertip touch contact glow point
                              Positioned(
                                top: 4,
                                left: 6,
                                child: Container(
                                  width: 14,
                                  height: 14,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: accent.withAlpha(200),
                                    boxShadow: [
                                      BoxShadow(
                                        color: accent,
                                        blurRadius: 10,
                                        spreadRadius: 3,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              // Hand Icon with 3D drop shadow
                              Positioned(
                                top: 2.5,
                                left: 1.5,
                                child: Icon(
                                  Icons.pan_tool_alt_rounded,
                                  size: 44,
                                  color: Colors.black.withAlpha(120),
                                ),
                              ),
                              const Icon(
                                Icons.pan_tool_alt_rounded,
                                size: 44,
                                color: Colors.white,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  // 6. Floating Hint Badge
                  if (widget.label != null) ...[
                    Positioned(
                      left: 0,
                      right: 0,
                      top: math.max(2.0, math.min(from.dy, to.dy) - 38),
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: widget.isHint
                                  ? const [Color(0xFFFFD54F), Color(0xFFFFA000)]
                                  : const [Color(0xFF382375), Color(0xFF20124D)],
                            ),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: widget.isHint
                                  ? const Color(0xFFFFF176)
                                  : const Color(0xFF7C3AED),
                              width: 1.6,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: (widget.isHint
                                        ? const Color(0xFFC57A0A)
                                        : Colors.black)
                                    .withAlpha(120),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                widget.isHint
                                    ? Icons.lightbulb_rounded
                                    : Icons.touch_app_rounded,
                                size: 13,
                                color: widget.isHint
                                    ? const Color(0xFF5D3600)
                                    : const Color(0xFFFFD54F),
                              ),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  widget.label!,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: widget.isHint
                                        ? const Color(0xFF5D3600)
                                        : Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Custom painter for the animated glowing trail connecting origin and destination.
class _DragTrailPainter extends CustomPainter {
  final Offset from;
  final Offset to;
  final double progress;
  final Color color;

  _DragTrailPainter({
    required this.from,
    required this.to,
    required this.progress,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0.01) return;

    final cur = Offset.lerp(from, to, progress)!;

    // Glowing halo line
    final glowPaint = Paint()
      ..color = color.withAlpha(110)
      ..strokeWidth = 7.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    canvas.drawLine(from, cur, glowPaint);

    // Inner bright beam
    final corePaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    canvas.drawLine(from, cur, corePaint);
  }

  @override
  bool shouldRepaint(covariant _DragTrailPainter old) {
    return old.from != from ||
        old.to != to ||
        old.progress != progress ||
        old.color != color;
  }
}
