import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:remindus/models/base_reminder_model.dart';
import 'package:remindus/models/voice_notification_model.dart';
import 'package:remindus/services/local_notification_service.dart';
import 'package:remindus/services/notification_service.dart' as notif;
import 'package:intl/intl.dart';

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

      // Create notification for the new reminder
      if (reminder.scheduledAt != null && reminder.time != null) {
        final notificationService = notif.NotificationService();
        final date = DateFormat(
          'yyyy/MM/dd',
        ).format(reminder.scheduledAt!.toDate());
        await notificationService.createReminderNotification(
          userId: activeFamilyId,
          reminderId: docRef.id,
          reminderTitle:
              reminder.title ??
              (reminder.type == "Medicine" ? "Medicine" : "Meeting"),
          date: date,
          time: reminder.time!,
        );
      }

      return true;
    } catch (e) {
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

      if (heartRate != null) dataToUpdate['heartRate'] = "$heartRate bpm";
      if (bloodPressure != null)
        dataToUpdate['bloodPressure'] = "$bloodPressure mmHg";
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
      if (activeFamilyId == null) throw Exception("User not logged in");

      final docRef = _firestore
          .collection('users')
          .doc(activeFamilyId)
          .collection('reminders')
          .doc(reminderId);

      // Set the ID inside the map before saving
      final data = reminder.toMap();
      data['reminderId'] = docRef.id;

      await docRef.set(data);

      // Create/Update notification for the reminder
      if (reminder.scheduledAt != null && reminder.time != null) {
        final notificationService = notif.NotificationService();
        final date = DateFormat(
          'yyyy/MM/dd',
        ).format(reminder.scheduledAt!.toDate());
        await notificationService.createReminderNotification(
          userId: activeFamilyId,
          reminderId: docRef.id,
          reminderTitle:
              reminder.title ??
              (reminder.type == "Medicine" ? "Medicine" : "Meeting"),
          date: date,
          time: reminder.time!,
        );
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  // Add Voice  Notification
  @override
  Future<bool> addVoiceNotification({
    required VoiceNotificationModel voiceNotificationModel,
    required bool isAppOwner,
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
      return false;
    }
  }

  Future<ReminderModel?> getLatestReminderByType({
    required String familyId,
    required String type,
  }) async {
    try {
      // We remove .orderBy to avoid requiring a composite index.
      // For health reminders, the number of records is usually small enough
      // to filter and sort in memory if needed, or we can just fetch all by type.
      final snapshot = await _firestore
          .collection('users')
          .doc(familyId)
          .collection('reminders')
          .where('type', isEqualTo: type)
          .get();

      if (snapshot.docs.isNotEmpty) {
        // Sort in memory instead of Firestore
        final docs = snapshot.docs.toList();
        docs.sort((a, b) {
          final aTime =
              (a.data()['createdAt'] as Timestamp?) ?? Timestamp(0, 0);
          final bTime =
              (b.data()['createdAt'] as Timestamp?) ?? Timestamp(0, 0);
          return bTime.compareTo(aTime); // Descending
        });
        return ReminderModel.fromMap(docs.first.data());
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
