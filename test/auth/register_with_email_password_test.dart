import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:task/features/auth/domain/entities/user.dart';
import 'package:task/features/auth/domain/usecases/register_with_email_password.dart';

import '../test.mocks.dart';

void main() {
  late MockAuthRepository mockAuthRepository;
  late RegisterWithEmailPassword registerWithEmailPassword;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    registerWithEmailPassword = RegisterWithEmailPassword(mockAuthRepository);
  });

  test('should return an AppUser after registration', () async {
    final user = AppUser(
      uid: '1',
      displayName: 'User1',
      email: 'user1@example.com',
      photoUrl: '',
    );
    when(mockAuthRepository.registerWithEmailPassword(
            "user1@example.com", "password", "User1"))
        .thenAnswer((_) async => user);
    final result = await registerWithEmailPassword(
        "user1@example.com", "password", "User1");
    expect(result, user);
    verify(mockAuthRepository.registerWithEmailPassword(
            "user1@example.com", "password", "User1"))
        .called(1);
  });
}
