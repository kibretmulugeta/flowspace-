import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'web_notification_helper.dart';

class NativeNotificationService {
  NativeNotificationService._();
  static final NativeNotificationService instance = NativeNotificationService._();

  FlutterLocalNotificationsPlugin? _plugin;
  bool _isInitialized = false;

  FlutterLocalNotificationsPlugin get plugin {
    _plugin ??= FlutterLocalNotificationsPlugin();
    return _plugin!;
  }

  static const String _channelId = 'flowspace_alarms_channel';
  static const String _channelName = 'FlowSpace Alarms & Reminders';
  static const String _channelDesc =
      'Offline lock-screen reminders and time alarms with sound and vibration';

  /// Initializes timezone data and native lock-screen notification channels
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // 1. Initialize offline timezone database
      tz.initializeTimeZones();

      if (kIsWeb || (Platform.environment.containsKey('FLUTTER_TEST'))) {
        _isInitialized = true;
        return;
      }

      // 2. Android Initialization Settings
      const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

      // 3. iOS / macOS Initialization Settings
      final darwinSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      final initSettings = InitializationSettings(
        android: androidSettings,
        iOS: darwinSettings,
        macOS: darwinSettings,
      );

      await plugin.initialize(
        settings: initSettings,
        onDidReceiveNotificationResponse: (NotificationResponse details) {
          // Handle tap on lock-screen notification
        },
      );

      // 4. Create High-Priority Notification Channel for Android
      if (!kIsWeb && Platform.isAndroid) {
        final androidPlugin = plugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

        if (androidPlugin != null) {
          const androidChannel = AndroidNotificationChannel(
            _channelId,
            _channelName,
            description: _channelDesc,
            importance: Importance.max,
            playSound: true,
            enableVibration: true,
            showBadge: true,
          );
          await androidPlugin.createNotificationChannel(androidChannel);

          // Request notifications permission (Android 13+)
          await androidPlugin.requestNotificationsPermission();
          await androidPlugin.requestExactAlarmsPermission();
        }
      }

      _isInitialized = true;
    } catch (e) {
      debugPrint('NativeNotificationService init warning: $e');
    }
  }

  /// Schedules a 100% offline alarm that wakes up the device even when locked and asleep
  Future<void> scheduleOfflineAlarm({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledAt,
  }) async {
    await initialize();

    final now = DateTime.now();
    if (!scheduledAt.isAfter(now)) {
      // If time has already arrived, display immediately
      await showInstantNotification(id: id, title: title, body: body);
      return;
    }

    if (kIsWeb || (Platform.environment.containsKey('FLUTTER_TEST'))) {
      // On web, WebNotificationHelper handles browser alerts; in tests, mocked
      return;
    }

    try {
      final tzScheduled = tz.TZDateTime.from(scheduledAt, tz.local);

      final notificationDetails = NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: _channelDesc,
          importance: Importance.max,
          priority: Priority.high,
          visibility: NotificationVisibility.public, // VISIBLE ON LOCK SCREEN
          fullScreenIntent: true, // WAKES DEVICE SCREEN WHEN LOCKED
          category: AndroidNotificationCategory.alarm,
          playSound: true,
          enableVibration: true,
          styleInformation: BigTextStyleInformation(body),
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentSound: true,
          presentBadge: true,
          interruptionLevel: InterruptionLevel.timeSensitive, // Bypasses focus modes
        ),
      );

      await plugin.zonedSchedule(
        id: id,
        title: title,
        body: body,
        scheduledDate: tzScheduled,
        notificationDetails: notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle, // WAKES UP PHONE FROM DOZE/LOCK
      );
    } catch (e) {
      debugPrint('Error scheduling offline lock-screen alarm: $e');
    }
  }

  /// Cancels an existing scheduled alarm by integer ID
  Future<void> cancelAlarm(int id) async {
    if (kIsWeb || (Platform.environment.containsKey('FLUTTER_TEST'))) return;
    try {
      await plugin.cancel(id: id);
    } catch (_) {}
  }

  /// Displays an instant heads-up notification with lock-screen visibility
  Future<void> showInstantNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    if (kIsWeb || (Platform.environment.containsKey('FLUTTER_TEST'))) {
      if (kIsWeb) WebNotificationHelper.showNotification(title, body);
      return;
    }

    try {
      final notificationDetails = NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: _channelDesc,
          importance: Importance.max,
          priority: Priority.high,
          visibility: NotificationVisibility.public,
          fullScreenIntent: true,
          category: AndroidNotificationCategory.alarm,
          playSound: true,
          enableVibration: true,
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentSound: true,
          presentBadge: true,
          interruptionLevel: InterruptionLevel.timeSensitive,
        ),
      );

      await plugin.show(
        id: id,
        title: title,
        body: body,
        notificationDetails: notificationDetails,
      );
    } catch (e) {
      debugPrint('Error showing instant notification: $e');
    }
  }

  /// Helper to convert any string ID (e.g. UUID) to a safe 31-bit integer for alarms
  static int generateAlarmId(String key) {
    return key.hashCode.abs() % 2147483647;
  }
}
