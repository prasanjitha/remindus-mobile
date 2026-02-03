import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:remindus/models/vaccination_record.dart';
import 'package:remindus/repositories/vaccination/vaccination_repository.dart';

part 'vaccination_event.dart';
part 'vaccination_state.dart';

class VaccinationBloc extends Bloc<VaccinationEvent, VaccinationState> {
  final VaccinationRepository _repository;
  StreamSubscription? _vaccinationSubscription;

  VaccinationBloc({required VaccinationRepository repository})
    : _repository = repository,
      super(VaccinationInitial()) {
    on<LoadVaccinationsEvent>(_onLoadVaccinations);
    on<AddVaccinationEvent>(_onAddVaccination);
    on<UpdateVaccinationEvent>(_onUpdateVaccination);
    on<DeleteVaccinationEvent>(_onDeleteVaccination);
    on<_VaccinationsUpdated>(
      (event, emit) => emit(VaccinationLoaded(event.records)),
    );
    on<_VaccinationsError>(
      (event, emit) => emit(VaccinationError(event.error)),
    );
  }

  Future<void> _onLoadVaccinations(
    LoadVaccinationsEvent event,
    Emitter<VaccinationState> emit,
  ) async {
    emit(VaccinationLoading());
    await _vaccinationSubscription?.cancel();
    _vaccinationSubscription = _repository
        .getVaccinations(event.activeFamilyId)
        .listen(
          (records) => add(_VaccinationsUpdated(records)),
          onError: (error) => add(_VaccinationsError(error.toString())),
        );
  }

  Future<void> _onAddVaccination(
    AddVaccinationEvent event,
    Emitter<VaccinationState> emit,
  ) async {
    emit(VaccinationLoading());
    try {
      await _repository.addVaccination(event.record);
      emit(const VaccinationOperationSuccess("Vaccination Added Successfully"));
      // Re-load will be handled by stream
    } catch (e) {
      emit(VaccinationError(e.toString()));
    }
  }

  Future<void> _onUpdateVaccination(
    UpdateVaccinationEvent event,
    Emitter<VaccinationState> emit,
  ) async {
    emit(VaccinationLoading());
    try {
      await _repository.updateVaccination(event.record);
      emit(
        const VaccinationOperationSuccess("Vaccination Updated Successfully"),
      );
    } catch (e) {
      emit(VaccinationError(e.toString()));
    }
  }

  Future<void> _onDeleteVaccination(
    DeleteVaccinationEvent event,
    Emitter<VaccinationState> emit,
  ) async {
    emit(VaccinationDeletedLoading());
    try {
      await _repository.deleteVaccination(
        recordId: event.recordId,
        activeFamilyId: event.activeFamilyId,
        reminderId: event.reminderId,
      );
      emit(VaccinationDeletedSuccess());
    } catch (e) {
      emit(VaccinationError(e.toString()));
    }
  }

  // Internal events for stream handling
  @override
  Future<void> close() {
    _vaccinationSubscription?.cancel();
    return super.close();
  }
}

// Internal events to bridge Stream and Bloc
class _VaccinationsUpdated extends VaccinationEvent {
  final List<VaccinationRecord> records;
  const _VaccinationsUpdated(this.records);
}

class _VaccinationsError extends VaccinationEvent {
  final String error;
  const _VaccinationsError(this.error);
}
