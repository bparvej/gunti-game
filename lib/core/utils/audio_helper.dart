import 'package:audioplayers/audioplayers.dart';
import '../constants/app_config.dart';

class AudioHelper {
  final AudioPlayer _player = AudioPlayer();
  bool _enabled = true;

  bool get enabled => _enabled;

  void toggle() => _enabled = !_enabled;

  void setEnabled(bool value) => _enabled = value;

  Future<void> _play(String name) async {
    if (!_enabled) return;
    try {
      await _player.play(AssetSource('${AppConfig.assetSoundsPath}$name.wav'));
    } catch (_) {}
  }

  Future<void> playSelect() => _play('select');
  Future<void> playMove() => _play('move');
  Future<void> playSlide() => _play('slide');
  Future<void> playWin() => _play('win');
  Future<void> playError() => _play('error');
  Future<void> playUndo() => _play('undo');
  Future<void> playFunny() => _play('funny');

  void dispose() => _player.dispose();
}