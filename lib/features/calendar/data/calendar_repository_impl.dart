import 'package:uuid/uuid.dart';
import '../../../core/storage/local_database_service.dart';
import '../domain/calendar_event_model.dart';
import '../domain/calendar_model.dart';
import '../domain/calendar_repository.dart';

/// Concrete persistent CalendarRepository backed by LocalDatabaseService
class CalendarRepositoryImpl implements CalendarRepository {
  List<Calendar>? _calendars;
  List<CalendarEvent>? _events;
  final LocalDatabaseService _db = LocalDatabaseService.instance;
  final _uuid = const Uuid();

  Future<List<Calendar>> _ensureCalendarsLoaded() async {
    _calendars ??= await _db.loadCalendars();
    return _calendars!;
  }

  Future<List<CalendarEvent>> _ensureEventsLoaded() async {
    _events ??= await _db.loadEvents();
    return _events!;
  }

  @override
  Future<List<Calendar>> getCalendars() async {
    final calendars = await _ensureCalendarsLoaded();
    return List.unmodifiable(calendars);
  }

  @override
  Future<List<CalendarEvent>> getEvents() async {
    final events = await _ensureEventsLoaded();
    return List.unmodifiable(events);
  }

  @override
  Future<List<CalendarEvent>> getEventsForRange(DateTime start, DateTime end) async {
    final events = await _ensureEventsLoaded();
    return events.where((event) {
      return event.startDateTime.isAfter(start.subtract(const Duration(seconds: 1))) &&
          event.startDateTime.isBefore(end.add(const Duration(seconds: 1)));
    }).toList();
  }

  @override
  Future<CalendarEvent?> getEventById(String id) async {
    final events = await _ensureEventsLoaded();
    try {
      return events.firstWhere((e) => e.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<CalendarEvent> createEvent(CalendarEvent event) async {
    final events = await _ensureEventsLoaded();
    events.add(event);
    await _db.saveEvents(events);
    return event;
  }

  @override
  Future<CalendarEvent> updateEvent(CalendarEvent event) async {
    final events = await _ensureEventsLoaded();
    final index = events.indexWhere((e) => e.id == event.id);
    if (index != -1) {
      events[index] = event;
    } else {
      events.add(event);
    }
    await _db.saveEvents(events);
    return event;
  }

  @override
  Future<void> deleteEvent(String id) async {
    final events = await _ensureEventsLoaded();
    events.removeWhere((e) => e.id == id);
    await _db.saveEvents(events);
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
    final events = await _ensureEventsLoaded();
    events.add(duplicated);
    await _db.saveEvents(events);
    return duplicated;
  }
}
