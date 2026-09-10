import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../data/calendar_repository_impl.dart';
import '../domain/calendar_event_model.dart';
import '../domain/calendar_model.dart';
import '../domain/calendar_repository.dart';

final calendarRepositoryProvider = Provider<CalendarRepository>((ref) {
  return CalendarRepositoryImpl();
});

enum CalendarViewType {
  day,
  week,
  month,
  agenda;

  String get label {
    switch (this) {
      case CalendarViewType.day:
        return 'Day';
      case CalendarViewType.week:
        return 'Week';
      case CalendarViewType.month:
        return 'Month';
      case CalendarViewType.agenda:
        return 'Agenda';
    }
  }
}

class CalendarState {
  final DateTime selectedDate;
  final CalendarViewType viewType;
  final List<Calendar> calendars;
  final List<CalendarEvent> events;
  final bool isLoading;

  const CalendarState({
    required this.selectedDate,
    this.viewType = CalendarViewType.week,
    this.calendars = const [],
    this.events = const [],
    this.isLoading = false,
  });

  CalendarState copyWith({
    DateTime? selectedDate,
    CalendarViewType? viewType,
    List<Calendar>? calendars,
    List<CalendarEvent>? events,
    bool? isLoading,
  }) {
    return CalendarState(
      selectedDate: selectedDate ?? this.selectedDate,
      viewType: viewType ?? this.viewType,
      calendars: calendars ?? this.calendars,
      events: events ?? this.events,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  List<CalendarEvent> get visibleEvents {
    final visibleCalendarIds = calendars.where((c) => c.isVisible).map((c) => c.id).toSet();
    return events.where((e) => visibleCalendarIds.contains(e.calendarId)).toList();
  }

  List<CalendarEvent> get eventsForSelectedDay {
    return visibleEvents.where((e) {
      return e.startDateTime.year == selectedDate.year &&
          e.startDateTime.month == selectedDate.month &&
          e.startDateTime.day == selectedDate.day;
    }).toList();
  }
}

class CalendarNotifier extends Notifier<CalendarState> {
  late final CalendarRepository _repository;
  final _uuid = const Uuid();

  @override
  CalendarState build() {
    _repository = ref.read(calendarRepositoryProvider);
    Future.microtask(() => loadData());
    return CalendarState(selectedDate: DateTime.now());
  }

  Future<void> loadData() async {
    state = state.copyWith(isLoading: true);
    final cals = await _repository.getCalendars();
    final evts = await _repository.getEvents();
    state = state.copyWith(calendars: cals, events: evts, isLoading: false);
  }

  void setSelectedDate(DateTime date) {
    state = state.copyWith(selectedDate: date);
  }

  void setViewType(CalendarViewType type) {
    state = state.copyWith(viewType: type);
  }

  void toggleCalendarVisibility(String calendarId) {
    final updatedCals = state.calendars.map((c) {
      if (c.id == calendarId) {
        return c.copyWith(isVisible: !c.isVisible);
      }
      return c;
    }).toList();
    state = state.copyWith(calendars: updatedCals);
  }

  Future<void> addEvent({
    required String title,
    String description = '',
    required DateTime startDateTime,
    required DateTime endDateTime,
    String? location,
    required Color color,
    required String calendarId,
    List<String> participants = const [],
    String? reminderMinutesBefore = '15',
    String? recurrence = 'none',
    String? projectId,
    bool isAllDay = false,
  }) async {
    final now = DateTime.now();
    final newEvent = CalendarEvent(
      id: _uuid.v4(),
      title: title,
      description: description,
      startDateTime: startDateTime,
      endDateTime: endDateTime,
      location: location,
      colorValue: color.toARGB32(),
      calendarId: calendarId,
      participants: participants,
      reminderMinutesBefore: reminderMinutesBefore,
      recurrence: recurrence,
      projectId: projectId,
      isAllDay: isAllDay,
      createdAt: now,
      updatedAt: now,
    );

    await _repository.createEvent(newEvent);
    state = state.copyWith(events: [...state.events, newEvent]);
  }

  Future<void> updateEvent(CalendarEvent event) async {
    final updated = event.copyWith(updatedAt: DateTime.now());
    await _repository.updateEvent(updated);
    final list = state.events.map((e) => e.id == updated.id ? updated : e).toList();
    state = state.copyWith(events: list);
  }

  Future<void> deleteEvent(String eventId) async {
    await _repository.deleteEvent(eventId);
    state = state.copyWith(
      events: state.events.where((e) => e.id != eventId).toList(),
    );
  }

  Future<void> duplicateEvent(String eventId) async {
    final dup = await _repository.duplicateEvent(eventId);
    state = state.copyWith(events: [...state.events, dup]);
  }
}

final calendarProvider = NotifierProvider<CalendarNotifier, CalendarState>(CalendarNotifier.new);
