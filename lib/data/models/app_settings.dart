import 'package:equatable/equatable.dart';
import '../../domain/models/game_models.dart';

class AppSettings extends Equatable {
  final bool soundOn;
  final bool vibrationOn;
  final bool isDarkMode;
  final bool isBangla;
  final GutuShape gutiShape;

  const AppSettings({
    required this.soundOn,
    required this.vibrationOn,
    required this.isDarkMode,
    required this.isBangla,
    required this.gutiShape,
  });

  factory AppSettings.defaults() => const AppSettings(
        soundOn: true,
        vibrationOn: true,
        isDarkMode: false,
        isBangla: false,
        gutiShape: GutuShape.circle,
      );

  factory AppSettings.fromMap(Map<String, dynamic> map) => AppSettings(
        soundOn: map['soundOn'] ?? true,
        vibrationOn: map['vibrationOn'] ?? true,
        isDarkMode: map['isDarkMode'] ?? false,
        isBangla: map['isBangla'] ?? false,
        gutiShape: GutuShape.values.firstWhere(
          (s) => s.name == map['gutiShape'],
          orElse: () => GutuShape.circle,
        ),
      );

  Map<String, dynamic> toMap() => {
        'soundOn': soundOn,
        'vibrationOn': vibrationOn,
        'isDarkMode': isDarkMode,
        'isBangla': isBangla,
        'gutiShape': gutiShape.name,
      };

  AppSettings copyWith({
    bool? soundOn,
    bool? vibrationOn,
    bool? isDarkMode,
    bool? isBangla,
    GutuShape? gutiShape,
  }) =>
      AppSettings(
        soundOn: soundOn ?? this.soundOn,
        vibrationOn: vibrationOn ?? this.vibrationOn,
        isDarkMode: isDarkMode ?? this.isDarkMode,
        isBangla: isBangla ?? this.isBangla,
        gutiShape: gutiShape ?? this.gutiShape,
      );

  @override
  List<Object?> get props => [soundOn, vibrationOn, isDarkMode, isBangla, gutiShape];
}
