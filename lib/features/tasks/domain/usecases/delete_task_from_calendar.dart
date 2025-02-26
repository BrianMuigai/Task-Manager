import 'package:injectable/injectable.dart';
import 'package:task/core/services/calendar_service.dart';

@lazySingleton
class DeleteTaskFromCalendar {
  final CalendarService calendarService;

  DeleteTaskFromCalendar(this.calendarService);

  Future<bool> call(String calendarEventId) async {
    return await calendarService.deleteEvent(calendarEventId);
  }
}
