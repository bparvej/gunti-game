import 'package:flutter/material.dart';
import '../models/board.dart';
import '../models/guti_theme.dart';

class BoardPainter extends CustomPainter {
  final GutiTheme theme;
  final bool showHints;
  final String? selectedNode;
  final List<String> hintNodes;
  final Color hintColor;

  const BoardPainter({
    required this.theme,
    this.showHints = false,
    this.selectedNode,
    this.hintNodes = const [],
    required this.hintColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final nodes = Board.nodes;

    final linePaint = Paint()
      ..shader = LinearGradient(
        colors: [
          Color(theme.boardLineColor).withValues(alpha: 0.6),
          Color(theme.boardLineColor),
          Color(theme.boardLineColor).withValues(alpha: 0.6),
        ],
      ).createShader(const Rect.fromLTWH(0, 0, 600, 600))
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 5
      ..isAntiAlias = true
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1);

    for (final fromEntry in nodes.entries) {
      final from = fromEntry.value;
      for (final targetKey in from.links) {
        final target = nodes[targetKey]!;
        canvas.drawLine(
          Offset(from.x, from.y),
          Offset(target.x, target.y),
          linePaint,
        );
      }
    }

    for (final node in nodes.values) {
      final glowPaint = Paint()
        ..color = Color(theme.boardLineColor).withValues(alpha: 0.25)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
      canvas.drawCircle(Offset(node.x, node.y), 14, glowPaint);

      final gradient = RadialGradient(
        colors: [
          Color(theme.boardLineColor),
          Color(theme.boardLineColor).withValues(alpha: 0.7),
        ],
        radius: 1,
      );
      final nodeGradientPaint = Paint()
        ..shader = gradient.createShader(
          Rect.fromCircle(center: Offset(node.x, node.y), radius: 10),
        );
      canvas.drawCircle(Offset(node.x, node.y), 10, nodeGradientPaint);

      final highlightPaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.15)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
      canvas.drawCircle(
          Offset(node.x - 2, node.y - 2), 4, highlightPaint);
    }

    if (showHints && selectedNode != null && hintNodes.isNotEmpty) {
      final pulsePaint = Paint()
        ..color = hintColor.withValues(alpha: 0.35)
        ..style = PaintingStyle.fill
        ..isAntiAlias = true
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);

      final hintBorderPaint = Paint()
        ..color = hintColor.withValues(alpha: 0.9)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..isAntiAlias = true;

      for (final hintKey in hintNodes) {
        final node = nodes[hintKey]!;
        canvas.drawCircle(Offset(node.x, node.y), 16, pulsePaint);
        canvas.drawCircle(Offset(node.x, node.y), 16, hintBorderPaint);

        final innerGlow = Paint()
          ..color = hintColor.withValues(alpha: 0.6)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
        canvas.drawCircle(Offset(node.x, node.y), 6, innerGlow);
      }
    }

    if (showHints && selectedNode != null) {
      final selectedNode = nodes[this.selectedNode]!;
      final pulsePaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..isAntiAlias = true
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
      canvas.drawCircle(
          Offset(selectedNode.x, selectedNode.y), 26, pulsePaint);

      final outerGlow = Paint()
        ..color = Colors.white.withValues(alpha: 0.2)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
      canvas.drawCircle(
          Offset(selectedNode.x, selectedNode.y), 32, outerGlow);
    }
  }

  @override
  bool shouldRepaint(covariant BoardPainter old) {
    return old.theme != theme ||
        old.showHints != showHints ||
        old.selectedNode != selectedNode ||
        old.hintNodes != hintNodes ||
        old.hintColor != hintColor;
  }
}
