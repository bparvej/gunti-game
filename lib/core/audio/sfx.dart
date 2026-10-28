import 'package:audioplayers/audioplayers.dart';

typedef SoundEnabledProvider = bool Function();
SoundEnabledProvider isSoundEnabled = () => true;

class Sfx {
  static AudioPlayer? _player;

  static void _init() {
    _player ??= AudioPlayer()..setReleaseMode(ReleaseMode.stop);
  }

  static void play(String kind) {
    if (!isSoundEnabled()) return;
    try {
      _init();
      String? asset;
      switch (kind) {
        case 'move':
          asset = 'sounds/move.wav';
          break;
        case 'undo':
          asset = 'sounds/undo.wav';
          break;
        case 'click':
          asset = 'sounds/select.wav';
          break;
        case 'win':
          asset = 'sounds/win.wav';
          break;
        case 'lose':
          asset = 'sounds/error.wav';
          break;
        case 'draw':
          asset = 'sounds/funny.wav';
          break;
      }
      if (asset != null) {
        _player?.play(AssetSource(asset));
      }
    } catch (_) {}
  }
}

