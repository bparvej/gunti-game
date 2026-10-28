import 'dart:async';
import 'package:flutter/material.dart';

import '../../core/theme/palette.dart';
import '../widgets/chunky_button.dart';
import '../widgets/level_bar.dart';

/// Interactive rewarded & interstitial ad simulation.
/// Runs for 5 seconds with early close detection.
class AdDialog extends StatefulWidget {
  final String title;
  final String rewardLabel;
  final bool isRewarded;
  final void Function(bool rewarded) onClose;

  const AdDialog({
    super.key,
    this.title = 'Sponsored Ad',
    this.rewardLabel = 'Hint Reward',
    this.isRewarded = true,
    required this.onClose,
  });

  static Future<bool> show(
    BuildContext context, {
    String title = 'Sponsored Ad',
    String rewardLabel = 'Hint Reward',
    bool isRewarded = true,
  }) async {
    final result = await showGeneralDialog<bool>(
      context: context,
      barrierDismissible: false,
      barrierLabel: 'ad_dialog',
      barrierColor: const Color(0xE60A051B),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (ctx, a1, a2) => AdDialog(
        title: title,
        rewardLabel: rewardLabel,
        isRewarded: isRewarded,
        onClose: (rewarded) => Navigator.of(ctx).pop(rewarded),
      ),
      transitionBuilder: (ctx, anim, _, child) => FadeTransition(
        opacity: anim,
        child: ScaleTransition(
          scale: CurvedAnimation(parent: anim, curve: Curves.easeOutBack),
          child: child,
        ),
      ),
    );
    return result ?? false;
  }

  @override
  State<AdDialog> createState() => _AdDialogState();
}

class _AdDialogState extends State<AdDialog> {
  static const int _adDuration = 5;
  int _secondsLeft = _adDuration;
  Timer? _timer;
  bool _completed = false;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      if (_secondsLeft > 1) {
        setState(() => _secondsLeft--);
      } else {
        _timer?.cancel();
        setState(() {
          _secondsLeft = 0;
          _completed = true;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _handleEarlyClose() {
    if (_completed) {
      widget.onClose(true);
      return;
    }

    if (!widget.isRewarded) {
      widget.onClose(true);
      return;
    }

    // Warn player about forfeiting reward if closed early
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: pal.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Skip Ad?',
          style: TextStyle(color: pal.text, fontWeight: FontWeight.w800),
        ),
        content: Text(
          'If you close before the timer ends, your ${widget.rewardLabel} will not be unlocked.',
          style: TextStyle(color: pal.sub, fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop(); // close warning
              widget.onClose(false); // close ad without reward
            },
            child: const Text('Quit & Lose Reward',
                style: TextStyle(color: Color(0xFFE53935), fontWeight: FontWeight.w700)),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('Resume (${_secondsLeft}s left)',
                style: TextStyle(color: pal.primary, fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final progress = (_adDuration - _secondsLeft) / _adDuration;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
          decoration: BoxDecoration(
            color: const Color(0xFF1E133E),
            borderRadius: BorderRadius.circular(26),
            border: Border.all(color: const Color(0xFF6B4CC9), width: 2),
            boxShadow: const [
              BoxShadow(
                color: Color(0x66000000),
                blurRadius: 28,
                offset: Offset(0, 14),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Top Bar with Countdown and Close button
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
                child: Row(
                  children: [
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF382375),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFF8B5CF6), width: 1.2),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.videocam_rounded, size: 14, color: Color(0xFFFFD54F)),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                widget.title,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _completed ? const Color(0xFF2E9E43) : const Color(0xFF382375),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        _completed ? 'Ready!' : '${_secondsLeft}s',
                        style: TextStyle(
                          color: _completed ? Colors.white : const Color(0xFFFFD54F),
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: _handleEarlyClose,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2B1A5C),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: _completed ? const Color(0xFF4FCB62) : const Color(0xFF756A8F),
                            width: 1.5,
                          ),
                        ),
                        child: Icon(
                          _completed ? Icons.check_rounded : Icons.close_rounded,
                          size: 18,
                          color: _completed ? const Color(0xFF4FCB62) : Colors.white70,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Progress Bar (using LevelBar)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: LevelBar(
                  value: progress.clamp(0.05, 1.0),
                  height: 6,
                  track: const Color(0xFF2B1A5C),
                  colors: const [Color(0xFFFFD54F), Color(0xFFFFA000)],
                ),
              ),

              // Ad Content Placeholder Graphic
              Container(
                margin: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                height: 220,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF3E1D7D), Color(0xFF1E0A47)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFF5636A6), width: 1.5),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xFF5B29B8),
                            boxShadow: [
                              BoxShadow(
                                color: Color(0x66FFB300),
                                blurRadius: 20,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.play_circle_fill_rounded,
                            size: 48,
                            color: Color(0xFFFFD54F),
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Bangla Guti Mega Challenge',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Play more matches & unlock legendary avatars!',
                          style: TextStyle(
                            color: Colors.white.withAlpha(180),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    Positioned(
                      top: 10,
                      right: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.black45,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'AD · 0:05',
                          style: TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Bottom Action Button
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: ChunkyButton(
                  label: _completed
                      ? (widget.isRewarded ? 'CLAIM ${widget.rewardLabel.toUpperCase()}' : 'CONTINUE TO LOBBY')
                      : 'WAITING FOR REWARD (${_secondsLeft}s)',
                  icon: _completed ? Icons.check_circle_rounded : Icons.timer_outlined,
                  top: _completed ? const Color(0xFF9CF2A3) : const Color(0xFF5A4491),
                  bottom: _completed ? const Color(0xFF4FCB62) : const Color(0xFF382375),
                  edge: _completed ? const Color(0xFF2E9E43) : const Color(0xFF20124D),
                  height: 52,
                  fontSize: 14,
                  onTap: () {
                    if (_completed) {
                      widget.onClose(true);
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
