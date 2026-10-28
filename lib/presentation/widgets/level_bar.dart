import 'package:flutter/material.dart';
import '../../core/theme/palette.dart';

/// Glossy 3D green progress bar.
class LevelBar extends StatelessWidget {
  final double value;
  final double height;
  final Color? track;
  final List<Color>? colors;

  const LevelBar({
    super.key,
    required this.value,
    this.height = 10,
    this.track,
    this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      alignment: Alignment.centerLeft,
      decoration: BoxDecoration(
        color: track ?? fade(Colors.black, .28),
        borderRadius: BorderRadius.circular(height),
      ),
      child: FractionallySizedBox(
        widthFactor: value.clamp(0.06, 1.0).toDouble(),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: colors ?? const [Color(0xFF9CF2A3), Pal.greenDark],
            ),
            borderRadius: BorderRadius.circular(height),
            boxShadow: const [
              BoxShadow(
                color: Color(0x33000000),
                offset: Offset(0, 1),
                blurRadius: 2,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

