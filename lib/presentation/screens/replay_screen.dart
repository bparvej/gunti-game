import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../../core/audio/sfx.dart';
import '../../core/constants/strings.dart';
import '../../core/theme/palette.dart';
import '../../domain/game/game_enums.dart';
import '../../domain/game/game_models.dart';
import '../controllers/app_state.dart';
import '../widgets/chunky_icon_button.dart';
import '../widgets/gradient_bg.dart';
import '../widgets/guti_view.dart';
import '../widgets/level_bar.dart';
import '../widgets/painters.dart';

class ReplayScreen extends StatefulWidget {
  final List<Snap> history;
  final String p1Name, p2Name;
  final Outcome outcome;
  final List<int>? winLine;
  final Color? p1Color;
  final Color? p2Color;

  const ReplayScreen({
    super.key,
    required this.history,
    required this.p1Name,
    required this.p2Name,
    required this.outcome,
    this.winLine,
    this.p1Color,
    this.p2Color,
  });

  @override
  State<ReplayScreen> createState() => _ReplayScreenState();
}

class _ReplayScreenState extends State<ReplayScreen> {
  late int _step = 0;
  bool _isPlaying = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _step = 0;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startPlayback();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startPlayback() {
    if (_isPlaying) return;
    _timer?.cancel();
    setState(() => _isPlaying = true);
    _timer = Timer.periodic(const Duration(milliseconds: 900), (t) {
      if (!mounted) return;
      if (_step < widget.history.length - 1) {
        setState(() => _step++);
        Sfx.play('move');
      } else {
        _stopPlayback();
      }
    });
  }

  void _stopPlayback() {
    _timer?.cancel();
    if (mounted) setState(() => _isPlaying = false);
  }

  void _togglePlayback() {
    app.haptic();
    if (_isPlaying) {
      _stopPlayback();
    } else {
      if (_step >= widget.history.length - 1) {
        setState(() => _step = 0);
      }
      _startPlayback();
    }
  }

  void _next() {
    app.haptic();
    _stopPlayback();
    if (_step < widget.history.length - 1) {
      setState(() => _step++);
      Sfx.play('move');
    }
  }

  void _prev() {
    app.haptic();
    _stopPlayback();
    if (_step > 0) {
      setState(() => _step--);
      Sfx.play('undo');
    }
  }

  void _restart() {
    app.haptic();
    _stopPlayback();
    setState(() => _step = 0);
  }

