import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:remindus/models/medicine_store_model.dart';
import 'package:remindus/services/notification_service.dart';

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
      final docRef = _firestore
          .collection('users')
          .doc(activeFamilyId)
          .collection('medicinesStore')
          .doc();
      medicineStoreModel.medicineStoreId = docRef.id;
      medicineStoreModel.createdAt = DateTime.now();
      await docRef.set(medicineStoreModel.toMap());

      final int qty = int.tryParse(medicineStoreModel.quantity) ?? 0;

      final notificationService = NotificationService();
      // Create notification for new medicine
      await notificationService.createNewMedicineNotification(
        userId: activeFamilyId,
        medicineId: docRef.id,
        medicineName: medicineStoreModel.name,
        quantity: qty,
      );

      // Also check if quantity 0 to trigger low stock notification
      if (qty == 0) {
        await notificationService.createLowStockNotification(
          userId: activeFamilyId,
          medicineId: docRef.id,
          medicineName: medicineStoreModel.name,
        );
      }

      return true;
    } catch (e) {
      rethrow;
    }
  }

  // Update Medical Store
  Future<bool> updateMedicalStore(
    MedicineStoreModel medicineStoreModel,
    String activeFamilyId,
  ) async {
    try {
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

      final int qty = int.tryParse(medicineStoreModel.quantity) ?? 0;

      // Create notification if quantity is 0
      if (qty == 0) {
        final notificationService = NotificationService();
        await notificationService.createLowStockNotification(
          userId: activeFamilyId,
          medicineId: medicineStoreModel.medicineStoreId!,
          medicineName: medicineStoreModel.name,
        );
      }

      return true;
    } catch (e) {
      rethrow;
    }
  }
}
