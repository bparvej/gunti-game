import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../../core/theme/palette.dart';
import '../../domain/game/game_enums.dart';
import '../controllers/app_state.dart';

class Guti extends StatelessWidget {
  final Color color;
  final double size;
  final bool ring;
  final Color? ringColor;
  final GutiShape? shape;
  const Guti({
    super.key,
    required this.color,
    this.size = 52,
    this.ring = false,
    this.ringColor,
    this.shape,
  });

  @override
  Widget build(BuildContext context) => CustomPaint(
        size: Size(size, size),
        isComplex: true,
        willChange: false,
        painter: GutiPainter(
            color, ring, ringColor ?? Pal.green, shape ?? app.shape),
      );
}

/// Glossy 3D piece – same treatment as the popup stars: dark outline,
/// thickness edge, shaded face, engraved detail and gloss.
class GutiPainter extends CustomPainter {
  final Color base;
  final bool ring;
  final Color ringColor;
  final GutiShape shape;

  final Color _edge;
  final Color _side;
  final Color _faceLight;
  final Color _faceDark;
  final Color _faceDarker;
  final Color _broomDark;
  final Color _broomLight;
  final Color _broomDarker;
  final Color _capLight;
  final Color _capMid;

  static final Paint _fillPaint = Paint();
  static final Paint _strokePaint = Paint()..style = PaintingStyle.stroke;
  static final Paint _shadowPaint = Paint();

  GutiPainter(this.base, this.ring, this.ringColor, this.shape)
      : _edge = Color.lerp(base, Colors.black, .5)!,
        _side = Color.lerp(base, Colors.black, .3)!,
        _faceLight = Color.lerp(base, Colors.white, .55)!,
        _faceDark = Color.lerp(base, Colors.black, .22)!,
        _faceDarker = Color.lerp(base, Colors.black, .35)!,
        _broomDark = Color.lerp(base, Colors.black, .28)!,
        _broomLight = Color.lerp(base, Colors.white, .45)!,
        _broomDarker = Color.lerp(base, Colors.black, .32)!,
        _capLight = Color.lerp(base, Colors.white, .7)!,
        _capMid = Color.lerp(base, Colors.white, .25)!;

  @override
  void paint(Canvas canvas, Size size) {
    switch (shape) {
      case GutiShape.round:
        _round(canvas, size);
        break;
      case GutiShape.square:
        _square(canvas, size);
        break;
      case GutiShape.broom:
        _broom(canvas, size);
        break;
    }
  }

