part of 'medical_store_bloc.dart';

abstract class MedicalStoreEvent extends Equatable {
  const MedicalStoreEvent();

  @override
  List<Object> get props => [];
}

class AddMedicalStoreEvent extends MedicalStoreEvent {
  final MedicineStoreModel medicineStoreModel;

  AddMedicalStoreEvent({required this.medicineStoreModel});
  @override
  List<Object> get props => [medicineStoreModel];
}

class UpdateMedicalStoreEvent extends MedicalStoreEvent {
  final MedicineStoreModel medicine;

  UpdateMedicalStoreEvent({
    required this.medicine,
  });

  @override
  List<Object> get props => [medicine];
}

