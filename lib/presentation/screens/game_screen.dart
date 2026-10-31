import 'package:flutter/material.dart';

import '../../core/audio/sfx.dart';
import '../../core/constants/strings.dart';
import '../../core/theme/palette.dart';
import '../../domain/game/ai.dart';
import '../../domain/game/game_enums.dart';
import '../controllers/app_state.dart';
import '../controllers/game_controller.dart';
import '../dialogs/ad_dialog.dart';
import '../dialogs/pause_dialog.dart';
import '../dialogs/result_dialog.dart';
import '../widgets/avatar_view.dart';
import '../widgets/board_view.dart';
import '../widgets/chunky_button.dart';
import '../widgets/chunky_icon_button.dart';
import '../widgets/gradient_bg.dart';
import '../widgets/guti_view.dart';
import '../widgets/level_bar.dart';
import '../widgets/painters.dart';
import 'replay_screen.dart';

// ════════════════════════════════════════════════════════════════
//  Game screen (styled like the QuizOn question screen)
// ════════════════════════════════════════════════════════════════

class GameScreen extends StatefulWidget {
  final Mode? mode;
  final Difficulty? difficulty;
  final Map<String, dynamic>? savedSession;
  final Color? p1Color;
  final Color? p2Color;
  final String? opponentName;
  final int? opponentAvatarIndex;
  final String? opponentPing;
  final int? opponentRating;

  const GameScreen({
    super.key,
    this.mode,
    this.difficulty,
    this.savedSession,
    this.p1Color,
    this.p2Color,
    this.opponentName,
    this.opponentAvatarIndex,
    this.opponentPing,
    this.opponentRating,
  });

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late final GameController c;
  bool _leaving = false;
  int _hintsUsedThisGame = 0;

  @override
  void initState() {
    super.initState();
    if (widget.savedSession != null) {
      c = GameController.restore(
        widget.savedSession!,
        p1Color: widget.p1Color,
        p2Color: widget.p2Color,
      );
    } else {
      c = GameController(
        mode: widget.mode ?? Mode.vsComputer,
        difficulty: widget.difficulty ?? Difficulty.medium,
        p1Color: widget.p1Color,
        p2Color: widget.p2Color,
        opponentName: widget.opponentName,
        opponentAvatarIndex: widget.opponentAvatarIndex,
        opponentPing: widget.opponentPing,
        opponentRating: widget.opponentRating,
      );
    }
    c.addListener(_onChange);
  }

  void _onHintTapped(BuildContext context) async {
    if (c.outcome != Outcome.none || c.isComputer(c.state.turn)) return;
    if (c.thinking) return;

    if (_hintsUsedThisGame == 0) {
      // 1st hint is FREE
      c.computeHint();
      _hintsUsedThisGame++;
      Sfx.play('click');
      toast(context, tr('freeHint'));
    } else {
      // Subsequent hints require watching an ad
      final rewarded = await AdDialog.show(
        context,
        title: tr('watchAdForHint'),
        rewardLabel: tr('hint'),
        isRewarded: true,
      );
      if (rewarded) {
        c.computeHint();
        _hintsUsedThisGame++;
        Sfx.play('win');
        if (context.mounted) {
          toast(context, tr('adRewardClaimed'));
        }
      } else {
        if (context.mounted) {
          toast(context, tr('adForfeited'));
        }
      }
    }
  }

