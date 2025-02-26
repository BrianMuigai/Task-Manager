import 'package:injectable/injectable.dart';
import 'package:task/features/settings/domain/repositories/settings_repository.dart';
import 'package:task/features/settings/domain/usecases/get_settings.dart';

@lazySingleton
class ChangeLanguage {
  final SettingsRepository _repo;
  final GetSettings _getSettingsUsecase;

  ChangeLanguage(this._repo, this._getSettingsUsecase);

  Future<void> call(String langCode) async {
    final settings = await _getSettingsUsecase();
    settings.copyWith(langCode: langCode);
    await _repo.saveSettings(settings);
  }
}
