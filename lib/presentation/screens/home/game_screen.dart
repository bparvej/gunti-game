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

class GameScreen extends StatelessWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<SettingsCubit, SettingsState>(
        builder: (context, settingsState) {
          final settings = settingsState.settings;
          final isDark = settings.isDarkMode;
          final isBangla = settings.isBangla;
          final gutiShape = settings.gutiShape;

          final strings = isBangla ? AppStrings.bn : AppStrings.en;
          final lineColor = isDark ? Colors.white : AppColors.deepBlue;

          return Stack(
            children: [
              SafeArea(
                child: Column(
                  children: [
                    _buildAppBar(context, strings, isBangla, isDark),
                    Expanded(
                      child: BlocBuilder<GameCubit, GameState>(
                        builder: (context, state) {
                          return _GameBoardBody(
                            state: state,
                            gutiShape: gutiShape,
                            lineColor: lineColor,
                            onTap: context.read<GameCubit>().onNodeTap,
                          );
                        },
                      ),
                    ),
                    _buildBottomInfo(context, strings, isBangla, gutiShape),
                  ],
                ),
              ),
              BlocBuilder<GameCubit, GameState>(
                builder: (context, state) {
                  if (state.status == GameStatus.ongoing) {
                    return const SizedBox.shrink();
                  }
                  final winnerName = (state.status == GameStatus.redWin
                          ? strings['redWins']
                          : strings['blueWins']) ??
                      '';
                  return _WinOverlay(
                    strings: strings,
                    isBangla: isBangla,
                    winnerName: winnerName,
                    moveCount: state.moveCount,
                    onPlayAgain: context.read<GameCubit>().newGame,
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, Map<String, String> strings,
      bool isBangla, bool isDark) {
    return BlocBuilder<GameCubit, GameState>(
      builder: (context, state) {
        final redTurn = state.currentTurn == Player.red;
        final turnColor = redTurn
            ? (isDark ? const Color(0xFFEF9A9A) : AppColors.red)
            : (isDark ? const Color(0xFF90CAF9) : AppColors.blue);

        final title = redTurn ? strings['redTurn'] : strings['blueTurn'];

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
              Expanded(
                child: Text(
                  title ?? '',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.turn.copyWith(color: turnColor),
                ),
              ),
              IconButton(
                onPressed: () => context.read<GameCubit>().undo(),
                icon: const Icon(Icons.undo, color: AppColors.white),
                tooltip: strings['undo'],
              ),
              IconButton(
                onPressed: () => context.push('/settings'),
                icon: const Icon(Icons.settings, color: AppColors.white),
                tooltip: strings['settings'],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBottomInfo(
      BuildContext context, Map<String, String> strings, bool isBangla, GutuShape gutiShape) {
    final shapeNames = {
      GutuShape.circle: strings['circle'],
      GutuShape.square: strings['square'],
      GutuShape.bar: strings['bar'],
      GutuShape.lalBadshah: strings['lalBadshah'],
    };

    return BlocBuilder<GameCubit, GameState>(
      builder: (context, state) {
        return Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimens.contentPadding,
            vertical: AppDimens.sectionGap,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${strings['moveCount']}: ${state.moveCount}',
                style: AppTextStyles.subtitle,
              ),
              Text(
                shapeNames[gutiShape] ?? '',
                style: AppTextStyles.label,
              ),
            ],
          ),
        );
      },
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

class _WinOverlay extends StatelessWidget {
  final Map<String, String> strings;
  final bool isBangla;
  final String winnerName;
  final int moveCount;
  final VoidCallback onPlayAgain;

  const _WinOverlay({
    required this.strings,
    required this.isBangla,
    required this.winnerName,
    required this.moveCount,
    required this.onPlayAgain,
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
                strings['winnerCrown'] ?? 'WINNER!',
                style: baseStyle,
              ),
              const SizedBox(height: 12),
              Text(
                winnerName,
                style: AppTextStyles.titleLarge.copyWith(color: AppColors.white),
              ),
              const SizedBox(height: 8),
              Text(
                '${strings['moveCount']}: $moveCount',
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
                  strings['playAgain'] ?? 'Play Again',
                  style: AppTextStyles.button,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
