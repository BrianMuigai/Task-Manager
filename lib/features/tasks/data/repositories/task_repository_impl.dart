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
  Future<Task> addTask(Task task) async {
    final taskModel = TaskModel(
        id: task.id,
        title: task.title,
        startTime: task.startTime,
        dueDateTime: task.dueDateTime,
        completed: task.completed,
        ownerId: task.ownerId,
        collaboratorIds: task.collaboratorIds,
        updatedAt: task.updatedAt,
        description: task.description);
    final newDocSnapshot = await dataSource.addTask(taskModel);
    // Convert Firestore snapshot -> TaskModel -> domain Task
    final newData = newDocSnapshot.data() as Map<String, dynamic>?;
    if (newData == null) {
      throw Exception("Failed to retrieve newly created task data.");
    }

    final createdTaskModel = TaskModel(
      id: newDocSnapshot.id,
      title: newData['title'] ?? '',
      description: newData['description'] ?? '',
      startTime: newData['startTime']?.toDate(),
      dueDateTime: newData['dueDateTime']?.toDate(),
      completed: newData['completed'] ?? false,
      ownerId: newData['ownerId'] ?? '',
      collaboratorIds: newData['collaboratorIds'] != null
          ? List<String>.from(newData['collaboratorIds'])
          : [],
      updatedAt: newData['updatedAt']?.toDate(),
      calendarEventId: newData['calendarEventId'],
      priority: newData['priority'],
      tags: newData['tags'] != null ? List<String>.from(newData['tags']) : [],
    );

    return createdTaskModel;
  }

  @override
  Future<void> updateTask(Task task) async {
    final taskModel = TaskModel(
        id: task.id,
        title: task.title,
        startTime: task.startTime,
        dueDateTime: task.dueDateTime,
        completed: task.completed,
        ownerId: task.ownerId,
        collaboratorIds: task.collaboratorIds,
        updatedAt: task.updatedAt,
        description: task.description);
    await dataSource.updateTask(taskModel);
  }

  @override
  Future<void> deleteTask(String id) async {
    await dataSource.deleteTask(id);
  }
}
