import 'package:task/core/services/calendar_service.dart';
import 'package:task/features/auth/domain/repositories/auth_repository.dart';
import 'package:task/features/tasks/domain/repositories/task_repository.dart';

import 'package:mockito/annotations.dart';

@GenerateMocks([TaskRepository, AuthRepository, CalendarService])
void main() {}
