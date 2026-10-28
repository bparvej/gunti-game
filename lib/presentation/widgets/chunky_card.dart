import 'package:flutter/material.dart';
import '../../core/theme/palette.dart';

/// 3D Card with elevated bevel and smooth depth
class Chunky3DCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final Color bg;
  final Color edge;

  const Chunky3DCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.margin = const EdgeInsets.symmetric(vertical: 8),
    this.bg = Colors.white,
    this.edge = const Color(0xFFB9A8EC),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: edge, offset: const Offset(0, 6)),
          BoxShadow(
            color: fade(Colors.black, .18),
            blurRadius: 16,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: child,
    );
  }
}

