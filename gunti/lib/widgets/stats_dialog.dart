import 'package:flutter/material.dart';
import '../models/board.dart';
import '../models/game_manager.dart';

class StatsDialog extends StatelessWidget {
  final GameManager gameManager;

  const StatsDialog({super.key, required this.gameManager});

  @override
  Widget build(BuildContext context) {
    final stats = gameManager.statsService.getStats();
    final theme = gameManager.currentTheme;

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
                  child: Container(
                    width: 340,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.white,
                          Colors.grey.shade50,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.3),
                          blurRadius: 30,
                          offset: const Offset(0, 15),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.bar_chart_rounded,
                                size: 24,
                                color: const Color(0xFF50A897),
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                "Statistics",
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF1A1A2E),
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          Row(
                            children: [
                              Expanded(
                                child: _buildStatCard(
                                  "Red Wins",
                                  stats.redWins.toString(),
                                  theme.redColor,
                                  Icons.circle,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildStatCard(
                                  "Blue Wins",
                                  stats.blueWins.toString(),
                                  theme.blueColor,
                                  Icons.circle,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _buildStatRow(
                            "Total Games",
                            stats.totalGames.toString(),
                            icon: Icons.sports_esports_rounded,
                          ),
                          _buildStatRow(
                            "Avg Moves",
                            stats.averageMoves.toInt().toString(),
                            icon: Icons.calculate_rounded,
                          ),
                          if (stats.lastWinner != null) ...[
                            const SizedBox(height: 8),
                            _buildStatRow(
                              "Last Winner",
                              stats.lastWinner == Player.red ? "RED" : "BLUE",
                              icon: Icons.emoji_events_rounded,
                              valueColor: stats.lastWinner == Player.red
                                  ? theme.redColor
                                  : theme.blueColor,
                            ),
                          ],
                          const SizedBox(height: 20),
                          TextButton.icon(
                            onPressed: () {
                              gameManager.statsService.resetStats();
                              gameManager.closeStats();
                            },
                            icon: Icon(
                              Icons.delete_outline_rounded,
                              size: 18,
                              color: Colors.red.shade400,
                            ),
                            label: Text(
                              "Reset Stats",
                              style: TextStyle(
                                color: Colors.red.shade400,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
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

  Widget _buildStatCard(String label, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withValues(alpha: 0.15),
            color.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: 20,
            color: color,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(
    String label,
    String value, {
    IconData? icon,
    Color? valueColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.shade200,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: 18,
              color: Colors.grey.shade600,
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: valueColor ?? const Color(0xFF1A1A2E),
            ),
          ),
        ],
      ),
    );
  }
}
