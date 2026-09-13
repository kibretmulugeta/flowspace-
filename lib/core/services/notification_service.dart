import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/calendar/presentation/calendar_provider.dart';
import '../../features/reminders/domain/notification_model.dart';
import '../../features/reminders/presentation/reminder_provider.dart';
import '../../features/tasks/presentation/task_provider.dart';
import '../utils/date_formatter.dart';
import 'native_notification_service.dart';
import 'web_notification_helper.dart';

class NotificationServiceState {
  final List<AppNotification> activeBanners;
  final List<AppNotification> history;
  final bool isMonitoring;
  final String? feedbackToast;

  const NotificationServiceState({
    this.activeBanners = const [],
    this.history = const [],
    this.isMonitoring = false,
    this.feedbackToast,
  });

  AppNotification? get activeBanner => activeBanners.isNotEmpty ? activeBanners.first : null;
  int get bannerCount => activeBanners.length;

  NotificationServiceState copyWith({
    List<AppNotification>? activeBanners,
    List<AppNotification>? history,
    bool? isMonitoring,
    String? feedbackToast,
    bool clearFeedbackToast = false,
  }) {
    return NotificationServiceState(
      activeBanners: activeBanners ?? this.activeBanners,
      history: history ?? this.history,
      isMonitoring: isMonitoring ?? this.isMonitoring,
      feedbackToast: clearFeedbackToast ? null : (feedbackToast ?? this.feedbackToast),
    );
  }
}

class NotificationServiceNotifier extends Notifier<NotificationServiceState> {
  Timer? _timer;
  Timer? _feedbackTimer;
  final Set<String> _dismissedKeys = {};
  final Map<String, DateTime> _snoozedKeys = {};

  @override
  NotificationServiceState build() {
    ref.onDispose(() {
      _timer?.cancel();
      _feedbackTimer?.cancel();
    });

    // Start scanner after initial frame
    Future.microtask(() => startMonitoring());
    return const NotificationServiceState();
  }

