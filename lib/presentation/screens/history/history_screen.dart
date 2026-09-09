import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../domain/models/game_models.dart';
import '../../cubits/history/history_cubit.dart';
import '../../cubits/settings/settings_cubit.dart';
import '../../cubits/settings/settings_state.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, settingsState) {
        final isBangla = settingsState.settings.isBangla;
        final s = isBangla ? AppStrings.bn : AppStrings.en;

        return Scaffold(
          appBar: AppBar(
            title: Text(s['history']!),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => context.go('/'),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: () => _showClearDialog(context, s),
              ),
            ],
          ),
          body: BlocBuilder<HistoryCubit, HistoryState>(
            builder: (context, historyState) {
              if (historyState.entries.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.history, size: 64, color: AppColors.textSecondary),
                      const SizedBox(height: 12),
                      Text(s['historyEmpty']!, style: AppTextStyles.body),
                    ],
                  ),
                );
              }

              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: historyState.entries.length,
                separatorBuilder: (_, _) => const Divider(
                  height: 1,
                  thickness: 1,
                  color: AppColors.lightGrey,
                ),
                itemBuilder: (context, index) {
                  final entry = historyState.entries[index];
                  return Container(
                    color: AppColors.surface,
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    _modeLabel(entry.mode, s),
                                    style: AppTextStyles.bodyBold,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    _difficultyLabel(entry.difficulty, s),
                                    style: AppTextStyles.label,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(_winnerLabel(entry, s), style: AppTextStyles.body),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text('${entry.moveCount}', style: AppTextStyles.bodyBold),
                            const SizedBox(height: 4),
                            Text(_formatDate(entry.playedAt), style: AppTextStyles.label),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }

  String _modeLabel(GameMode mode, Map<String, String> s) {
    return mode == GameMode.singlePlayer ? s['singlePlayer']! : s['twoPlayers']!;
  }

  String _difficultyLabel(Difficulty difficulty, Map<String, String> s) {
    switch (difficulty) {
      case Difficulty.easy:
        return s['easy']!;
      case Difficulty.medium:
        return s['medium']!;
      case Difficulty.hard:
        return s['hard']!;
    }
  }

  String _winnerLabel(GameHistoryEntry entry, Map<String, String> s) {
    if (entry.winner == null) return s['draw']!;
    return entry.winner == Player.red ? s['redWins']! : s['blueWins']!;
  }

  String _formatDate(DateTime d) {
    final y = d.year.toString().padLeft(4, '0');
    final mo = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    final h = d.hour.toString().padLeft(2, '0');
    final mi = d.minute.toString().padLeft(2, '0');
    return '$y-$mo-$day $h:$mi';
  }

  void _showClearDialog(BuildContext context, Map<String, String> s) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(s['clearHistory']!),
        content: Text(s['confirmClearHistory']!),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(s['confirmResetNo']!),
          ),
          TextButton(
            onPressed: () {
              context.read<HistoryCubit>().clear();
              Navigator.pop(context);
            },
            child: Text(s['confirmResetYes']!),
          ),
        ],
      ),
    );
  }
}