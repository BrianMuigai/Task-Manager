import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:task/features/tasks/domain/entities/task.dart';
import 'package:task/features/tasks/domain/usecases/get_tasks.dart';

import '../test.mocks.dart';

void main() {
  late MockTaskRepository mockTaskRepository;
  late GetTasksStream getTasksStreamUsecase;

  setUp(() {
    mockTaskRepository = MockTaskRepository();
    getTasksStreamUsecase = GetTasksStream(mockTaskRepository);
  });

  test('should return a stream of tasks', () {
    final tasks = [
      Task(
        id: '1',
        title: 'Task1',
        description: 'Desc',
        ownerId: 'user1',
      )
    ];
    when(mockTaskRepository.getTasksStream())
        .thenAnswer((_) => Stream.value(tasks));

    expect(getTasksStreamUsecase(), emits(tasks));
    verify(mockTaskRepository.getTasksStream()).called(1);
  });
}