  void startMonitoring() {
    if (_timer != null) return;
    state = state.copyWith(isMonitoring: true);

    // Initialize native offline alarm service (guarantees alerts when phone is locked)
    NativeNotificationService.instance.initialize();

    // Initial check
    _checkScheduledItems();

    // Check periodically for due items
    _timer = Timer.periodic(const Duration(seconds: 3), (_) {
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
    final List<AppNotification> newAlerts = [];

    // 1. Check Reminders & Register Offline Lock-Screen Alarms
    final reminderState = ref.read(reminderProvider);
    for (final rem in reminderState.pendingReminders) {
      DateTime alertTime = rem.scheduledAt;
      if (rem.isSnoozed && rem.snoozeUntil != null) {
        if (now.isBefore(rem.snoozeUntil!)) continue;
        alertTime = rem.snoozeUntil!;
      }

      // Schedule native offline lock-screen alarm if scheduled in future
      if (alertTime.isAfter(now)) {
        NativeNotificationService.instance.scheduleOfflineAlarm(
          id: NativeNotificationService.generateAlarmId('rem_${rem.id}'),
          title: '⏰ Reminder: ${rem.title}',
          body: rem.description.isNotEmpty
              ? rem.description
              : 'Scheduled for ${DateFormatter.formatTime(alertTime)}',
          scheduledAt: alertTime,
        );
      }

      final key = 'reminder_${rem.id}_${alertTime.millisecondsSinceEpoch}';
      if (_dismissedKeys.contains(key)) continue;
      if (state.activeBanners.any((b) => b.id == key)) continue;

      // Check if scheduled time has arrived (within the last 24 hours)
      if (now.isAfter(alertTime) && now.difference(alertTime).inHours < 24) {
        newAlerts.add(
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
      if (_dismissedKeys.contains(key)) continue;
      if (state.activeBanners.any((b) => b.id == key)) continue;

      if (now.isAfter(taskDueDateTime) && now.difference(taskDueDateTime).inHours < 24) {
        newAlerts.add(
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
      if (_dismissedKeys.contains(key)) continue;
      if (state.activeBanners.any((b) => b.id == key)) continue;

      if (now.isAfter(alertTime) && now.isBefore(ev.endDateTime)) {
        newAlerts.add(
          AppNotification(
            id: key,
            title: '📅 Event Alert: ${ev.title}',
            body: ev.location != null && ev.location!.isNotEmpty
                ? 'At ${ev.location} • Starts ${DateFormatter.formatTime(ev.startDateTime)}'
                : 'Starts at ${DateFormatter.formatTime(ev.startDateTime)}',
            scheduledTime: ev.startDateTime,
            payloadType: 'event',
            payloadId: ev.id,
            createdAt: now,
            updatedAt: now,
          ),
        );
      }
    }

    if (newAlerts.isNotEmpty) {
      for (final alert in newAlerts) {
        WebNotificationHelper.showNotification(alert.title, alert.body);
      }
      state = state.copyWith(
        activeBanners: [...state.activeBanners, ...newAlerts],
        history: [...newAlerts, ...state.history],
      );
    }
  }

  void showNotification(AppNotification notification) {
    WebNotificationHelper.showNotification(notification.title, notification.body);
    NativeNotificationService.instance.showInstantNotification(
      id: NativeNotificationService.generateAlarmId(notification.id),
      title: notification.title,
      body: notification.body,
    );

    final exists = state.activeBanners.any((b) => b.id == notification.id);
    final updatedActive = exists ? state.activeBanners : [notification, ...state.activeBanners];
    final updatedHistory = [notification, ...state.history];

    state = state.copyWith(
      activeBanners: updatedActive,
      history: updatedHistory,
    );
  }

  /// Dismisses a specific banner or the current top banner.
  /// The banner is permanently removed from the active queue and will NOT auto-reappear.
  void dismissBanner([String? id]) {
    final targetId = id ?? state.activeBanner?.id;
    if (targetId == null) return;

    _dismissedKeys.add(targetId);
    final updated = state.activeBanners.where((b) => b.id != targetId).toList();
    state = state.copyWith(activeBanners: updated);
  }

  /// Dismiss all active banners at once
  void dismissAll() {
    for (final b in state.activeBanners) {
      _dismissedKeys.add(b.id);
    }
    state = state.copyWith(activeBanners: []);
  }

  /// Cycle to the next banner in the queue
  void nextBanner() {
    if (state.activeBanners.length <= 1) return;
    final first = state.activeBanners.first;
    final rest = state.activeBanners.sublist(1);
    state = state.copyWith(activeBanners: [...rest, first]);
  }

  /// Completes the item (Reminder or Task) and dismisses its banner
  void completeItem(AppNotification notification) async {
    dismissBanner(notification.id);

    // Cancel offline alarm
    await NativeNotificationService.instance.cancelAlarm(
      NativeNotificationService.generateAlarmId(notification.id),
    );

    if (notification.payloadType == 'reminder' && notification.payloadId != null) {
      await ref.read(reminderProvider.notifier).completeReminder(notification.payloadId!);
    } else if (notification.payloadType == 'task' && notification.payloadId != null) {
      await ref.read(taskProvider.notifier).toggleTaskCompletion(notification.payloadId!);
    }

    _showFeedbackToast('✅ Marked as completed: ${notification.title}');
  }

  /// Snoozes an item for a meaningful duration (default: 10 minutes)
  /// Guaranteed not to return for the specified duration and wakes device even if locked.
  void snoozeItem(
    AppNotification notification, {
    Duration duration = const Duration(minutes: 10),
  }) async {
    dismissBanner(notification.id);

    final now = DateTime.now();
    final newTime = now.add(duration);
    final timeStr = DateFormatter.formatTime(newTime);
    final minutes = duration.inMinutes;

    // Schedule 100% offline alarm that will wake phone even if locked and sleeping!
    await NativeNotificationService.instance.scheduleOfflineAlarm(
      id: NativeNotificationService.generateAlarmId(notification.id),
      title: notification.title,
      body: 'Snooze alert • Scheduled for $timeStr',
      scheduledAt: newTime,
    );

    if (notification.payloadType == 'reminder' && notification.payloadId != null) {
      await ref.read(reminderProvider.notifier).snoozeReminder(notification.payloadId!, duration);
    } else if (notification.payloadId != null) {
      _snoozedKeys[notification.payloadId!] = newTime;
    }

    _showFeedbackToast('⏰ Snoozed for $minutes min (Will alert at $timeStr)');
  }

  void _showFeedbackToast(String message) {
    _feedbackTimer?.cancel();
    state = state.copyWith(feedbackToast: message);
    _feedbackTimer = Timer(const Duration(seconds: 4), () {
      state = state.copyWith(clearFeedbackToast: true);
    });
  }

  void clearFeedbackToast() {
    _feedbackTimer?.cancel();
    state = state.copyWith(clearFeedbackToast: true);
  }

  void triggerTestNotification({String type = 'reminder'}) {
    final now = DateTime.now();
    AppNotification notification;

    switch (type) {
      case 'task':
        notification = AppNotification(
          id: 'test_task_${now.millisecondsSinceEpoch}',
          title: '📌 Task Due: Finish presentation slides',
          body: 'Due right now • High Priority',
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
          body: 'Scheduled alert for right now (Stays until removed)',
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
