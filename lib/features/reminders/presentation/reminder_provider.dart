import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../data/reminder_repository_impl.dart';
import '../domain/reminder_model.dart';
import '../domain/reminder_repository.dart';

final reminderRepositoryProvider = Provider<ReminderRepository>((ref) {
  return ReminderRepositoryImpl();
});

class ReminderState {
  final List<Reminder> reminders;
  final bool isLoading;

  const ReminderState({
    this.reminders = const [],
    this.isLoading = false,
  });

  ReminderState copyWith({
    List<Reminder>? reminders,
    bool? isLoading,
  }) {
    return ReminderState(
      reminders: reminders ?? this.reminders,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  List<Reminder> get pendingReminders {
    return reminders.where((r) => !r.isCompleted).toList();
  }

  List<Reminder> get completedReminders {
    return reminders.where((r) => r.isCompleted).toList();
  }
}

class ReminderNotifier extends Notifier<ReminderState> {
  late final ReminderRepository _repository;
  final _uuid = const Uuid();

  @override
  ReminderState build() {
    _repository = ref.read(reminderRepositoryProvider);
    Future.microtask(() => loadReminders());
    return const ReminderState();
  }

  Future<void> loadReminders() async {
    state = state.copyWith(isLoading: true);
    final list = await _repository.getReminders();
    state = state.copyWith(reminders: list, isLoading: false);
  }

  Future<Reminder> addReminder({
    required String title,
    String description = '',
    required DateTime scheduledAt,
    ReminderTargetType targetType = ReminderTargetType.standalone,
    String? targetId,
    ReminderRecurrence recurrence = ReminderRecurrence.none,
  }) async {
    final now = DateTime.now();
    final newReminder = Reminder(
      id: _uuid.v4(),
      title: title,
      description: description,
      scheduledAt: scheduledAt,
      targetType: targetType,
      targetId: targetId,
      recurrence: recurrence,
      createdAt: now,
      updatedAt: now,
    );

    await _repository.createReminder(newReminder);
    state = state.copyWith(reminders: [newReminder, ...state.reminders]);
    return newReminder;
  }

  Future<void> updateReminder(Reminder reminder) async {
    await _repository.updateReminder(reminder);
    final list = state.reminders.map((r) => r.id == reminder.id ? reminder : r).toList();
    state = state.copyWith(reminders: list);
  }

  Future<void> completeReminder(String id) async {
    await _repository.completeReminder(id);
    final list = state.reminders.map((r) {
      if (r.id == id) {
        return r.copyWith(isCompleted: true, updatedAt: DateTime.now());
      }
      return r;
    }).toList();
    state = state.copyWith(reminders: list);
  }

  Future<void> snoozeReminder(String id, Duration duration) async {
    await _repository.snoozeReminder(id, duration);
    final list = state.reminders.map((r) {
      if (r.id == id) {
        return r.copyWith(
          isSnoozed: true,
          snoozeUntil: DateTime.now().add(duration),
          updatedAt: DateTime.now(),
        );
      }
      return r;
    }).toList();
    state = state.copyWith(reminders: list);
  }

  Future<void> deleteReminder(String id) async {
    await _repository.deleteReminder(id);
    state = state.copyWith(
      reminders: state.reminders.where((r) => r.id != id).toList(),
    );
  }
}

final reminderProvider = NotifierProvider<ReminderNotifier, ReminderState>(ReminderNotifier.new);
