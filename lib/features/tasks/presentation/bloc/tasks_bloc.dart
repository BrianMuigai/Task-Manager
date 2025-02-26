import 'dart:async';
import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:task/features/auth/domain/entities/user.dart';
import 'package:task/features/auth/domain/usecases/search_users.dart';
import 'package:task/features/tasks/domain/entities/task.dart';
import 'package:task/features/tasks/domain/usecases/add_task.dart';
import 'package:task/features/tasks/domain/usecases/add_task_to_calendar.dart';
import 'package:task/features/tasks/domain/usecases/delete_task.dart';
import 'package:task/features/tasks/domain/usecases/delete_task_from_calendar.dart';
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
  final SearchUsers searchUsersUseCase;
  final AddTaskToCalendar addTaskToCalendarUseCase;
  final DeleteTaskFromCalendar deleteTaskFromCalendarUseCase;

  StreamSubscription? _tasksSubscription;

  TasksBloc(
    this.getTasksUseCase,
    this.addTaskUseCase,
    this.updateTaskUseCase,
    this.deleteTaskUseCase,
    this.getTasksStreamUseCase,
    this.searchUsersUseCase,
    this.addTaskToCalendarUseCase,
    this.deleteTaskFromCalendarUseCase,
  ) : super(TasksInitial()) {
    on<LoadTasksEvent>((event, emit) async {
      emit(TasksLoading());
      try {
        final tasks = await getTasksUseCase();
        // Sort tasks:
        // 1. Uncompleted tasks come first.
        // 2. Then sort by due date. Tasks without due date come last.
        tasks.sort((a, b) {
          // Bring uncompleted tasks first.
          if (a.completed != b.completed) {
            return a.completed ? 1 : -1;
          }
          // Both tasks have the same completion status.
          // If both have due dates, compare them.
          if (a.dueDate != null && b.dueDate != null) {
            return a.dueDate!.compareTo(b.dueDate!);
          }
          // If only a has no due date, place it after b.
          if (a.dueDate == null && b.dueDate != null) return 1;
          // If only b has no due date, place it after a.
          if (a.dueDate != null && b.dueDate == null) return -1;
          // If both are null, they are equal.
          return 0;
        });
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

        final eventId = await addTaskToCalendarUseCase(event.task);
        if (eventId != null) {
          // Update the task with the new calendar event id.
          final updatedTask = event.task.copyWith(calendarEventId: eventId);
          await updateTaskUseCase(updatedTask);
          final tasksAfterUpdate = await getTasksUseCase();
          emit(TasksLoaded(tasksAfterUpdate));
          emit(CalendarSyncSuccess());
        } else {
          emit(CalendarSyncFailure());
        }
      } catch (e) {
        emit(TasksError("Failed to add task: ${e.toString()}"));
      }
    });

    on<UpdateTaskEvent>((event, emit) async {
      try {
        await updateTaskUseCase(event.task);
        // Update calendar event if dueDate is present.
        if (event.task.dueDate != null) {
          final eventId = await addTaskToCalendarUseCase(event.task);
          if (eventId != null) {
            // Update the task with the new calendar event id if needed.
            final updatedTask = event.task.copyWith(calendarEventId: eventId);
            await updateTaskUseCase(updatedTask);
            emit(CalendarSyncSuccess());
          } else {
            emit(CalendarSyncFailure());
          }
        }
        // Reload tasks after updating
        final tasks = await getTasksUseCase();
        emit(TasksLoaded(tasks));
      } catch (e) {
        emit(TasksError("Failed to update task: ${e.toString()}"));
      }
    });

    on<DeleteTaskEvent>((event, emit) async {
      try {
        // Before deleting, if the task has a calendar event, delete it.
        final currentTasks = await getTasksUseCase();
        final taskToDelete =
            currentTasks.firstWhereOrNull((t) => t.id == event.taskId);
        if (taskToDelete != null && taskToDelete.calendarEventId != null) {
          await deleteTaskFromCalendarUseCase(taskToDelete.calendarEventId!);
        }
        await deleteTaskUseCase(event.taskId);
        // Reload tasks after deleting
        final tasks = await getTasksUseCase();
        emit(TasksLoaded(tasks));
      } catch (e) {
        emit(TasksError("Failed to delete task: ${e.toString()}"));
      }
    });

    on<SearchCollaboratorsEvent>((event, emit) async {
      try {
        emit(CollaboratorsSearchLoading());
        final results = await searchUsersUseCase(event.query);
        // Filter out the current user if needed.
        final filteredResults =
            results.where((user) => user.uid != event.currentUserId).toList();
        emit(CollaboratorsSearchLoaded(filteredResults));
      } catch (e) {
        emit(CollaboratorsSearchError(e.toString()));
      }
    });
  }

  @override
  Future<void> close() {
    _tasksSubscription?.cancel();
    return super.close();
  }
}
