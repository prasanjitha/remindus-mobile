import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:remindus/models/base_reminder_model.dart';
import 'package:remindus/models/medicine_store_model.dart';
import 'package:remindus/models/user_model.dart';
import 'package:remindus/screens/reminders/reminder_tab_screen.dart';

class ReminderService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  CollectionReference<Map<String, dynamic>> _reminderRef(String userId) {
    return _firestore.collection('users').doc(userId).collection('reminders');
  }

  //All Reminders
  Stream<List<ReminderModel>> getAllReminders({
    required String activeFamilyId,
  }) {
    log("Active Family ID: $activeFamilyId");
    return _reminderRef(
      activeFamilyId,
    ).orderBy('scheduledAt', descending: false).snapshots().map(_mapSnapshot);
  }

  //Completed Reminders (isRead = true)
  Stream<List<ReminderModel>> getCompletedReminders({
    required String activeFamilyId,
  }) {
    return getAllReminders(activeFamilyId: activeFamilyId).map((reminders) {
      return reminders.where((r) => r.isRead == true).toList();
    });
  }

  // Upcoming Reminders (isRead = false)
  Stream<List<ReminderModel>> getUpcomingReminders({
    required String activeFamilyId,
  }) {
    return getAllReminders(activeFamilyId: activeFamilyId).map((reminders) {
      return reminders.where((r) => r.isRead == false).toList();
    });
  }

  /// Unified API
  Stream<List<ReminderModel>> getReminders(
    ReminderFilter filter, {
    required String activeFamilyId,
  }) {
    switch (filter) {
      case ReminderFilter.completed:
        return getCompletedReminders(activeFamilyId: activeFamilyId);
      case ReminderFilter.upcoming:
        return getUpcomingReminders(activeFamilyId: activeFamilyId);
      case ReminderFilter.all:
      default:
        return getAllReminders(activeFamilyId: activeFamilyId);
    }
  }

  /// Get latest two upcoming reminders
  Stream<List<ReminderModel>> getLatestTwoUpcoming({
    required String activeFamilyId,
  }) {
    final now = Timestamp.now();

    return getAllReminders(activeFamilyId: activeFamilyId).map((reminders) {
      return reminders
          .where(
            (r) =>
                r.isRead == false &&
                r.scheduledAt != null &&
                r.scheduledAt!.compareTo(now) >= 0,
          )
          .take(2)
          .toList();
    });
  }

  // Refill Alerts from Medicine Store
  Stream<List<MedicineStoreModel>> getRefillAlerts({
    required String activeFamilyId,
  }) {
    // final String? userId = FirebaseAuth.instance.currentUser?.uid;

    if (activeFamilyId == null) {
      return Stream.value([]);
    }

    return FirebaseFirestore.instance
        .collection('users')
        .doc(activeFamilyId)
        .collection('medicinesStore')
        .where('status', isEqualTo: 'refill')
        .orderBy('updatedAt', descending: false)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return MedicineStoreModel.fromMap(doc.data())
              ..medicineStoreId = doc.id;
          }).toList();
        });
  }

  // Mapper
  List<ReminderModel> _mapSnapshot(
    QuerySnapshot<Map<String, dynamic>> snapshot,
  ) {
    try {
      return snapshot.docs.map((doc) {
        return ReminderModel.fromMap({...doc.data(), 'reminderId': doc.id});
      }).toList();
    } catch (e) {
      print("Mapping Error: $e");
      return [];
    }
  }

  /// Delete a specific reminder
  Future<void> deleteReminder(
    String reminderId, {
    required String activeFamilyId,
  }) async {
    try {
      await _reminderRef(activeFamilyId).doc(reminderId).delete();
    } catch (e) {
      rethrow;
    }
  }

  Stream<UserModel> getUserData({required String activeFamilyId}) {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(activeFamilyId)
        .snapshots()
        .map((snapshot) {
          if (!snapshot.exists || snapshot.data() == null) {
            return UserModel();
          }
          final rawData = snapshot.data();
          try {
            final userModel = UserModel.fromMap(rawData!);
            return userModel;
          } catch (e) {
            return UserModel();
          }
        });
  }
}
