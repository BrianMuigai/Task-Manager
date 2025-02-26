import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:task/features/settings/domain/entities/settings.dart';
import 'package:task/features/settings/domain/usecases/change_language.dart';
import 'package:task/features/settings/domain/usecases/get_settings.dart';

part 'settings_event.dart';
part 'settings_state.dart';

@injectable
class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final ChangeLanguage _changeLanguageUsecase;
  final GetSettings _getSettingsUseCase;

  SettingsBloc(this._changeLanguageUsecase, this._getSettingsUseCase)
      : super(SettingsInitial()) {
    on<ChangeLanguageEvent>(_changeLanguage);
    on<GetSettingsEvent>(_getSettings);
  }

  FutureOr<void> _changeLanguage(
      ChangeLanguageEvent event, Emitter<SettingsState> emit) async {
    emit(LanguageLoading());
    await _changeLanguageUsecase.call(event.langCode);
    emit(ChangeLanguageSuccess(langCode: event.langCode));
  }

  FutureOr<void> _getSettings(
      GetSettingsEvent event, Emitter<SettingsState> emit) async {
    emit(SettingsLoading());
    final settings = await _getSettingsUseCase();
    emit(SettingsLoaded(settings: settings));
  }
}
