import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:task/core/di/injector.dart';
import 'package:task/core/shared_preferences_manager.dart';
import 'package:task/features/settings/data/models/settings_model.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static String getString(BuildContext context, String str) =>
      AppLocalizations.of(context)?.translate(str) ?? str;

  static LocalizationsDelegate<AppLocalizations> delegate() =>
      _AppLocalizationsDelegate();

  late Map<String, String> _localizedStrings;

  Future<bool> load() async {
    String jsonString =
        await rootBundle.loadString('assets/lang/${locale.languageCode}.json');
    Map<String, dynamic> jsonMap = json.decode(jsonString);

    _localizedStrings = jsonMap.map((key, value) {
      return MapEntry(key, value.toString());
    });

    return true;
  }

  String translate(String key) {
    return _localizedStrings[key] ?? key;
  }
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  late String languageCode;

  _AppLocalizationsDelegate() {
    final settingsString = getIt<SharedPreferencesManager>()
        .getString(SharedPreferencesManager.settings);
    if (settingsString == null) {
      languageCode = 'en';
    } else {
      languageCode =
          SettingsModel.fromJson(jsonDecode(settingsString)).langCode;
    }
  }

  @override
  bool isSupported(Locale locale) =>
      ['en', 'es', 'fr'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    AppLocalizations localizations = AppLocalizations(locale);
    await localizations.load();
    return localizations;
  }

  @override
  bool shouldReload(covariant LocalizationsDelegate old) => false;
}
