import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimens.dart';
import '../../domain/models/game_models.dart';

/// Paints the Guti board, guti pieces, selection highlight and move hints
/// in a 600x600 logical space.
class BoardPainter extends CustomPainter {
  final Map<String, String?> occupied;
  final String? selectedNode;
  final List<String> availableTargets;
  final GutuShape gutiShape;
  final Color boardLineColor;
  final Color redColor;
  final Color blueColor;
  final Color hintColor;

  const BoardPainter({
    required this.occupied,
    required this.selectedNode,
    required this.availableTargets,
    required this.gutiShape,
    required this.boardLineColor,
    required this.redColor,
    required this.blueColor,
    required this.hintColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / AppDimens.boardSize;
    canvas.scale(scale, scale);

    _drawBoardLines(canvas);
    _drawMoveHints(canvas);
    _drawGutis(canvas);
    _drawSelectionHighlight(canvas);
  }

  void _drawBoardLines(Canvas canvas) {
    final linePaint = Paint()
      ..color = boardLineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    final outer = Offset(100, 100);
    final outerSize = 400.0;

    final rect = Rect.fromLTWH(outer.dx, outer.dy, outerSize, outerSize);
    canvas.drawRect(rect, linePaint);

    canvas.drawLine(const Offset(300, 100), const Offset(300, 500), linePaint);
    canvas.drawLine(const Offset(100, 300), const Offset(500, 300), linePaint);
    canvas.drawLine(const Offset(100, 100), const Offset(500, 500), linePaint);
    canvas.drawLine(const Offset(100, 500), const Offset(500, 100), linePaint);

    final dotPaint = Paint()
      ..color = boardLineColor
      ..style = PaintingStyle.fill;

    for (final node in boardNodes.values) {
      canvas.drawCircle(Offset(node.x, node.y), 8, dotPaint);
    }
  }

  void _drawMoveHints(Canvas canvas) {
    final hintPaint = Paint()
      ..color = hintColor
      ..style = PaintingStyle.fill;

    for (final key in availableTargets) {
      final node = boardNodes[key];
      if (node == null) continue;
      canvas.drawCircle(Offset(node.x, node.y), 12, hintPaint);
    }
  }

  void _drawGutis(Canvas canvas) {
    for (final entry in occupied.entries) {
      final key = entry.key;
      final owner = entry.value;
      if (owner == null) continue;

      final node = boardNodes[key];
      if (node == null) continue;

      final color = owner == 'red' ? redColor : blueColor;
      _drawGuti(canvas, node.x, node.y, color);
    }
  }

  void _drawGuti(Canvas canvas, double x, double y, Color color) {
    final center = Offset(x, y);

    switch (gutiShape) {
      case GutuShape.circle:
        canvas.drawCircle(center, 14, Paint()..color = color);
      case GutuShape.square:
        final rect = Rect.fromCenter(center: center, width: 28, height: 28);
        canvas.drawRect(rect, Paint()..color = color);
      case GutuShape.bar:
        final rect = Rect.fromCenter(center: center, width: 10, height: 36);
        canvas.drawRect(rect, Paint()..color = color);
      case GutuShape.lalBadshah:
        canvas.drawCircle(center, 14, Paint()..color = color);
        final textPainter = TextPainter(
          text: const TextSpan(
            text: '♛',
            style: TextStyle(
              fontSize: 18,
              color: AppColors.white,
            ),
          ),
          textDirection: TextDirection.ltr,
          textAlign: TextAlign.center,
        )..layout();
        textPainter.paint(
          canvas,
          center - Offset(textPainter.width / 2, textPainter.height / 2),
        );
    }
  }

  void _drawSelectionHighlight(Canvas canvas) {
    final node = selectedNode == null ? null : boardNodes[selectedNode];
    if (node == null) return;

    final highlightPaint = Paint()
      ..color = AppColors.green
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    switch (gutiShape) {
      case GutuShape.circle:
      case GutuShape.lalBadshah:
        canvas.drawCircle(Offset(node.x, node.y), 17, highlightPaint);
      case GutuShape.square:
        final rect = Rect.fromCenter(center: Offset(node.x, node.y), width: 33, height: 33);
        canvas.drawRect(rect, highlightPaint);
      case GutuShape.bar:
        final rect = Rect.fromCenter(center: Offset(node.x, node.y), width: 15, height: 41);
        canvas.drawRect(rect, highlightPaint);
    }
  }

  @override
  bool shouldRepaint(covariant BoardPainter oldDelegate) {
    return oldDelegate.occupied != occupied ||
        oldDelegate.selectedNode != selectedNode ||
        oldDelegate.availableTargets != availableTargets ||
        oldDelegate.gutiShape != gutiShape ||
        oldDelegate.boardLineColor != boardLineColor ||
        oldDelegate.redColor != redColor ||
        oldDelegate.blueColor != blueColor ||
        oldDelegate.hintColor != hintColor;
  }
}
