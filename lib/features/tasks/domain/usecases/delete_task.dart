import 'package:injectable/injectable.dart';
import 'package:task/features/tasks/domain/repositories/task_repository.dart';

@lazySingleton
class DeleteTask {
  final TaskRepository repository;

  DeleteTask(this.repository);

  Future<void> call(String taskId) async {
    await repository.deleteTask(taskId);
  }
}
