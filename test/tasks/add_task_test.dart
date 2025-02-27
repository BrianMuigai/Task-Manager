import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:task/features/tasks/domain/entities/task.dart';
import 'package:task/features/tasks/domain/usecases/add_task.dart';

import '../test.mocks.dart';

void main() {
  late MockTaskRepository mockTaskRepository;
  late AddTask addTaskUsecase;

  setUp(() {
    mockTaskRepository = MockTaskRepository();
    addTaskUsecase = AddTask(mockTaskRepository);
  });

  test('should call repository addTask', () async {
    final task = Task(
      id: '1',
      title: 'Task1',
      description: 'Desc',
      ownerId: 'user1',
    );
    when(mockTaskRepository.addTask(task)).thenAnswer((_) async {});

    await addTaskUsecase(task);
    verify(mockTaskRepository.addTask(task)).called(1);
  });
}
