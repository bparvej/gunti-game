import 'package:audioplayers/audioplayers.dart';

class AudioService {
  final AudioPlayer _player = AudioPlayer()..setReleaseMode(ReleaseMode.stop);

  bool soundEnabled = true;
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;
    try {
      await _player.setPlayerMode(PlayerMode.lowLatency);
    } catch (_) {}
  }

  void _playBeep(double frequency, double durationMs) async {
    if (!soundEnabled) return;
    try {
      await init();
      final player = AudioPlayer()..setReleaseMode(ReleaseMode.stop);
      final bytes = _generateBeep(frequency, durationMs, 44100);
      final url = Uri.dataFromBytes(bytes, mimeType: 'audio/wav');
      await player.play(UrlSource(url.toString()));
    } catch (_) {}
  }

  List<int> _generateBeep(double frequency, double durationMs, int sampleRate) {
    final numSamples = (durationMs / 1000 * sampleRate).round();
    final buffer = <int>[];
    final header = _wavHeader(numSamples, sampleRate);
    buffer.addAll(header);
    for (int i = 0; i < numSamples; i++) {
      final t = i / sampleRate;
      final sample = (0.2 * 32767 * (frequency * 2 * 3.14159265 * t)).round().toSigned(16);
      buffer.add(sample & 0xFF);
      buffer.add((sample >> 8) & 0xFF);
    }
    return buffer;
  }

  List<int> _wavHeader(int numSamples, int sampleRate) {
    final byteRate = sampleRate * 2;
    final blockSize = 2;
    final dataSize = numSamples * blockSize;
    final totalSize = 36 + dataSize;
    final header = <int>[];
    void addString(String s) => header.addAll(s.codeUnits);
    void addInt16(int v) {
      header.add(v & 0xFF);
      header.add((v >> 8) & 0xFF);
    }
    void addInt32(int v) {
      header.add(v & 0xFF);
      header.add((v >> 8) & 0xFF);
      header.add((v >> 16) & 0xFF);
      header.add((v >> 24) & 0xFF);
    }

    addString('RIFF');
    addInt32(totalSize);
    addString('WAVE');
    addString('fmt ');
    addInt32(16);
    addInt16(1);
    addInt16(1);
    addInt32(sampleRate);
    addInt32(byteRate);
    addInt16(blockSize);
    addInt16(16);
    addString('data');
    addInt32(dataSize);
    return header;
  }

  void playMoveSound() => _playBeep(400, 100);
  void playWinSound() {
    _playBeep(800, 200);
    Future.delayed(const Duration(milliseconds: 150), () => _playBeep(1000, 200));
  }
  void playErrorSound() => _playBeep(300, 100);
  void playSlideSound() => _playBeep(800, 80);
  void playYooSound() {
    _playBeep(600, 100);
    Future.delayed(const Duration(milliseconds: 100), () => _playBeep(700, 100));
    Future.delayed(const Duration(milliseconds: 200), () => _playBeep(800, 100));
    Future.delayed(const Duration(milliseconds: 300), () => _playBeep(900, 100));
    Future.delayed(const Duration(milliseconds: 400), () => _playBeep(1000, 100));
  }

  void toggleSound() {
    soundEnabled = !soundEnabled;
  }

  bool isSoundEnabled() => soundEnabled;

  void dispose() {
    _player.dispose();
  }
}
