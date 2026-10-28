import 'package:flutter/material.dart';

import '../../core/constants/strings.dart';
import '../../core/theme/palette.dart';
import '../../domain/game/game_enums.dart';
import '../controllers/app_state.dart';
import '../widgets/chunky_button.dart';
import '../widgets/gradient_bg.dart';
import '../widgets/guti_view.dart';
import '../widgets/painters.dart';

class ThemePicker extends StatelessWidget {
  const ThemePicker({super.key});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        for (var i = 0; i < Pal.themes.length; i++)
          _tile(context, i),
      ],
    );
  }

  Widget _tile(BuildContext context, int i) {
    final t = Pal.themes[i];
    final open = app.themeUnlocked(i);
    final sel = app.themeIndex == i;
    return GestureDetector(
      onTap: () {
        if (open) {
          app.set(() => app.themeIndex = i);
        } else {
          toast(context, tr('unlockAt', {'n': '${t.unlock}'}));
        }
      },
      child: SizedBox(
        width: 84,
        child: Column(
          children: [
            Container(
              width: 84,
              height: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [t.bg1, t.bg2],
                ),
                border: Border.all(
                    color: sel ? Pal.green : pal.border,
                    width: sel ? 3.5 : 1.5),
                boxShadow: sel
                    ? const [
                        BoxShadow(color: Pal.greenDark, offset: Offset(0, 3))
                      ]
                    : const [],
              ),
              child: Stack(
                children: [
                  Positioned(
                    left: 8,
                    right: 8,
                    bottom: 8,
                    height: 24,
                    child: Container(
                      decoration: BoxDecoration(
                        color: t.card,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                              width: 11,
                              height: 11,
                              decoration: BoxDecoration(
                                  color: t.me, shape: BoxShape.circle)),
                          const SizedBox(width: 6),
                          Container(
                              width: 11,
                              height: 11,
                              decoration: BoxDecoration(
                                  color: t.opp, shape: BoxShape.circle)),
                        ],
                      ),
                    ),
                  ),
                  if (!open)
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          color: fade(Colors.black, .35),
                          borderRadius: BorderRadius.circular(13),
                        ),
                        child: Center(child: LockBadge(t.unlock)),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            Text(tr('th$i'),
                textAlign: TextAlign.center,
                maxLines: 2,
                style: TextStyle(
                    color: open ? pal.text : pal.sub,
                    fontSize: 11,
                    fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }
}

class ShapePicker extends StatelessWidget {
  const ShapePicker({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (final s in GutiShape.values) ...[
          if (s.index > 0) const SizedBox(width: 12),
          Expanded(child: _tile(context, s)),
        ],
      ],
    );
  }

  Widget _tile(BuildContext context, GutiShape s) {
    final open = app.shapeUnlocked(s);
    final sel = app.shape == s;
    final need = AppState.shapeUnlock[s.index];
    return GestureDetector(
      onTap: () {
        if (open) {
          app.set(() => app.shape = s);
        } else {
          toast(context, tr('unlockAt', {'n': '$need'}));
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: pal.soft,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: sel ? Pal.green : pal.border, width: sel ? 3 : 1.5),
          boxShadow: sel
              ? const [BoxShadow(color: Pal.greenDark, offset: Offset(0, 3))]
              : const [],
        ),
        child: Column(
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Opacity(
                  opacity: open ? 1 : .45,
                  child: Guti(color: pal.me, size: 50, shape: s),
                ),
                if (!open) LockBadge(need),
              ],
            ),
            const SizedBox(height: 4),
            Text(tr('sh${s.index}'),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    color: open ? pal.text : pal.sub,
                    fontSize: 11,
                    fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }
}

class SettingsForm extends StatefulWidget {
  const SettingsForm({super.key});

  @override
  State<SettingsForm> createState() => _SettingsFormState();
}

class _SettingsFormState extends State<SettingsForm> {
  late final TextEditingController _ctrl =
      TextEditingController(text: app.name);

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Widget _label(String t) => Padding(
        padding: const EdgeInsets.only(top: 22, bottom: 10),
        child: Text(t,
            style: TextStyle(
                color: pal.text, fontSize: 17, fontWeight: FontWeight.w700)),
      );

  @override
  Widget build(BuildContext context) {
    return appBuilder((_) {
      OutlineInputBorder border(Color c, [double w = 1]) => OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: c, width: w),
          );
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(tr('yourName'),
              style: TextStyle(
                  color: pal.text, fontSize: 17, fontWeight: FontWeight.w700)),
          const SizedBox(height: 10),
          TextField(
            controller: _ctrl,
            onChanged: (v) => app.set(() => app.name = v),
            style: TextStyle(color: pal.text, fontSize: 17),
            cursorColor: pal.primary,
            decoration: InputDecoration(
              hintText: 'Player 1',
              hintStyle: TextStyle(color: pal.sub, fontSize: 17),
              filled: true,
              fillColor: pal.soft,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
              enabledBorder: border(pal.border),
              focusedBorder: border(pal.primary, 1.6),
            ),
          ),
          _label(tr('difficulty')),
          OptionRow<Difficulty>(
            value: app.difficulty,
            options: {
              Difficulty.easy: tr('easy'),
              Difficulty.medium: tr('medium'),
              Difficulty.hard: tr('hard'),
            },
            onChanged: (v) => app.set(() => app.difficulty = v),
          ),
          _label(tr('language')),
          OptionRow<AppLanguage>(
            value: app.language,
            options: const {
              AppLanguage.english: 'English',
              AppLanguage.bangla: 'বাংলা',
            },
            onChanged: (v) => app.set(() => app.language = v),
          ),
          if (app.onboarded) ...[
            _label(tr('theme')),
            const ThemePicker(),
            _label(tr('shape')),
            const ShapePicker(),
          ],
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: Text(tr('soundSetting'),
                    style: TextStyle(
                        color: pal.text,
                        fontSize: 15,
                        fontWeight: FontWeight.w700)),
              ),
              Switch(
                value: app.soundOn,
                onChanged: (v) => app.set(() => app.soundOn = v),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: Text(tr('autoSetting'),
                    style: TextStyle(
                        color: pal.text,
                        fontSize: 15,
                        fontWeight: FontWeight.w700)),
              ),
              Switch(
                value: app.autoEnabled,
                onChanged: (v) => app.set(() => app.autoEnabled = v),
              ),
            ],
          ),
        ],
      );
    });
  }
}