  @override
  Widget build(BuildContext context) {
    final snaps = widget.history;
    final totalSteps = math.max(0, snaps.length - 1);
    final currentSnap =
        snaps.isNotEmpty ? snaps[_step.clamp(0, totalSteps)] : null;
    final isLast = _step == totalSteps;
    final winLine = isLast ? widget.winLine : null;

    String statusText;
    if (isLast) {
      if (widget.outcome == Outcome.p1) {
        statusText = tr('winsN', {'n': widget.p1Name});
      } else if (widget.outcome == Outcome.p2) {
        statusText = tr('winsN', {'n': widget.p2Name});
      } else {
        statusText = tr('drawTitle');
      }
    } else if (currentSnap != null) {
      final turnName =
          currentSnap.state.turn == 1 ? widget.p1Name : widget.p2Name;
      statusText = tr('turnOf', {'n': turnName});
    } else {
      statusText = '';
    }

    return appBuilder((context) {
      return Scaffold(
        backgroundColor: pal.bg1,
        body: GradientBg(
          child: SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
                  child: Column(
                    children: [
                      // Top Bar
                      Row(
                        children: [
                          ChunkyIconButton(
                            icon: Icons.close_rounded,
                            size: 44,
                            top: const Color(0xFFFF6584),
                            bottom: const Color(0xFFD62B52),
                            edge: const Color(0xFF9E1534),
                            onTap: () => Navigator.of(context).pop(),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.videocam_rounded,
                                        color: Pal.gold, size: 20),
                                    const SizedBox(width: 6),
                                    Text(
                                      tr('replay').toUpperCase(),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: 1.2,
                                      ),
                                    ),
                                  ],
                                ),
                                Text(
                                  statusText,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: isLast
                                        ? Pal.gold
                                        : fade(Colors.white, .85),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Move Counter 3D Pill
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 7),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              gradient: const LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [Color(0xFF382375), Color(0xFF20124D)],
                              ),
                              border: Border.all(
                                  color: const Color(0xFF6B4CC9), width: 1.5),
                              boxShadow: const [
                                BoxShadow(
                                    color: Color(0xFF130933),
                                    offset: Offset(0, 3)),
                              ],
                            ),
                            child: Text(
                              '${tr('moves')} $_step / $totalSteps',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Board Card
                      Expanded(
                        child: Center(
                          child: SingleChildScrollView(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(18),
                                  decoration: BoxDecoration(
                                    color: pal.card,
                                    borderRadius: BorderRadius.circular(26),
                                    boxShadow: const [
                                      BoxShadow(
                                          color: Color(0xFFB9A8EC),
                                          offset: Offset(0, 6)),
                                      BoxShadow(
                                          color: Color(0x33000000),
                                          blurRadius: 18,
                                          offset: Offset(0, 10)),
                                    ],
                                  ),
                                  child: Column(
                                    children: [
                                      ConstrainedBox(
                                        constraints:
                                            const BoxConstraints(maxWidth: 320),
                                        child: AspectRatio(
                                          aspectRatio: 1,
                                          child: LayoutBuilder(
                                              builder: (context, cons) {
                                            final size = cons.maxWidth;
                                            final pad = size * .14;
                                            final step = (size - 2 * pad) / 2;
                                            Offset pos(int i) => Offset(
                                                pad + (i % 3) * step,
                                                pad + (i ~/ 3) * step);
                                            final hit = size * .27;
                                            final d = hit * .66;

                                            return Container(
                                              decoration: BoxDecoration(
                                                color: pal.soft,
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                              ),
                                              child: Stack(
                                                children: [
                                                  Positioned.fill(
                                                    child: CustomPaint(
                                                        painter: LinesPainter(
                                                            pad,
                                                            step,
                                                            pal.line)),
                                                  ),
                                                  for (var i = 0; i < 9; i++)
                                                    Positioned(
                                                      left:
                                                          pos(i).dx - d * .13,
                                                      top:
                                                          pos(i).dy - d * .13,
                                                      width: d * .26,
                                                      height: d * .26,
                                                      child: Container(
                                                        decoration:
                                                            BoxDecoration(
                                                          color: pal.line,
                                                          shape:
                                                              BoxShape.circle,
                                                        ),
                                                      ),
                                                    ),
                                                  if (currentSnap != null)
                                                    for (final pc
                                                        in currentSnap.pcs)
                                                      AnimatedPositioned(
                                                        key: ValueKey(
                                                            'replay_pc_${pc.id}'),
                                                        duration: const Duration(
                                                            milliseconds: 320),
                                                        curve: Curves
                                                            .easeInOutCubic,
                                                        left: pos(pc.node).dx -
                                                            d / 2,
                                                        top: pos(pc.node).dy -
                                                            d / 2,
                                                        width: d,
                                                        height: d,
                                                        child: Guti(
                                                          color: pc.player == 1
                                                              ? (widget.p1Color ?? pal.me)
                                                              : (widget.p2Color ?? pal.opp),
                                                          size: d,
                                                          shape: app.shape,
                                                          ring: winLine?.contains(
                                                                  pc.node) ??
                                                              false,
                                                          ringColor: Pal.gold,
                                                        ),
                                                      ),
                                                ],
                                              ),
                                            );
                                          }),
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
                      const SizedBox(height: 14),

                      // Replay Controls Card (3D)
                      Container(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: const [
                            BoxShadow(
                                color: Color(0xFFB9A8EC),
                                offset: Offset(0, 6)),
                            BoxShadow(
                                color: Color(0x33000000),
                                blurRadius: 16,
                                offset: Offset(0, 8)),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Progress bar using unified LevelBar
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                              child: LevelBar(
                                value:
                                    totalSteps > 0 ? _step / totalSteps : 0.0,
                                height: 10,
                              ),
                            ),
                            const SizedBox(height: 8),
                            // 3D Playback Control Buttons
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                ChunkyIconButton(
                                  icon: Icons.replay_rounded,
                                  size: 46,
                                  top: const Color(0xFFE0E0E0),
                                  bottom: const Color(0xFFBDBDBD),
                                  edge: const Color(0xFF757575),
                                  iconColor: const Color(0xFF424242),
                                  tooltip: 'Restart',
                                  onTap: _restart,
                                ),
                                ChunkyIconButton(
                                  icon: Icons.skip_previous_rounded,
                                  size: 50,
                                  top: const Color(0xFF90CAF9),
                                  bottom: const Color(0xFF1E88E5),
                                  edge: const Color(0xFF1565C0),
                                  onTap: _prev,
                                ),
                                ChunkyIconButton(
                                  icon: _isPlaying
                                      ? Icons.pause_rounded
                                      : Icons.play_arrow_rounded,
                                  size: 60,
                                  top: _isPlaying
                                      ? const Color(0xFFFFB300)
                                      : const Color(0xFF9CF2A3),
                                  bottom: _isPlaying
                                      ? const Color(0xFFF57C00)
                                      : const Color(0xFF4FCB62),
                                  edge: _isPlaying
                                      ? const Color(0xFFE65100)
                                      : const Color(0xFF2E9E43),
                                  onTap: _togglePlayback,
                                ),
                                ChunkyIconButton(
                                  icon: Icons.skip_next_rounded,
                                  size: 50,
                                  top: const Color(0xFF90CAF9),
                                  bottom: const Color(0xFF1E88E5),
                                  edge: const Color(0xFF1565C0),
                                  onTap: _next,
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
            ),
          ),
        ),
      );
    });
  }
}

