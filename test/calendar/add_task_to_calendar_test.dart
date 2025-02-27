import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:task/features/tasks/domain/entities/task.dart';
import 'package:task/features/tasks/domain/usecases/add_task_to_calendar.dart';

import '../test.mocks.dart';

void main() {
  late MockCalendarService mockCalendarService;
  late AddTaskToCalendar addTaskToCalendar;

  setUp(() {
    mockCalendarService = MockCalendarService();
    addTaskToCalendar = AddTaskToCalendar(mockCalendarService);
  });

  test('should return event id when successful', () async {
    final task = Task(
      id: '1',
      title: 'Task1',
      description: 'Desc',
      startTime: DateTime(2025, 1, 1, 10, 0),
      dueDateTime: DateTime(2025, 1, 1, 11, 0),
      ownerId: 'user1',
    );
    when(mockCalendarService.addOrUpdateEvent(
      title: task.title,
      start: task.startTime!,
      end: task.dueDateTime!,
      description: task.description,
      existingEventId: null,
    )).thenAnswer((_) async => "event123");

    final result = await addTaskToCalendar(task);
    expect(result, "event123");
    verify(mockCalendarService.addOrUpdateEvent(
      title: task.title,
      start: task.startTime!,
      end: task.dueDateTime!,
      description: task.description,
      existingEventId: null,
    )).called(1);
  });
}
