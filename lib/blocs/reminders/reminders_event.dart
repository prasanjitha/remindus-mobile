part of 'reminders_bloc.dart';

abstract class RemindersEvent extends Equatable {
  const RemindersEvent();

  @override
  List<Object> get props => [];
}

class AddMeetingsReminderEvent extends RemindersEvent {
  final ReminderModel reminderMeetingsModel;
  final String activeFamilyId;

  const AddMeetingsReminderEvent({
    required this.reminderMeetingsModel,
    required this.activeFamilyId,
  });
  @override
  List<Object> get props => [reminderMeetingsModel];
}

class UpdateMeetingsReminderEvent extends RemindersEvent {
  final ReminderModel reminderMeetingsModel;
  final String reminderId;
  final String activeFamilyId;

  const UpdateMeetingsReminderEvent({
    required this.reminderMeetingsModel,
    required this.reminderId,
    required this.activeFamilyId,
  });
  @override
  List<Object> get props => [reminderMeetingsModel, reminderId];
}

class SetVoiceNotificationEvent extends RemindersEvent {
  final VoiceNotificationModel  voiceNotificationModel;
  final bool isAppOwner;

  const SetVoiceNotificationEvent({
    required this.voiceNotificationModel,
    required this.isAppOwner,
  });
  @override
  List<Object> get props => [voiceNotificationModel, isAppOwner];

}



