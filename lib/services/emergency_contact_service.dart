import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:remindus/models/emergency_contact_model.dart';

class EmergencyContactService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<bool> addEmergencyContact(
    EmergencyContact emergencyContactModel,
    String activeFamilyId,
  ) async {
    try {
      if (activeFamilyId.isEmpty) {
        throw Exception("Family ID is required. User might not be logged in.");
      }

      final docRef = _firestore
          .collection('users')
          .doc(activeFamilyId)
          .collection('emergency-contact')
          .doc();

      emergencyContactModel.emergencyContactId = docRef.id;
      emergencyContactModel.createdAt = DateTime.now();
      await docRef.set(emergencyContactModel.toMap());

      await docRef.set(emergencyContactModel.toMap());

      return true;
    } catch (e) {
      rethrow;
    }
  }

  Stream<List<EmergencyContact>> getEmergencyContacts(String activeFamilyId) {
    try {
      if (activeFamilyId.isEmpty) {
        throw Exception("Family ID is required. User might not be logged in.");
      }

      final collection = _firestore
          .collection('users')
          .doc(activeFamilyId)
          .collection('emergency-contact');

      // Create a stream that starts with a 'get' to ensure data arrives immediately
      return Stream.fromFuture(collection.get()).asyncExpand((_) {
        return collection.snapshots().map((snapshot) {
          final List<EmergencyContact> contacts = snapshot.docs
              .map((doc) => EmergencyContact.fromMap(doc.data(), doc.id))
              .where((c) => c.active == true)
              .toList();

          // Sort by createdAt descending
          contacts.sort((a, b) {
            final dateA = a.createdAt ?? DateTime(2000);
            final dateB = b.createdAt ?? DateTime(2000);
            return dateB.compareTo(dateA);
          });

          return contacts;
        });
      }).asBroadcastStream();
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> updateEmergencyContact(
    EmergencyContact contact,
    String activeFamilyId,
  ) async {
    try {
      await _firestore
          .collection('users')
          .doc(activeFamilyId)
          .collection('emergency-contact')
          .doc(contact.emergencyContactId)
          .update(contact.toMap());
      return true;
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> deleteEmergencyContact(
    String activeFamilyId,
    String contactId,
  ) async {
    try {
      await _firestore
          .collection('users')
          .doc(activeFamilyId)
          .collection('emergency-contact')
          .doc(contactId)
          .update({'active': false, 'updatedAt': FieldValue.serverTimestamp()});

      return true;
    } catch (e) {
      rethrow;
    }
  }
}
