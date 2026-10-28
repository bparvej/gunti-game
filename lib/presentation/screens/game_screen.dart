import 'package:flutter/material.dart';

import '../../core/audio/sfx.dart';
import '../../core/constants/strings.dart';
import '../../core/theme/palette.dart';
import '../../domain/game/ai.dart';
import '../../domain/game/game_enums.dart';
import '../../domain/game/rules.dart';
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

  String _status() {
    if (c.outcome == Outcome.p1) {
      return tr('winsN', {'n': c.p1Name});
    }
    if (c.outcome == Outcome.p2) {
      return tr('winsN', {'n': c.p2Name});
    }
    if (c.outcome == Outcome.draw) return tr('drawTitle');
    if (c.autoActive) return tr('autoOn');
    if (c.isOpponentThinking) return tr('opponentThinking');
    if (c.thinking) return tr('thinking');
    final placing = Rules.placed(c.state, c.state.turn) < 3;
    final hint = placing ? tr('placeHint') : tr('moveHint');
    if (c.counting && c.idleLeft <= 6) {
      return '$hint\n${tr('autoIn', {'s': '${c.idleLeft}'})}';
    }
    return hint;
  }

  /// Small-screen helper: pick a target with a slider, then press MOVE.
  Widget _sliderPanel() {
    final t = c.targets;
    final n = t.length;
    final idx = c.pick.clamp(0, n - 1);
    String lbl(int node) => 'R${node ~/ 3 + 1} · C${node % 3 + 1}';
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
      decoration: BoxDecoration(
        color: pal.soft,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Pal.green, width: 1.6),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(tr('pickTarget'),
                    style: TextStyle(
                        color: pal.text,
                        fontSize: 13,
                        fontWeight: FontWeight.w700)),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Pal.green,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(lbl(t[idx]),
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w900)),
              ),
            ],
          ),
          if (n > 1)
            Slider(
              value: idx.toDouble(),
              min: 0,
              max: (n - 1).toDouble(),
              divisions: n - 1,
              label: lbl(t[idx]),
              activeColor: Pal.greenDark,
              onChanged: (v) => c.setPick(v.round()),
            )
          else
            const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: c.cancelSelection,
                  child: Text(tr('cancel'),
                      style: TextStyle(
                          color: pal.sub, fontWeight: FontWeight.w800)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 2,
                child: ChunkyButton(
                  label: tr('move'),
                  height: 46,
                  fontSize: 14,
                  top: const Color(0xFF9CF2A3),
                  bottom: const Color(0xFF4FCB62),
                  edge: const Color(0xFF2E9E43),
                  onTap: c.moveToPicked,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
        ],
      ),
    );
  }

  Widget _modeChip(int p) {
    if (!app.autoEnabled || c.isComputer(p)) return const SizedBox.shrink();
    final auto = c.isAuto(p);
    return GestureDetector(
      onTap: auto ? () => c.takeOver(p) : null,
      child: Container(
        margin: const EdgeInsets.only(left: 8),
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
        decoration: BoxDecoration(
          color: auto ? const Color(0xFFFFA726) : pal.soft,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (auto)
              const Icon(Icons.bolt_rounded, size: 11, color: Colors.white),
            Text(
              auto ? tr('auto') : tr('manual'),
              style: TextStyle(
                color: auto ? Colors.white : pal.sub,
                fontSize: 9,
                letterSpacing: .6,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _playerRow(int p) {
    final name = p == 1 ? c.p1Name : c.p2Name;
    final active = c.outcome == Outcome.none && c.state.turn == p;
    final won = (p == 1 && c.outcome == Outcome.p1) ||
        (p == 2 && c.outcome == Outcome.p2);
    final hl = active || won;
    String turnLabel = '';
    if (active) {
      if (p == 2 && c.isOpponentThinking) {
        turnLabel = tr('opponentThinking');
      } else {
        turnLabel = ((c.mode == Mode.vsComputer || c.mode == Mode.online) && p == 1)
            ? tr('yourTurn')
            : tr('turnOf', {'n': name});
      }
    }

    Widget trailing;
    if (won) {
      trailing =
          const Icon(Icons.emoji_events_rounded, color: Pal.gold, size: 28);
    } else if (active && c.isAuto(p)) {
      trailing = const Icon(Icons.bolt_rounded,
          color: Color(0xFFFFA726), size: 28);
    } else if (active && c.counting) {
      trailing = IdleRing(left: c.idleLeft, total: GameController.idleLimit);
    } else if (active && p == 2 && c.isOpponentThinking) {
      trailing = Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: fade(Pal.green, .15),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Pal.green, width: 1.2),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 10,
              height: 10,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation(Pal.greenDark),
              ),
            ),
            SizedBox(width: 4),
            Text('…',
                style: TextStyle(
                    color: Pal.greenDark,
                    fontSize: 11,
                    fontWeight: FontWeight.w900)),
          ],
        ),
      );
    } else if (active) {
      trailing = const Icon(Icons.check_circle_rounded,
          color: Pal.greenDark, size: 28);
    } else {
      trailing = const SizedBox(width: 28, height: 28);
    }

    return Container(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: hl ? pal.greenFill : Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: hl ? Pal.green : pal.border, width: 1.4),
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
                      size: 34,
                    )
                  : Guti(
                      color: p == 1
                          ? (c.p1Color ?? pal.me)
                          : (c.p2Color ?? pal.opp),
                      size: 32),
              if (c.mode == Mode.online)
                Positioned(
                  right: -2,
                  bottom: -2,
                  child: Container(
                    width: 13,
                    height: 13,
                    decoration: BoxDecoration(
                      color: p == 1
                          ? (c.p1Color ?? pal.me)
                          : (c.p2Color ?? pal.opp),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 1.5),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              color: pal.text,
                              fontSize: 15,
                              fontWeight: FontWeight.w700)),
                    ),
                    if (c.mode == Mode.online) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: fade(const Color(0xFF4CAF50), .15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                color: Color(0xFF4CAF50),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              p == 1 ? '24 ms' : c.opponentPing,
                              style: const TextStyle(
                                color: Color(0xFF2E7D32),
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    _modeChip(p),
                  ],
                ),
                if (turnLabel.isNotEmpty)
                  Text(turnLabel,
                      style: TextStyle(
                          color: pal.sub,
                          fontSize: 11,
                          fontWeight: FontWeight.w500)),
              ],
            ),
          ),
          Text('${Rules.placed(c.state, p)}/3',
              style: TextStyle(
                  color: pal.sub, fontSize: 12, fontWeight: FontWeight.w600)),
          const SizedBox(width: 10),
          trailing,
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return appBuilder((context) {
      return ListenableBuilder(
        listenable: c,
        builder: (context, _) {
          final modeLabel = c.mode == Mode.vsComputer
              ? '${tr('vsComputer')} · ${diffName(c.difficulty)}'
              : c.mode == Mode.online
                  ? '${tr('onlineMatch')} · ${c.opponentPing}'
                  : tr('twoPlayers');
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
                                Expanded(
                                  child: Center(
                                    child: Container(
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
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                                  child: Row(
                                    children: [
                                      const Icon(Icons.timer_outlined, color: Color(0xFFFFD54F), size: 16),
                                      const SizedBox(width: 6),
                                      Text(
                                        fmtTime(c.seconds),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ],
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
                                          Row(
                                            children: [
                                              Expanded(
                                                child: Text(
                                                    modeLabel.toUpperCase(),
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: TextStyle(
                                                        color: pal.sub,
                                                        fontSize: 11,
                                                        letterSpacing: 1,
                                                        fontWeight:
                                                            FontWeight.w600)),
                                              ),
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 10,
                                                        vertical: 4),
                                                decoration: BoxDecoration(
                                                  color: pal.soft,
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                                child: Text(
                                                    '${tr('score')}  ${app.sessionP1} : ${app.sessionP2}',
                                                    style: TextStyle(
                                                        color: pal.text,
                                                        fontSize: 11,
                                                        fontWeight:
                                                            FontWeight.w800)),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 6),
                                          Text(_status(),
                                              style: TextStyle(
                                                  color: pal.text,
                                                  fontSize: 17,
                                                  height: 1.35,
                                                  fontWeight: FontWeight.w700)),
                                          if (c.skipped)
                                            Padding(
                                              padding:
                                                  const EdgeInsets.only(top: 4),
                                              child: Text(tr('skipped'),
                                                  style: const TextStyle(
                                                      color: Color(0xFFE0762E),
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.w600)),
                                            ),
                                          const SizedBox(height: 14),
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
                                          if (MediaQuery.of(context).size.width <
                                                  600 &&
                                              c.outcome == Outcome.none &&
                                              c.selected != null &&
                                              c.targets.isNotEmpty &&
                                              !c.isComputer(c.state.turn))
                                            _sliderPanel(),
                                          const SizedBox(height: 4),
                                          _playerRow(1),
                                          _playerRow(2),
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
                                  const EdgeInsets.symmetric(horizontal: 32),
                              child: ChunkyButton(
                                label: tr('restart'),
                                icon: Icons.refresh_rounded,
                                top: const Color(0xFF9CF2A3),
                                bottom: const Color(0xFF4FCB62),
                                edge: const Color(0xFF2E9E43),
                                height: 58,
                                fontSize: 17,
                                onTap: c.restart,
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

