import 'dart:convert';

import 'package:injectable/injectable.dart';
import 'package:task/core/shared_preferences_manager.dart';
import 'package:task/features/settings/data/models/settings_model.dart';

@lazySingleton
class SettingsDatasource {
  final SharedPreferencesManager _preferencesManager;

  SettingsDatasource(this._preferencesManager);

  Future<SettingsModel?> getSettings() async {
    final settingsString =
        _preferencesManager.getString(SharedPreferencesManager.settings);
    if (settingsString == null) return null;
    return SettingsModel.fromJson(jsonDecode(settingsString));
  }

  Future<void> saveSettings(SettingsModel settings) async {
    await _preferencesManager.putString(
        SharedPreferencesManager.settings, jsonEncode(settings.toJson()));
  }
}
