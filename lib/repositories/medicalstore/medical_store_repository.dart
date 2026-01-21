import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:remindus/models/medicine_store_model.dart';

import 'base_medical_store.dart';

class MedicalStoreRepository extends BaseMedicalStoreRepositories {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Add Medical Store
  @override
  Future<bool> addMedicalStore(
    MedicineStoreModel medicineStoreModel,
    String activeFamilyId,
  ) async {
    try {
    log("user not logged in 2");

      if (activeFamilyId == null) throw Exception("User not logged in");
      final docRef = _firestore
          .collection('users')
          .doc(activeFamilyId)
          .collection('medicinesStore')
          .doc();
      medicineStoreModel.medicineStoreId = docRef.id;
      medicineStoreModel.createdAt = DateTime.now();
      await docRef.set(medicineStoreModel.toMap());
      return true;
    } catch (e) {
      log('Error adding medical store: $e');
      rethrow;
    }
  }

  // Update Medical Store
  Future<bool> updateMedicalStore(MedicineStoreModel medicineStoreModel, String activeFamilyId) async {
    try {
    log("user not logged in 3");

      if (activeFamilyId == null) throw Exception("User not logged in");
      String? finalImageUrl = medicineStoreModel.imageUrl;

      await FirebaseFirestore.instance
          .collection('users')
          .doc(activeFamilyId)
          .collection('medicinesStore')
          .doc(medicineStoreModel.medicineStoreId)
          .update({
            'name': medicineStoreModel.name,
            'quantity': medicineStoreModel.quantity,
            'status': medicineStoreModel.status,
            'imageUrl': finalImageUrl,
            'updatedAt': FieldValue.serverTimestamp(),
            'isNotified': false,
            'lastNotifiedAt': null,
          });
      return true;
    } catch (e) {
      log('Error updating medical store: $e');
      rethrow;
    }
  }
}
