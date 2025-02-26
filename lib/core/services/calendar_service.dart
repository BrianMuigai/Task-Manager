import 'package:device_calendar/device_calendar.dart';

class CalendarService {
  final DeviceCalendarPlugin _deviceCalendarPlugin = DeviceCalendarPlugin();

  /// Retrieves the first available calendar ID.
  Future<String?> getDefaultCalendarId() async {
    final calendarsResult = await _deviceCalendarPlugin.retrieveCalendars();
    if (!calendarsResult.isSuccess ||
        calendarsResult.data == null ||
        calendarsResult.data!.isEmpty) {
      return null;
    }
    // Return the ID of the first available calendar.
    return calendarsResult.data!.first.id;
  }

  /// Adds (or updates) an event to the local device calendar.
  Future<bool> addEventToCalendar({
    required String title,
    required DateTime start,
    required DateTime end,
    String? description,
  }) async {
    // Check for existing calendar permissions.
    final permissionsResult = await _deviceCalendarPlugin.hasPermissions();
    bool permissionsGranted = permissionsResult.data ?? false;
    if (!permissionsGranted) {
      // Request permissions if not already granted.
      final requestPermissionsResult =
          await _deviceCalendarPlugin.requestPermissions();
      permissionsGranted = requestPermissionsResult.data ?? false;
      if (!permissionsGranted) {
        return false; // Permissions not granted.
      }
    }

    // Retrieve the default calendar ID.
    final calendarId = await getDefaultCalendarId();
    if (calendarId == null) {
      return false; // No available calendar.
    }

    // Create a new event.
    final event = Event(
      calendarId,
      title: title,
      // start: start,
      // end: end,
      description: description,
    );

    // Create or update the event.
    final createOrUpdateResult =
        await _deviceCalendarPlugin.createOrUpdateEvent(event);
    return (createOrUpdateResult?.isSuccess ?? false) &&
        (createOrUpdateResult?.data?.isNotEmpty ?? false);
  }
}
