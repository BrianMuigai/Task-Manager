import 'package:device_calendar/device_calendar.dart';
import 'package:injectable/injectable.dart';
import 'package:timezone/timezone.dart' as tz;

@lazySingleton
class CalendarService {
  final DeviceCalendarPlugin _deviceCalendarPlugin = DeviceCalendarPlugin();

  Future<String?> getDefaultCalendarId() async {
    final calendarsResult = await _deviceCalendarPlugin.retrieveCalendars();
    if (!calendarsResult.isSuccess ||
        calendarsResult.data == null ||
        calendarsResult.data!.isEmpty) {
      return null;
    }
    return calendarsResult.data!.first.id;
  }

  /// Adds or updates an event. If [existingEventId] is provided, it updates that event.
  Future<String?> addOrUpdateEvent({
    required String title,
    required DateTime start,
    required DateTime end,
    String? description,
    String? existingEventId,
  }) async {
    final permissionsResult = await _deviceCalendarPlugin.hasPermissions();
    bool permissionsGranted = permissionsResult.data ?? false;
    if (!permissionsGranted) {
      final requestPermissionsResult =
          await _deviceCalendarPlugin.requestPermissions();
      permissionsGranted = requestPermissionsResult.data ?? false;
      if (!permissionsGranted) {
        return null;
      }
    }

    final calendarId = await getDefaultCalendarId();
    if (calendarId == null) return null;

    final tzStart = tz.TZDateTime.from(start, tz.local);
    final tzEnd = tz.TZDateTime.from(end, tz.local);

    final event = Event(
      calendarId,
      eventId: existingEventId,
      title: title,
      start: tzStart,
      end: tzEnd,
      description: description,
    );

    final result = await _deviceCalendarPlugin.createOrUpdateEvent(event);
    if ((result?.isSuccess ?? false) && (result?.data?.isNotEmpty ?? false)) {
      return result?.data; // Returns eventId
    }
    return null;
  }

  /// Deletes an event from the calendar using its eventId.
  Future<bool> deleteEvent(String eventId) async {
    final calendarId = await getDefaultCalendarId();
    if (calendarId == null) return false;
    final result = await _deviceCalendarPlugin.deleteEvent(calendarId, eventId);
    return result.isSuccess;
  }
}
