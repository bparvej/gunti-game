import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimens.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../domain/models/game_models.dart';
import '../../cubits/game/game_cubit.dart';
import '../../cubits/game/game_state.dart';
import '../../cubits/settings/settings_cubit.dart';
import '../../cubits/settings/settings_state.dart';
import '../../widgets/board_painter.dart';

class GameScreen extends StatefulWidget {
  final Map<String, String> params;
  const GameScreen({super.key, required this.params});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_initialized) return;
      _initialized = true;
      _dispatchGameStart();
    });
  }

  void _dispatchGameStart() {
    final cubit = context.read<GameCubit>();
    final params = widget.params;

    if (params['continue'] == 'true') {
      cubit.continueGame();
    } else if (params['mode'] == 'single') {
      final diffName = params['diff'] ?? 'medium';
      final diff = Difficulty.values.firstWhere(
        (d) => d.name == diffName,
        orElse: () => Difficulty.medium,
      );
      final side = PlayerX.fromName(params['side'] ?? 'red');
      cubit.startNewGame(
        mode: GameMode.singlePlayer,
        difficulty: diff,
        humanSide: side,
      );
    } else {
      cubit.startNewGame(
        mode: GameMode.twoPlayers,
        difficulty: Difficulty.medium,
        humanSide: Player.red,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<SettingsCubit, SettingsState>(
        builder: (context, settingsState) {
          final isBangla = settingsState.settings.isBangla;
          final isDark = settingsState.settings.isDarkMode;
          final gutiShape = settingsState.settings.gutiShape;
          final s = isBangla ? AppStrings.bn : AppStrings.en;
          final lineColor = isDark ? Colors.white : AppColors.deepBlue;

          return BlocBuilder<GameCubit, GameState>(
            builder: (context, state) {
              return Stack(
                children: [
                  SafeArea(
                    child: Column(
                      children: [
                        _buildAppBar(context, s, isBangla, isDark, state),
                        Expanded(
                          child: _GameBoardBody(
                            state: state,
                            gutiShape: gutiShape,
                            lineColor: lineColor,
                            onTap: context.read<GameCubit>().onNodeTap,
                          ),
                        ),
                        _buildBottomInfo(s, gutiShape, state),
                      ],
                    ),
                  ),
                  if (state.paused)
                    _PauseOverlay(
                      s: s,
                      isBangla: isBangla,
                      onResume: context.read<GameCubit>().resume,
                      onReset: () => _confirmReset(context, s),
                      onExit: () => context.go('/'),
                    ),
                  if (state.status != GameStatus.ongoing)
                    _buildWinOverlay(context, s, isBangla, state),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildAppBar(
    BuildContext context,
    Map<String, String> s,
    bool isBangla,
    bool isDark,
    GameState state,
  ) {
    String turnText;
    Color turnColor;

    if (state.paused) {
      turnText = s['pause'] ?? '';
      turnColor = AppColors.white;
    } else if (state.mode == GameMode.singlePlayer) {
      if (state.aiThinking || state.isAiTurn) {
        turnText = s['deviceThinking'] ?? '';
        turnColor = AppColors.white;
      } else {
        turnText = s['yourTurn'] ?? '';
        turnColor = state.humanSide == Player.red
            ? (isDark ? const Color(0xFFEF9A9A) : AppColors.red)
            : (isDark ? const Color(0xFF90CAF9) : AppColors.blue);
      }
    } else {
      final redTurn = state.currentTurn == Player.red;
      turnColor = redTurn
          ? (isDark ? const Color(0xFFEF9A9A) : AppColors.red)
          : (isDark ? const Color(0xFF90CAF9) : AppColors.blue);
      turnText = redTurn ? (s['redTurn'] ?? '') : (s['blueTurn'] ?? '');
    }

    final canUndo =
        state.moveHistory.isNotEmpty && state.status == GameStatus.ongoing;
    final canPause = state.status == GameStatus.ongoing;

    return Container(
      color: AppColors.deepBlue,
      padding: const EdgeInsets.only(
        left: AppDimens.contentPadding,
        right: AppDimens.contentPadding - 8,
        top: 8,
        bottom: 12,
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => context.go('/'),
            icon: const Icon(Icons.arrow_back, color: AppColors.white),
          ),
          Expanded(
            child: Text(
              turnText,
              textAlign: TextAlign.center,
              style: AppTextStyles.turn.copyWith(color: turnColor),
            ),
          ),
          IconButton(
            onPressed: canUndo ? () => context.read<GameCubit>().undo() : null,
            icon: Icon(
              Icons.undo,
              color: canUndo
                  ? AppColors.white
                  : AppColors.white.withValues(alpha: 0.3),
            ),
            tooltip: s['undo'],
          ),
          IconButton(
            onPressed: canPause
                ? () => context.read<GameCubit>().pause()
                : null,
            icon: Icon(
              Icons.pause,
              color: canPause
                  ? AppColors.white
                  : AppColors.white.withValues(alpha: 0.3),
            ),
            tooltip: s['pause'],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomInfo(
    Map<String, String> s,
    GutuShape gutiShape,
    GameState state,
  ) {
    final shapeNames = {
      GutuShape.circle: s['circle'],
      GutuShape.square: s['square'],
      GutuShape.bar: s['bar'],
      GutuShape.lalBadshah: s['lalBadshah'],
    };

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimens.contentPadding,
        vertical: AppDimens.sectionGap,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '${s['moveCount']}: ${state.moveCount}',
            style: AppTextStyles.subtitle,
          ),
          Text(
            shapeNames[gutiShape] ?? '',
            style: AppTextStyles.label,
          ),
        ],
      ),
    );
  }

  Widget _buildWinOverlay(
    BuildContext context,
    Map<String, String> s,
    bool isBangla,
    GameState state,
  ) {
    String winnerName;
    if (state.mode == GameMode.singlePlayer) {
      final humanWon = (state.status == GameStatus.redWin &&
              state.humanSide == Player.red) ||
          (state.status == GameStatus.blueWin &&
              state.humanSide == Player.blue);
      winnerName = humanWon ? (s['youWin'] ?? '') : (s['deviceWins'] ?? '');
    } else {
      winnerName = state.status == GameStatus.redWin
          ? (s['redWins'] ?? '')
          : (s['blueWins'] ?? '');
    }

    return _WinOverlay(
      s: s,
      isBangla: isBangla,
      winnerName: winnerName,
      moveCount: state.moveCount,
      onPlayAgain: context.read<GameCubit>().reset,
      onExit: () => context.go('/'),
    );
  }

  void _confirmReset(BuildContext context, Map<String, String> s) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        content: Text(s['confirmResetGame'] ?? ''),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(s['confirmResetNo'] ?? 'Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              context.read<GameCubit>().reset();
            },
            child: Text(s['confirmResetYes'] ?? 'Yes'),
          ),
        ],
      ),
    );
  }
}

class _GameBoardBody extends StatelessWidget {
  final GameState state;
  final GutuShape gutiShape;
  final Color lineColor;
  final void Function(String) onTap;

  const _GameBoardBody({
    required this.state,
    required this.gutiShape,
    required this.lineColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.lightGrey,
      child: Center(
        child: AspectRatio(
          aspectRatio: 1,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final size = constraints.biggest.shortestSide;
              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTapUp: (details) {
                  final local = details.localPosition;
                  final scale = AppDimens.boardSize / size;
                  final x = local.dx * scale;
                  final y = local.dy * scale;
                  final nodeKey = _findNearestNode(x, y);
                  if (nodeKey.isNotEmpty) {
                    onTap(nodeKey);
                  }
                },
                child: Container(
                  width: size,
                  height: size,
                  color: AppColors.surface,
                  child: CustomPaint(
                    painter: BoardPainter(
                      occupied: state.occupied,
                      selectedNode: state.selectedNode,
                      availableTargets: state.availableTargets,
                      gutiShape: gutiShape,
                      boardLineColor: lineColor,
                      redColor: AppColors.red,
                      blueColor: AppColors.blue,
                      hintColor: AppColors.green.withValues(alpha: 0.35),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  String _findNearestNode(double x, double y) {
    const hitRadius = 40.0;
    String? nearest;
    var bestDistance = double.infinity;

    for (final node in boardNodes.values) {
      final dx = node.x - x;
      final dy = node.y - y;
      final dist = dx * dx + dy * dy;
      if (dist <= hitRadius * hitRadius && dist < bestDistance) {
        bestDistance = dist;
        nearest = node.key;
      }
    }

    return nearest ?? '';
  }
}

class _PauseOverlay extends StatelessWidget {
  final Map<String, String> s;
  final bool isBangla;
  final VoidCallback onResume;
  final VoidCallback onReset;
  final VoidCallback onExit;

  const _PauseOverlay({
    required this.s,
    required this.isBangla,
    required this.onResume,
    required this.onReset,
    required this.onExit,
  });

  @override
  Widget build(BuildContext context) {
    final baseStyle = isBangla ? AppTextStyles.bangla : AppTextStyles.win;

    return Positioned.fill(
      child: ColoredBox(
        color: AppColors.deepBlue.withValues(alpha: 0.92),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                s['pause'] ?? '',
                style: baseStyle,
              ),
              const SizedBox(height: 32),
              TextButton(
                onPressed: onResume,
                style: TextButton.styleFrom(
                  backgroundColor: AppColors.orange,
                  foregroundColor: AppColors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 12,
                  ),
                ),
                child: Text(
                  s['resume'] ?? '',
                  style: AppTextStyles.button,
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: onReset,
                child: Text(
                  s['resetGame'] ?? '',
                  style: AppTextStyles.button.copyWith(color: AppColors.white),
                ),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: onExit,
                child: Text(
                  s['exitToMenu'] ?? '',
                  style: AppTextStyles.button.copyWith(color: AppColors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WinOverlay extends StatelessWidget {
  final Map<String, String> s;
  final bool isBangla;
  final String winnerName;
  final int moveCount;
  final VoidCallback onPlayAgain;
  final VoidCallback onExit;

  const _WinOverlay({
    required this.s,
    required this.isBangla,
    required this.winnerName,
    required this.moveCount,
    required this.onPlayAgain,
    required this.onExit,
  });

  @override
  Widget build(BuildContext context) {
    final baseStyle = isBangla ? AppTextStyles.bangla : AppTextStyles.win;

    return Positioned.fill(
      child: ColoredBox(
        color: AppColors.deepBlue.withValues(alpha: 0.92),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('👑', style: TextStyle(fontSize: 64)),
              const SizedBox(height: 8),
              Text(
                s['winnerCrown'] ?? 'WINNER!',
                style: baseStyle,
              ),
              const SizedBox(height: 12),
              Text(
                winnerName,
                style: AppTextStyles.titleLarge.copyWith(color: AppColors.white),
              ),
              const SizedBox(height: 8),
              Text(
                '${s['moveCount']}: $moveCount',
                style: AppTextStyles.subtitle.copyWith(color: AppColors.white),
              ),
              const SizedBox(height: 32),
              TextButton(
                onPressed: onPlayAgain,
                style: TextButton.styleFrom(
                  backgroundColor: AppColors.orange,
                  foregroundColor: AppColors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 12,
                  ),
                ),
                child: Text(
                  s['playAgain'] ?? 'Play Again',
                  style: AppTextStyles.button,
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: onExit,
                child: Text(
                  s['backToMenu'] ?? '',
                  style: AppTextStyles.button.copyWith(color: AppColors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
