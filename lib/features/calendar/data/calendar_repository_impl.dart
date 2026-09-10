import 'package:uuid/uuid.dart';
import '../../../core/constants/sample_data.dart';
import '../domain/calendar_event_model.dart';
import '../domain/calendar_model.dart';
import '../domain/calendar_repository.dart';

/// Concrete CalendarRepository implementation
class CalendarRepositoryImpl implements CalendarRepository {
  final List<Calendar> _calendars = List.from(SampleData.calendars);
  final List<CalendarEvent> _events = List.from(SampleData.calendarEvents);
  final _uuid = const Uuid();

  @override
  Future<List<Calendar>> getCalendars() async {
    return List.unmodifiable(_calendars);
  }

  @override
  Future<List<CalendarEvent>> getEvents() async {
    return List.unmodifiable(_events);
  }

  @override
  Future<List<CalendarEvent>> getEventsForRange(DateTime start, DateTime end) async {
    return _events.where((event) {
      return event.startDateTime.isAfter(start.subtract(const Duration(seconds: 1))) &&
          event.startDateTime.isBefore(end.add(const Duration(seconds: 1)));
    }).toList();
  }

  @override
  Future<CalendarEvent?> getEventById(String id) async {
    try {
      return _events.firstWhere((e) => e.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<CalendarEvent> createEvent(CalendarEvent event) async {
    _events.add(event);
    return event;
  }

  @override
  Future<CalendarEvent> updateEvent(CalendarEvent event) async {
    final index = _events.indexWhere((e) => e.id == event.id);
    if (index != -1) {
      _events[index] = event;
    } else {
      _events.add(event);
    }
    return event;
  }

  @override
  Future<void> deleteEvent(String id) async {
    _events.removeWhere((e) => e.id == id);
  }

  @override
  Future<CalendarEvent> duplicateEvent(String id) async {
    final original = await getEventById(id);
    if (original == null) {
      throw Exception('Event not found');
    }
    final now = DateTime.now();
    final duplicated = original.copyWith(
      id: _uuid.v4(),
      title: '${original.title} (Copy)',
      startDateTime: original.startDateTime.add(const Duration(hours: 1)),
      endDateTime: original.endDateTime.add(const Duration(hours: 1)),
      createdAt: now,
      updatedAt: now,
    );
    _events.add(duplicated);
    return duplicated;
  }
}
