import 'package:equatable/equatable.dart';

class Settings extends Equatable {
  final String langCode;

  const Settings({required this.langCode});

  Settings copyWith({String? langCode}) {
    return Settings(langCode: langCode ?? this.langCode);
  }

  @override
  List<Object?> get props => [langCode];
}
