import 'package:equatable/equatable.dart';
import '../../../data/models/app_settings.dart';

class SettingsState extends Equatable {
  final AppSettings settings;

  const SettingsState({required this.settings});

  factory SettingsState.initial() => SettingsState(settings: AppSettings.defaults());

  @override
  List<Object?> get props => [settings];
}