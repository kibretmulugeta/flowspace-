import '../../../core/storage/local_database_service.dart';
import '../domain/reminder_model.dart';
import '../domain/reminder_repository.dart';

/// Concrete persistent ReminderRepository backed by LocalDatabaseService
class ReminderRepositoryImpl implements ReminderRepository {
  List<Reminder>? _reminders;
  final LocalDatabaseService _db = LocalDatabaseService.instance;

  Future<List<Reminder>> _ensureLoaded() async {
    _reminders ??= await _db.loadReminders();
    return _reminders!;
  }

  @override
  Future<List<Reminder>> getReminders() async {
    final reminders = await _ensureLoaded();
    return List.unmodifiable(reminders);
  }

  @override
  Future<Reminder?> getReminderById(String id) async {
    final reminders = await _ensureLoaded();
    try {
      return reminders.firstWhere((r) => r.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<Reminder> createReminder(Reminder reminder) async {
    final reminders = await _ensureLoaded();
    reminders.insert(0, reminder);
    await _db.saveReminders(reminders);
    return reminder;
  }

  @override
  Future<Reminder> updateReminder(Reminder reminder) async {
    final reminders = await _ensureLoaded();
    final index = reminders.indexWhere((r) => r.id == reminder.id);
    if (index != -1) {
      reminders[index] = reminder;
    } else {
      reminders.add(reminder);
    }
    await _db.saveReminders(reminders);
    return reminder;
  }

  @override
  Future<void> deleteReminder(String id) async {
    final reminders = await _ensureLoaded();
    reminders.removeWhere((r) => r.id == id);
    await _db.saveReminders(reminders);
  }

  @override
  Future<void> completeReminder(String id) async {
    final reminders = await _ensureLoaded();
    final index = reminders.indexWhere((r) => r.id == id);
    if (index != -1) {
      reminders[index] = reminders[index].copyWith(
        isCompleted: true,
        updatedAt: DateTime.now(),
      );
      await _db.saveReminders(reminders);
    }
  }

  @override
  Future<void> snoozeReminder(String id, Duration duration) async {
    final reminders = await _ensureLoaded();
    final index = reminders.indexWhere((r) => r.id == id);
    if (index != -1) {
      final now = DateTime.now();
      reminders[index] = reminders[index].copyWith(
        isSnoozed: true,
        snoozeUntil: now.add(duration),
        updatedAt: now,
      );
      await _db.saveReminders(reminders);
    }
  }
}
