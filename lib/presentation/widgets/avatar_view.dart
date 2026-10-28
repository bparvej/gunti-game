import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../../core/theme/palette.dart';
import '../controllers/app_state.dart';

class AvatarView extends StatelessWidget {
  final int avatarIndex;
  final double size;
  final bool circle;
  final bool withCrown;
  final VoidCallback? onTap;

  const AvatarView({
    super.key,
    required this.avatarIndex,
    this.size = 46,
    this.circle = true,
    this.withCrown = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final idx = avatarIndex.clamp(0, kAvatars.length - 1);
    final a = kAvatars[idx];
    final r = circle
        ? BorderRadius.circular(size / 2)
        : BorderRadius.circular(size * .32);

    Widget content = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: r,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [a.bg1, a.bg2],
        ),
        border: Border.all(color: a.border, width: math.max(2.0, size * 0.06)),
        boxShadow: [
          BoxShadow(
            color: Color.lerp(a.border, Colors.black, .4)!,
            offset: Offset(0, math.max(2.0, size * 0.08)),
          ),
          BoxShadow(
            color: fade(Colors.black, .25),
            blurRadius: size * 0.15,
            offset: Offset(0, size * 0.08),
          ),
        ],
      ),
      child: Center(
        child: Text(
          a.emoji,
          style: TextStyle(
            fontSize: size * 0.52,
            height: 1.1,
          ),
        ),
      ),
    );

    if (withCrown) {
      content = Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          content,
          Positioned(
            top: -size * 0.35,
            child: Text('👑', style: TextStyle(fontSize: size * 0.44)),
          ),
        ],
      );
    }

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

