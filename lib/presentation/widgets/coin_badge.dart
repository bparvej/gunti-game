import 'package:flutter/material.dart';
import '../../core/theme/palette.dart';
import '../controllers/app_state.dart';

/// Three stacked gold coins, painted in code.
class CoinStack extends StatelessWidget {
  final double width;
  const CoinStack({super.key, this.width = 46});

  @override
  Widget build(BuildContext context) => CustomPaint(
        size: Size(width, width * .8),
        painter: _CoinPainter(),
      );
}

class _CoinPainter extends CustomPainter {
  void _coin(Canvas canvas, Offset c, double r) {
    // edge
    canvas.drawCircle(
        c.translate(0, r * .28), r, Paint()..color = const Color(0xFFD9780A));
    // face
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..shader = const RadialGradient(
          center: Alignment(-.3, -.4),
          colors: [Color(0xFFFFF0A0), Color(0xFFFFC53D), Color(0xFFF59E0B)],
          stops: [0, .5, 1],
        ).createShader(Rect.fromCircle(center: c, radius: r)),
    );
    canvas.drawCircle(
      c,
      r * .66,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = r * .16
        ..color = const Color(0xFFE59A0C),
    );
  }

  @override
  void paint(Canvas canvas, Size size) {
    final r = size.width * .25;
    _coin(canvas, Offset(size.width * .30, size.height * .70), r);
    _coin(canvas, Offset(size.width * .70, size.height * .70), r);
    _coin(canvas, Offset(size.width * .50, size.height * .36), r);
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

/// 3D Coin Badge (tappable to open Leaderboard)
class CoinBadge extends StatelessWidget {
  final int points;
  final VoidCallback? onTap;

  const CoinBadge({
    super.key,
    required this.points,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Widget content = Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFFFD54F), Color(0xFFFFA000)],
        ),
        boxShadow: const [
          BoxShadow(color: Color(0xFFC57A0A), offset: Offset(0, 3.5)),
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 6,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CoinStack(width: 26),
          const SizedBox(width: 5),
          Text(
            fmtNum(points),
            style: const TextStyle(
              color: Color(0xFF5D3600),
              fontSize: 14,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );

    if (onTap != null) {
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          app.haptic();
          onTap!();
        },
        child: content,
      );
    }
    return content;
  }
}

