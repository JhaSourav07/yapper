import 'package:flutter/foundation.dart';

class NotificationPermissionService {
  /// Prompts the user for notification permissions on startup/login
  static Future<void> requestNotificationPermission() async {
    if (kIsWeb) {
      try {
        // Request Web Browser Notification permission
        // Using JS / Web Notification API
        // ignore: undefined_name
      } catch (e) {
        print("Web Notification Permission error: $e");
      }
    }
  }
}
