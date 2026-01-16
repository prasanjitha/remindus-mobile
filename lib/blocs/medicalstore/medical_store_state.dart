part of 'medical_store_bloc.dart';

abstract class MedicalStoreState extends Equatable {
  const MedicalStoreState();

  @override
  List<Object> get props => [];
}

class MedicalStoreInitialState extends MedicalStoreState {
  @override
  List<Object> get props => [];
}

class IsMedicalStoreLoadingState extends MedicalStoreState {
  final bool isMedicalStoreLoading;

  IsMedicalStoreLoadingState({required this.isMedicalStoreLoading});

  @override
  List<Object> get props => [isMedicalStoreLoading];
}

class MedicalStoreSuccessState extends MedicalStoreState {
  final bool isMedicalStoreAddedSuccessfully;

  MedicalStoreSuccessState({required this.isMedicalStoreAddedSuccessfully});

  @override
  List<Object> get props => [isMedicalStoreAddedSuccessfully];
}

class MedicalStoreErrorState extends MedicalStoreState {
  final String errorMessage;

  MedicalStoreErrorState({required this.errorMessage});

  @override
  List<Object> get props => [errorMessage];
}

class NoInternetConnectionState extends MedicalStoreState {}
