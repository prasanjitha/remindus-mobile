import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:remindus/blocs/ai_reminder/ai_reminder_event.dart';
import 'package:remindus/blocs/ai_reminder/ai_reminder_state.dart';
import 'package:remindus/models/base_reminder_model.dart';
import 'package:remindus/repositories/reminder/ai_reminder_repository.dart';
import 'package:remindus/services/ai_reminder_service.dart';

class AiReminderBloc extends Bloc<AiReminderEvent, AiReminderState> {
  final AiReminderService _aiService;
  final AiReminderRepository _repository;

  AiReminderBloc({
    required AiReminderService aiService,
    required AiReminderRepository repository,
  }) : _aiService = aiService,
       _repository = repository,
       super(AiReminderInitial()) {
    on<LoadAiReminders>(_onLoadAiReminders);
    on<NextReminderItem>(_onNextReminderItem);
    on<UpdateCurrentReminder>(_onUpdateCurrentReminder);
    on<SaveAllReminders>(_onSaveAllReminders);
  }

  Future<void> _onLoadAiReminders(
    LoadAiReminders event,
    Emitter<AiReminderState> emit,
  ) async {
    emit(AiReminderLoading());
    try {
      final reminders = await _aiService.extractRemindersFromAi(
        imagePath: event.imagePath,
      );
      if (reminders.isEmpty) {
        emit(const AiReminderError("No reminders found in the scan."));
      } else {
        emit(
          AiReminderLoaded(
            reminders: reminders,
            currentIndex: 0,
            currentItem: reminders.first,
          ),
        );
      }
    } catch (e) {
      emit(AiReminderError(e.toString()));
    }
  }

  void _onNextReminderItem(
    NextReminderItem event,
    Emitter<AiReminderState> emit,
  ) {
    if (state is AiReminderLoaded) {
      final currentState = state as AiReminderLoaded;

      // Update the list with the latest changes from currentItem before moving on
      List<ReminderModel> updatedList = List.from(currentState.reminders);
      updatedList[currentState.currentIndex] = currentState.currentItem;

      if (currentState.currentIndex < updatedList.length - 1) {
        int nextIndex = currentState.currentIndex + 1;
        emit(
          currentState.copyWith(
            reminders: updatedList,
            currentIndex: nextIndex,
            currentItem: updatedList[nextIndex],
          ),
        );
      }
    }
  }

  void _onUpdateCurrentReminder(
    UpdateCurrentReminder event,
    Emitter<AiReminderState> emit,
  ) {
    if (state is AiReminderLoaded) {
      final currentState = state as AiReminderLoaded;
      emit(currentState.copyWith(currentItem: event.updatedReminder));
    }
  }

  Future<void> _onSaveAllReminders(
    SaveAllReminders event,
    Emitter<AiReminderState> emit,
  ) async {
    if (state is AiReminderLoaded) {
      final currentState = state as AiReminderLoaded;
      // make sure implementation saves the CURRENT item to list before saving all
      List<ReminderModel> finalReminders = List.from(currentState.reminders);
      finalReminders[currentState.currentIndex] = currentState.currentItem;

      emit(AiReminderLoading());
      try {
        final savedReminders = await _repository.saveReminders(
          finalReminders,
          event.activeFamilyId,
        );
        emit(AiReminderSaved(savedReminders));
      } catch (e) {
        emit(AiReminderError("Failed to save reminders: ${e.toString()}"));
        // Revert to loaded state if we want the user to try again?
        // for now error state is fine.
      }
    }
  }
}
