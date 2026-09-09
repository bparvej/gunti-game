import 'package:equatable/equatable.dart';
import '../../../data/models/app_settings.dart';

class SettingsState extends Equatable {
  final AppSettings settings;
  final bool loaded;

  const SettingsState({required this.settings, this.loaded = false});

  factory SettingsState.initial() => SettingsState(settings: AppSettings.defaults());

  SettingsState copyWith({AppSettings? settings, bool? loaded}) =>
      SettingsState(settings: settings ?? this.settings, loaded: loaded ?? this.loaded);

  @override
  List<Object?> get props => [settings, loaded];
}