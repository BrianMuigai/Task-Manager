import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:task/features/auth/domain/usecases/reset_password.dart';

import '../test.mocks.dart';

void main() {
  late MockAuthRepository mockAuthRepository;
  late ResetPassword resetPassword;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    resetPassword = ResetPassword(mockAuthRepository);
  });

  test('should complete without error', () async {
    when(mockAuthRepository.sendPasswordResetEmail("user1@example.com"))
        .thenAnswer((_) async {});
    await resetPassword("user1@example.com");
    verify(mockAuthRepository.sendPasswordResetEmail("user1@example.com"))
        .called(1);
  });
}
