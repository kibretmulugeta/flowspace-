import '../domain/calendar_event_model.dart';
import '../domain/calendar_model.dart';

/// Calendar repository interface
abstract class CalendarRepository {
  Future<List<Calendar>> getCalendars();
  Future<List<CalendarEvent>> getEvents();
  Future<List<CalendarEvent>> getEventsForRange(DateTime start, DateTime end);
  Future<CalendarEvent?> getEventById(String id);
  Future<CalendarEvent> createEvent(CalendarEvent event);
  Future<CalendarEvent> updateEvent(CalendarEvent event);
  Future<void> deleteEvent(String id);
  Future<CalendarEvent> duplicateEvent(String id);
}
