import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:remindus/models/medicine_store_model.dart';
import '../../repositories/connection/connection_repositories.dart';
import 'package:remindus/repositories/medicalstore/medical_store_repository.dart';

part 'medical_store_event.dart';

part 'medical_store_state.dart';

class MedicalStoreBloc extends Bloc<MedicalStoreEvent, MedicalStoreState> {
  ConnectionRepository connectionRepository;
  MedicalStoreRepository medicalStoreRepository;

  MedicalStoreBloc({
    required this.connectionRepository,
    required this.medicalStoreRepository,
  }) : super(MedicalStoreInitialState()) {
    on<MedicalStoreEvent>((event, emit) async {
      bool isConnected = await connectionRepository.isConnectedToInternet();
      if (isConnected) {
        if (event is AddMedicalStoreEvent) {
          await _addMedicalStore(event, emit);
        } else if (event is UpdateMedicalStoreEvent) {
          await _updateMedicalStore(event, emit);
        }
      } else {
        _safeEmit(emit, NoInternetConnectionState());
      }
    });
  }
  // Safely emit a state only if the handler is still active
  void _safeEmit(Emitter<MedicalStoreState> emit, MedicalStoreState state) {
    if (emit.isDone) return;
    emit(state);
  }

  // Handler for adding medicine store
  Future<void> _addMedicalStore(
    AddMedicalStoreEvent event,
    Emitter<MedicalStoreState> emit,
  ) async {
    try {
      _safeEmit(emit, IsMedicalStoreLoadingState(isMedicalStoreLoading: true));
      await medicalStoreRepository.addMedicalStore(
        event.medicineStoreModel,
        event.activeFamiltId,
      );
      _safeEmit(emit, IsMedicalStoreLoadingState(isMedicalStoreLoading: false));

      _safeEmit(
        emit,
        MedicalStoreSuccessState(isMedicalStoreAddedSuccessfully: true),
      );
    } catch (e) {
      _safeEmit(emit, IsMedicalStoreLoadingState(isMedicalStoreLoading: false));

      _safeEmit(emit, MedicalStoreErrorState(errorMessage: e.toString()));
    }
  }

  // Handler for updating medicine store
  Future<void> _updateMedicalStore(
    UpdateMedicalStoreEvent event,
    Emitter<MedicalStoreState> emit,
  ) async {
    try {
      _safeEmit(emit, IsMedicalStoreLoadingState(isMedicalStoreLoading: true));
      await medicalStoreRepository.updateMedicalStore(
        event.medicine,
        event.activeFamiltId,
      );
      _safeEmit(emit, IsMedicalStoreLoadingState(isMedicalStoreLoading: false));
      _safeEmit(
        emit,
        MedicalStoreSuccessState(isMedicalStoreAddedSuccessfully: true),
      );
    } catch (e) {
      _safeEmit(emit, IsMedicalStoreLoadingState(isMedicalStoreLoading: false));
      _safeEmit(emit, MedicalStoreErrorState(errorMessage: e.toString()));
    }
  }
}
