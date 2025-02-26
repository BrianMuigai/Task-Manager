import 'package:injectable/injectable.dart';
import 'package:task/features/settings/data/datasources/settings_datasource.dart';
import 'package:task/features/settings/data/models/settings_model.dart';
import 'package:task/features/settings/domain/entities/settings.dart';
import 'package:task/features/settings/domain/repositories/settings_repository.dart';

@LazySingleton(as: SettingsRepository)
class SettingsRepositoryImpl implements SettingsRepository {
  final SettingsDatasource _datasource;

  SettingsRepositoryImpl(this._datasource);

  @override
  Future<Settings> getSettings() async {
    SettingsModel? model = await _datasource.getSettings();
    if (model == null) return Settings(langCode: 'en');
    return model;
  }

  @override
  Future<void> saveSettings(Settings settings) async {
    SettingsModel model = SettingsModel(langCode: settings.langCode);
    await _datasource.saveSettings(model);
  }
}
