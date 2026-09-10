import '../../../core/constants/sample_data.dart';
import '../domain/reminder_model.dart';
import '../domain/reminder_repository.dart';

/// Concrete ReminderRepository implementation
class ReminderRepositoryImpl implements ReminderRepository {
  final List<Reminder> _reminders = List.from(SampleData.reminders);

  @override
  Future<List<Reminder>> getReminders() async {
    return List.unmodifiable(_reminders);
  }

  @override
  Future<Reminder?> getReminderById(String id) async {
    try {
      return _reminders.firstWhere((r) => r.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<Reminder> createReminder(Reminder reminder) async {
    _reminders.insert(0, reminder);
    return reminder;
  }

  @override
  Future<Reminder> updateReminder(Reminder reminder) async {
    final index = _reminders.indexWhere((r) => r.id == reminder.id);
    if (index != -1) {
      _reminders[index] = reminder;
    } else {
      _reminders.add(reminder);
    }
    return reminder;
  }

  @override
  Future<void> deleteReminder(String id) async {
    _reminders.removeWhere((r) => r.id == id);
  }

  @override
  Future<void> completeReminder(String id) async {
    final index = _reminders.indexWhere((r) => r.id == id);
    if (index != -1) {
      _reminders[index] = _reminders[index].copyWith(
        isCompleted: true,
        updatedAt: DateTime.now(),
      );
    }
  }

  @override
  Future<void> snoozeReminder(String id, Duration duration) async {
    final index = _reminders.indexWhere((r) => r.id == id);
    if (index != -1) {
      final now = DateTime.now();
      _reminders[index] = _reminders[index].copyWith(
        isSnoozed: true,
        snoozeUntil: now.add(duration),
        updatedAt: now,
      );
    }
  }
}
