part of 'vaccination_bloc.dart';

abstract class VaccinationState extends Equatable {
  const VaccinationState();

  @override
  List<Object?> get props => [];
}

class VaccinationInitial extends VaccinationState {}

class VaccinationLoading extends VaccinationState {}

class VaccinationLoaded extends VaccinationState {
  final List<VaccinationRecord> records;

  const VaccinationLoaded(this.records);

  @override
  List<Object?> get props => [records];
}

class VaccinationError extends VaccinationState {
  final String message;

  const VaccinationError(this.message);

  @override
  List<Object?> get props => [message];
}

class VaccinationOperationSuccess extends VaccinationState {
  final String message;

  const VaccinationOperationSuccess(this.message);

  @override
  List<Object?> get props => [message];
}
