part of 'medical_store_bloc.dart';

abstract class MedicalStoreEvent extends Equatable {
  const MedicalStoreEvent();

  @override
  List<Object> get props => [];
}

class AddMedicalStoreEvent extends MedicalStoreEvent {
  final MedicineStoreModel medicineStoreModel;
  final String activeFamiltId;

  AddMedicalStoreEvent({
    required this.medicineStoreModel,
    required this.activeFamiltId,
  });
  @override
  List<Object> get props => [medicineStoreModel, activeFamiltId];
}

class UpdateMedicalStoreEvent extends MedicalStoreEvent {
  final MedicineStoreModel medicine;
  final String activeFamiltId;

  UpdateMedicalStoreEvent({required this.medicine, required this.activeFamiltId});

  @override
  List<Object> get props => [medicine];
}
