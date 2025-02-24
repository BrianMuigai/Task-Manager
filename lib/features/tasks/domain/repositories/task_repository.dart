import '../entities/task.dart';

abstract class TaskRepository {
  Future<List<Task>> getTasks();
  Stream<List<Task>> getTasksStream();
  Future<void> addTask(Task task);
  Future<void> updateTask(Task task);
  Future<void> deleteTask(String id);
}
