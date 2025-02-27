import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:task/features/tasks/domain/entities/task.dart';
import 'package:task/features/tasks/domain/usecases/get_tasks.dart';

import '../test.mocks.dart';

void main() {
  late MockTaskRepository mockTaskRepository;
  late GetTasks getTasksUseCase;

  setUp(() {
    mockTaskRepository = MockTaskRepository();
    getTasksUseCase = GetTasks(mockTaskRepository);
  });

  test('should return list of tasks', () async {
    final tasks = [
      Task(
        id: '1',
        title: 'Task1',
        description: 'Desc',
        ownerId: 'user1',
      )
    ];
    when(mockTaskRepository.getTasks()).thenAnswer((_) async => tasks);

    final result = await getTasksUseCase();
    expect(result, tasks);
    verify(mockTaskRepository.getTasks()).called(1);
  });
}
