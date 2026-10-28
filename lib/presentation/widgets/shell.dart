import 'package:flutter/material.dart';

import '../../core/theme/palette.dart';
import '../controllers/app_state.dart';
import '../screens/home_page.dart';
import 'gradient_bg.dart';

// ════════════════════════════════════════════════════════════════
//  Shell: App scaffold wrapper with gradient background & SafeArea
// ════════════════════════════════════════════════════════════════

class Shell extends StatelessWidget {
  final Widget? child;

  const Shell({super.key, this.child});

  @override
  Widget build(BuildContext context) {
    return appBuilder((context) {
      return Scaffold(
        backgroundColor: pal.bg1,
        body: GradientBg(
          child: SafeArea(
            child: child ?? const HomePage(),
          ),
        ),
      );
    });
  }
}

