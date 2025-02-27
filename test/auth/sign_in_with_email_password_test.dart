import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:task/features/auth/domain/entities/user.dart';
import 'package:task/features/auth/domain/usecases/sign_in_with_email_password.dart';

import '../test.mocks.dart';

void main() {
  late MockAuthRepository mockAuthRepository;
  late SignInWithEmailPassword signInWithEmailPassword;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    signInWithEmailPassword = SignInWithEmailPassword(mockAuthRepository);
  });

  test('should return an AppUser', () async {
    final user = AppUser(
      uid: '1',
      displayName: 'User1',
      email: 'user1@example.com',
      photoUrl: '',
    );
    when(mockAuthRepository.signInWithEmailPassword(
            "user1@example.com", "password"))
        .thenAnswer((_) async => user);
    final result =
        await signInWithEmailPassword("user1@example.com", "password");
    expect(result, user);
    verify(mockAuthRepository.signInWithEmailPassword(
            "user1@example.com", "password"))
        .called(1);
  });
}
