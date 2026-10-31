import 'package:flutter/material.dart';
import '../../core/theme/palette.dart';
import '../controllers/app_state.dart';

/// 3D Icon button with tactile press animation and rich bevel
class ChunkyIconButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final Color top, bottom, edge;
  final double size;
  final Color iconColor;
  final String? tooltip;
  final Widget? badge;

  const ChunkyIconButton({
    super.key,
    required this.icon,
    this.onTap,
    this.top = const Color(0xFFA567FF),
    this.bottom = const Color(0xFF7430E0),
    this.edge = const Color(0xFF4B1D9C),
    this.iconColor = Colors.white,
    this.size = 46,
    this.tooltip,
    this.badge,
  });

  @override
  State<ChunkyIconButton> createState() => _ChunkyIconButtonState();
}

class _ChunkyIconButtonState extends State<ChunkyIconButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final s = widget.size;
    final r = BorderRadius.circular(s * 0.34);
    final offset = _pressed ? 1.5 : 4.5;

    final enabled = widget.onTap != null;
    Widget btn = GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: enabled ? (_) => setState(() => _pressed = true) : null,
      onTapUp: enabled
          ? (_) {
              setState(() => _pressed = false);
              app.haptic();
              widget.onTap!();
            }
          : null,
      onTapCancel: enabled ? () => setState(() => _pressed = false) : null,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 150),
        opacity: enabled ? 1.0 : 0.45,
        child: AnimatedContainer(
        duration: const Duration(milliseconds: 90),
        width: s,
        height: s,
        transform: Matrix4.translationValues(0, _pressed ? 3 : 0, 0),
        decoration: BoxDecoration(
          borderRadius: r,
          boxShadow: [
            BoxShadow(
              color: widget.edge,
              offset: Offset(0, offset),
            ),
            if (!_pressed)
              BoxShadow(
                color: fade(Colors.black, .25),
                blurRadius: 8,
                offset: const Offset(0, 6),
              ),
          ],
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: r,
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [widget.top, widget.bottom],
            ),
            border: Border.all(
              color: fade(Colors.white, .35),
              width: 1.2,
            ),
          ),
          child: Center(
            child: Icon(
              widget.icon,
              size: s * 0.52,
              color: widget.iconColor,
              shadows: const [
                Shadow(color: Color(0x66000000), offset: Offset(0, 1.5)),
              ],
            ),
          ),
        ),
      ),
    ),
  );

    if (widget.tooltip != null) {
      btn = Tooltip(message: widget.tooltip!, child: btn);
    }
    if (widget.badge != null) {
      btn = Stack(
        clipBehavior: Clip.none,
        children: [
          btn,
          Positioned(right: -2, top: -2, child: widget.badge!),
        ],
      );
    }
    return btn;
  }
}

