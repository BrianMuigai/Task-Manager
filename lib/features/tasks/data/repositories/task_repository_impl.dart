import 'package:injectable/injectable.dart';

import '../../domain/entities/task.dart';
import '../../domain/repositories/task_repository.dart';
import '../datasources/firebase_task_datasource.dart';
import '../models/task_model.dart';

@LazySingleton(as: TaskRepository)
class TaskRepositoryImpl implements TaskRepository {
  final FirebaseTaskDataSource dataSource;

  TaskRepositoryImpl({required this.dataSource});

  @override
  Future<List<Task>> getTasks() async {
    final taskModels = await dataSource.getTasks();
    return taskModels; // TaskModel extends Task
  }

  @override
  Stream<List<Task>> getTasksStream() {
    return dataSource.tasksStream();
  }

  @override
  Future<void> addTask(Task task) async {
    final taskModel = TaskModel(
      id: task.id,
      title: task.title,
      dueDate: task.dueDate,
      completed: task.completed,
      ownerId: task.ownerId,
      collaboratorIds: task.collaboratorIds,
      updatedAt: task.updatedAt,
    );
    await dataSource.addTask(taskModel);
  }

  @override
  Future<void> updateTask(Task task) async {
    final taskModel = TaskModel(
      id: task.id,
      title: task.title,
      dueDate: task.dueDate,
      completed: task.completed,
      ownerId: task.ownerId,
      collaboratorIds: task.collaboratorIds,
      updatedAt: task.updatedAt,
    );
    await dataSource.updateTask(taskModel);
  }

  @override
  Future<void> deleteTask(String id) async {
    await dataSource.deleteTask(id);
  }
}
