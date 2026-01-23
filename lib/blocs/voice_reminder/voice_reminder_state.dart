import 'package:equatable/equatable.dart';

abstract class VoiceReminderState extends Equatable {
  const VoiceReminderState();

  @override
  List<Object?> get props => [];
}

class VoiceReminderInitial extends VoiceReminderState {}

class VoiceReminderListening extends VoiceReminderState {
  final String partialText;

  const VoiceReminderListening({this.partialText = ''});

  @override
  List<Object> get props => [partialText];
}

class VoiceReminderProcessing extends VoiceReminderState {}

class VoiceReminderLoaded extends VoiceReminderState {
  final String title;
  final DateTime date;
  final String time;
  final String type; // "Medicine" or "General"
  final String? medicineName;
  final String? dose;
  final String? duration;

  const VoiceReminderLoaded({
    required this.title,
    required this.date,
    required this.time,
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
    type,
    medicineName,
    dose,
    duration,
  ];
}

class VoiceReminderError extends VoiceReminderState {
  final String message;

  const VoiceReminderError(this.message);

  @override
  List<Object> get props => [message];
}

class VoiceReminderSaved extends VoiceReminderState {}
