import 'package:flutter/material.dart';
import '../controllers/app_state.dart';

/// 3D Toggle Switch (ON / OFF)
class ChunkyToggle extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const ChunkyToggle({super.key, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        app.haptic();
        onChanged(!value);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 68,
        height: 38,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: value
                ? const [Color(0xFF86E37A), Color(0xFF38B249)]
                : const [Color(0xFF756A8F), Color(0xFF43385C)],
          ),
          boxShadow: [
            BoxShadow(
              color: value ? const Color(0xFF22752E) : const Color(0xFF261D38),
              offset: const Offset(0, 3.5),
            ),
          ],
        ),
        alignment: value ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          width: 30,
          height: 30,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Color(0x33000000),
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Icon(
            value ? Icons.check_rounded : Icons.close_rounded,
            size: 18,
            color: value ? const Color(0xFF2E9E43) : const Color(0xFF5B4F75),
          ),
        ),
      ),
    );
  }
}

