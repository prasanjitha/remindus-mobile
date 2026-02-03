import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:remindus/models/emergency_contact_model.dart';
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
    } catch (e) {
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
          .add({...data, 'createdAt': FieldValue.serverTimestamp()});
    } catch (e) {
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
    } catch (e) {
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

      contact.emergencyContactId = docRef.id;
      contact.active = true;
      contact.createdAt = DateTime.now();
      contact.updatedAt = DateTime.now();

      await docRef.set(contact.toMap());
    } catch (e) {
      rethrow;
    }
  }

  /// Get emergency contacts for user (as Stream)
  Stream<List<EmergencyContact>> getEmergencyContactsStream(String userId) {
    try {
      if (userId.isEmpty) {
        throw Exception("User ID is required. User might not be logged in.");
      }

      final collection = _firestore
          .collection('users')
          .doc(userId)
          .collection('emergency-contact');

      // Create a stream that starts with a 'get' to avoid waiting state
      return Stream.fromFuture(collection.get()).asyncExpand((firstSnapshot) {
        return collection.snapshots().map((snapshot) {
          final List<EmergencyContact> contacts = snapshot.docs
              .map((doc) => EmergencyContact.fromMap(doc.data(), doc.id))
              .where((c) => c.active == true)
              .toList();

          contacts.sort((a, b) {
            final dateA = a.createdAt ?? DateTime(2000);
            final dateB = b.createdAt ?? DateTime(2000);
            return dateB.compareTo(dateA);
          });
          return contacts;
        });
      });
    } catch (e) {
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
          .map((doc) => EmergencyContact.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
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
          .doc(contact.emergencyContactId)
          .update({
            ...contact.toMap(),
            'updatedAt': FieldValue.serverTimestamp(),
          });

      return true;
    } catch (e) {
      rethrow;
    }
  }

  /// Delete emergency contact (soft delete)
  Future<bool> deleteEmergencyContact(String userId, String contactId) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('emergency-contact')
          .doc(contactId)
          .update({'active': false, 'updatedAt': FieldValue.serverTimestamp()});

      return true;
    } catch (e) {
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
    } catch (e) {
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
  Future<void> markNotificationAsRead(
    String userId,
    String notificationId,
  ) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('notifications')
          .doc(notificationId)
          .update({'read': true, 'readAt': FieldValue.serverTimestamp()});
    } catch (e) {
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
