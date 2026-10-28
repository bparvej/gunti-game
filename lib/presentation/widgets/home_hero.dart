import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../../core/constants/strings.dart';
import '../../core/theme/palette.dart';
import '../controllers/app_state.dart';
import 'guti_view.dart';
import 'painters.dart';

// ════════════════════════════════════════════════════════════════
//  Home Hero: 3D board card with animated stars and ribbon banner
// ════════════════════════════════════════════════════════════════

class HomeHero extends StatefulWidget {
  const HomeHero({super.key});

  @override
  State<HomeHero> createState() => _HomeHeroState();
}

class _HomeHeroState extends State<HomeHero>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  late final AnimationController _starCtrl;
  ModalRoute<dynamic>? _observedRoute;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _starCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route != _observedRoute) {
      _removeRouteListeners();
      _observedRoute = route;
      route?.secondaryAnimation?.addStatusListener(_onRouteAnimationStatus);
      route?.animation?.addStatusListener(_onRouteAnimationStatus);
    }
    _updateAnimation();
  }

  void _onRouteAnimationStatus(AnimationStatus status) {
    _updateAnimation();
  }

  void _removeRouteListeners() {
    _observedRoute?.secondaryAnimation
        ?.removeStatusListener(_onRouteAnimationStatus);
    _observedRoute?.animation?.removeStatusListener(_onRouteAnimationStatus);
    _observedRoute = null;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _updateAnimation();
    } else {
      if (_starCtrl.isAnimating) {
        _starCtrl.stop();
      }
    }
  }

  void _updateAnimation() {
    if (!mounted) return;
    final tickerActive = TickerMode.of(context);
    final isCurrent = ModalRoute.of(context)?.isCurrent ?? true;
    final appActive = WidgetsBinding.instance.lifecycleState == null ||
        WidgetsBinding.instance.lifecycleState == AppLifecycleState.resumed;

    if (tickerActive && isCurrent && appActive) {
      if (!_starCtrl.isAnimating) {
        _starCtrl.repeat(reverse: true);
      }
    } else {
      if (_starCtrl.isAnimating) {
        _starCtrl.stop();
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _removeRouteListeners();
    _starCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const ribbon = RibbonColors(
      Color(0xFFFFA000),
      Color(0xFFFF6F00),
      Color(0xFFE65100),
      Color(0xFF8D2E00),
    );

    return Center(
      child: SizedBox(
        width: 250,
        height: 250,
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            // Ambient glow
            Positioned(
              top: 30,
              child: RepaintBoundary(
                child: Container(
                  width: 210,
                  height: 210,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFFB300).withAlpha(70),
                        blurRadius: 40,
                        spreadRadius: 8,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Elevated 3D Board preview card
            Positioned(
              top: 24,
              child: RepaintBoundary(
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0xFFD3CCE8),
                        offset: Offset(0, 10),
                      ),
                      BoxShadow(
                        color: Color(0x33000000),
                        blurRadius: 18,
                        offset: Offset(0, 14),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Stack(
                      children: [
                        // Board lines
                        Positioned.fill(
                          child: RepaintBoundary(
                            child: CustomPaint(
                              isComplex: true,
                              willChange: false,
                              painter: const LinesPainter(
                                14,
                                70,
                                Color(0xFFCBBDF2),
                              ),
                            ),
                          ),
                        ),
                        // Sample guti layout
                        _miniGuti(0, 0, app.playerCoinColor),
                        _miniGuti(2, 0, app.opponentCoinColor),
                        _miniGuti(1, 1, app.playerCoinColor),
                        _miniGuti(2, 1, app.playerCoinColor),
                        _miniGuti(0, 2, app.opponentCoinColor),
                        _miniGuti(1, 2, app.opponentCoinColor),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Animated Stars on top
            RepaintBoundary(
              child: AnimatedBuilder(
                animation: _starCtrl,
                builder: (context, _) {
                  final v = _starCtrl.value;
                  final bob = math.sin(v * math.pi) * 3;
                  return Stack(
                    clipBehavior: Clip.none,
                    alignment: Alignment.center,
                    children: [
                      Positioned(
                        top: -18 - bob * 0.7,
                        left: 36,
                        child: Transform.rotate(
                          angle: -0.22,
                          child: const StarPainterWidget(size: 40),
                        ),
                      ),
                      Positioned(
                        top: -24 - bob,
                        child: const StarPainterWidget(size: 54),
                      ),
                      Positioned(
                        top: -18 - bob * 0.7,
                        right: 36,
                        child: Transform.rotate(
                          angle: 0.22,
                          child: const StarPainterWidget(size: 40),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),

            // 3D Ribbon Banner
            Positioned(
              top: 14,
              child: RepaintBoundary(
                child: SizedBox(
                  width: 250,
                  height: 52,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CustomPaint(
                        size: const Size(250, 52),
                        isComplex: true,
                        willChange: false,
                        painter: const RibbonPainter(ribbon),
                      ),
                      Positioned(
                        top: 7,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              tr('tagline').toUpperCase(),
                              style: TextStyle(
                                color: fade(Colors.white, .88),
                                fontSize: 9,
                                letterSpacing: 1.4,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              child: outlinedText(
                                tr('appName').toUpperCase(),
                                23,
                                Colors.white,
                                ribbon.outline,
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
          ],
        ),
      ),
    );
  }

  Widget _miniGuti(int col, int row, Color color) {
    const pad = 14.0;
    const step = (200 - 32 - 28) / 2;
    const d = 34.0;
    final x = pad + col * step - d / 2;
    final y = pad + row * step - d / 2;

    return Positioned(
      left: x,
      top: y,
      width: d,
      height: d,
      child: Guti(
        color: color,
        size: d,
        shape: app.shape,
      ),
    );
  }
}

class StarPainterWidget extends StatelessWidget {
  final double size;
  const StarPainterWidget({super.key, required this.size});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      isComplex: true,
      willChange: false,
      painter: const StarPainter(lit: true),
    );
  }
}

