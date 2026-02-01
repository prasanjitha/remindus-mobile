import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:remindus/models/notification_model.dart';

class NotificationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _notificationRef(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('notifications');
  }

  /// Get stream of all notifications for a user
  Stream<List<NotificationModel>> getNotificationsStream(String userId) {
    return _notificationRef(
      userId,
    ).orderBy('createdAt', descending: true).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return NotificationModel.fromMap(data);
      }).toList();
    });
  }

  /// Get stream of unread notification count
  Stream<int> getUnreadCountStream(String userId) {
    return _notificationRef(userId)
        .where('isRead', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  /// Mark a notification as read
  Future<void> markAsRead(String userId, String notificationId) async {
    try {
      await _notificationRef(
        userId,
      ).doc(notificationId).update({'isRead': true});
    } catch (e) {
      print('Error marking notification as read: $e');
      rethrow;
    }
  }

  /// Mark all notifications as read
  Future<void> markAllAsRead(String userId) async {
    try {
      final unreadNotifications = await _notificationRef(
        userId,
      ).where('isRead', isEqualTo: false).get();

      final batch = _firestore.batch();
      for (var doc in unreadNotifications.docs) {
        batch.update(doc.reference, {'isRead': true});
      }
      await batch.commit();
    } catch (e) {
      print('Error marking all notifications as read: $e');
      rethrow;
    }
  }

  /// Create a reminder notification
  Future<void> createReminderNotification({
    required String userId,
    required String reminderId,
    required String reminderTitle,
    required String date,
    required String time,
  }) async {
    try {
      final notification = NotificationModel(
        type: 'reminder',
        title: 'New Reminder Added',
        message: '$reminderTitle scheduled for $date at $time',
        isRead: false,
        createdAt: Timestamp.now(),
        data: {
          'reminderId': reminderId,
          'reminderTitle': reminderTitle,
          'date': date,
          'time': time,
        },
      );

      await _notificationRef(userId).add(notification.toMap());
    } catch (e) {
      print('Error creating reminder notification: $e');
      rethrow;
    }
  }

  /// Create a low stock notification
  Future<void> createLowStockNotification({
    required String userId,
    required String medicineId,
    required String medicineName,
  }) async {
    try {
      // Check if notification already exists for this medicine
      final existingNotification = await _notificationRef(userId)
          .where('type', isEqualTo: 'low_stock')
          .where('data.medicineId', isEqualTo: medicineId)
          .where('isRead', isEqualTo: false)
          .get();

      // Don't create duplicate notification if one already exists
      if (existingNotification.docs.isNotEmpty) {
        return;
      }

      final notification = NotificationModel(
        type: 'low_stock',
        title: 'Medicine Out of Stock',
        message: '$medicineName is out of stock',
        isRead: false,
        createdAt: Timestamp.now(),
        data: {'medicineId': medicineId, 'medicineName': medicineName},
      );

      await _notificationRef(userId).add(notification.toMap());
    } catch (e) {
      print('Error creating low stock notification: $e');
      rethrow;
    }
  }

  /// Create a guardian invitation notification
  Future<void> createGuardianNotification({
    required String guardianUserId,
    required String familyId,
    required String familyName,
    required String relationship,
    required String accessLevel,
  }) async {
    try {
      final notification = NotificationModel(
        type: 'guardian_invitation',
        title: 'Added as Guardian',
        message: 'You have been added as a guardian for $familyName',
        isRead: false,
        createdAt: Timestamp.now(),
        data: {
          'familyId': familyId,
          'familyName': familyName,
          'relationship': relationship,
          'accessLevel': accessLevel,
        },
      );

      await _notificationRef(guardianUserId).add(notification.toMap());
    } catch (e) {
      print('Error creating guardian notification: $e');
      rethrow;
    }
  }

  /// Create a new medicine notification
  Future<void> createNewMedicineNotification({
    required String userId,
    required String medicineId,
    required String medicineName,
    required int quantity,
  }) async {
    try {
      final notification = NotificationModel(
        type: 'new_medicine',
        title: 'New Medicine Added',
        message: '$medicineName added to store with quantity $quantity',
        isRead: false,
        createdAt: Timestamp.now(),
        data: {
          'medicineId': medicineId,
          'medicineName': medicineName,
          'quantity': quantity,
        },
      );

      await _notificationRef(userId).add(notification.toMap());
      log(
        "Creating new medicine notification for user: $userId, item: $medicineName",
      );
      await _notificationRef(userId).add(notification.toMap());
      log("Notification created successfully in Firestore");
    } catch (e) {
      log('Error creating new medicine notification: $e');
      rethrow;
    }
  }

  /// Delete a notification
  Future<void> deleteNotification(String userId, String notificationId) async {
    try {
      await _notificationRef(userId).doc(notificationId).delete();
    } catch (e) {
      print('Error deleting notification: $e');
      rethrow;
    }
  }
}
