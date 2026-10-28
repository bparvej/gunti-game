import 'package:flutter/material.dart';

import '../../core/constants/strings.dart';
import '../../core/theme/palette.dart';
import '../../domain/game/game_enums.dart';
import '../controllers/app_state.dart';
import '../dialogs/avatar_picker_sheet.dart';
import '../widgets/avatar_view.dart';
import '../widgets/chunky_button.dart';
import '../widgets/chunky_card.dart';
import '../widgets/chunky_icon_button.dart';
import '../widgets/chunky_toggle.dart';
import '../widgets/gradient_bg.dart';
import '../widgets/painters.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late final TextEditingController _nameCtrl =
      TextEditingController(text: app.name);

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  void _showAvatarPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => const AvatarPickerSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return appBuilder((context) {
      return Scaffold(
        backgroundColor: pal.bg1,
        body: GradientBg(
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 30),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 440),
                  child: Column(
                    children: [
                      // Top Bar
                      Row(
                        children: [
                          ChunkyIconButton(
                            icon: Icons.arrow_back_rounded,
                            size: 44,
                            top: const Color(0xFFA567FF),
                            bottom: const Color(0xFF7430E0),
                            edge: const Color(0xFF4B1D9C),
                            onTap: () => Navigator.of(context).pop(),
                          ),
                          Expanded(
                            child: Center(
                              child: Text(
                                tr('settings').toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 44),
                        ],
                      ),
                      const SizedBox(height: 18),

                      // Profile & Avatar Card
                      Chunky3DCard(
                        padding: const EdgeInsets.all(18),
                        child: Column(
                          children: [
                            GestureDetector(
                              onTap: _showAvatarPicker,
                              child: Stack(
                                alignment: Alignment.bottomRight,
                                children: [
                                  AvatarView(
                                    avatarIndex: app.avatarIndex,
                                    size: 80,
                                  ),
                                  Container(
                                    padding: const EdgeInsets.all(5),
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Color(0xFF7430E0),
                                    ),
                                    child: const Icon(Icons.edit_rounded,
                                        size: 14, color: Colors.white),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextButton(
                              onPressed: _showAvatarPicker,
                              child: Text(
                                tr('changeAvatar'),
                                style: const TextStyle(
                                  color: Color(0xFF6A4FE0),
                                  fontWeight: FontWeight.w800,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: _nameCtrl,
                                    maxLength: 16,
                                    decoration: InputDecoration(
                                      labelText: tr('yourName'),
                                      counterText: '',
                                      filled: true,
                                      fillColor: const Color(0xFFF3EFFF),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 16, vertical: 12),
                                      border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(16),
                                        borderSide: const BorderSide(
                                            color: Color(0xFFB9A8EC),
                                            width: 1.5),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                ChunkyButton(
                                  label: tr('save'),
                                  top: const Color(0xFF9CF2A3),
                                  bottom: const Color(0xFF4FCB62),
                                  edge: const Color(0xFF2E9E43),
                                  height: 48,
                                  onTap: () {
                                    app.set(() =>
                                        app.name = _nameCtrl.text.trim());
                                    FocusScope.of(context).unfocus();
                                    toast(context, tr('unlocked'));
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Audio & Feedback Card
                      Chunky3DCard(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 18, vertical: 14),
                        child: Column(
                          children: [
                            // Sound Effects Toggle
                            Row(
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF1EDFC),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    app.soundOn
                                        ? Icons.volume_up_rounded
                                        : Icons.volume_off_rounded,
                                    color: const Color(0xFF6A4FE0),
                                    size: 22,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        tr('sound'),
                                        style: const TextStyle(
                                          color: Color(0xFF28185C),
                                          fontSize: 15,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                      Text(
                                        tr('soundSetting'),
                                        style: const TextStyle(
                                          color: Color(0xFF756A8F),
                                          fontSize: 11,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                ChunkyToggle(
                                  value: app.soundOn,
                                  onChanged: (v) =>
                                      app.set(() => app.soundOn = v),
                                ),
                              ],
                            ),
                            const Divider(
                                height: 24,
                                thickness: 1,
                                color: Color(0xFFECE6F8)),

                            // Vibration Toggle
                            Row(
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF1EDFC),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(
                                    Icons.vibration_rounded,
                                    color: Color(0xFF6A4FE0),
                                    size: 22,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        tr('vibration'),
                                        style: const TextStyle(
                                          color: Color(0xFF28185C),
                                          fontSize: 15,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                      Text(
                                        tr('vibrationSetting'),
                                        style: const TextStyle(
                                          color: Color(0xFF756A8F),
                                          fontSize: 11,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                ChunkyToggle(
                                  value: app.vibrationOn,
                                  onChanged: (v) =>
                                      app.set(() => app.vibrationOn = v),
                                ),
                              ],
                            ),
                            const Divider(
                                height: 24,
                                thickness: 1,
                                color: Color(0xFFECE6F8)),

                            // Autoplay Toggle
                            Row(
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF1EDFC),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(
                                    Icons.bolt_rounded,
                                    color: Color(0xFFFFA726),
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        tr('auto'),
                                        style: const TextStyle(
                                          color: Color(0xFF28185C),
                                          fontSize: 15,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                      Text(
                                        tr('autoSetting'),
                                        style: const TextStyle(
                                          color: Color(0xFF756A8F),
                                          fontSize: 11,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                ChunkyToggle(
                                  value: app.autoEnabled,
                                  onChanged: (v) =>
                                      app.set(() => app.autoEnabled = v),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Language 3D Card
                      Chunky3DCard(
                        padding: const EdgeInsets.all(18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              tr('language'),
                              style: const TextStyle(
                                color: Color(0xFF28185C),
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: ChunkyButton(
                                    label: 'English',
                                    top: app.language == AppLanguage.english
                                        ? const Color(0xFFA567FF)
                                        : const Color(0xFFE4DCF9),
                                    bottom: app.language == AppLanguage.english
                                        ? const Color(0xFF7430E0)
                                        : const Color(0xFFC7B8EC),
                                    edge: app.language == AppLanguage.english
                                        ? const Color(0xFF4B1D9C)
                                        : const Color(0xFFA292D0),
                                    height: 52,
                                    onTap: () => app.set(() =>
                                        app.language = AppLanguage.english),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: ChunkyButton(
                                    label: 'বাংলা',
                                    top: app.language == AppLanguage.bangla
                                        ? const Color(0xFFA567FF)
                                        : const Color(0xFFE4DCF9),
                                    bottom: app.language == AppLanguage.bangla
                                        ? const Color(0xFF7430E0)
                                        : const Color(0xFFC7B8EC),
                                    edge: app.language == AppLanguage.bangla
                                        ? const Color(0xFF4B1D9C)
                                        : const Color(0xFFA292D0),
                                    height: 52,
                                    onTap: () => app.set(() =>
                                        app.language = AppLanguage.bangla),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: ChunkyButton(
                          label: tr('save'),
                          icon: Icons.check_circle_rounded,
                          top: const Color(0xFF9CF2A3),
                          bottom: const Color(0xFF4FCB62),
                          edge: const Color(0xFF2E9E43),
                          height: 60,
                          fontSize: 18,
                          onTap: () {
                            app.set(() => app.name = _nameCtrl.text.trim());
                            FocusScope.of(context).unfocus();
                            toast(context, tr('unlocked'));
                            Navigator.of(context).pop();
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    });
  }
}

