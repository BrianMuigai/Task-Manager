import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:task/core/di/injector.dart';
import 'package:task/features/settings/domain/usecases/get_settings.dart';

class LocaleProvider with ChangeNotifier {
  Locale _locale = Locale('en'); // Default locale is English

  Locale get locale => _locale;

  void loadLocale() {
    final GetSettings getSettingsUsecase = getIt<GetSettings>();
    getSettingsUsecase.call().then((settings) {
      final String langCode = settings.langCode;
      log('LangCode: $langCode');
      _locale = Locale(langCode);
      notifyListeners();
    });
  }

  void setLocale(Locale locale) {
    _locale = locale;
    notifyListeners(); // Notify listeners about the change
  }
}
