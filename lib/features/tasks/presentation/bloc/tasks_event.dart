part of 'tasks_bloc.dart';

abstract class TasksEvent extends Equatable {
  const TasksEvent();

  @override
  List<Object> get props => [];
}

class LoadTasksEvent extends TasksEvent {}

class AddTaskEvent extends TasksEvent {
  final Task task;
  const AddTaskEvent(this.task);
}

class SubscribeToTasksEvent extends TasksEvent {}

class UpdateTaskEvent extends TasksEvent {
  final Task task;
  const UpdateTaskEvent(this.task);
}

class DeleteTaskEvent extends TasksEvent {
  final String taskId;
  const DeleteTaskEvent(this.taskId);
}

class SearchCollaboratorsEvent extends TasksEvent {
  final String query;
  final String currentUserId;

  const SearchCollaboratorsEvent({
    required this.query,
    required this.currentUserId,
  });
}
