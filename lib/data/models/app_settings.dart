import 'package:equatable/equatable.dart';
import '../../domain/models/game_models.dart';

class AppSettings extends Equatable {
  final bool soundOn;
  final bool vibrationOn;
  final bool isDarkMode;
  final bool isBangla;
  final GutuShape gutiShape;
  final String playerName;
  final Difficulty difficulty;
  final bool hasOnboarded;

  const AppSettings({
    required this.soundOn,
    required this.vibrationOn,
    required this.isDarkMode,
    required this.isBangla,
    required this.gutiShape,
    required this.playerName,
    required this.difficulty,
    required this.hasOnboarded,
  });

  factory AppSettings.defaults() => const AppSettings(
        soundOn: true,
        vibrationOn: true,
        isDarkMode: false,
        isBangla: false,
        gutiShape: GutuShape.circle,
        playerName: 'Player 1',
        difficulty: Difficulty.medium,
        hasOnboarded: false,
      );

  factory AppSettings.fromMap(Map<String, dynamic> map) {
    final defaults = AppSettings.defaults();
    return AppSettings(
      soundOn: map['soundOn'] ?? true,
      vibrationOn: map['vibrationOn'] ?? true,
      isDarkMode: map['isDarkMode'] ?? false,
      isBangla: map['isBangla'] ?? false,
      gutiShape: GutuShape.values.firstWhere(
        (s) => s.name == map['gutiShape'],
        orElse: () => GutuShape.circle,
      ),
      playerName: map['playerName'] ?? defaults.playerName,
      difficulty: Difficulty.values.firstWhere(
        (d) => d.name == map['difficulty'],
        orElse: () => defaults.difficulty,
      ),
      hasOnboarded: map['hasOnboarded'] ?? false,
    );
  }

  Map<String, dynamic> toMap() => {
        'soundOn': soundOn,
        'vibrationOn': vibrationOn,
        'isDarkMode': isDarkMode,
        'isBangla': isBangla,
        'gutiShape': gutiShape.name,
        'playerName': playerName,
        'difficulty': difficulty.name,
        'hasOnboarded': hasOnboarded,
      };

  AppSettings copyWith({
    bool? soundOn,
    bool? vibrationOn,
    bool? isDarkMode,
    bool? isBangla,
    GutuShape? gutiShape,
    String? playerName,
    Difficulty? difficulty,
    bool? hasOnboarded,
  }) =>
      AppSettings(
        soundOn: soundOn ?? this.soundOn,
        vibrationOn: vibrationOn ?? this.vibrationOn,
        isDarkMode: isDarkMode ?? this.isDarkMode,
        isBangla: isBangla ?? this.isBangla,
        gutiShape: gutiShape ?? this.gutiShape,
        playerName: playerName ?? this.playerName,
        difficulty: difficulty ?? this.difficulty,
        hasOnboarded: hasOnboarded ?? this.hasOnboarded,
      );

  @override
  List<Object?> get props => [
        soundOn, vibrationOn, isDarkMode, isBangla, gutiShape,
        playerName, difficulty, hasOnboarded,
      ];
}