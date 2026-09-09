import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/utils/audio_helper.dart';
import '../../../core/utils/haptics_helper.dart';
import '../../../data/models/app_settings.dart';
import '../../../domain/models/game_models.dart';
import '../../../domain/repositories/settings_repository.dart';
import 'settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  final SettingsRepository _repo;
  final AudioHelper _audio;
  final HapticsHelper _haptics;

  SettingsCubit({
    required SettingsRepository repo,
    required AudioHelper audio,
    required HapticsHelper haptics,
  })  : _repo = repo,
        _audio = audio,
        _haptics = haptics,
        super(SettingsState.initial());

  Future<void> load() async {
    final settings = await _repo.load();
    emit(SettingsState(settings: settings));
    _audio.setEnabled(settings.soundOn);
    _haptics.setEnabled(settings.vibrationOn);
  }

  Future<void> _save(AppSettings s) async {
    emit(SettingsState(settings: s));
    await _repo.save(s);
  }

  Future<void> toggleSound() async {
    final s = state.settings.copyWith(soundOn: !state.settings.soundOn);
    await _save(s);
    _audio.setEnabled(s.soundOn);
  }

  Future<void> toggleVibration() async {
    final s = state.settings.copyWith(vibrationOn: !state.settings.vibrationOn);
    await _save(s);
    _haptics.setEnabled(s.vibrationOn);
  }

  Future<void> toggleDarkMode() async {
    final s = state.settings.copyWith(isDarkMode: !state.settings.isDarkMode);
    await _save(s);
  }

  Future<void> toggleLanguage() async {
    final s = state.settings.copyWith(isBangla: !state.settings.isBangla);
    await _save(s);
  }

  Future<void> setGutiShape(GutuShape shape) async {
    final s = state.settings.copyWith(gutiShape: shape);
    await _save(s);
  }
}