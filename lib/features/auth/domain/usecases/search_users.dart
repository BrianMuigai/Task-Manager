import 'package:injectable/injectable.dart';

import '../entities/user.dart';
import '../repositories/auth_repository.dart';

@lazySingleton
class SearchUsers {
  final AuthRepository repository;
  SearchUsers(this.repository);

  /// Searches for users whose display name or email matches the [query].
  Future<List<AppUser>> call(String query) async {
    return await repository.searchUsers(query);
  }
}
