part of 'settings_bloc.dart';

abstract class SettingsEvent extends Equatable {
  const SettingsEvent();

  @override
  List<Object> get props => [];
}

class ChangeLanguageEvent extends SettingsEvent {
  final String langCode;

  const ChangeLanguageEvent({required this.langCode});
}

class GetSettingsEvent extends SettingsEvent {}
