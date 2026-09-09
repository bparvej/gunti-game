import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimens.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../domain/models/game_models.dart';
import '../../cubits/settings/settings_cubit.dart';
import '../../cubits/settings/settings_state.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  late TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    final settings = context.read<SettingsCubit>().state.settings;
    _nameController = TextEditingController(text: settings.playerName);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, settingsState) {
        final isBangla = settingsState.settings.isBangla;
        final s = isBangla ? AppStrings.bn : AppStrings.en;
        final settings = settingsState.settings;

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
                      s['onboardingTitle']!,
                      style: AppTextStyles.titleLarge
                          .copyWith(color: AppColors.white),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      s['onboardingSubtitle']!,
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
                      Text(s['yourName']!, style: AppTextStyles.bodyBold),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _nameController,
                        style: AppTextStyles.body,
                        decoration: InputDecoration(
                          hintText: s['onboardingNameHint'],
                          hintStyle: AppTextStyles.label,
                          filled: true,
                          fillColor: AppColors.lightGrey,
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                        ),
                        onChanged: (value) {
                          context.read<SettingsCubit>().setPlayerName(value);
                        },
                      ),
                      const SizedBox(height: AppDimens.sectionGap * 1.5),
                      Text(s['chooseDifficulty']!, style: AppTextStyles.bodyBold),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: _OnboardChip(
                              label: s['easy']!,
                              selected: settings.difficulty == Difficulty.easy,
                              onTap: () => context
                                  .read<SettingsCubit>()
                                  .setDifficulty(Difficulty.easy),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _OnboardChip(
                              label: s['medium']!,
                              selected:
                                  settings.difficulty == Difficulty.medium,
                              onTap: () => context
                                  .read<SettingsCubit>()
                                  .setDifficulty(Difficulty.medium),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _OnboardChip(
                              label: s['hard']!,
                              selected: settings.difficulty == Difficulty.hard,
                              onTap: () => context
                                  .read<SettingsCubit>()
                                  .setDifficulty(Difficulty.hard),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppDimens.sectionGap * 1.5),
                      Text(s['language']!, style: AppTextStyles.bodyBold),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: _OnboardChip(
                              label: s['english']!,
                              selected: !settings.isBangla,
                              onTap: () {
                                if (settings.isBangla) {
                                  context.read<SettingsCubit>().toggleLanguage();
                                }
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _OnboardChip(
                              label: s['bangla']!,
                              selected: settings.isBangla,
                              onTap: () {
                                if (!settings.isBangla) {
                                  context.read<SettingsCubit>().toggleLanguage();
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppDimens.sectionGap * 1.5),
                      Text(s['theme']!, style: AppTextStyles.bodyBold),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: _OnboardChip(
                              label: s['light']!,
                              selected: !settings.isDarkMode,
                              onTap: () {
                                if (settings.isDarkMode) {
                                  context.read<SettingsCubit>().toggleDarkMode();
                                }
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _OnboardChip(
                              label: s['dark']!,
                              selected: settings.isDarkMode,
                              onTap: () {
                                if (!settings.isDarkMode) {
                                  context.read<SettingsCubit>().toggleDarkMode();
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppDimens.sectionGap * 2),
                      SizedBox(
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
                          onPressed: () {
                            context.read<SettingsCubit>().setPlayerName(
                                _nameController.text);
                            context
                                .read<SettingsCubit>()
                                .completeOnboarding();
                            context.go('/');
                          },
                          child: Text(
                            s['getStarted']!,
                            style: AppTextStyles.button,
                          ),
                        ),
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
  }
}

class _OnboardChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _OnboardChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 40,
        alignment: Alignment.center,
        color: selected ? AppColors.deepBlue : AppColors.lightGrey,
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
