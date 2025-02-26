part of 'settings_bloc.dart';

abstract class SettingsState extends Equatable {
  const SettingsState();

  @override
  List<Object> get props => [];
}

class SettingsInitial extends SettingsState {}

class ChangeLanguageSuccess extends SettingsState {
  final String langCode;

  const ChangeLanguageSuccess({required this.langCode});
}

class LanguageLoading extends SettingsState {}

class ChangeLanguageError extends SettingsState {
  final String error;
  final String lang;

  const ChangeLanguageError({required this.error, required this.lang});
}

class SettingsLoading extends SettingsState {}

class SettingsLoaded extends SettingsState {
  final Settings settings;

  const SettingsLoaded({required this.settings});
}
