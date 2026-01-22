import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/location_data.dart';

class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Share current location to Firestore
  Future<void> shareLocation(LocationData locationData) async {
    try {
      await _firestore
          .collection('users')
          .doc(locationData.userId)
          .collection('locations')
          .doc('current')
          .set({
        ...locationData.toJson(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      log('Location shared successfully');
    } catch (e) {
      log('Error sharing location: $e');
      rethrow;
    }
  }

  /// Update location with check-in status
  Future<void> updateCheckInStatus(
    String userId,
    LocationData locationData,
    bool isSafe,
  ) async {
    try {
      Map<String, dynamic> data = locationData.toJson();
      data['isSafe'] = isSafe;
      data['lastCheckIn'] = DateTime.now().millisecondsSinceEpoch;
      data['updatedAt'] = FieldValue.serverTimestamp();

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('locations')
          .doc('current')
          .update(data);

      // Also add to check-in history
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('check-ins')
          .add({
        ...data,
        'createdAt': FieldValue.serverTimestamp(),
      });

      log('Check-in status updated');
    } catch (e) {
      log('Error updating check-in: $e');
      rethrow;
    }
  }

  /// Share emergency SOS
  Future<void> shareEmergencySOS(
    String userId,
    LocationData locationData,
    List<String> contactIds,
  ) async {
    try {
      // Store emergency location
      Map<String, dynamic> emergencyData = locationData.toJson();
      emergencyData['isEmergency'] = true;
      emergencyData['createdAt'] = FieldValue.serverTimestamp();

      final emergencyRef = await _firestore
          .collection('users')
          .doc(userId)
          .collection('emergencies')
          .add(emergencyData);

      log('Emergency SOS created with ID: ${emergencyRef.id}');

      // Notify emergency contacts
      for (String contactId in contactIds) {
        await _firestore
            .collection('users')
            .doc(contactId)
            .collection('notifications')
            .add({
          'type': 'emergency',
          'userId': userId,
          'emergencyId': emergencyRef.id,
          'latitude': locationData.latitude,
          'longitude': locationData.longitude,
          'address': locationData.address,
          'timestamp': DateTime.now().millisecondsSinceEpoch,
          'read': false,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
      log('Emergency SOS sent to ${contactIds.length} contacts');
    } catch (e) {
      log('Error sending SOS: $e');
      rethrow;
    }
  }

  /// Get location stream for a specific user
  Stream<LocationData?> getLocationStream(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('locations')
        .doc('current')
        .snapshots()
        .map((snapshot) {
      if (snapshot.exists && snapshot.data() != null) {
        return LocationData.fromJson(snapshot.data()!);
      }
      return null;
    });
  }

  /// Add emergency contact
  Future<void> addEmergencyContact(
    String userId,
    EmergencyContact contact,
  ) async {
    try {
      if (userId.isEmpty) {
        throw Exception("User ID is required. User might not be logged in.");
      }

      final docRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('emergency-contact')
          .doc();

      contact = EmergencyContact(
        id: docRef.id,
        name: contact.name,
        phoneNumber: contact.phoneNumber,
      );

      await docRef.set({
        ...contact.toJson(),
        'active': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      log("Emergency contact added successfully with ID: ${docRef.id}");
    } catch (e) {
      log('Error adding contact: $e');
      rethrow;
    }
  }

  /// Get emergency contacts for user (as Stream)
  Stream<List<EmergencyContact>> getEmergencyContactsStream(String userId) {
    try {
      if (userId.isEmpty) {
        throw Exception("User ID is required. User might not be logged in.");
      }

      return _firestore
          .collection('users')
          .doc(userId)
          .collection('emergency-contact')
          .where('active', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs
            .map((doc) => EmergencyContact.fromJson({
                  'id': doc.id,
                  'name': doc.data()['name'],
                  'phoneNumber': doc.data()['phoneNumber'],
                }))
            .toList();
      });
    } catch (e) {
      log('Error fetching emergency contacts: $e');
      rethrow;
    }
  }

  /// Get emergency contacts for user (as Future)
  Future<List<EmergencyContact>> getEmergencyContacts(String userId) async {
    try {
      if (userId.isEmpty) {
        throw Exception("User ID is required. User might not be logged in.");
      }

      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('emergency-contact')
          .where('active', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => EmergencyContact.fromJson({
                'id': doc.id,
                'name': doc.data()['name'],
                'phoneNumber': doc.data()['phoneNumber'],
              }))
          .toList();
    } catch (e) {
      log('Error getting contacts: $e');
      return [];
    }
  }

  /// Update emergency contact
  Future<bool> updateEmergencyContact(
    String userId,
    EmergencyContact contact,
  ) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('emergency-contact')
          .doc(contact.id)
          .update({
        ...contact.toJson(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      log("Emergency contact updated successfully");
      return true;
    } catch (e) {
      log('Error updating emergency contact: $e');
      rethrow;
    }
  }

  /// Delete emergency contact (soft delete)
  Future<bool> deleteEmergencyContact(
    String userId,
    String contactId,
  ) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('emergency-contact')
          .doc(contactId)
          .update({
        'active': false,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      log("Contact soft-deleted successfully");
      return true;
    } catch (e) {
      log('Error deleting contact: $e');
      rethrow;
    }
  }

  /// Delete location sharing
  Future<void> stopSharing(String userId) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('locations')
          .doc('current')
          .delete();
      log('Location sharing stopped');
    } catch (e) {
      log('Error stopping sharing: $e');
      rethrow;
    }
  }

  /// Get check-in history
  Stream<List<Map<String, dynamic>>> getCheckInHistory(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('check-ins')
        .orderBy('createdAt', descending: true)
        .limit(20)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => doc.data()).toList();
    });
  }

  /// Get emergency history
  Stream<List<Map<String, dynamic>>> getEmergencyHistory(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('emergencies')
        .orderBy('createdAt', descending: true)
        .limit(10)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => doc.data()).toList();
    });
  }

  /// Mark notification as read
  Future<void> markNotificationAsRead(String userId, String notificationId) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('notifications')
          .doc(notificationId)
          .update({
        'read': true,
        'readAt': FieldValue.serverTimestamp(),
      });
      log('Notification marked as read');
    } catch (e) {
      log('Error marking notification as read: $e');
      rethrow;
    }
  }

  /// Get unread notifications count
  Stream<int> getUnreadNotificationsCount(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('notifications')
        .where('read', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }
}