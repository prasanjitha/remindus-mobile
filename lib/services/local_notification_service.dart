import 'dart:developer';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

class NotificationService {
  // Initialize with listeners
  Future<void> initialize() async {
    await AwesomeNotifications().initialize('resource://drawable/logo', [
      NotificationChannel(
        channelKey: 'silent_voice_v1',
        channelName: 'Voice Notifications',
        channelDescription: 'Default notification channel',
        defaultColor: Color(0xFF9D50DD),
        ledColor: Colors.white,
        importance: NotificationImportance.Max,
        channelShowBadge: true,
        playSound: false,
        enableVibration: false,
      ),
    ], debug: true);

    // Request permissions
    await AwesomeNotifications().requestPermissionToSendNotifications();

    // Set up listeners
    await AwesomeNotifications().setListeners(
      onActionReceivedMethod: onActionReceivedMethod,
      onNotificationCreatedMethod: onNotificationCreatedMethod,
      onNotificationDisplayedMethod: onNotificationDisplayedMethod,
      onDismissActionReceivedMethod: onDismissActionReceivedMethod,
    );
  }

  // Triggered when notification is CREATED (scheduled or immediate)
  @pragma("vm:entry-point")
  static Future<void> onNotificationCreatedMethod(
    ReceivedNotification receivedNotification,
  ) async {
    print('🔔 Notification Created: ${receivedNotification.id}');
  }

  // Triggered when notification is DISPLAYED to user
  @pragma("vm:entry-point")
  static Future<void> onNotificationDisplayedMethod(
    ReceivedNotification receivedNotification,
  ) async {
    final payload = receivedNotification.payload ?? {};
    final reminderId = payload['reminderId'] ?? '';
    final medicineName = payload['medicineName'] ?? '';
    final dose = payload['dose'] ?? '';
    final userId = FirebaseAuth.instance.currentUser?.uid;
    final String isAppOwnerStr = payload['isAppOwner'] ?? 'false';
    final String isAppOwner = isAppOwnerStr;

    log("Notification Displayed - isAppOwner: $isAppOwner");

    if (isAppOwner == 'true') {
      Future.delayed(const Duration(seconds: 30), () async {
        log("Notification Displayed - Initial Check - isAppOwner: $isAppOwner");

        if (medicineName.isNotEmpty) {
          await deductMedicineStock(
            userId: userId!,
            medicineName: medicineName,
            dose: dose,
          );
          await updateMedicineNotificationStatus(
            userId: userId,
            medicineName: medicineName,
          );
        }
      });
      await yourCustomFunction(receivedNotification);
      if (userId != null) {
        await markReminderAsRead(userId: userId, reminderId: reminderId);
      }
    }
  }

  // Triggered when user TAPS the notification
  @pragma("vm:entry-point")
  static Future<void> onActionReceivedMethod(
    ReceivedAction receivedAction,
  ) async {
    print('👆 Notification Tapped: ${receivedAction.id}');
  }

  // Triggered when user DISMISSES the notification
  @pragma("vm:entry-point")
  static Future<void> onDismissActionReceivedMethod(
    ReceivedAction receivedAction,
  ) async {
    print('❌ Notification Dismissed: ${receivedAction.id}');

    // Handle notification dismissal
  }

  // Your custom function that runs when notification is displayed
  static Future<void> yourCustomFunction(
    ReceivedNotification notification,
  ) async {
    log("Speech functionality triggered for notification ID: ${notification.id}");
    FlutterTts flutterTts = FlutterTts();

    await flutterTts.speak(
      notification.payload?['message'] ?? "You have a new notification",
    );
  }

  static Future<void> markReminderAsRead({
    required String userId,
    required String reminderId,
  }) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('reminders')
        .doc(reminderId)
        .update({'isRead': true, 'updatedAt': FieldValue.serverTimestamp()});
  }

  static Future<void> updateMedicineNotificationStatus({
    required String userId,
    required String medicineName,
  }) async {
    try {
      String formattedName = medicineName.trim().toLowerCase().replaceAll(
        ' ',
        '',
      );

      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('medicinesStore')
          .where('name', isEqualTo: formattedName)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final docId = querySnapshot.docs.first.id;

        await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('medicinesStore')
            .doc(docId)
            .update({
              'isNotified': true,
              'lastNotifiedAt': FieldValue.serverTimestamp(),
            });
      }
    } catch (e) {}
  }

  static Future<void> deductMedicineStock({
    required String userId,
    required String medicineName,
    required String dose,
  }) async {
    try {
      String formattedName = medicineName.trim().toLowerCase().replaceAll(
        ' ',
        '',
      );

      int doseAmount =
          int.tryParse(dose.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;

      if (doseAmount == 0) return;
      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('medicinesStore')
          .where('name', isEqualTo: formattedName)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        return;
      }

      final doc = querySnapshot.docs.first;
      final docId = doc.id;

      String currentQtyStr = doc.data()['quantity'] ?? "0";
      int currentQty =
          int.tryParse(currentQtyStr.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;

      if (currentQty >= doseAmount) {
        int newQty = currentQty - doseAmount;

        String status;
        if (newQty > 10) {
          status = "wellStocked";
        } else if (newQty > 0 && newQty <= 10) {
          status = "lowRemaining";
        } else {
          status = "refill";
        }

        await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('medicinesStore')
            .doc(docId)
            .update({
              'quantity': newQty.toString(),
              'status': status,
              'updatedAt': FieldValue.serverTimestamp(),
            });
      }
    } catch (e) {}
  }

  // Schedule a notification
  Future<void> scheduleNotification({
    required int id,
    required int hour,
    required int minute,
    required String title,
    required String body,
    int? day,
    int? month,
    String? reminderId,
    String? message,
    String? dose,
    bool? isAppOwner,
  }) async {
    try {
      NotificationCalendar schedule = NotificationCalendar(
        hour: hour,
        minute: minute,
        second: 0,
        millisecond: 0,
        repeats: false,
        day: day,
        month: month,
        allowWhileIdle: true,
      );
      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: id,
          channelKey: 'silent_voice_v1',
          title: title,
          body: body,
          notificationLayout: NotificationLayout.Default,
          payload: {
            'reminderId': reminderId,
            'message': message,
            'dose': dose,
            'medicineName': body,
            'isAppOwner': isAppOwner.toString(),
          },
        ),
        schedule: schedule,
      );
    } catch (e) {}
  }

  // Show immediate notification
  Future<void> showNotification() async {
    try {
      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: 2,
          channelKey: 'silent_voice_v1',
          title: 'Immediate Notification',
          body: 'This shows immediately!',
        ),
      );
    } catch (e) {}
  }

  Future<void> showInstantNotification({
    required int id,
    required String title,
    required String body,
    Map<String, String>? payload,
  }) async {
    print("Showing instant notification: $title - $body");
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: id,
        channelKey: 'basic_channel',
        title: title,
        body: body,
        payload: payload,
        notificationLayout: NotificationLayout.Default,
      ),
    );
  }

  Future<void> cancelAllNotifications() async {
    await AwesomeNotifications().cancelAllSchedules();
  }
}
