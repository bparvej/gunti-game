import 'package:flutter/material.dart';

class HowToPlayOverlay extends StatelessWidget {
  final VoidCallback onDismiss;

  const HowToPlayOverlay({super.key, required this.onDismiss});

  static final List<RuleItem> rules = [
    RuleItem(
      icon: Icons.people_rounded,
      text: "2 players, 3 gutis each",
      color: const Color(0xFF1A1A2E),
      bgColor: const Color(0xFF50A897).withValues(alpha: 0.1),
    ),
    RuleItem(
      icon: Icons.touch_app_rounded,
      text: "Tap your guti to select it",
      color: const Color(0xFF1A1A2E),
      bgColor: const Color(0xFF1A237E).withValues(alpha: 0.1),
    ),
    RuleItem(
      icon: Icons.circle_rounded,
      text: "Green ring = legal move (1 step)",
      color: const Color(0xFF1A1A2E),
      bgColor: Colors.green.withValues(alpha: 0.1),
    ),
    RuleItem(
      icon: Icons.block_rounded,
      text: "No jumping, no overlapping",
      color: const Color(0xFF1A1A2E),
      bgColor: Colors.red.withValues(alpha: 0.1),
    ),
    RuleItem(
      icon: Icons.block_rounded,
      text: "No capturing / eating stones",
      color: const Color(0xFF1A1A2E),
      bgColor: Colors.red.withValues(alpha: 0.1),
    ),
    RuleItem(
      icon: Icons.emoji_events_rounded,
      text: "Line up all 3 to WIN!",
      color: const Color(0xFF1A1A2E),
      bgColor: const Color(0xFFFFA000).withValues(alpha: 0.1),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withValues(alpha: 0.85),
        child: Center(
          child: TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeOutCubic,
            tween: Tween(begin: 0.9, end: 1.0),
            builder: (context, value, child) {
              return Transform.scale(
                scale: value,
                child: Opacity(
                  opacity: value,
                  child: Container(
                    width: 420,
                    constraints: const BoxConstraints(maxHeight: 580),
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
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.help_outline_rounded,
                                size: 28,
                                color: const Color(0xFF1A1A2E),
                              ),
                              const SizedBox(width: 10),
                              const Text(
                                "HOW TO PLAY",
                                style: TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFF1A1A2E),
                                  letterSpacing: 1,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            "Bangla Guti Game",
                            style: TextStyle(
                              fontSize: 13,
                              fontStyle: FontStyle.italic,
                              color: Colors.grey.shade500,
                              letterSpacing: 0.3,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Expanded(
                            child: ListView.builder(
                              shrinkWrap: true,
                              itemCount: rules.length,
                              itemBuilder: (context, index) {
                                final rule = rules[index];
                                return TweenAnimationBuilder<double>(
                                  duration: Duration(milliseconds: 400 + (index * 80)),
                                  tween: Tween(begin: 0.0, end: 1.0),
                                  curve: Curves.easeOutCubic,
                                  builder: (context, value, child) {
                                    return Transform.translate(
                                      offset: Offset(0, 20 * (1 - value)),
                                      child: Opacity(
                                        opacity: value,
                                        child: Container(
                                          margin: const EdgeInsets.only(bottom: 10),
                                          padding: const EdgeInsets.all(14),
                                          decoration: BoxDecoration(
                                            color: rule.bgColor,
                                            borderRadius: BorderRadius.circular(14),
                                            border: Border.all(
                                              color: Colors.grey.shade200,
                                              width: 1,
                                            ),
                                          ),
                                          child: Row(
                                            children: [
                                              Container(
                                                width: 36,
                                                height: 36,
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius: BorderRadius.circular(10),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.black.withValues(alpha: 0.05),
                                                      blurRadius: 4,
                                                    ),
                                                  ],
                                                ),
                                                child: Icon(
                                                  rule.icon,
                                                  size: 18,
                                                  color: rule.color,
                                                ),
                                              ),
                                              const SizedBox(width: 12),
                                              Expanded(
                                                child: Text(
                                                  rule.text,
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w600,
                                                    color: rule.color,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1A1A2E).withValues(alpha: 0.05),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: const Color(0xFF1A1A2E).withValues(alpha: 0.1),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.lightbulb_rounded,
                                  size: 18,
                                  color: const Color(0xFFFFA000),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    "Tip: Use ⚙️ to change colors, background & guti shapes",
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade700,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: onDismiss,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF1A1A2E),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                elevation: 4,
                              ),
                              child: const Text(
                                "LET'S PLAY",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1,
                                ),
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
}

class RuleItem {
  final IconData icon;
  final String text;
  final Color color;
  final Color bgColor;

  const RuleItem({
    required this.icon,
    required this.text,
    required this.color,
    required this.bgColor,
  });
}
