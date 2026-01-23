import 'package:equatable/equatable.dart';

abstract class VoiceReminderEvent extends Equatable {
  const VoiceReminderEvent();

  @override
  List<Object?> get props => [];
}

class StartListening extends VoiceReminderEvent {}

class StopListening extends VoiceReminderEvent {}

class ProcessVoiceInput extends VoiceReminderEvent {
  final String text;

  const ProcessVoiceInput(this.text);

  @override
  List<Object> get props => [text];
}

class UpdateVoiceText extends VoiceReminderEvent {
  final String text;

  const UpdateVoiceText(this.text);

  @override
  List<Object> get props => [text];
}

class ConfirmReminder extends VoiceReminderEvent {
  final String title;
  final DateTime date;
  final String time;
  final String activeFamilyId;
  final String type;
  final String? medicineName;
  final String? dose;
  final String? duration;

  const ConfirmReminder({
    required this.title,
    required this.date,
    required this.time,
    required this.activeFamilyId,
    this.type = 'General',
    this.medicineName,
    this.dose,
    this.duration,
  });

  @override
  List<Object?> get props => [
    title,
    date,
    time,
    activeFamilyId,
    type,
    medicineName,
    dose,
    duration,
  ];
}

class ResetVoiceReminder extends VoiceReminderEvent {}
