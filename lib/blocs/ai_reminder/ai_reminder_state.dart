import 'package:equatable/equatable.dart';
import 'package:remindus/models/base_reminder_model.dart';

abstract class AiReminderState extends Equatable {
  const AiReminderState();

  @override
  List<Object?> get props => [];
}

class AiReminderInitial extends AiReminderState {}

class AiReminderLoading extends AiReminderState {}

class AiReminderLoaded extends AiReminderState {
  final List<ReminderModel> reminders;
  final int currentIndex;
  final ReminderModel currentItem;

  const AiReminderLoaded({
    required this.reminders,
    required this.currentIndex,
    required this.currentItem,
  });

  @override
  List<Object?> get props => [reminders, currentIndex, currentItem];

  AiReminderLoaded copyWith({
    List<ReminderModel>? reminders,
    int? currentIndex,
    ReminderModel? currentItem,
  }) {
    return AiReminderLoaded(
      reminders: reminders ?? this.reminders,
      currentIndex: currentIndex ?? this.currentIndex,
      currentItem: currentItem ?? this.currentItem,
    );
  }
}

class AiReminderError extends AiReminderState {
  final String message;
  const AiReminderError(this.message);

  @override
  List<Object?> get props => [message];
}

class AiReminderSaved extends AiReminderState {
  final List<ReminderModel> reminders;
  const AiReminderSaved(this.reminders);

  @override
  List<Object?> get props => [reminders];
}
