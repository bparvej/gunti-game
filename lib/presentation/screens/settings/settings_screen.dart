import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../domain/models/game_models.dart';
import '../../cubits/settings/settings_cubit.dart';
import '../../cubits/settings/settings_state.dart';
import '../../cubits/stats/stats_cubit.dart';
import '../../cubits/stats/stats_state.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, settingsState) {
        final isBangla = settingsState.settings.isBangla;
        final s = isBangla ? AppStrings.bn : AppStrings.en;

        return Scaffold(
          appBar: AppBar(
            title: Text(s['settings']!),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => context.go('/'),
            ),
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Language toggle
              _SettingRow(
                label: s['language']!,
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('EN', style: AppTextStyles.label.copyWith(
                      fontWeight: isBangla ? FontWeight.w400 : FontWeight.w700,
                      color: isBangla ? AppColors.textSecondary : AppColors.deepBlue,
                    )),
                    const SizedBox(width: 8),
                    Switch(
                      value: isBangla,
                      onChanged: (_) => context.read<SettingsCubit>().toggleLanguage(),
                    ),
                    const SizedBox(width: 8),
                    Text('BN', style: AppTextStyles.label.copyWith(
                      fontWeight: isBangla ? FontWeight.w700 : FontWeight.w400,
                      color: isBangla ? AppColors.deepBlue : AppColors.textSecondary,
                    )),
                  ],
                ),
              ),

              // Theme toggle
              _SettingRow(
                label: s['theme']!,
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(s['light']!, style: AppTextStyles.label.copyWith(
                      fontWeight: !settingsState.settings.isDarkMode ? FontWeight.w700 : FontWeight.w400,
                      color: !settingsState.settings.isDarkMode ? AppColors.deepBlue : AppColors.textSecondary,
                    )),
                    const SizedBox(width: 8),
                    Switch(
                      value: settingsState.settings.isDarkMode,
                      onChanged: (_) => context.read<SettingsCubit>().toggleDarkMode(),
                    ),
                    const SizedBox(width: 8),
                    Text(s['dark']!, style: AppTextStyles.label.copyWith(
                      fontWeight: settingsState.settings.isDarkMode ? FontWeight.w700 : FontWeight.w400,
                      color: settingsState.settings.isDarkMode ? AppColors.deepBlue : AppColors.textSecondary,
                    )),
                  ],
                ),
              ),

              // Sound toggle
              _SettingRow(
                label: s['sound']!,
                trailing: Switch(
                  value: settingsState.settings.soundOn,
                  onChanged: (_) => context.read<SettingsCubit>().toggleSound(),
                ),
              ),

              // Vibration toggle
              _SettingRow(
                label: s['vibration']!,
                trailing: Switch(
                  value: settingsState.settings.vibrationOn,
                  onChanged: (_) => context.read<SettingsCubit>().toggleVibration(),
                ),
              ),

              const SizedBox(height: 16),

              // Guti shape picker
              Text(s['shape']!, style: AppTextStyles.bodyBold),
              const SizedBox(height: 8),
              Row(
                children: GutuShape.values.map((shape) {
                  final label = s[shapeNameKey(shape)]!;
                  final selected = settingsState.settings.gutiShape == shape;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => context.read<SettingsCubit>().setGutiShape(shape),
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        color: selected ? AppColors.deepBlue : AppColors.lightGrey,
                        child: Text(
                          label,
                          textAlign: TextAlign.center,
                          style: AppTextStyles.buttonSmall.copyWith(
                            color: selected ? AppColors.white : AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 24),

              // Stats
              BlocBuilder<StatsCubit, StatsState>(
                builder: (context, statsState) {
                  final stats = statsState.stats;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(s['stats']!, style: AppTextStyles.titleMedium),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          _StatTile(label: s['redWins']!, value: '${stats.redWins}'),
                          _StatTile(label: s['blueWins']!, value: '${stats.blueWins}'),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _StatTile(label: s['totalGames']!, value: '${stats.totalGames}'),
                          _StatTile(label: s['avgMoves']!, value: '${stats.averageMoves.round()}'),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: () => _showResetDialog(context, s),
                          child: Text(s['resetStats']!),
                        ),
                      ),
                    ],
                  );
                },
              ),

              const SizedBox(height: 24),

              // How to play
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => context.push('/how-to-play'),
                  child: Text(s['howToPlay']!),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String shapeNameKey(GutuShape shape) {
    switch (shape) {
      case GutuShape.circle: return 'circle';
      case GutuShape.square: return 'square';
      case GutuShape.bar: return 'bar';
      case GutuShape.lalBadshah: return 'lalBadshah';
    }
  }

  void _showResetDialog(BuildContext context, Map<String, String> s) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(s['resetStats']!),
        content: Text(s['confirmReset']!),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(s['confirmResetNo']!),
          ),
          TextButton(
            onPressed: () {
              context.read<StatsCubit>().reset();
              Navigator.pop(context);
            },
            child: Text(s['confirmResetYes']!),
          ),
        ],
      ),
    );
  }
}

class _SettingRow extends StatelessWidget {
  final String label;
  final Widget trailing;

  const _SettingRow({required this.label, required this.trailing});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.bodyBold),
          trailing,
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final String label;
  final String value;

  const _StatTile({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value, style: AppTextStyles.statValue),
            Text(label, style: AppTextStyles.statTitle),
          ],
        ),
      ),
    );
  }
}
