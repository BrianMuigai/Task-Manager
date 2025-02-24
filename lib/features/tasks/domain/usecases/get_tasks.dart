import 'package:injectable/injectable.dart';

import '../entities/task.dart';
import '../repositories/task_repository.dart';

@lazySingleton
class GetTasks {
  final TaskRepository repository;

  GetTasks(this.repository);

  Future<List<Task>> call() async {
    return await repository.getTasks();
  }
}

@lazySingleton
class GetTasksStream {
  final TaskRepository repository;

  GetTasksStream(this.repository);

  Stream<List<Task>> call() {
    return repository.getTasksStream();
  }
}
