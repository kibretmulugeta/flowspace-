// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:html' as html;

class WebNotificationHelper {
  static Future<bool> requestPermission() async {
    try {
      if (html.Notification.supported) {
        final permission = await html.Notification.requestPermission();
        return permission == 'granted';
      }
    } catch (_) {}
    return false;
  }

  static void showNotification(String title, String body) {
    try {
      if (html.Notification.supported && html.Notification.permission == 'granted') {
        html.Notification(title, body: body);
      }
    } catch (_) {}
  }
}
