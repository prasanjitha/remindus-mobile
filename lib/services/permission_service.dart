import 'package:awesome_notifications/awesome_notifications.dart';

class PermissionService {
  // Check if notification permission is already granted
  Future<bool> checkNotificationPermission() async {
    return await AwesomeNotifications().isNotificationAllowed();
  }

  // Request notification permission and return if it was granted
  Future<bool> ensureNotificationPermission() async {
    bool isAllowed = await AwesomeNotifications().isNotificationAllowed();
    if (!isAllowed) {
      isAllowed = await AwesomeNotifications()
          .requestPermissionToSendNotifications();
    }
    return isAllowed;
  }
}
