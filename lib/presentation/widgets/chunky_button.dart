import 'package:flutter/material.dart';
import '../../core/theme/palette.dart';

/// Chunky 3D game button (same look as the popup's OK button).
class ChunkyButton extends StatelessWidget {
  final String label;
  final String? sub;
  final IconData? icon;
  final Color top, bottom, edge;
  final VoidCallback onTap;
  final double height;
  final double fontSize;

  const ChunkyButton({
    super.key,
    required this.label,
    this.sub,
    this.icon,
    required this.top,
    required this.bottom,
    required this.edge,
    required this.onTap,
    this.height = 64,
    this.fontSize = 21,
  });

  @override
  Widget build(BuildContext context) {
    final r = BorderRadius.circular(22);
    return Container(
      height: height,
      decoration: BoxDecoration(
        borderRadius: r,
        boxShadow: [
          BoxShadow(color: edge, offset: const Offset(0, 6)),
          BoxShadow(
            color: fade(Colors.black, .25),
            blurRadius: 14,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: r,
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [top, bottom],
            ),
          ),
          child: InkWell(
            borderRadius: r,
            onTap: onTap,
            child: Stack(
              children: [
                Positioned(
                  left: 14,
                  right: 14,
                  top: 5,
                  height: height * .24,
                  child: Container(
                    decoration: BoxDecoration(
                      color: fade(Colors.white, .28),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (icon != null)
                        Icon(icon, color: Colors.white, size: 30),
                      if (icon != null && label.isNotEmpty)
                        const SizedBox(width: 8),
                      if (label.isNotEmpty)
                        Flexible(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                label,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: fontSize,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1,
                                  shadows: [
                                    Shadow(
                                      color: edge,
                                      offset: const Offset(0, 2.5),
                                    ),
                                  ],
                                ),
                              ),
                              if (sub != null)
                                Text(
                                  sub!,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: fade(Colors.white, .92),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