  void _showPauseDialog(BuildContext context) {
    if (c.outcome != Outcome.none) return;
    c.pause();
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: 'pause',
      barrierColor: const Color(0xB3120A2E),
      transitionDuration: const Duration(milliseconds: 350),
      pageBuilder: (ctx, a1, a2) => Center(
        child: PauseDialog(
          controller: c,
          onResume: () {
            Navigator.of(ctx).pop();
            c.resume();
          },
          onRestart: () {
            Navigator.of(ctx).pop();
            _hintsUsedThisGame = 0;
            c.restart();
          },
          onExit: () async {
            c.saveToApp();
            Navigator.of(ctx).pop();
            // Show interstitial Ad when player quits match to lobby
            await AdDialog.show(
              context,
              title: 'Sponsored Ad',
              isRewarded: false,
            );
            if (context.mounted) {
              Navigator.of(context).pop();
            }
          },
        ),
      ),
      transitionBuilder: (ctx, anim, _, child) => ScaleTransition(
        scale: CurvedAnimation(
            parent: anim,
            curve: Curves.easeOutBack,
            reverseCurve: Curves.easeIn),
        child: FadeTransition(opacity: anim, child: child),
      ),
    );
  }

  void _onChange() {
    if (c.outcome != Outcome.none && !_leaving) {
      _leaving = true;
      final res = c.result!;
      Future.delayed(const Duration(milliseconds: 1200), () {
        if (!mounted) return;
        showGeneralDialog(
          context: context,
          barrierDismissible: false,
          barrierLabel: 'result',
          barrierColor: const Color(0xB3120A2E),
          transitionDuration: const Duration(milliseconds: 450),
          pageBuilder: (ctx, a1, a2) => Center(
            child: ResultDialog(
              result: res,
              onOk: () {
                Navigator.of(ctx).pop(); // close popup
                Navigator.of(context).pop(); // back to home
              },
              onAgain: () {
                Navigator.of(ctx).pop();
                _leaving = false;
                c.restart();
              },
              onReplay: () {
                final hist = c.replayHistory;
                final p1 = c.p1Name;
                final p2 = c.p2Name;
                final out = c.outcome;
                final win = c.winLine;
                Navigator.of(ctx).pop(); // close popup
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => ReplayScreen(
                      history: hist,
                      p1Name: p1,
                      p2Name: p2,
                      outcome: out,
                      winLine: win,
                      p1Color: c.p1Color,
                      p2Color: c.p2Color,
                    ),
                  ),
                );
              },
            ),
          ),
          transitionBuilder: (ctx, anim, _, child) => ScaleTransition(
            scale: CurvedAnimation(
                parent: anim,
                curve: Curves.easeOutBack,
                reverseCurve: Curves.easeIn),
            child: FadeTransition(opacity: anim, child: child),
          ),
        );
      });
    }
  }

  @override
  void dispose() {
    c.removeListener(_onChange);
    c.dispose();
    super.dispose();
  }

  Widget _playersRow() {
    return Row(
      children: [
        _playerCard(1),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF382375), Color(0xFF20124D)],
              ),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFF8B5CF6), width: 1.2),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x33000000),
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: const Text(
              'VS',
              style: TextStyle(
                color: Color(0xFFFFD54F),
                fontSize: 11,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.6,
              ),
            ),
          ),
        ),
        _playerCard(2),
      ],
    );
  }

  Widget _playerCard(int p) {
    final name = p == 1 ? c.p1Name : c.p2Name;
    final active = c.outcome == Outcome.none && c.state.turn == p;
    final won = (p == 1 && c.outcome == Outcome.p1) ||
        (p == 2 && c.outcome == Outcome.p2);
    final color = p == 1 ? (c.p1Color ?? pal.me) : (c.p2Color ?? pal.opp);

    return Expanded(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: won
              ? const Color(0xFFFFF9C4)
              : active
                  ? pal.greenFill
                  : pal.soft,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: won
                ? const Color(0xFFFFB300)
                : active
                    ? Pal.green
                    : pal.border,
            width: active || won ? 2.0 : 1.2,
          ),
          boxShadow: active
              ? [
                  BoxShadow(
                    color: fade(Pal.green, .22),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                c.mode == Mode.online
                    ? AvatarView(
                        avatarIndex:
                            p == 1 ? app.avatarIndex : c.opponentAvatarIndex,
                        size: 32,
                      )
                    : Guti(color: color, size: 28),
                if (c.mode == Mode.online)
                  Positioned(
                    right: -2,
                    bottom: -2,
                    child: Container(
                      width: 11,
                      height: 11,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 1.5),
                      ),
                    ),
                  ),
                if (c.isAuto(p))
                  Positioned(
                    left: -2,
                    top: -2,
                    child: Container(
                      padding: const EdgeInsets.all(1.5),
                      decoration: const BoxDecoration(
                        color: Color(0xFFFFA726),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.bolt_rounded,
                          size: 9, color: Colors.white),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: pal.text,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  if (won)
                    const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.emoji_events_rounded,
                            color: Color(0xFFF57C00), size: 12),
                        SizedBox(width: 2),
                        Text(
                          'WINNER',
                          style: TextStyle(
                            color: Color(0xFFF57C00),
                            fontSize: 9,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.4,
                          ),
                        ),
                      ],
                    )
                  else if (c.isAuto(p))
                    GestureDetector(
                      onTap: () => c.takeOver(p),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 5, vertical: 1),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFA726),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.bolt_rounded, size: 9, color: Colors.white),
                            SizedBox(width: 1),
                            Text(
                              'AUTO',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 8.5,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else if (active &&
                      p == 2 &&
                      (c.isOpponentThinking || c.thinking))
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(
                          width: 8,
                          height: 8,
                          child: CircularProgressIndicator(
                            strokeWidth: 1.6,
                            valueColor:
                                AlwaysStoppedAnimation(Pal.greenDark),
                          ),
                        ),
                        const SizedBox(width: 3),
                        Flexible(
                          child: Text(
                            tr('thinking'),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Pal.greenDark,
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    )
                  else if (active)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 5, vertical: 1),
                      decoration: BoxDecoration(
                        color: Pal.greenDark,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        (p == 1 &&
                                (c.mode == Mode.vsComputer ||
                                    c.mode == Mode.online))
                            ? tr('yourTurn').toUpperCase()
                            : tr('turn').toUpperCase(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 8.5,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.3,
                        ),
                      ),
                    )
                  else if (c.mode == Mode.online)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 5,
                          height: 5,
                          decoration: const BoxDecoration(
                            color: Color(0xFF4CAF50),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 3),
                        Text(
                          p == 1 ? '24 ms' : c.opponentPing,
                          style: TextStyle(
                            color: pal.sub,
                            fontSize: 9.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    )
                  else
                    Text(
                      p == 1 ? tr('player1') : tr('player2'),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: pal.sub,
                        fontSize: 9.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return appBuilder((context) {
      return ListenableBuilder(
        listenable: c,
        builder: (context, _) {
          final progress =
              (c.state.ply / Ai.maxPly).clamp(0.0, 1.0).toDouble();
          return PopScope(
            canPop: c.outcome != Outcome.none,
            onPopInvokedWithResult: (didPop, _) {
              if (didPop) return;
              _showPauseDialog(context);
            },
            child: Scaffold(
              backgroundColor: pal.bg1,
              body: GradientBg(
                child: SafeArea(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 480),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
                        child: Column(
                          children: [
                            // top bar (3D buttons & timer)
                            Row(
                              children: [
                                ChunkyIconButton(
                                  icon: Icons.arrow_back_rounded,
                                  size: 44,
                                  top: const Color(0xFFA567FF),
                                  bottom: const Color(0xFF7430E0),
                                  edge: const Color(0xFF4B1D9C),
                                  onTap: () {
                                    if (c.outcome != Outcome.none) {
                                      Navigator.of(context).pop();
                                    } else {
                                      _showPauseDialog(context);
                                    }
                                  },
                                ),
                                const SizedBox(width: 8),
                                ChunkyIconButton(
                                  icon: c.paused ? Icons.play_arrow_rounded : Icons.pause_rounded,
                                  size: 44,
                                  top: c.paused ? const Color(0xFF9CF2A3) : const Color(0xFFFFB300),
                                  bottom: c.paused ? const Color(0xFF4FCB62) : const Color(0xFFF57C00),
                                  edge: c.paused ? const Color(0xFF2E9E43) : const Color(0xFFE65100),
                                  onTap: () => _showPauseDialog(context),
                                ),
                                const SizedBox(width: 8),
                                ChunkyIconButton(
                                  icon: Icons.lightbulb_rounded,
                                  size: 44,
                                  top: const Color(0xFFFFD54F),
                                  bottom: const Color(0xFFFFA000),
                                  edge: const Color(0xFFC57A0A),
                                  tooltip: _hintsUsedThisGame == 0 ? tr('freeHint') : tr('hint'),
                                  onTap: () => _onHintTapped(context),
                                ),
                                const SizedBox(width: 8),
                                ChunkyIconButton(
                                  icon: Icons.undo_rounded,
                                  size: 44,
                                  top: c.canUndo ? const Color(0xFF4DD0E1) : const Color(0xFF6E56A3),
                                  bottom: c.canUndo ? const Color(0xFF00ACC1) : const Color(0xFF4B357F),
                                  edge: c.canUndo ? const Color(0xFF00838F) : const Color(0xFF2E1C59),
                                  tooltip: tr('undo'),
                                  onTap: c.canUndo ? () => c.undo() : null,
                                ),
                                const Spacer(),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                    gradient: const LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [Color(0xFF382375), Color(0xFF20124D)],
                                    ),
                                    border: Border.all(color: const Color(0xFF6B4CC9), width: 1.6),
                                    boxShadow: const [
                                      BoxShadow(color: Color(0xFF130933), offset: Offset(0, 3)),
                                    ],
                                  ),
                                  child: Text(
                                    tr('moveN', {'n': (c.state.ply + 1).toString().padLeft(2, '0')}),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            // progress
                            LevelBar(value: progress, height: 10),
                            const SizedBox(height: 14),
                            Expanded(
                              child: SingleChildScrollView(
                                child: Column(
                                  children: [
                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.fromLTRB(
                                          18, 18, 18, 16),
                                      decoration: BoxDecoration(
                                        color: pal.card,
                                        borderRadius: BorderRadius.circular(24),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          if (c.skipped)
                                            Container(
                                              margin: const EdgeInsets.only(bottom: 10),
                                              padding: const EdgeInsets.symmetric(
                                                  horizontal: 12, vertical: 6),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFFFFF3E0),
                                                borderRadius: BorderRadius.circular(10),
                                                border: Border.all(color: const Color(0xFFFFB74D)),
                                              ),
                                              child: Text(
                                                tr('skipped'),
                                                style: const TextStyle(
                                                  color: Color(0xFFE65100),
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                            ),
                                          // 5s Auto-mode warning alert with CANCEL button
                                          if (c.isAutoWarning)
                                            Container(
                                              margin: const EdgeInsets.only(bottom: 12),
                                              padding: const EdgeInsets.symmetric(
                                                  horizontal: 14, vertical: 8),
                                              decoration: BoxDecoration(
                                                gradient: const LinearGradient(
                                                  colors: [
                                                    Color(0xFFFF5252),
                                                    Color(0xFFD32F2F)
                                                  ],
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(16),
                                                boxShadow: const [
                                                  BoxShadow(
                                                      color: Color(0xFFB71C1C),
                                                      offset: Offset(0, 3)),
                                                ],
                                              ),
                                              child: Row(
                                                children: [
                                                  const Icon(
                                                      Icons.timer_rounded,
                                                      color: Colors.white,
                                                      size: 20),
                                                  const SizedBox(width: 8),
                                                  Expanded(
                                                    child: Text(
                                                      tr('autoMoveWarning', {
                                                        's': '${c.idleLeft}'
                                                      }),
                                                      style: const TextStyle(
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.w900,
                                                        fontSize: 13,
                                                      ),
                                                    ),
                                                  ),
                                                  ChunkyButton(
                                                    label: tr('cancelAuto'),
                                                    height: 34,
                                                    fontSize: 12,
                                                    top: const Color(0xFFFFF9C4),
                                                    bottom:
                                                        const Color(0xFFFFEE58),
                                                    edge:
                                                        const Color(0xFFFBC02D),
                                                    onTap: c.cancelAutoTimer,
                                                  ),
                                                ],
                                              ),
                                            ),

                                          // First-time tutorial reminder
                                          if (!app.hasSeenTutorial &&
                                              c.state.ply == 0 &&
                                              c.outcome == Outcome.none)
                                            Container(
                                              margin: const EdgeInsets.only(bottom: 12),
                                              padding: const EdgeInsets.symmetric(
                                                  horizontal: 14, vertical: 8),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFFE8EAF6),
                                                borderRadius:
                                                    BorderRadius.circular(14),
                                                border: Border.all(
                                                    color: const Color(0xFF7986CB),
                                                    width: 1.4),
                                              ),
                                              child: Row(
                                                children: [
                                                  const Text('💡',
                                                      style: TextStyle(
                                                          fontSize: 18)),
                                                  const SizedBox(width: 8),
                                                  Expanded(
                                                    child: Text(
                                                      '${tr('firstTimeTutorial')}\n${tr('firstTimeTutorialNote')}',
                                                      style: const TextStyle(
                                                        color: Color(0xFF283593),
                                                        fontSize: 11,
                                                        fontWeight:
                                                            FontWeight.w700,
                                                        height: 1.3,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          Center(
                                            child: ConstrainedBox(
                                              constraints: const BoxConstraints(
                                                  maxWidth: 330),
                                              child: AspectRatio(
                                                aspectRatio: 1,
                                                child: BoardView(controller: c),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 12),
                                          _playersRow(),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      height: 10,
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 14),
                                      decoration: BoxDecoration(
                                        color: fade(Colors.white, .4),
                                        borderRadius: const BorderRadius.vertical(
                                            bottom: Radius.circular(16)),
                                      ),
                                    ),
                                    Container(
                                      height: 10,
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 28),
                                      decoration: BoxDecoration(
                                        color: fade(Colors.white, .2),
                                        borderRadius: const BorderRadius.vertical(
                                            bottom: Radius.circular(16)),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 14),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              child: Row(
                                children: [
                                  if (c.mode != Mode.online) ...[
                                    Expanded(
                                      flex: 4,
                                      child: ChunkyButton(
                                        label: tr('undo'),
                                        icon: Icons.undo_rounded,
                                        top: c.canUndo ? const Color(0xFF4DD0E1) : const Color(0xFF6E56A3),
                                        bottom: c.canUndo ? const Color(0xFF00ACC1) : const Color(0xFF4B357F),
                                        edge: c.canUndo ? const Color(0xFF00838F) : const Color(0xFF2E1C59),
                                        height: 54,
                                        fontSize: 15,
                                        onTap: c.canUndo ? c.undo : null,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                  ],
                                  Expanded(
                                    flex: c.mode != Mode.online ? 5 : 1,
                                    child: ChunkyButton(
                                      label: tr('restart'),
                                      icon: Icons.refresh_rounded,
                                      top: const Color(0xFF9CF2A3),
                                      bottom: const Color(0xFF4FCB62),
                                      edge: const Color(0xFF2E9E43),
                                      height: 54,
                                      fontSize: 15,
                                      onTap: c.restart,
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
                ),
              ),
            ),
          );
        },
      );
    });
  }
}

