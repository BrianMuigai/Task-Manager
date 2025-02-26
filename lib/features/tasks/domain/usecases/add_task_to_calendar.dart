import 'package:injectable/injectable.dart';
import 'package:task/core/services/calendar_service.dart';

import '../../domain/entities/task.dart';

@lazySingleton
class AddTaskToCalendar {
  final CalendarService calendarService;

  AddTaskToCalendar(this.calendarService);

  /// Returns the event id if the operation is successful, or null otherwise.
  Future<String?> call(Task task) async {
    if (task.dueDate == null) return null;
    final endTime =
        task.dueDate!.add(Duration(hours: 1)); // Example: 1-hour event
    return await calendarService.addOrUpdateEvent(
      title: task.title,
      start: task.dueDate!,
      end: endTime,
      description: task.description,
      existingEventId: task.calendarEventId, // Update if exists
    );
  }
}
