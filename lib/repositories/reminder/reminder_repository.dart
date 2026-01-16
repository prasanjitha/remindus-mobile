import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:remindus/models/base_reminder_model.dart';
import 'package:remindus/models/voice_notification_model.dart';
import 'package:remindus/services/local_notification_service.dart';

import 'base_reminder.dart';

class ReminderRepository extends BaseReminderRepositories {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Add Meetings Reminder
  @override
  Future<bool> addReminder({required ReminderModel reminder}) async {
    try {
      final String? userId = _auth.currentUser?.uid;
      if (userId == null) throw Exception("User not logged in");

      final docRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('reminders')
          .doc();

      // Set the ID inside the map before saving
      final data = reminder.toMap();
      data['reminderId'] = docRef.id;

      await docRef.set(data);
      return true;
    } catch (e) {
      log("Error adding reminder: $e");
      return false;
    }
  }

  // Update  Reminder
  @override
  Future<bool> updateReminder({
    required ReminderModel reminder,
    required String reminderId,
  }) async {
    try {
      log("Starting update for reminder ID: $reminderId");
      final String? userId = _auth.currentUser?.uid;
      if (userId == null) throw Exception("User not logged in");
log("Updating reminder with ID: $reminderId for user: $userId");
      final docRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('reminders')
          .doc(reminderId);

      // Set the ID inside the map before saving
      final data = reminder.toMap();
      data['reminderId'] = docRef.id;

      await docRef.set(data);
      return true;
    } catch (e) {
      log("Error adding reminder: $e");
      return false;
    }
  }

  // Add Voice  Notification
  @override
  Future<bool> addVoiceNotification({
    required VoiceNotificationModel voiceNotificationModel,
  }) async {
    try {
      NotificationService notificationService = NotificationService();

      await notificationService.scheduleNotification(
        id: voiceNotificationModel.id!,
        hour: voiceNotificationModel.hour!,
        minute: voiceNotificationModel.minute!,
        title: voiceNotificationModel.title!,
        body: voiceNotificationModel.body!,
        day: voiceNotificationModel.day!,
        month: voiceNotificationModel.month!,
      );
      return true;
    } catch (e) {
      log("General Error in addMeetingsReminder: $e");
      return false;
    }
  }
}
