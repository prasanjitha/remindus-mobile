import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:remindus/models/medicine_store_model.dart';

import 'base_medical_store.dart';

class MedicalStoreRepository extends BaseMedicalStoreRepositories {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Add Medical Store
  Future<bool> addMedicalStore(MedicineStoreModel medicineStoreModel) async {
    try {
      final String? userId = _auth.currentUser?.uid;
      if (userId == null) throw Exception("User not logged in");
      final docRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('medicinesStore')
          .doc();

      // String? uploadedImageUrl;

      // if (imageFile != null) {
      //   final storageRef = FirebaseStorage.instance.ref().child(
      //     'users/$userId/medicines/${docRef.id}.jpg',
      //   );

      //   await storageRef.putFile(imageFile);
      //   uploadedImageUrl = await storageRef.getDownloadURL();
      // }

      // medicine.medicineStoreId = docRef.id;
      // medicine.imageUrl = uploadedImageUrl;
      // medicine.createdAt = DateTime.now();

      // await docRef.set(medicine.toMap());
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
  Future<bool> updateMedicalStore(MedicineStoreModel medicineStoreModel) async {
    try {
      final String? userId = _auth.currentUser?.uid;
      if (userId == null) throw Exception("User not logged in");
      String? finalImageUrl = medicineStoreModel.imageUrl;

      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
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
