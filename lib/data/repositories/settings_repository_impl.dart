import '../../domain/repositories/settings_repository.dart';
import '../datasources/local_data_source.dart';
import '../models/app_settings.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  final LocalDataSource _local;

  SettingsRepositoryImpl(this._local);

  @override
  Future<AppSettings> load() => _local.loadSettings();

  @override
  Future<void> save(AppSettings settings) => _local.saveSettings(settings);
}
