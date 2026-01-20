part of 'reminders_bloc.dart';

abstract class RemindersEvent extends Equatable {
  const RemindersEvent();

  @override
  List<Object> get props => [];
}

class AddMeetingsReminderEvent extends RemindersEvent {
  final ReminderModel reminderMeetingsModel;

  const AddMeetingsReminderEvent({required this.reminderMeetingsModel});
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

    const SetVoiceNotificationEvent({required this.voiceNotificationModel});
  @override
  List<Object> get props => [voiceNotificationModel];

}



