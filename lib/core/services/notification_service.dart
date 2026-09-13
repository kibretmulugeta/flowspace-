import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/calendar/presentation/calendar_provider.dart';
import '../../features/reminders/domain/notification_model.dart';
import '../../features/reminders/presentation/reminder_provider.dart';
import '../../features/tasks/presentation/task_provider.dart';
import '../utils/date_formatter.dart';
import 'web_notification_helper.dart';

class NotificationServiceState {
  final AppNotification? activeBanner;
  final List<AppNotification> history;
  final bool isMonitoring;

  const NotificationServiceState({
    this.activeBanner,
    this.history = const [],
    this.isMonitoring = false,
  });

  NotificationServiceState copyWith({
    AppNotification? activeBanner,
    bool clearActiveBanner = false,
    List<AppNotification>? history,
    bool? isMonitoring,
  }) {
    return NotificationServiceState(
      activeBanner: clearActiveBanner ? null : (activeBanner ?? this.activeBanner),
      history: history ?? this.history,
      isMonitoring: isMonitoring ?? this.isMonitoring,
    );
  }
}

class NotificationServiceNotifier extends Notifier<NotificationServiceState> {
  Timer? _timer;
  Timer? _autoDismissTimer;
  final Set<String> _firedAlertKeys = {};
  final Map<String, DateTime> _snoozedKeys = {};

  @override
  NotificationServiceState build() {
    ref.onDispose(() {
      _timer?.cancel();
      _autoDismissTimer?.cancel();
    });

    // Start background scanner after initial frame
    Future.microtask(() => startMonitoring());
    return const NotificationServiceState();
  }

  void startMonitoring() {
    if (_timer != null) return;
    state = state.copyWith(isMonitoring: true);

    // Initial check
    _checkScheduledItems();

    // Scan every 5 seconds for scheduled times
    _timer = Timer.periodic(const Duration(seconds: 5), (_) {
      _checkScheduledItems();
    });
  }

  void stopMonitoring() {
    _timer?.cancel();
    _timer = null;
    state = state.copyWith(isMonitoring: false);
  }

  void _checkScheduledItems() {
    final now = DateTime.now();

    // 1. Check Reminders
    final reminderState = ref.read(reminderProvider);
    for (final rem in reminderState.pendingReminders) {
      DateTime alertTime = rem.scheduledAt;
      if (rem.isSnoozed && rem.snoozeUntil != null) {
        alertTime = rem.snoozeUntil!;
      }

      final key = 'reminder_${rem.id}_${alertTime.millisecondsSinceEpoch}';
      if (_firedAlertKeys.contains(key)) continue;

      if (now.isAfter(alertTime) && now.difference(alertTime).inHours < 24) {
        _firedAlertKeys.add(key);
        showNotification(
          AppNotification(
            id: key,
            title: '⏰ Reminder: ${rem.title}',
            body: rem.description.isNotEmpty
                ? rem.description
                : 'Scheduled for ${DateFormatter.formatTime(alertTime)}',
            scheduledTime: alertTime,
            payloadType: 'reminder',
            payloadId: rem.id,
            createdAt: now,
            updatedAt: now,
          ),
        );
        return; // Trigger one banner at a time for optimal UX
      }
    }

    // 2. Check Tasks with Due Date & Time
    final taskState = ref.read(taskProvider);
    for (final task in taskState.tasks) {
      if (task.isCompleted || task.dueDate == null) continue;

      DateTime taskDueDateTime;
      if (task.dueTime != null && task.dueTime!.contains(':')) {
        final parts = task.dueTime!.split(':');
        final hour = int.tryParse(parts[0]) ?? 12;
        final minute = int.tryParse(parts[1]) ?? 0;
        taskDueDateTime = DateTime(
          task.dueDate!.year,
          task.dueDate!.month,
          task.dueDate!.day,
          hour,
          minute,
        );
      } else {
        taskDueDateTime = DateTime(
          task.dueDate!.year,
          task.dueDate!.month,
          task.dueDate!.day,
          9,
          0,
        );
      }

      final snoozeUntil = _snoozedKeys[task.id];
      if (snoozeUntil != null && now.isBefore(snoozeUntil)) continue;

      final key = 'task_${task.id}_${taskDueDateTime.millisecondsSinceEpoch}';
      if (_firedAlertKeys.contains(key)) continue;

      if (now.isAfter(taskDueDateTime) && now.difference(taskDueDateTime).inHours < 24) {
        _firedAlertKeys.add(key);
        showNotification(
          AppNotification(
            id: key,
            title: '📌 Task Due: ${task.title}',
            body: task.dueTime != null
                ? 'Due at ${task.dueTime} today'
                : 'Due date reached today',
            scheduledTime: taskDueDateTime,
            payloadType: 'task',
            payloadId: task.id,
            createdAt: now,
            updatedAt: now,
          ),
        );
        return;
      }
    }

    // 3. Check Calendar Events
    final calendarState = ref.read(calendarProvider);
    for (final ev in calendarState.events) {
      final minsBefore = int.tryParse(ev.reminderMinutesBefore ?? '10') ?? 10;
      final alertTime = ev.startDateTime.subtract(Duration(minutes: minsBefore));

      final snoozeUntil = _snoozedKeys[ev.id];
      if (snoozeUntil != null && now.isBefore(snoozeUntil)) continue;

      final key = 'event_${ev.id}_${alertTime.millisecondsSinceEpoch}';
      if (_firedAlertKeys.contains(key)) continue;

      if (now.isAfter(alertTime) && now.isBefore(ev.endDateTime)) {
        _firedAlertKeys.add(key);
        showNotification(
          AppNotification(
            id: key,
            title: '📅 Event Alert: ${ev.title}',
            body: ev.location != null && ev.location!.isNotEmpty
                ? 'At ${ev.location} • ${DateFormatter.formatTime(ev.startDateTime)}'
                : 'Starts at ${DateFormatter.formatTime(ev.startDateTime)}',
            scheduledTime: ev.startDateTime,
            payloadType: 'event',
            payloadId: ev.id,
            createdAt: now,
            updatedAt: now,
          ),
        );
        return;
      }
    }
  }

