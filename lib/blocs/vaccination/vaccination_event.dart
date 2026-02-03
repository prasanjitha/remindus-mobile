part of 'vaccination_bloc.dart';

abstract class VaccinationEvent extends Equatable {
  const VaccinationEvent();

  @override
  List<Object?> get props => [];
}

class LoadVaccinationsEvent extends VaccinationEvent {
  final String activeFamilyId;

  const LoadVaccinationsEvent(this.activeFamilyId);

  @override
  List<Object?> get props => [activeFamilyId];
}

class AddVaccinationEvent extends VaccinationEvent {
  final VaccinationRecord record;

  const AddVaccinationEvent(this.record);

  @override
  List<Object?> get props => [record];
}

class UpdateVaccinationEvent extends VaccinationEvent {
  final VaccinationRecord record;

  const UpdateVaccinationEvent(this.record);

  @override
  List<Object?> get props => [record];
}

class DeleteVaccinationEvent extends VaccinationEvent {
  final String recordId;
  final String activeFamilyId;
  final String? reminderId;

  const DeleteVaccinationEvent({
    required this.recordId,
    required this.activeFamilyId,
    this.reminderId,
  });

  @override
  List<Object?> get props => [recordId, activeFamilyId, reminderId];
}
