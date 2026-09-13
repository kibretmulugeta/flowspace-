import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../features/calendar/domain/calendar_event_model.dart';
import '../../features/calendar/domain/calendar_model.dart';
import '../../features/categories/domain/category_model.dart';
import '../../features/categories/domain/tag_model.dart';
import '../../features/notes/domain/note_page_model.dart';
import '../../features/projects/domain/project_model.dart';
import '../../features/reminders/domain/reminder_model.dart';
import '../../features/tasks/domain/task_model.dart';
import '../constants/sample_data.dart';

/// Production-grade Persistent Database Service for FlowSpace
/// Backed by SharedPreferences (LocalStorage/IndexedDB on Web, disk on Mobile/Desktop).
class LocalDatabaseService {
  static final LocalDatabaseService instance = LocalDatabaseService._internal();
  LocalDatabaseService._internal();

  SharedPreferences? _prefs;
  bool _initialized = false;

  bool get isConnected => _initialized;

  static const String _keyTasks = 'flowspace_db_tasks_v1';
  static const String _keyNotes = 'flowspace_db_notes_v1';
  static const String _keyProjects = 'flowspace_db_projects_v1';
  static const String _keyCategories = 'flowspace_db_categories_v1';
  static const String _keyTags = 'flowspace_db_tags_v1';
  static const String _keyCalendars = 'flowspace_db_calendars_v1';
  static const String _keyEvents = 'flowspace_db_events_v1';
  static const String _keyReminders = 'flowspace_db_reminders_v1';
  static const String _keySeeded = 'flowspace_db_seeded_v1';

  Future<void> initialize() async {
    if (_initialized) return;
    _prefs = await SharedPreferences.getInstance();
    _initialized = true;

    final isSeeded = _prefs?.getBool(_keySeeded) ?? false;
    if (!isSeeded) {
      await _seedInitialData();
    }
  }

  Future<void> _seedInitialData() async {
    await saveTasks(SampleData.tasks);
    await saveNotes(SampleData.notePages);
    await saveProjects(SampleData.projects);
    await saveCategories(SampleData.categories);
    await saveTags(SampleData.tags);
    await saveCalendars(SampleData.calendars);
    await saveEvents(SampleData.calendarEvents);
    await saveReminders(SampleData.reminders);
    await _prefs?.setBool(_keySeeded, true);
  }

