import 'package:add_2_calendar/add_2_calendar.dart';
import 'package:flutter/foundation.dart';

class CalendarService {
  Future<bool> addEvent({
    required String title,
    required String description,
    required DateTime startDate,
    required DateTime endDate,
    String? location,
    bool allDay = false,
  }) async {
    final event = Event(
      title: title,
      description: description,
      location: location ?? 'No location',
      startDate: startDate,
      endDate: endDate,
      allDay: allDay,
    );

    try {
      return await Add2Calendar.addEvent2Cal(event);
    } catch (e) {
      debugPrint('Error adding event to calendar: $e');
      return false;
    }
  }
}