  void _shadow(Canvas canvas, double s, double width) {
    _shadowPaint
      ..shader = null
      ..color = const Color(0x4D000000)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, s * .04);
    canvas.drawOval(
      Rect.fromCenter(
          center: Offset(s / 2, s * .93), width: width, height: s * .13),
      _shadowPaint,
    );
  }

  // ───────── round ─────────
  void _round(Canvas canvas, Size size) {
    final s = size.width;
    final c = Offset(s / 2, s * .44);
    final r = s * .37;
    final depth = s * .11;
    final lw = s * .035;

    _shadow(canvas, s, s * .76);

    if (ring) {
      final rc = c.translate(0, depth * .5);
      _shadowPaint
        ..shader = null
        ..color = fade(ringColor, .38)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, s * .06);
      canvas.drawCircle(rc, r + s * .11, _shadowPaint);

      _strokePaint
        ..shader = null
        ..maskFilter = null
        ..strokeCap = StrokeCap.butt
        ..strokeJoin = StrokeJoin.miter
        ..strokeWidth = math.max(2.5, s * .07)
        ..color = ringColor;
      canvas.drawCircle(rc, r + s * .085, _strokePaint);
    }

    final low = c.translate(0, depth);
    _fillPaint
      ..shader = null
      ..maskFilter = null
      ..color = _edge;
    canvas.drawCircle(low, r + lw, _fillPaint);
    canvas.drawRect(
        Rect.fromLTRB(c.dx - r - lw, c.dy, c.dx + r + lw, c.dy + depth),
        _fillPaint);

    _fillPaint.color = _side;
    canvas.drawCircle(low, r, _fillPaint);
    canvas.drawRect(Rect.fromLTRB(c.dx - r, c.dy, c.dx + r, c.dy + depth),
        _fillPaint);

    _fillPaint.color = _edge;
    canvas.drawCircle(c, r + lw, _fillPaint);

    final rect = Rect.fromCircle(center: c, radius: r);
    _fillPaint.shader = RadialGradient(
      center: const Alignment(-.35, -.45),
      radius: 1.0,
      colors: [
        _faceLight,
        base,
        _faceDark,
      ],
      stops: const [0, .55, 1],
    ).createShader(rect);
    canvas.drawCircle(c, r, _fillPaint);
    _fillPaint.shader = null;

    _strokePaint
      ..shader = null
      ..maskFilter = null
      ..strokeCap = StrokeCap.butt
      ..strokeJoin = StrokeJoin.miter
      ..strokeWidth = r * .13
      ..color = fade(_faceDarker, .55);
    canvas.drawCircle(c, r * .64, _strokePaint);

    _strokePaint
      ..strokeWidth = r * .06
      ..strokeCap = StrokeCap.round
      ..color = const Color(0x80FFFFFF);
    canvas.drawArc(
      Rect.fromCircle(center: c, radius: r * .64),
      math.pi * 1.05,
      math.pi * .55,
      false,
      _strokePaint,
    );

    _fillPaint.color = const Color(0x9EFFFFFF);
    canvas.save();
    canvas.translate(c.dx - r * .40, c.dy - r * .52);
    canvas.rotate(-.6);
    canvas.drawOval(
      Rect.fromCenter(center: Offset.zero, width: r * .55, height: r * .26),
      _fillPaint,
    );
    canvas.restore();
  }

  // ───────── square ─────────
  void _square(Canvas canvas, Size size) {
    final s = size.width;
    final c = Offset(s / 2, s * .44);
    final h = s * .34;
    final depth = s * .11;
    final lw = s * .035;
    final rad = s * .16;

    RRect rr(Offset o, double inflate) => RRect.fromRectAndRadius(
        Rect.fromCenter(
            center: o, width: 2 * (h + inflate), height: 2 * (h + inflate)),
        Radius.circular(rad + inflate));

    _shadow(canvas, s, s * .78);

    if (ring) {
      final rc = c.translate(0, depth * .5);
      _shadowPaint
        ..shader = null
        ..color = fade(ringColor, .38)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, s * .06);
      canvas.drawRRect(rr(rc, s * .11), _shadowPaint);

      _strokePaint
        ..shader = null
        ..maskFilter = null
        ..strokeCap = StrokeCap.butt
        ..strokeJoin = StrokeJoin.miter
        ..strokeWidth = math.max(2.5, s * .07)
        ..color = ringColor;
      canvas.drawRRect(rr(rc, s * .085), _strokePaint);
    }

    final low = c.translate(0, depth);
    _fillPaint
      ..shader = null
      ..maskFilter = null
      ..color = _edge;
    canvas.drawRRect(rr(low, lw), _fillPaint);
    canvas.drawRect(
        Rect.fromLTRB(c.dx - h - lw, c.dy, c.dx + h + lw, c.dy + depth),
        _fillPaint);

    _fillPaint.color = _side;
    canvas.drawRRect(rr(low, 0), _fillPaint);
    canvas.drawRect(Rect.fromLTRB(c.dx - h, c.dy, c.dx + h, c.dy + depth),
        _fillPaint);

    _fillPaint.color = _edge;
    canvas.drawRRect(rr(c, lw), _fillPaint);

    _fillPaint.shader = RadialGradient(
      center: const Alignment(-.4, -.5),
      radius: 1.15,
      colors: [
        _faceLight,
        base,
        _faceDark,
      ],
      stops: const [0, .55, 1],
    ).createShader(Rect.fromCenter(center: c, width: 2 * h, height: 2 * h));
    canvas.drawRRect(rr(c, 0), _fillPaint);
    _fillPaint.shader = null;

    // engraved inner square
    final inner = RRect.fromRectAndRadius(
        Rect.fromCenter(center: c, width: h * 1.28, height: h * 1.28),
        Radius.circular(rad * .6));
    _strokePaint
      ..shader = null
      ..maskFilter = null
      ..strokeCap = StrokeCap.butt
      ..strokeJoin = StrokeJoin.miter
      ..strokeWidth = h * .13
      ..color = fade(_faceDarker, .55);
    canvas.drawRRect(inner, _strokePaint);

    // rim shine along the top-left
    _strokePaint
      ..strokeWidth = h * .06
      ..strokeCap = StrokeCap.round
      ..color = const Color(0x80FFFFFF);
    canvas.drawPath(
      Path()
        ..moveTo(c.dx - h * .62, c.dy + h * .1)
        ..lineTo(c.dx - h * .62, c.dy - h * .50)
        ..quadraticBezierTo(
            c.dx - h * .62, c.dy - h * .62, c.dx - h * .50, c.dy - h * .62)
        ..lineTo(c.dx + h * .1, c.dy - h * .62),
      _strokePaint,
    );

    _fillPaint.color = const Color(0x9EFFFFFF);
    canvas.save();
    canvas.translate(c.dx - h * .45, c.dy - h * .62);
    canvas.rotate(-.35);
    canvas.drawOval(
      Rect.fromCenter(center: Offset.zero, width: h * .6, height: h * .26),
      _fillPaint,
    );
    canvas.restore();
  }

  // ───────── broom stick (ঝাড়ুর কাঠি) ─────────
  void _broom(Canvas canvas, Size size) {
    final s = size.width;
    final cx = s / 2;
    final w = s * .34;
    final topY = s * .20;
    final botY = s * .80;
    final capH = w * .46;
    final lw = s * .03;

    _shadow(canvas, s, w * 2.0);

    if (ring) {
      final rect = Rect.fromCenter(
          center: Offset(cx, botY), width: w * 2.5, height: capH * 2.2);
      _shadowPaint
        ..shader = null
        ..color = fade(ringColor, .38)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, s * .06);
      canvas.drawOval(rect, _shadowPaint);

      _strokePaint
        ..shader = null
        ..maskFilter = null
        ..strokeCap = StrokeCap.butt
        ..strokeJoin = StrokeJoin.miter
        ..strokeWidth = math.max(2.5, s * .07)
        ..color = ringColor;
      canvas.drawOval(rect, _strokePaint);
    }

    final body = Path()
      ..moveTo(cx - w / 2, topY)
      ..lineTo(cx - w / 2, botY)
      ..arcTo(
          Rect.fromCenter(center: Offset(cx, botY), width: w, height: capH),
          math.pi,
          -math.pi,
          false)
      ..lineTo(cx + w / 2, topY)
      ..close();

    // outline
    _strokePaint
      ..shader = null
      ..maskFilter = null
      ..strokeWidth = lw * 2
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.butt
      ..color = _edge;
    canvas.drawPath(body, _strokePaint);

    // cylinder shading
    final bodyRect =
        Rect.fromLTRB(cx - w / 2, topY, cx + w / 2, botY + capH / 2);
    _fillPaint
      ..maskFilter = null
      ..shader = LinearGradient(
        colors: [
          _broomDark,
          _broomLight,
          base,
          _broomDarker,
        ],
        stops: const [0, .28, .62, 1],
      ).createShader(bodyRect);
    canvas.drawPath(body, _fillPaint);
    _fillPaint.shader = null;

    // straw-binding bands
    _strokePaint
      ..shader = null
      ..maskFilter = null
      ..strokeWidth = s * .035
      ..strokeCap = StrokeCap.butt
      ..strokeJoin = StrokeJoin.miter
      ..color = const Color(0x4D000000);
    for (final f in [.30, .62]) {
      final y = topY + (botY - topY) * f;
      canvas.drawArc(
          Rect.fromCenter(center: Offset(cx, y), width: w, height: capH),
          0,
          math.pi,
          false,
          _strokePaint);
    }

    // vertical shine
    _fillPaint.color = const Color(0x61FFFFFF);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          Rect.fromLTWH(cx - w * .32, topY + capH * .5, w * .11,
              (botY - topY) * .62),
          Radius.circular(w)),
      _fillPaint,
    );

    // top cap
    final cap =
        Rect.fromCenter(center: Offset(cx, topY), width: w, height: capH);
    _fillPaint.color = _edge;
    canvas.drawOval(cap.inflate(lw), _fillPaint);

    _fillPaint.shader = RadialGradient(
      center: const Alignment(-.3, -.4),
      colors: [
        _capLight,
        _capMid,
      ],
    ).createShader(cap);
    canvas.drawOval(cap, _fillPaint);
    _fillPaint.shader = null;

    _fillPaint.color = const Color(0x99FFFFFF);
    canvas.drawOval(
      Rect.fromCenter(
          center: Offset(cx - w * .12, topY - capH * .1),
          width: w * .35,
          height: capH * .3),
      _fillPaint,
    );
  }

  @override
  bool shouldRepaint(covariant GutiPainter old) =>
      old.base != base ||
      old.ring != ring ||
      old.ringColor != ringColor ||
      old.shape != shape;
}

