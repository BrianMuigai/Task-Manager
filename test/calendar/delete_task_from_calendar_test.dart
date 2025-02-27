import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:task/features/tasks/domain/usecases/delete_task_from_calendar.dart';

import '../test.mocks.dart';

void main() {
  late MockCalendarService mockCalendarService;
  late DeleteTaskFromCalendar deleteTaskFromCalendar;

  setUp(() {
    mockCalendarService = MockCalendarService();
    deleteTaskFromCalendar = DeleteTaskFromCalendar(mockCalendarService);
  });

  test('should call calendar service to delete event', () async {
    when(mockCalendarService.deleteEvent("event123"))
        .thenAnswer((_) async => true);
    final result = await deleteTaskFromCalendar("event123");
    expect(result, true);
    verify(mockCalendarService.deleteEvent("event123")).called(1);
  });
}