class OptionRow<T> extends StatelessWidget {
  final T value;
  final Map<T, String> options;
  final ValueChanged<T> onChanged;
  const OptionRow(
      {super.key,
      required this.value,
      required this.options,
      required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final entries = options.entries.toList();
    final radius = BorderRadius.circular(14);
    return Row(
      children: [
        for (var i = 0; i < entries.length; i++) ...[
          if (i > 0) const SizedBox(width: 12),
          Expanded(
            child: Material(
              color: entries[i].key == value ? pal.primary : Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: radius,
                side: BorderSide(color: pal.primary, width: 1.3),
              ),
              child: InkWell(
                borderRadius: radius,
                onTap: () => onChanged(entries[i].key),
                child: SizedBox(
                  height: 50,
                  child: Center(
                    child: Text(
                      entries[i].value,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: entries[i].key == value
                            ? Colors.white
                            : pal.text,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return appBuilder((context) {
      return Scaffold(
        backgroundColor: pal.bg1,
        body: GradientBg(
          child: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 480),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 74,
                        height: 74,
                        decoration: BoxDecoration(
                          color: fade(Colors.white, .16),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Guti(color: pal.me, size: 16),
                              const SizedBox(width: 4),
                              Guti(color: pal.opp, size: 16),
                              const SizedBox(width: 4),
                              Guti(color: pal.me, size: 16),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 22),
                      Text(
                        tr('welcome'),
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 30,
                            fontWeight: FontWeight.w800,
                            height: 1.15),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        tr('subtitle'),
                        style: TextStyle(
                            color: fade(Colors.white, .78),
                            fontSize: 16,
                            height: 1.4),
                      ),
                      const SizedBox(height: 24),
                      Container(
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                        decoration: BoxDecoration(
                          color: pal.card,
                          borderRadius: BorderRadius.circular(26),
                        ),
                        child: Column(
                          children: [
                            const SettingsForm(),
                            const SizedBox(height: 28),
                            ChunkyButton(
                              label: tr('getStarted'),
                              icon: Icons.play_arrow_rounded,
                              top: const Color(0xFF9CF2A3),
                              bottom: const Color(0xFF4FCB62),
                              edge: const Color(0xFF2E9E43),
                              height: 64,
                              fontSize: 19,
                              onTap: () => app.set(() => app.onboarded = true),
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
      );
    });
  }
}

