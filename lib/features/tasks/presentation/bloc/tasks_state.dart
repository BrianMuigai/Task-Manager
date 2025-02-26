part of 'tasks_bloc.dart';

abstract class TasksState extends Equatable {
  const TasksState();

  @override
  List<Object> get props => [];
}

class TasksInitial extends TasksState {}

class TasksLoading extends TasksState {}

class TasksLoaded extends TasksState {
  final List<Task> tasks;
  const TasksLoaded(this.tasks);
}

class TasksError extends TasksState {
  final String message;
  const TasksError(this.message);
}

class CollaboratorsSearchLoading extends TasksState {}

class CollaboratorsSearchLoaded extends TasksState {
  final List<AppUser> results;
  const CollaboratorsSearchLoaded(this.results);
}

class CollaboratorsSearchError extends TasksState {
  final String message;
  const CollaboratorsSearchError(this.message);
}

class CalendarSyncSuccess extends TasksState {}

class CalendarSyncFailure extends TasksState {}
