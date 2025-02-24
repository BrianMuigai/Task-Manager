import 'package:injectable/injectable.dart';

import '../entities/task.dart';
import '../repositories/task_repository.dart';

@lazySingleton
class AddTask {
  final TaskRepository repository;

  AddTask(this.repository);

  Future<void> call(Task task) async {
    await repository.addTask(task);
  }
}
