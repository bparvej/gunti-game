import 'package:flutter/material.dart';

enum BackgroundType {
  teakwood,
  velvet,
  greenmat,
  night,
  marble,
  dino,
}

class BackgroundPainter extends CustomPainter {
  final BackgroundType type;

  BackgroundPainter({required this.type});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    switch (type) {
      case BackgroundType.teakwood:
        _paintTeakwood(canvas, w, h);
      case BackgroundType.velvet:
        _paintVelvet(canvas, w, h);
      case BackgroundType.greenmat:
        _paintGreenMat(canvas, w, h);
      case BackgroundType.night:
        _paintNight(canvas, w, h);
      case BackgroundType.marble:
        _paintMarble(canvas, w, h);
      case BackgroundType.dino:
        _paintDino(canvas, w, h);
    }
  }

  void _paintTeakwood(Canvas canvas, double w, double h) {
    final paint = Paint();
    paint.color = const Color(0xFF9B7359);
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), paint);

    paint.color = const Color(0xFFA67B61).withValues(alpha: 0.35);
    for (int i = 0; i < h.toInt(); i += 45) {
      canvas.drawRect(
          Rect.fromLTWH(0, (i + 8).toDouble(), w, 12), paint);
    }

    paint.color = const Color(0xFF7C5A3C).withValues(alpha: 0.5);
    paint.strokeCap = StrokeCap.round;
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 1.5;
    for (int i = 0; i < 26; i++) {
      final y = i * 24.0;
      final path = Path()
        ..moveTo(0, y)
        ..lineTo(150, y + 6)
        ..lineTo(300, y - 2)
        ..lineTo(450, y - 2)
        ..lineTo(600, y + 4);
      canvas.drawPath(path, paint);
    }

    paint.style = PaintingStyle.fill;
    paint.color = const Color(0xFF7C5A3C).withValues(alpha: 0.3);
    canvas.drawCircle(const Offset(40, 40), 30, paint);
    canvas.drawCircle(Offset(w - 40, 40), 30, paint);
    canvas.drawCircle(Offset(40, h - 40), 30, paint);
    canvas.drawCircle(Offset(w - 40, h - 40), 30, paint);
  }

  void _paintVelvet(Canvas canvas, double w, double h) {
    final paint = Paint();
    paint.color = const Color(0xFFB22222);
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), paint);

    paint.color = const Color(0xFF8B0000).withValues(alpha: 0.5);
    canvas.drawCircle(Offset(w / 2, h / 2), 340, paint);

    paint.color = const Color(0xFFDC143C).withValues(alpha: 0.3);
    canvas.drawCircle(Offset(w / 2, h / 2), 230, paint);

    paint.color = const Color(0xFFB22222).withValues(alpha: 0.2);
    canvas.drawCircle(Offset(w / 2, h / 2), 140, paint);

    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 6;
    paint.color = Colors.green;
    canvas.drawRect(Rect.fromLTWH(12, 12, w - 24, h - 24), paint);

    paint.strokeWidth = 2;
    paint.color = Colors.green.withValues(alpha: 0.7);
    canvas.drawRect(Rect.fromLTWH(28, 28, w - 56, h - 56), paint);

    paint.style = PaintingStyle.fill;
    paint.color = Colors.green;
    for (final pos in [
      const Offset(36, 36),
      Offset(w - 36, 36),
      Offset(36, h - 36),
      Offset(w - 36, h - 36),
    ]) {
      canvas.drawCircle(pos, 8, paint);
    }
  }

  void _paintGreenMat(Canvas canvas, double w, double h) {
    final paint = Paint();
    paint.color = const Color(0xFF006400);
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), paint);

    paint.color = const Color(0xFF228B22).withValues(alpha: 0.45);
    paint.strokeCap = StrokeCap.round;
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 3;
    for (double i = 0; i < w; i += 28) {
      canvas.drawLine(Offset(i, 0), Offset(i, h), paint);
    }
    paint.color = const Color(0xFF32CD32).withValues(alpha: 0.35);
    for (double i = 0; i < h; i += 28) {
      canvas.drawLine(Offset(0, i), Offset(w, i), paint);
    }

    paint.style = PaintingStyle.fill;
    paint.color = const Color(0xFF8B4513).withValues(alpha: 0.18);
    canvas.drawRect(Rect.fromLTWH(0, h - 100, w, 100), paint);

    paint.color = const Color(0xFF228B22).withValues(alpha: 0.5);
    final rnd = _SimpleRandom();
    for (int i = 0; i < 24; i++) {
      final x = rnd.nextDouble() * (w - 20) + 10;
      final y = rnd.nextDouble() * (h - 120) + 10;
      final path = Path()
        ..addOval(Rect.fromLTWH(x - 10, y - 5, 20, 10));
      canvas.drawPath(path, paint);
    }
  }

  void _paintNight(Canvas canvas, double w, double h) {
    final paint = Paint();
    paint.color = const Color(0xFF001122);
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), paint);

    paint.color = const Color(0xFF003366).withValues(alpha: 0.4);
    canvas.drawCircle(Offset(w * 0.7, h * 0.2), 180, paint);

    paint.color = const Color(0xFF0066CC).withValues(alpha: 0.3);
    canvas.drawCircle(Offset(w * 0.7, h * 0.2), 120, paint);

    paint.color = Colors.white;
    final rnd = _SimpleRandom();
    for (int i = 0; i < 130; i++) {
      final x = rnd.nextDouble() * w;
      final y = rnd.nextDouble() * (h * 0.8);
      final r = rnd.nextDouble() * 1.6 + 0.5;
      canvas.drawCircle(Offset(x, y), r, paint);
    }

    paint.color = const Color(0xFFFFD700);
    canvas.drawCircle(Offset(w * 0.7, h * 0.2), 40, paint);

    paint.color = const Color(0xFF0066CC).withValues(alpha: 0.7);
    canvas.drawCircle(Offset(w * 0.7 - 10, h * 0.2 - 10), 8, paint);
    canvas.drawCircle(Offset(w * 0.7 + 4, h * 0.2 - 10), 6, paint);

    paint.color = const Color(0xFF003366);
    final treeTop1 = Path()
      ..moveTo(0, h)
      ..lineTo(120, h * 0.72)
      ..lineTo(260, h)
      ..close();
    canvas.drawPath(treeTop1, paint);

    final treeTop2 = Path()
      ..moveTo(200, h)
      ..lineTo(360, h * 0.72)
      ..lineTo(520, h)
      ..close();
    canvas.drawPath(treeTop2, paint);

    final treeTop3 = Path()
      ..moveTo(420, h)
      ..lineTo(540, h * 0.72)
      ..lineTo(600, h)
      ..close();
    canvas.drawPath(treeTop3, paint);

    paint.color = const Color(0xFF006400);
    canvas.drawRect(
        Rect.fromLTWH(0, h * 0.78, w, h * 0.22), paint);
  }

  void _paintMarble(Canvas canvas, double w, double h) {
    final paint = Paint();
    paint.color = const Color(0xFFD2B48C);
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), paint);

    paint.color = const Color(0xFFA0522D).withValues(alpha: 0.5);
    paint.strokeCap = StrokeCap.round;
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 1.5;
    final rnd = _SimpleRandom();
    for (int i = 0; i < 30; i++) {
      final y = rnd.nextDouble() * h;
      final path = Path()
        ..moveTo(0, y)
        ..lineTo(150, y + 8)
        ..lineTo(300, y - 6)
        ..lineTo(450, y + 8)
        ..lineTo(600, y - 4);
      canvas.drawPath(path, paint);
    }

    paint.style = PaintingStyle.fill;
    paint.color = const Color(0xFFBC8B5A).withValues(alpha: 0.5);
    for (int i = 0; i < 12; i++) {
      final x = rnd.nextDouble() * (w - 80) + 40;
      final y = rnd.nextDouble() * (h - 80) + 40;
      final ew = 80 + rnd.nextDouble() * 80;
      final eh = 50 + rnd.nextDouble() * 50;
      final path = Path()..addOval(Rect.fromLTWH(x, y, ew, eh));
      canvas.drawPath(path, paint);
    }

    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 3;
    paint.color = const Color(0xFF8B4513).withValues(alpha: 0.4);
    canvas.drawRect(Rect.fromLTWH(8, 8, w - 16, h - 16), paint);
  }

  void _paintDino(Canvas canvas, double w, double h) {
    final paint = Paint();
    paint.color = const Color(0xFF8FBC8F);
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), paint);

    paint.color = const Color(0xFF0000FF);
    canvas.drawCircle(Offset(w * 0.88, h * 0.12), 40, paint);

    paint.color = Colors.white;
    canvas.drawOval(
        Rect.fromLTWH(50, 50, 120, 42), paint);
    canvas.drawOval(
        Rect.fromLTWH(80, 50, 80, 36), paint);

    paint.color = const Color(0xFF8FBC8F);
    canvas.drawOval(
        Rect.fromLTWH(100, 60, 60, 50), paint);

    paint.color = Colors.white;
    canvas.drawOval(
        Rect.fromLTWH(200, 70, 120, 36), paint);

    paint.color = Colors.black;
    canvas.drawCircle(Offset(w * 0.88, h * 0.12 - 10), 8, paint);

    paint.color = const Color(0xFF8B4513);
    canvas.drawRect(
        Rect.fromLTWH(0, h * 0.83, w, h * 0.17), paint);

    paint.color = const Color(0xFF006400);
    final trees = [
      [0.0, 120.0, 200.0, 290.0],
      [200.0, 360.0, 520.0, 400.0],
    ];
    for (final tree in trees) {
      final path = Path()
        ..moveTo(tree[0], h)
        ..lineTo(tree[1], tree[2])
        ..lineTo(tree[3], h)
        ..close();
      canvas.drawPath(path, paint);
    }

    paint.color = Colors.white;
    paint.style = PaintingStyle.fill;
    for (final pos in [
      const Offset(90, 500),
      Offset(w - 100, 520),
      Offset(w / 2, 540),
    ]) {
      canvas.drawCircle(pos, 3.5, paint);
    }
  }

  @override
  bool shouldRepaint(covariant BackgroundPainter old) => old.type != type;
}

class _SimpleRandom {
  int _seed = 12345;

  double nextDouble() {
    _seed = (_seed * 1103515245 + 12345) & 0x7FFFFFFF;
    return _seed / 0x7FFFFFFF;
  }
}
