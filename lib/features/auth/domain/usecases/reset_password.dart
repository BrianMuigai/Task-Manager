import 'package:injectable/injectable.dart';

import '../repositories/auth_repository.dart';

@lazySingleton
class ResetPassword {
  final AuthRepository repository;

  ResetPassword(this.repository);

  Future<void> call(String email) async {
    await repository.sendPasswordResetEmail(email);
  }
}
