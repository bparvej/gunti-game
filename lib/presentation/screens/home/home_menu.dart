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

class HomeMenuScreen extends StatelessWidget {
  const HomeMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, settingsState) {
        final isBangla = settingsState.settings.isBangla;
        final s = isBangla ? AppStrings.bn : AppStrings.en;

        return BlocBuilder<GameCubit, GameState>(
          builder: (context, gameState) {
            return Scaffold(
              backgroundColor: AppColors.surface,
              body: Column(
                children: [
                  Container(
                    width: double.infinity,
                    color: AppColors.deepBlue,
                    padding: EdgeInsets.only(
                      top: MediaQuery.of(context).padding.top + 24,
                      bottom: 24,
                      left: AppDimens.contentPadding,
                      right: AppDimens.contentPadding,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          s['appName']!,
                          style: AppTextStyles.titleLarge
                              .copyWith(color: AppColors.white),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          s['tagline']!,
                          style: AppTextStyles.subtitle
                              .copyWith(color: AppColors.white.withValues(alpha: 0.7)),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(AppDimens.contentPadding),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (gameState.hasSavedGame)
                            Padding(
                              padding:
                                  const EdgeInsets.only(bottom: AppDimens.sectionGap),
                              child: SizedBox(
                                width: double.infinity,
                                height: 56,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.orange,
                                    foregroundColor: AppColors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                          AppDimens.smallRadius),
                                    ),
                                    elevation: 0,
                                  ),
                                  onPressed: () =>
                                      context.go('/game?continue=true'),
                                  child: Text(
                                    s['continueGame']!,
                                    style: AppTextStyles.button,
                                  ),
                                ),
                              ),
                            ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Text(
                              s['modeSelect']!,
                              style: AppTextStyles.bodyBold,
                            ),
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: _ModeTile(
                                  icon: Icons.person,
                                  label: s['singlePlayer']!,
                                  caption: s['vsDevice']!,
                                  onTap: () => _showSinglePlayerSheet(
                                    context,
                                    s,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _ModeTile(
                                  icon: Icons.people,
                                  label: s['twoPlayers']!,
                                  caption: s['passAndPlay']!,
                                  onTap: () {
                                    context.go('/game?mode=two');
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppDimens.sectionGap),
                          _MenuRow(
                            icon: Icons.history,
                            label: s['history']!,
                            onTap: () => context.go('/history'),
                          ),
                          _MenuRow(
                            icon: Icons.settings,
                            label: s['settings']!,
                            onTap: () => context.go('/settings'),
                          ),
                          _MenuRow(
                            icon: Icons.help_outline,
                            label: s['howToPlay']!,
                            onTap: () => context.go('/how-to-play'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showSinglePlayerSheet(
    BuildContext context,
    Map<String, String> s,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(),
      builder: (_) => _SinglePlayerSheet(strings: s),
    );
  }
}

class _ModeTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String caption;
  final VoidCallback onTap;

  const _ModeTile({
    required this.icon,
    required this.label,
    required this.caption,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 12),
        color: AppColors.lightGrey,
        child: Column(
          children: [
            Icon(icon, size: 36, color: AppColors.deepBlue),
            const SizedBox(height: 8),
            Text(label, style: AppTextStyles.bodyBold),
            const SizedBox(height: 2),
            Text(caption, style: AppTextStyles.label),
          ],
        ),
      ),
    );
  }
}

class _MenuRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _MenuRow({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: AppColors.lightGrey, width: 1),
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.deepBlue, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Text(label, style: AppTextStyles.body),
            ),
            const Icon(Icons.chevron_right, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}

class _SinglePlayerSheet extends StatefulWidget {
  final Map<String, String> strings;

  const _SinglePlayerSheet({required this.strings});

  @override
  State<_SinglePlayerSheet> createState() => _SinglePlayerSheetState();
}

class _SinglePlayerSheetState extends State<_SinglePlayerSheet> {
  Player _selectedSide = Player.red;
  Difficulty _selectedDifficulty = Difficulty.medium;

  @override
  Widget build(BuildContext context) {
    final s = widget.strings;

    return Padding(
      padding: const EdgeInsets.all(AppDimens.contentPadding),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(s['chooseSide']!, style: AppTextStyles.bodyBold),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _SegmentButton(
                  label: s['red']!,
                  selected: _selectedSide == Player.red,
                  color: AppColors.red,
                  onTap: () => setState(() => _selectedSide = Player.red),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _SegmentButton(
                  label: s['blue']!,
                  selected: _selectedSide == Player.blue,
                  color: AppColors.blue,
                  onTap: () => setState(() => _selectedSide = Player.blue),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimens.sectionGap),
          Text(s['chooseDifficulty']!, style: AppTextStyles.bodyBold),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _SegmentButton(
                  label: s['easy']!,
                  selected: _selectedDifficulty == Difficulty.easy,
                  color: AppColors.deepBlue,
                  onTap: () =>
                      setState(() => _selectedDifficulty = Difficulty.easy),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _SegmentButton(
                  label: s['medium']!,
                  selected: _selectedDifficulty == Difficulty.medium,
                  color: AppColors.deepBlue,
                  onTap: () =>
                      setState(() => _selectedDifficulty = Difficulty.medium),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _SegmentButton(
                  label: s['hard']!,
                  selected: _selectedDifficulty == Difficulty.hard,
                  color: AppColors.deepBlue,
                  onTap: () =>
                      setState(() => _selectedDifficulty = Difficulty.hard),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimens.sectionGap),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.orange,
                foregroundColor: AppColors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppDimens.smallRadius),
                ),
                elevation: 0,
              ),
              onPressed: () {
                Navigator.pop(context);
                final side = _selectedSide == Player.red ? 'red' : 'blue';
                final diff = _selectedDifficulty.name;
                context.go('/game?mode=single&side=$side&diff=$diff');
              },
              child: Text(s['startGame']!, style: AppTextStyles.button),
            ),
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }
}

class _SegmentButton extends StatelessWidget {
  final String label;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  const _SegmentButton({
    required this.label,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 40,
        alignment: Alignment.center,
        color: selected ? color : AppColors.lightGrey,
        child: Text(
          label,
          style: AppTextStyles.buttonSmall.copyWith(
            color: selected ? AppColors.white : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}
