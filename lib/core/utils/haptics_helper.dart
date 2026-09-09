import 'package:vibration/vibration.dart';

class HapticsHelper {
  bool _enabled = true;

  bool get enabled => _enabled;

  void toggle() => _enabled = !_enabled;

  void setEnabled(bool value) => _enabled = value;

  Future<void> lightTap() async {
    if (!_enabled) return;
    if (await Vibration.hasVibrator()) {
      Vibration.vibrate(duration: 20);
    }
  }

  Future<void> mediumTap() async {
    if (!_enabled) return;
    if (await Vibration.hasVibrator()) {
      Vibration.vibrate(duration: 50);
    }
  }

  Future<void> winVibrate() async {
    if (!_enabled) return;
    if (await Vibration.hasVibrator()) {
      Vibration.vibrate(pattern: [0, 100, 50, 100, 50, 200]);
    }
  }

  Future<void> errorVibrate() async {
    if (!_enabled) return;
    if (await Vibration.hasVibrator()) {
      Vibration.vibrate(duration: 150);
    }
  }
}