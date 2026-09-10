import '../domain/reminder_model.dart';

/// Reminders repository interface
abstract class ReminderRepository {
  Future<List<Reminder>> getReminders();
  Future<Reminder?> getReminderById(String id);
  Future<Reminder> createReminder(Reminder reminder);
  Future<Reminder> updateReminder(Reminder reminder);
  Future<void> deleteReminder(String id);
  Future<void> completeReminder(String id);
  Future<void> snoozeReminder(String id, Duration duration);
}