  void showNotification(AppNotification notification) {
    _autoDismissTimer?.cancel();

    // Trigger browser-level notification if permitted on web
    WebNotificationHelper.showNotification(notification.title, notification.body);

    final updatedHistory = [notification, ...state.history];
    state = state.copyWith(
      activeBanner: notification,
      history: updatedHistory,
    );

    // Automatically dismiss on-screen banner after 8 seconds if not interacted with
    _autoDismissTimer = Timer(const Duration(seconds: 8), () {
      dismissBanner();
    });
  }

  void dismissBanner() {
    _autoDismissTimer?.cancel();
    state = state.copyWith(clearActiveBanner: true);
  }

  void completeItem(AppNotification notification) async {
    dismissBanner();

    if (notification.payloadType == 'reminder' && notification.payloadId != null) {
      await ref.read(reminderProvider.notifier).completeReminder(notification.payloadId!);
    } else if (notification.payloadType == 'task' && notification.payloadId != null) {
      await ref.read(taskProvider.notifier).toggleTaskCompletion(notification.payloadId!);
    }
  }

  void snoozeItem(AppNotification notification, {Duration duration = const Duration(minutes: 5)}) async {
    dismissBanner();
    final newTime = DateTime.now().add(duration);

    if (notification.payloadType == 'reminder' && notification.payloadId != null) {
      await ref.read(reminderProvider.notifier).snoozeReminder(notification.payloadId!, duration);
    } else if (notification.payloadId != null) {
      _snoozedKeys[notification.payloadId!] = newTime;
    }
  }

  void triggerTestNotification({String type = 'reminder'}) {
    final now = DateTime.now();
    AppNotification notification;

    switch (type) {
      case 'task':
        notification = AppNotification(
          id: 'test_task_${now.millisecondsSinceEpoch}',
          title: '📌 Task Due: Finish presentation slides',
          body: 'Due now • High Priority',
          scheduledTime: now,
          payloadType: 'task',
          payloadId: 'test-task',
          createdAt: now,
          updatedAt: now,
        );
        break;
      case 'event':
        notification = AppNotification(
          id: 'test_event_${now.millisecondsSinceEpoch}',
          title: '📅 Event Starting: Architecture Review Sync',
          body: 'Starts in 5 minutes • Room 402 / Zoom',
          scheduledTime: now.add(const Duration(minutes: 5)),
          payloadType: 'event',
          payloadId: 'test-event',
          createdAt: now,
          updatedAt: now,
        );
        break;
      case 'reminder':
      default:
        notification = AppNotification(
          id: 'test_reminder_${now.millisecondsSinceEpoch}',
          title: '⏰ Reminder: Hydration break & stretch',
          body: 'Scheduled alert for right now',
          scheduledTime: now,
          payloadType: 'reminder',
          payloadId: 'test-reminder',
          createdAt: now,
          updatedAt: now,
        );
        break;
    }

    showNotification(notification);
  }

  Future<bool> requestBrowserPermission() async {
    return await WebNotificationHelper.requestPermission();
  }
}

final notificationServiceProvider =
    NotifierProvider<NotificationServiceNotifier, NotificationServiceState>(
  NotificationServiceNotifier.new,
);
