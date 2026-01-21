import 'dart:developer';
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

      log("Emergency contact added successfully with ID: ${docRef.id}");
      return true;
    } catch (e) {
      log('Error adding emergency contact: $e');
      rethrow;
    }
  }

  Stream<List<EmergencyContact>> getEmergencyContacts(String activeFamilyId) {
    try {
      if (activeFamilyId.isEmpty) {
        throw Exception("Family ID is required. User might not be logged in.");
      }
      return _firestore
          .collection('users')
          .doc(activeFamilyId)
          .collection('emergency-contact')
          .where('active', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snapshot) {
            return snapshot.docs
                .map((doc) => EmergencyContact.fromMap(doc.data(), doc.id))
                .toList();
          });
    } catch (e) {
      log('Error fetching emergency contacts: $e');
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
      log('Error updating emergency contact: $e');
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
      log("Contact soft-deleted successfully");
      return true;
    } catch (e) {
      log('Error deleting contact: $e');
      rethrow;
    }
  }
}
