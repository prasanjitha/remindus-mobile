import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:remindus/models/vaccination_record.dart';

class VaccinationRepository {
  final FirebaseFirestore _firestore;

  VaccinationRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<void> addVaccination(VaccinationRecord record) async {
    try {
      if (record.activeFamilyId == null) {
        throw Exception(
          "Active Family ID is required to add a vaccination record.",
        );
      }

      // Path: users/{activeFamilyId}/vaccination-records/{docId}
      await _firestore
          .collection('users')
          .doc(record.activeFamilyId)
          .collection('vaccination-records')
          .add(record.toFirestore());
    } catch (e) {
      throw Exception("Failed to add vaccination record: $e");
    }
  }

  Future<void> updateVaccination(VaccinationRecord record) async {
    try {
      if (record.id == null || record.activeFamilyId == null) {
        throw Exception(
          "Record ID and Active Family ID are required to update.",
        );
      }

      await _firestore
          .collection('users')
          .doc(record.activeFamilyId)
          .collection('vaccination-records')
          .doc(record.id)
          .update(record.toFirestore());
    } catch (e) {
      throw Exception("Failed to update vaccination record: $e");
    }
  }

  Future<void> deleteVaccination(String recordId, String activeFamilyId) async {
    try {
      await _firestore
          .collection('users')
          .doc(activeFamilyId)
          .collection('vaccination-records')
          .doc(recordId)
          .delete();
    } catch (e) {
      throw Exception("Failed to delete vaccination record: $e");
    }
  }

  Stream<List<VaccinationRecord>> getVaccinations(String activeFamilyId) {
    return _firestore
        .collection('users')
        .doc(activeFamilyId)
        .collection('vaccination-records')
        .orderBy('dateReceived', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => VaccinationRecord.fromFirestore(doc))
              .toList();
        });
  }
}