  // --- TASKS ---
  Future<List<Task>> loadTasks() async {
    final raw = _prefs?.getString(_keyTasks);
    if (raw == null || raw.isEmpty) return List.from(SampleData.tasks);
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list.map((e) => Task.fromJson(Map<String, dynamic>.from(e as Map))).toList();
    } catch (_) {
      return List.from(SampleData.tasks);
    }
  }

  Future<void> saveTasks(List<Task> tasks) async {
    final list = tasks.map((e) => e.toJson()).toList();
    await _prefs?.setString(_keyTasks, jsonEncode(list));
  }

  // --- NOTES ---
  Future<List<NotePage>> loadNotes() async {
    final raw = _prefs?.getString(_keyNotes);
    if (raw == null || raw.isEmpty) return List.from(SampleData.notePages);
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list.map((e) => NotePage.fromJson(Map<String, dynamic>.from(e as Map))).toList();
    } catch (_) {
      return List.from(SampleData.notePages);
    }
  }

  Future<void> saveNotes(List<NotePage> notes) async {
    final list = notes.map((e) => e.toJson()).toList();
    await _prefs?.setString(_keyNotes, jsonEncode(list));
  }

  // --- PROJECTS ---
  Future<List<Project>> loadProjects() async {
    final raw = _prefs?.getString(_keyProjects);
    if (raw == null || raw.isEmpty) return List.from(SampleData.projects);
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list.map((e) => Project.fromJson(Map<String, dynamic>.from(e as Map))).toList();
    } catch (_) {
      return List.from(SampleData.projects);
    }
  }

  Future<void> saveProjects(List<Project> projects) async {
    final list = projects.map((e) => e.toJson()).toList();
    await _prefs?.setString(_keyProjects, jsonEncode(list));
  }

  // --- CATEGORIES ---
  Future<List<Category>> loadCategories() async {
    final raw = _prefs?.getString(_keyCategories);
    if (raw == null || raw.isEmpty) return List.from(SampleData.categories);
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list.map((e) => Category.fromJson(Map<String, dynamic>.from(e as Map))).toList();
    } catch (_) {
      return List.from(SampleData.categories);
    }
  }

  Future<void> saveCategories(List<Category> categories) async {
    final list = categories.map((e) => e.toJson()).toList();
    await _prefs?.setString(_keyCategories, jsonEncode(list));
  }

  // --- TAGS ---
  Future<List<Tag>> loadTags() async {
    final raw = _prefs?.getString(_keyTags);
    if (raw == null || raw.isEmpty) return List.from(SampleData.tags);
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list.map((e) => Tag.fromJson(Map<String, dynamic>.from(e as Map))).toList();
    } catch (_) {
      return List.from(SampleData.tags);
    }
  }

  Future<void> saveTags(List<Tag> tags) async {
    final list = tags.map((e) => e.toJson()).toList();
    await _prefs?.setString(_keyTags, jsonEncode(list));
  }

  // --- CALENDARS ---
  Future<List<Calendar>> loadCalendars() async {
    final raw = _prefs?.getString(_keyCalendars);
    if (raw == null || raw.isEmpty) return List.from(SampleData.calendars);
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list.map((e) => Calendar.fromJson(Map<String, dynamic>.from(e as Map))).toList();
    } catch (_) {
      return List.from(SampleData.calendars);
    }
  }

  Future<void> saveCalendars(List<Calendar> calendars) async {
    final list = calendars.map((e) => e.toJson()).toList();
    await _prefs?.setString(_keyCalendars, jsonEncode(list));
  }

  // --- CALENDAR EVENTS ---
  Future<List<CalendarEvent>> loadEvents() async {
    final raw = _prefs?.getString(_keyEvents);
    if (raw == null || raw.isEmpty) return List.from(SampleData.calendarEvents);
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list.map((e) => CalendarEvent.fromJson(Map<String, dynamic>.from(e as Map))).toList();
    } catch (_) {
      return List.from(SampleData.calendarEvents);
    }
  }

  Future<void> saveEvents(List<CalendarEvent> events) async {
    final list = events.map((e) => e.toJson()).toList();
    await _prefs?.setString(_keyEvents, jsonEncode(list));
  }

  // --- REMINDERS ---
  Future<List<Reminder>> loadReminders() async {
    final raw = _prefs?.getString(_keyReminders);
    if (raw == null || raw.isEmpty) return List.from(SampleData.reminders);
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list.map((e) => Reminder.fromJson(Map<String, dynamic>.from(e as Map))).toList();
    } catch (_) {
      return List.from(SampleData.reminders);
    }
  }

  Future<void> saveReminders(List<Reminder> reminders) async {
    final list = reminders.map((e) => e.toJson()).toList();
    await _prefs?.setString(_keyReminders, jsonEncode(list));
  }

  // --- BACKUP & RESTORE UTILITIES ---
  Future<String> exportDatabaseJson() async {
    final payload = {
      'version': '1.0.0',
      'exportedAt': DateTime.now().toIso8601String(),
      'tasks': (await loadTasks()).map((e) => e.toJson()).toList(),
      'notes': (await loadNotes()).map((e) => e.toJson()).toList(),
      'projects': (await loadProjects()).map((e) => e.toJson()).toList(),
      'categories': (await loadCategories()).map((e) => e.toJson()).toList(),
      'tags': (await loadTags()).map((e) => e.toJson()).toList(),
      'calendars': (await loadCalendars()).map((e) => e.toJson()).toList(),
      'events': (await loadEvents()).map((e) => e.toJson()).toList(),
      'reminders': (await loadReminders()).map((e) => e.toJson()).toList(),
    };
    return const JsonEncoder.withIndent('  ').convert(payload);
  }

  Future<bool> importDatabaseJson(String jsonStr) async {
    try {
      final data = jsonDecode(jsonStr) as Map<String, dynamic>;
      if (data.containsKey('tasks')) {
        final list = (data['tasks'] as List<dynamic>)
            .map((e) => Task.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList();
        await saveTasks(list);
      }
      if (data.containsKey('notes')) {
        final list = (data['notes'] as List<dynamic>)
            .map((e) => NotePage.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList();
        await saveNotes(list);
      }
      if (data.containsKey('projects')) {
        final list = (data['projects'] as List<dynamic>)
            .map((e) => Project.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList();
        await saveProjects(list);
      }
      if (data.containsKey('categories')) {
        final list = (data['categories'] as List<dynamic>)
            .map((e) => Category.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList();
        await saveCategories(list);
      }
      if (data.containsKey('tags')) {
        final list = (data['tags'] as List<dynamic>)
            .map((e) => Tag.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList();
        await saveTags(list);
      }
      if (data.containsKey('calendars')) {
        final list = (data['calendars'] as List<dynamic>)
            .map((e) => Calendar.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList();
        await saveCalendars(list);
      }
      if (data.containsKey('events')) {
        final list = (data['events'] as List<dynamic>)
            .map((e) => CalendarEvent.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList();
        await saveEvents(list);
      }
      if (data.containsKey('reminders')) {
        final list = (data['reminders'] as List<dynamic>)
            .map((e) => Reminder.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList();
        await saveReminders(list);
      }
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> resetToSampleData() async {
    await _seedInitialData();
  }
}
