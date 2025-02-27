import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:task/features/auth/domain/entities/user.dart';
import 'package:task/features/auth/domain/usecases/search_users.dart';

import '../test.mocks.dart';

void main() {
  late MockAuthRepository mockAuthRepository;
  late SearchUsers searchUsers;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    searchUsers = SearchUsers(mockAuthRepository);
  });

  test('should return list of AppUser matching query', () async {
    final users = [
      AppUser(
        uid: '1',
        displayName: 'Alice',
        email: 'alice@example.com',
        photoUrl: '',
      ),
      AppUser(
        uid: '2',
        displayName: 'Bob',
        email: 'bob@example.com',
        photoUrl: '',
      ),
    ];
    when(mockAuthRepository.searchUsers("a")).thenAnswer((_) async => users
        .where((user) => user.displayName.toLowerCase().contains("a"))
        .toList());
    final result = await searchUsers("a");
    expect(
        result,
        users
            .where((user) => user.displayName.toLowerCase().contains("a"))
            .toList());
    verify(mockAuthRepository.searchUsers("a")).called(1);
  });
}
