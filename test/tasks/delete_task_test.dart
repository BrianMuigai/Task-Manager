import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:task/features/tasks/domain/usecases/delete_task.dart';

import '../test.mocks.dart';

void main() {
  late MockTaskRepository mockTaskRepository;
  late DeleteTask deleteTaskUsecase;

  setUp(() {
    mockTaskRepository = MockTaskRepository();
    deleteTaskUsecase = DeleteTask(mockTaskRepository);
  });

  test('should call repository deleteTask', () async {
    const taskId = '1';
    when(mockTaskRepository.deleteTask(taskId)).thenAnswer((_) async {});

    await deleteTaskUsecase(taskId);
    verify(mockTaskRepository.deleteTask(taskId)).called(1);
  });
}
