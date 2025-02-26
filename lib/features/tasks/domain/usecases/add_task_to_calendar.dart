import 'package:injectable/injectable.dart';
import 'package:task/core/services/calendar_service.dart';

import '../../domain/entities/task.dart';

@lazySingleton
class AddTaskToCalendar {
  final CalendarService calendarService;

  AddTaskToCalendar(this.calendarService);

  /// Returns the event id if successful, or null otherwise.
  Future<String?> call(Task task) async {
    if (task.startTime == null || task.dueDateTime == null) return null;
    return await calendarService.addOrUpdateEvent(
      title: task.title,
      start: task.startTime!,
      end: task.dueDateTime!,
      description: task.description,
      existingEventId: task.calendarEventId,
    );
  }
}
