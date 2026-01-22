import 'dart:async';
import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:remindus/models/base_reminder_model.dart';
import 'package:remindus/models/voice_notification_model.dart';
import 'package:remindus/repositories/reminder/reminder_repository.dart';
import '../../repositories/connection/connection_repositories.dart';

part 'reminders_event.dart';

part 'reminders_state.dart';

class ReminderBloc extends Bloc<RemindersEvent, ReminderState> {
  ConnectionRepository connectionRepository;
  ReminderRepository reminderRepository;

  ReminderBloc({
    required this.connectionRepository,
    required this.reminderRepository,
  }) : super(ReminderInitialState()) {
    on<RemindersEvent>((event, emit) async {
      bool isConnected = await connectionRepository.isConnectedToInternet();
      if (isConnected) {
        if (event is AddMeetingsReminderEvent) {
          await _addMeetingsReminder(event, emit);
        }
        else if (event is SetVoiceNotificationEvent){
          await _addVoiceNotification(event, emit);

        } else if (event is UpdateMeetingsReminderEvent) {
          await _updateReminder(event, emit);
        }
      } else {
        _safeEmit(emit, NoInternetConnectionState());
      }
    });
  }

  // Safely emit a state only if the handler is still active
  void _safeEmit(Emitter<ReminderState> emit, ReminderState state) {
    if (emit.isDone) return;
    emit(state);
  }

  // Handler for adding meetings reminder
  Future<void> _addMeetingsReminder(
    AddMeetingsReminderEvent event,
    Emitter<ReminderState> emit,
  ) async {
    try {
      _safeEmit(emit, IsReminderLoadingState(isReminderLoading: true));
      await reminderRepository.addReminder(
        reminder: event.reminderMeetingsModel,
        activeFamilyId: event.activeFamilyId,
      );
      _safeEmit(emit, ReminderAddedSuccessState(isReminderAddedSuccess: true));

    } catch (e) {
      log('Error adding meetings reminder: $e');
      _safeEmit(emit, ReminderAddedSuccessState(isReminderAddedSuccess: false));

      _safeEmit(emit, IsReminderLoadingState(isReminderLoading: false));
    }
  }

  // Handler for updating meetings reminder
  Future<void> _updateReminder(
    UpdateMeetingsReminderEvent event,
    Emitter<ReminderState> emit,
  ) async {
    try {
      _safeEmit(emit, IsReminderLoadingState(isReminderLoading: true));
      await reminderRepository.updateReminder(
        reminder: event.reminderMeetingsModel,
        reminderId: event.reminderId,
        activeFamilyId: event.activeFamilyId,
      );
      _safeEmit(emit, IsReminderLoadingState(isReminderLoading: false));
      _safeEmit(emit, ReminderUpdatedSuccessState(isReminderUpdatedSuccess: true));

    } catch (e) {
      log('Error updating meetings reminder: $e');
      _safeEmit(emit, IsReminderLoadingState(isReminderLoading: false));
      _safeEmit(emit, ReminderUpdatedSuccessState(isReminderUpdatedSuccess: false));

    }
  }

  // add voice notification
  Future<void> _addVoiceNotification(
    SetVoiceNotificationEvent event,
    Emitter<ReminderState> emit,
  ) async {
    try {
      _safeEmit(emit, IsReminderLoadingState(isReminderLoading: true));

      await reminderRepository.addVoiceNotification(
        voiceNotificationModel: event.voiceNotificationModel,
        isAppOwner: event.isAppOwner,
      );
      _safeEmit(emit, ReminderAddedSuccessState(isReminderAddedSuccess: true));
      _safeEmit(emit, IsReminderLoadingState(isReminderLoading: false));


    } catch (e) {
      log('Error adding meetings reminder: $e');
      _safeEmit(emit, ReminderAddedSuccessState(isReminderAddedSuccess: false));

      _safeEmit(emit, IsReminderLoadingState(isReminderLoading: false));
    }
  }

}  
