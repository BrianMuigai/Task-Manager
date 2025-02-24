import '../entities/user.dart';

abstract class AuthRepository {
  Future<AppUser> signInWithGoogle();
  Future<AppUser> signInWithEmailPassword(String email, String password);
  Future<void> signOut();
  Future<void> sendPasswordResetEmail(String email);
}
