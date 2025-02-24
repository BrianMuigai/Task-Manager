import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:task/features/tasks/domain/entities/task.dart';
import 'package:task/features/tasks/domain/usecases/add_task.dart';
import 'package:task/features/tasks/domain/usecases/delete_task.dart';
import 'package:task/features/tasks/domain/usecases/get_tasks.dart';
import 'package:task/features/tasks/domain/usecases/update_task.dart';

part 'tasks_event.dart';
part 'tasks_state.dart';

@injectable
class TasksBloc extends Bloc<TasksEvent, TasksState> {
  final GetTasks getTasksUseCase;
  final AddTask addTaskUseCase;
  final UpdateTask updateTaskUseCase;
  final DeleteTask deleteTaskUseCase;
  final GetTasksStream getTasksStreamUseCase;

  StreamSubscription? _tasksSubscription;

  TasksBloc(
    this.getTasksUseCase,
    this.addTaskUseCase,
    this.updateTaskUseCase,
    this.deleteTaskUseCase,
    this.getTasksStreamUseCase,
  ) : super(TasksInitial()) {
    on<LoadTasksEvent>((event, emit) async {
      emit(TasksLoading());
      try {
        final tasks = await getTasksUseCase();
        emit(TasksLoaded(tasks));
      } catch (e) {
        emit(TasksError("Failed to load tasks: ${e.toString()}"));
      }
    });

    on<SubscribeToTasksEvent>((event, emit) {
      // Cancel any previous subscription.
      _tasksSubscription?.cancel();
      _tasksSubscription = getTasksStreamUseCase().listen(
        (tasks) => add(LoadTasksEvent()),
        onError: (error) => emit(TasksError("Stream error: $error")),
      );
    });

    on<AddTaskEvent>((event, emit) async {
      try {
        await addTaskUseCase(event.task);
        final tasks = await getTasksUseCase();
        emit(TasksLoaded(tasks));
      } catch (e) {
        emit(TasksError("Failed to add task: ${e.toString()}"));
      }
    });

    on<UpdateTaskEvent>((event, emit) async {
      try {
        await updateTaskUseCase(event.task);
        // Reload tasks after updating
        final tasks = await getTasksUseCase();
        emit(TasksLoaded(tasks));
      } catch (e) {
        emit(TasksError("Failed to update task: ${e.toString()}"));
      }
    });

    on<DeleteTaskEvent>((event, emit) async {
      try {
        await deleteTaskUseCase(event.taskId);
        // Reload tasks after deleting
        final tasks = await getTasksUseCase();
        emit(TasksLoaded(tasks));
      } catch (e) {
        emit(TasksError("Failed to delete task: ${e.toString()}"));
      }
    });
  }

  @override
  Future<void> close() {
    _tasksSubscription?.cancel();
    return super.close();
  }
}
