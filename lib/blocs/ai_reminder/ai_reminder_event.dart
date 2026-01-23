import 'package:equatable/equatable.dart';
import 'package:remindus/models/base_reminder_model.dart';

abstract class AiReminderEvent extends Equatable {
  const AiReminderEvent();

  @override
  List<Object?> get props => [];
}

class LoadAiReminders extends AiReminderEvent {
  final String? imagePath;
  LoadAiReminders({this.imagePath});

  @override
  List<Object?> get props => [imagePath];
}

class NextReminderItem extends AiReminderEvent {}

class UpdateCurrentReminder extends AiReminderEvent {
  final ReminderModel updatedReminder;
  const UpdateCurrentReminder(this.updatedReminder);

  @override
  List<Object?> get props => [updatedReminder];
}

class SaveAllReminders extends AiReminderEvent {
  final String activeFamilyId;
  const SaveAllReminders(this.activeFamilyId);

  @override
  List<Object?> get props => [activeFamilyId];
}
