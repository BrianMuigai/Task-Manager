import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:task/features/tasks/domain/entities/task.dart';
import 'package:task/features/tasks/domain/usecases/update_task.dart';

import '../test.mocks.dart';

void main() {
  late MockTaskRepository mockTaskRepository;
  late UpdateTask updateTaskUsecase;

  setUp(() {
    mockTaskRepository = MockTaskRepository();
    updateTaskUsecase = UpdateTask(mockTaskRepository);
  });

  test('should call repository updateTask', () async {
    final task = Task(
      id: '1',
      title: 'Task1',
      description: 'Desc',
      ownerId: 'user1',
    );
    when(mockTaskRepository.updateTask(task)).thenAnswer((_) async {});

    await updateTaskUsecase(task);
    verify(mockTaskRepository.updateTask(task)).called(1);
  });
}
