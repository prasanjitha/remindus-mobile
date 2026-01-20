import 'package:remindus/models/medicine_store_model.dart';

abstract class BaseMedicalStoreRepositories {
  Future<bool> addMedicalStore(
    MedicineStoreModel medicineStoreModel,
    String activeFamilyId,
  );
}
