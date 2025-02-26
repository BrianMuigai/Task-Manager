import 'package:task/features/settings/domain/entities/settings.dart';

abstract class SettingsRepository {
  Future<void> saveSettings(Settings settings);
  Future<Settings> getSettings();
}
