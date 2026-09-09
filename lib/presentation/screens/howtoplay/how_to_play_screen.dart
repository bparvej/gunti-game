import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../cubits/settings/settings_cubit.dart';
import '../../cubits/settings/settings_state.dart';

class HowToPlayScreen extends StatelessWidget {
  const HowToPlayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, state) {
        final isBangla = state.settings.isBangla;
        final s = isBangla ? AppStrings.bn : AppStrings.en;

        final rules = [
          s['rulesLine1']!,
          s['rulesLine2']!,
          s['rulesLine3']!,
          s['rulesLine4']!,
          s['rulesLine5']!,
          s['rulesLine6']!,
        ];

        final icons = ['👥', '👆', '🟢', '🚫', '🚫', '🏆'];

        return Scaffold(
          appBar: AppBar(
            title: Text(s['rulesTitle']!),
          ),
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(s['rulesTitle']!, style: AppTextStyles.titleLarge),
                const SizedBox(height: 24),
                ...List.generate(rules.length, (i) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        Text(icons[i], style: const TextStyle(fontSize: 20)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(rules[i], style: AppTextStyles.body),
                        ),
                      ],
                    ),
                  );
                }),
                const Spacer(),
                Center(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(s['letsPlay']!),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }
}
