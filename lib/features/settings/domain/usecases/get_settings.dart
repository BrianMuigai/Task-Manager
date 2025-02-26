import 'package:injectable/injectable.dart';
import 'package:task/features/settings/domain/entities/settings.dart';
import 'package:task/features/settings/domain/repositories/settings_repository.dart';

@lazySingleton
class GetSettings {
  final SettingsRepository _repo;

  GetSettings(this._repo);

  Future<Settings> call() async {
    return _repo.getSettings();
  }
}
