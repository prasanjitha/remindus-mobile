part of 'reminders_bloc.dart';

abstract class ReminderState extends Equatable {
  const ReminderState();

  @override
  List<Object> get props => [];
}

class ReminderInitialState extends ReminderState {
  @override
  List<Object> get props => [];
}

class IsReminderLoadingState extends ReminderState {
  final bool isReminderLoading;

  const IsReminderLoadingState({required this.isReminderLoading});
  @override
  List<Object> get props => [isReminderLoading];
}

class ReminderAddedSuccessState extends ReminderState {
  final bool isReminderAddedSuccess;

  const ReminderAddedSuccessState({required this.isReminderAddedSuccess});
  @override
  List<Object> get props => [isReminderAddedSuccess];
}

class ReminderUpdatedSuccessState extends ReminderState {
  final bool isReminderUpdatedSuccess;

  const ReminderUpdatedSuccessState({required this.isReminderUpdatedSuccess});
  @override
  List<Object> get props => [isReminderUpdatedSuccess];
}


class NoInternetConnectionState extends ReminderState {}
