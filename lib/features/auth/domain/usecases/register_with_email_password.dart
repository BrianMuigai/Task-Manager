import 'package:injectable/injectable.dart';

import '../entities/user.dart';
import '../repositories/auth_repository.dart';

@lazySingleton
class RegisterWithEmailPassword {
  final AuthRepository repository;

  RegisterWithEmailPassword(this.repository);

  Future<AppUser> call(
      String email, String password, String displayName) async {
    return await repository.registerWithEmailPassword(
        email, password, displayName);
  }
}
