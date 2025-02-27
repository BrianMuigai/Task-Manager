import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:task/features/auth/domain/entities/user.dart';
import 'package:task/features/auth/domain/usecases/sign_in_with_google.dart';

import '../test.mocks.dart';

void main() {
  late MockAuthRepository mockAuthRepository;
  late SignInWithGoogle signInWithGoogle;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    signInWithGoogle = SignInWithGoogle(mockAuthRepository);
  });

  test('should return an AppUser when signing in with google', () async {
    final user = AppUser(
      uid: '1',
      displayName: 'User1',
      email: 'user1@example.com',
      photoUrl: '',
    );
    when(mockAuthRepository.signInWithGoogle()).thenAnswer((_) async => user);

    final result = await signInWithGoogle();
    expect(result, user);
    verify(mockAuthRepository.signInWithGoogle()).called(1);
  });
}
