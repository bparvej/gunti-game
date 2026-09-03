import 'package:flutter/material.dart';
import '../models/game_manager.dart';
import '../models/guti_theme.dart';

class SettingsPanel extends StatelessWidget {
  final GameManager gameManager;

  const SettingsPanel({super.key, required this.gameManager});

  @override
  Widget build(BuildContext context) {
    final gm = gameManager;
    final theme = gm.currentTheme;

    return Positioned.fill(
      child: Container(
        color: Colors.black.withValues(alpha: 0.6),
        child: Center(
          child: TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeOutCubic,
            tween: Tween(begin: 0.9, end: 1.0),
            builder: (context, value, child) {
              return Transform.scale(
                scale: value,
                child: Opacity(
                  opacity: value,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {},
                    child: Container(
                      width: 360,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.white,
                            Colors.grey.shade50,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.4),
                            blurRadius: 40,
                            offset: const Offset(0, 20),
                          ),
                        ],
                      ),
                      child: Stack(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 24),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _buildHeader(),
                                const SizedBox(height: 20),
                                _buildSettingButton(
                                  "THEME",
                                  theme.name,
                                  color: const Color(0xFF50A897),
                                  icon: Icons.palette_rounded,
                                  onPressed: () {
                                    gm.switchTheme();
                                  },
                                ),
                                _buildSettingButton(
                                  "SOUND",
                                  gm.audioService.isSoundEnabled() ? 'ON' : 'OFF',
                                  color: const Color(0xFF1A237E),
                                  icon: gm.audioService.isSoundEnabled()
                                      ? Icons.volume_up_rounded
                                      : Icons.volume_off_rounded,
                                  onPressed: () => gm.audioService.toggleSound(),
                                ),
                              _buildSettingButton(
                                "STATS",
                                "View statistics",
                                color: const Color(0xFFA1887F),
                                icon: Icons.bar_chart_rounded,
                                onPressed: () => gm.showStats(),
                              ),
                              _buildSettingButton(
                                "UNDO",
                                "Undo last move",
                                color: const Color(0xFFB71C1C),
                                icon: Icons.undo_rounded,
                                enabled: gm.canUndo(),
                                onPressed: gm.canUndo() ? () => gm.undoMove() : null,
                              ),
                              _buildSettingButton(
                                "SHAPE",
                                gm.currentShape.label,
                                color: const Color(0xFF6A1B9A),
                                icon: Icons.circle_rounded,
                                onPressed: () => gm.switchShape(),
                              ),
                              _buildSettingButton(
                                "COLORS",
                                GameConfig.colorPairs[gm.colorPairIndex].name,
                                color: const Color(0xFFC62828),
                                icon: Icons.color_lens_rounded,
                                onPressed: () => gm.openColorPicker(),
                              ),
                              _buildSettingButton(
                                "BACKGROUND",
                                "Customize board",
                                color: const Color(0xFF00695C),
                                icon: Icons.image_rounded,
                                onPressed: () => gm.openBackgroundPicker(),
                              ),
                              _buildSettingButton(
                                "HOW TO PLAY",
                                "Learn the rules",
                                color: const Color(0xFFFFA000),
                                icon: Icons.help_outline_rounded,
                                onPressed: () {
                                  gm.closeSettingsOverlay();
                                },
                              ),
                              const SizedBox(height: 16),
                            ],
                          ),
                        ),
                        Positioned(
                          top: 16,
                          right: 16,
                          child: GestureDetector(
                            onTap: () => gm.closeSettingsOverlay(),
                            child: Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.grey.shade300, width: 1),
                              ),
                              child: Icon(Icons.close_rounded,
                                  size: 18, color: Colors.grey.shade600),
                            ),
                          ),
                        ),
                      ],
                    ),
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

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          width: 48,
          height: 4,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFF50A897),
                const Color(0xFF50A897).withValues(alpha: 0.3),
              ],
            ),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          "Settings",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: Color(0xFF1A1A2E),
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          "Bangla Guti Game",
          style: TextStyle(
            fontSize: 13,
            fontStyle: FontStyle.italic,
            color: Colors.grey.shade500,
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }

  Widget _buildSettingButton(
    String label,
    String value, {
    required Color color,
    IconData? icon,
    VoidCallback? onPressed,
    bool enabled = true,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      child: SizedBox(
        height: 56,
        child: ElevatedButton(
          onPressed: enabled ? onPressed : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: enabled ? color : Colors.grey.shade300,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: enabled ? 4 : 0,
            shadowColor: color.withValues(alpha: 0.3),
          ),
          child: Row(
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  color: Colors.white.withValues(alpha: 0.9),
                  size: 20,
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                      ),
                    ),
                    if (value.isNotEmpty)
                      Text(
                        value,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.85),
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: Colors.white.withValues(alpha: 0.7),
              ),
            ],
          ),
        ),
      ),
    );
  }
}