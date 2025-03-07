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
  final List<Task> _allTasks = [];

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
        _sortTasks(tasks);
        _allTasks.clear();
        _allTasks.addAll(tasks);
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
        final createdTask = await addTaskUseCase(event.task);
        final tasks = await getTasksUseCase();
        emit(TasksLoaded(tasks));

        final eventId = await addTaskToCalendarUseCase(createdTask);
        if (eventId != null) {
          // Update the task with the new calendar event id.
          final updatedTask = createdTask.copyWith(calendarEventId: eventId);
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
        if (event.task.startTime != null || event.task.dueDateTime != null) {
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
        _sortTasks(tasks);
        _allTasks.clear();
        _allTasks.addAll(tasks);
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
        _allTasks.remove(taskToDelete);
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

    on<FilterTasksEvent>((event, emit) {
      // Apply filters on _allTasks:
      var filtered = _allTasks;
      if (event.name != null && event.name!.isNotEmpty) {
        filtered = filtered
            .where((task) =>
                task.title.toLowerCase().contains(event.name!.toLowerCase()))
            .toList();
      }
      if (event.date != null) {
        filtered = filtered.where((task) {
          if (task.dueDateTime == null) return false;
          final taskDate = DateTime(task.dueDateTime!.year,
              task.dueDateTime!.month, task.dueDateTime!.day);
          final filterDate =
              DateTime(event.date!.year, event.date!.month, event.date!.day);
          return taskDate == filterDate;
        }).toList();
      }
      if (event.priority != null) {
        filtered =
            filtered.where((task) => task.priority == event.priority).toList();
      }
      if (event.tags != null && event.tags!.isNotEmpty) {
        filtered = filtered.where((task) {
          if (task.tags == null || task.tags!.isEmpty) return false;
          // Check if any filter tag exists in the task's tags.
          return event.tags!.any((tag) => task.tags!.contains(tag));
        }).toList();
      }
      emit(TasksLoaded(filtered));
    });
  }

  void _sortTasks(List<Task> tasks) {
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
      if (a.startTime != null && b.startTime != null) {
        return a.startTime!.compareTo(b.startTime!);
      }
      // If only a has no due date, place it after b.
      if (a.startTime == null && b.startTime != null) return 1;
      // If only b has no due date, place it after a.
      if (a.startTime != null && b.startTime == null) return -1;
      // If both are null, they are equal.
      return 0;
    });
  }

  @override
  Future<void> close() {
    _tasksSubscription?.cancel();
    return super.close();
  }
}
