import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../../core/constants/strings.dart';
import '../../core/theme/palette.dart';

void toast(BuildContext context, String msg) {
  final m = ScaffoldMessenger.maybeOf(context);
  m?.hideCurrentSnackBar();
  m?.showSnackBar(SnackBar(
    content: Text(msg),
    behavior: SnackBarBehavior.floating,
    duration: const Duration(milliseconds: 1600),
  ));
}

/// White text with a thick coloured outline (ribbon titles).
Widget outlinedText(String t, double size, Color fill, Color stroke) {
  final base = TextStyle(
      fontSize: size, fontWeight: FontWeight.w900, letterSpacing: 1.2);
  return Stack(
    children: [
      Text(t,
          style: base.copyWith(
              foreground: Paint()
                ..style = PaintingStyle.stroke
                ..strokeWidth = 5
                ..strokeJoin = StrokeJoin.round
                ..color = stroke)),
      Text(t, style: base.copyWith(color: fill)),
    ],
  );
}

class LockBadge extends StatelessWidget {
  final int level;
  const LockBadge(this.level, {super.key});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: fade(Colors.black, .62),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.lock_rounded, size: 11, color: Colors.white),
            const SizedBox(width: 3),
            Text(tr('lvN', {'n': '$level'}),
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w800)),
          ],
        ),
      );
}

class RaysPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    const radius = 300.0;
    final paint = Paint()
      ..shader = RadialGradient(
        colors: [fade(Colors.white, .30), fade(Colors.white, 0)],
      ).createShader(Rect.fromCircle(center: c, radius: radius));
    const n = 14;
    for (var i = 0; i < n; i++) {
      final a0 = (i * 2 * math.pi) / n;
      final a1 = a0 + math.pi / n;
      final path = Path()
        ..moveTo(c.dx, c.dy)
        ..lineTo(c.dx + radius * math.cos(a0), c.dy + radius * math.sin(a0))
        ..lineTo(c.dx + radius * math.cos(a1), c.dy + radius * math.sin(a1))
        ..close();
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

class StarPainter extends CustomPainter {
  final bool lit;
  const StarPainter({required this.lit});

  Path _star(Size s) {
    final c = Offset(s.width / 2, s.height / 2 + s.height * .03);
    final outer = s.width * .40;
    final inner = outer * .52;
    final path = Path();
    for (var i = 0; i < 10; i++) {
      final rad = i.isEven ? outer : inner;
      final ang = -math.pi / 2 + i * math.pi / 5;
      final p = Offset(c.dx + rad * math.cos(ang), c.dy + rad * math.sin(ang));
      if (i == 0) {
        path.moveTo(p.dx, p.dy);
      } else {
        path.lineTo(p.dx, p.dy);
      }
    }
    return path..close();
  }

  @override
  void paint(Canvas canvas, Size size) {
    final path = _star(size);
    final top = lit ? const Color(0xFFFFE66D) : const Color(0xFFC9C4DD);
    final bottom = lit ? const Color(0xFFFFA726) : const Color(0xFF9A94B8);
    final edge = lit ? const Color(0xFFE5860A) : const Color(0xFF7D77A0);
    final w = size.width * .12;

    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = w + 5
        ..strokeJoin = StrokeJoin.round
        ..color = edge,
    );
    final shader = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [top, bottom],
    ).createShader(Offset.zero & size);
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = w
        ..strokeJoin = StrokeJoin.round
        ..shader = shader,
    );
    canvas.drawPath(path, Paint()..shader = shader);
    // gloss
    canvas.drawOval(
      Rect.fromCenter(
          center: Offset(size.width * .40, size.height * .30),
          width: size.width * .16,
          height: size.height * .09),
      Paint()..color = fade(Colors.white, lit ? .55 : .3),
    );
  }

  @override
  bool shouldRepaint(covariant StarPainter old) => old.lit != lit;
}

class RibbonPainter extends CustomPainter {
  final RibbonColors col;
  const RibbonPainter(this.col);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final tail = Paint()..color = col.tail;

    // left tail (swallow-tail notch)
    canvas.drawPath(
      Path()
        ..moveTo(4, 16)
        ..lineTo(60, 16)
        ..lineTo(60, 74)
        ..lineTo(4, 74)
        ..lineTo(18, 45)
        ..close(),
      tail,
    );
    // right tail
    canvas.drawPath(
      Path()
        ..moveTo(w - 4, 16)
        ..lineTo(w - 60, 16)
        ..lineTo(w - 60, 74)
        ..lineTo(w - 4, 74)
        ..lineTo(w - 18, 45)
        ..close(),
      tail,
    );
    // folds
    final fold = Paint()..color = Color.lerp(col.tail, Colors.black, .25)!;
    canvas.drawPath(
      Path()
        ..moveTo(34, 62)
        ..lineTo(60, 62)
        ..lineTo(60, 74)
        ..close(),
      fold,
    );
    canvas.drawPath(
      Path()
        ..moveTo(w - 34, 62)
        ..lineTo(w - 60, 62)
        ..lineTo(w - 60, 74)
        ..close(),
      fold,
    );

    // main banner
    final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(34, 0, w - 68, 62), const Radius.circular(14));
    canvas.drawRRect(
      rect.shift(const Offset(0, 4)),
      Paint()..color = col.tail,
    );
    canvas.drawRRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [col.top, col.bottom],
        ).createShader(rect.outerRect),
    );
    // gloss
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          Rect.fromLTWH(40, 4, w - 80, 20), const Radius.circular(10)),
      Paint()..color = fade(Colors.white, .22),
    );
  }

  @override
  bool shouldRepaint(covariant RibbonPainter old) => old.col != col;
}

/// Circular countdown shown on the active player's row.
/// Turns orange/red in the last 5 seconds before auto mode starts.
class IdleRing extends StatelessWidget {
  final int left, total;
  const IdleRing({super.key, required this.left, required this.total});

  @override
  Widget build(BuildContext context) {
    final urgent = left <= 5;
    final color = urgent ? const Color(0xFFFF7043) : Pal.greenDark;
    return SizedBox(
      width: 30,
      height: 30,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 30,
            height: 30,
            child: CircularProgressIndicator(
              value: (left / total).clamp(0.0, 1.0).toDouble(),
              strokeWidth: 3.5,
              color: color,
              backgroundColor: pal.border,
            ),
          ),
          Text('$left',
              style: TextStyle(
                  color: urgent ? color : pal.text,
                  fontSize: 11,
                  fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }
}

class LinesPainter extends CustomPainter {
  final double pad, step;
  final Color color;
  const LinesPainter(this.pad, this.step, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = color
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;
    final a = pad, m = pad + step, z = pad + 2 * step;
    // rows & columns
    for (final v in [a, m, z]) {
      canvas.drawLine(Offset(a, v), Offset(z, v), p);
      canvas.drawLine(Offset(v, a), Offset(v, z), p);
    }
    // diagonals
    canvas.drawLine(Offset(a, a), Offset(z, z), p);
    canvas.drawLine(Offset(z, a), Offset(a, z), p);
  }

  @override
  bool shouldRepaint(covariant LinesPainter old) =>
      old.color != color || old.pad != pad || old.step != step;
}


