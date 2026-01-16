import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:remindus/models/base_reminder_model.dart';
import 'package:remindus/models/medicine_store_model.dart';
import 'package:remindus/models/user_model.dart';
import 'package:remindus/screens/reminders/reminder_tab_screen.dart';

class ReminderService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>> _reminderRef(String userId) {
    return _firestore.collection('users').doc(userId).collection('reminders');
  }

  String get _userId {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw Exception("User not logged in");
    return uid;
  }

  //All Reminders
  Stream<List<ReminderModel>> getAllReminders() {
    return _reminderRef(
      _userId,
    ).orderBy('scheduledAt', descending: false).snapshots().map(_mapSnapshot);
  }

  //Completed Reminders (isRead = true)
  Stream<List<ReminderModel>> getCompletedReminders() {
    return _reminderRef(_userId)
        .where('isRead', isEqualTo: true)
        .orderBy('scheduledAt', descending: false)
        .snapshots()
        .map(_mapSnapshot);
  }

  // Upcoming Reminders (isRead = false)
  Stream<List<ReminderModel>> getUpcomingReminders() {
    final now = Timestamp.now();
    return _reminderRef(_userId)
        .where('isRead', isEqualTo: false)
        .where('scheduledAt', isGreaterThanOrEqualTo: now)
        .orderBy('scheduledAt', descending: false)
        .snapshots()
        .map(_mapSnapshot);
  }

  /// Unified API
  Stream<List<ReminderModel>> getReminders(ReminderFilter filter) {
    switch (filter) {
      case ReminderFilter.completed:
        return getCompletedReminders();
      case ReminderFilter.upcoming:
        return getUpcomingReminders();
      case ReminderFilter.all:
      default:
        return getAllReminders();
    }
  }

  /// Get latest two upcoming reminders
  Stream<List<ReminderModel>> getLatestTwoUpcoming() {
    final now = Timestamp.now();

    return _reminderRef(_userId)
        .where('isRead', isEqualTo: false)
        .where('scheduledAt', isGreaterThanOrEqualTo: now)
        .orderBy('scheduledAt', descending: false)
        .limit(2)
        .snapshots()
        .map(_mapSnapshot);
  }

  // Refill Alerts from Medicine Store
  Stream<List<MedicineStoreModel>> getRefillAlerts() {
    final String? userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId == null) {
      return Stream.value([]);
    }

    return FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
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
  Future<void> deleteReminder(String reminderId) async {
    try {
      await _reminderRef(_userId).doc(reminderId).delete();
    } catch (e) {
      rethrow;
    }
  }

  Stream<UserModel> getUserData() {
    final String? userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return Stream.value(UserModel());

    return FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .snapshots()
        .map((snapshot) => UserModel.fromMap(snapshot.data()));
  }
}
