import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:remindus/models/base_reminder_model.dart';
import 'package:remindus/models/voice_notification_model.dart';
import 'package:remindus/services/local_notification_service.dart';

import 'base_reminder.dart';

class ReminderRepository extends BaseReminderRepositories {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Add Meetings Reminder
  @override
  Future<bool> addReminder({
    required ReminderModel reminder,
    required String activeFamilyId,
  }) async {
    try {
      if (activeFamilyId == null) throw Exception("User not logged in");

      final docRef = _firestore
          .collection('users')
          .doc(activeFamilyId)
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

  Stream<DocumentSnapshot> getHealthStatusStream(String familyId) {
  return _firestore
      .collection('users')
      .doc(familyId)
      .collection('health-condition')
      .doc('status')
      .snapshots();
}

Future<bool> updateFamilyHealthData({
  required String familyId,
  Map<String, Set<String>>? allergies,
  String? heartRate,
  String? bloodPressure,
  String? bloodGroup,
}) async {
  try {
    final Map<String, dynamic> dataToUpdate = {};
    if (allergies != null) {
      dataToUpdate['allergies'] = allergies.map(
        (key, value) => MapEntry(key, value.toList()),
      );
    }

    if (heartRate != null) dataToUpdate['heartRate'] = "$heartRate bpm" ;
    if (bloodPressure != null) dataToUpdate['bloodPressure'] = "$bloodPressure mmHg";
    if (bloodGroup != null) dataToUpdate['bloodGroup'] = bloodGroup;

    dataToUpdate['updatedAt'] = FieldValue.serverTimestamp();

    final docRef = _firestore
        .collection('users')
        .doc(familyId)
        .collection('health-condition')
        .doc('status'); 
    await docRef.set(dataToUpdate, SetOptions(merge: true));

    return true;
  } catch (e) {
    log("Error updating health records: $e");
    return false;
  }
}

  // Update  Reminder
  @override
  Future<bool> updateReminder({
    required ReminderModel reminder,
    required String reminderId,
    required String activeFamilyId,
  }) async {
    try {
      log("Starting update for reminder ID: $reminderId");
      // final String? userId = _auth.currentUser?.uid;
      log("user not logged in 5");

      if (activeFamilyId == null) throw Exception("User not logged in");
      log("Updating reminder with ID: $reminderId for user: $activeFamilyId");
      final docRef = _firestore
          .collection('users')
          .doc(activeFamilyId)
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
    required bool isAppOwner
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
        isAppOwner: isAppOwner,
      );
      return true;
    } catch (e) {
      log("General Error in addMeetingsReminder: $e");
      return false;
    }
  }
}
