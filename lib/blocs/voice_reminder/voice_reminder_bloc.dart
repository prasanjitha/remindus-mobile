import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'voice_reminder_event.dart';
import 'voice_reminder_state.dart';
import '../../models/base_reminder_model.dart';
import '../../repositories/reminder/reminder_repository.dart';
import '../../services/openai_service.dart';

class VoiceReminderBloc extends Bloc<VoiceReminderEvent, VoiceReminderState> {
  final stt.SpeechToText _speechToText = stt.SpeechToText();
  final OpenAIService _openAIService;
  final ReminderRepository _reminderRepository;
  bool _isListening = false;

  VoiceReminderBloc({
    required OpenAIService openAIService,
    required ReminderRepository reminderRepository,
  }) : _openAIService = openAIService,
       _reminderRepository = reminderRepository,
       super(VoiceReminderInitial()) {
    on<StartListening>(_onStartListening);
    on<StopListening>(_onStopListening);
    on<UpdateVoiceText>(_onUpdateVoiceText);
    on<ProcessVoiceInput>(_onProcessVoiceInput);
    on<ConfirmReminder>(_onConfirmReminder); // Handle saving later
    on<ResetVoiceReminder>(_onResetVoiceReminder);
  }

  Future<void> _onStartListening(
    StartListening event,
    Emitter<VoiceReminderState> emit,
  ) async {
    bool available = await _speechToText.initialize();
    if (available) {
      _isListening = true;
      emit(const VoiceReminderListening(partialText: ''));
      _speechToText.listen(
        onResult: (result) {
          // Dispatch event instead of emit to properly update UI
          add(UpdateVoiceText(result.recognizedWords));
        },
      );
    } else {
      emit(const VoiceReminderError("Speech recognition not available"));
    }
  }

  Future<void> _onStopListening(
    StopListening event,
    Emitter<VoiceReminderState> emit,
  ) async {
    if (_isListening) {
      _isListening = false;
      await _speechToText.stop();
    }
    // Reset to initial state to show the mic button again
    emit(VoiceReminderInitial());
  }

  void _onUpdateVoiceText(
    UpdateVoiceText event,
    Emitter<VoiceReminderState> emit,
  ) {
    emit(VoiceReminderListening(partialText: event.text));
  }

  Future<void> _onProcessVoiceInput(
    ProcessVoiceInput event,
    Emitter<VoiceReminderState> emit,
  ) async {
    emit(VoiceReminderProcessing());
    try {
      if (event.text.isEmpty) {
        emit(const VoiceReminderError("No voice detected. Please try again."));
        return;
      }

      final details = await _openAIService.extractReminderDetails(event.text);

      final title = details['title'] ?? 'New Reminder';
      final dateStr = details['date'] ?? 'tomorrow';
      final timeStr = details['time'] ?? '09:00';
      final type = details['type'] ?? 'General';
      final medicineName = details['medicineName'];
      final dose = details['dose'];
      final duration = details['duration'];

      // Simple handling for "tomorrow" - in a real app, use a proper date parser
      DateTime date;
      final now = DateTime.now();
      if (dateStr.toLowerCase().contains('tomorrow')) {
        date = now.add(const Duration(days: 1));
      } else if (dateStr.toLowerCase().contains('today')) {
        date = now;
      } else {
        // Try parse YYYY-MM-DD
        try {
          date = DateTime.parse(dateStr);
        } catch (_) {
          date = now.add(const Duration(days: 1)); // Default fallback
        }
      }

      emit(
        VoiceReminderLoaded(
          title: title,
          date: date,
          time: timeStr,
          type: type,
          medicineName: medicineName,
          dose: dose,
          duration: duration,
        ),
      );
    } catch (e) {
      emit(VoiceReminderError("Failed to process reminder: ${e.toString()}"));
    }
  }

  Future<void> _onConfirmReminder(
    ConfirmReminder event,
    Emitter<VoiceReminderState> emit,
  ) async {
    try {
      // Create ReminderModel from voice reminder data
      final reminder = ReminderModel(
        type: event.type,
        title: event.title,
        time: event.time,
        dateTime: Timestamp.fromDate(event.date),
        scheduledAt: Timestamp.fromDate(event.date),
        isRead: false,
        createdAt: FieldValue.serverTimestamp(),
        updatedAt: FieldValue.serverTimestamp(),
        // Medicine-specific fields (only included if type is Medicine)
        medicineName: event.type == 'Medicine' ? event.medicineName : null,
        dose: event.type == 'Medicine' ? event.dose : null,
        duration: event.type == 'Medicine' ? event.duration : null,
      );

      // Save to Firebase
      final success = await _reminderRepository.addReminder(
        reminder: reminder,
        activeFamilyId: event.activeFamilyId,
      );

      if (success) {
        emit(VoiceReminderSaved());
      } else {
        emit(const VoiceReminderError('Failed to save reminder'));
      }
    } catch (e) {
      emit(VoiceReminderError('Failed to save reminder: ${e.toString()}'));
    }
  }

  void _onResetVoiceReminder(
    ResetVoiceReminder event,
    Emitter<VoiceReminderState> emit,
  ) {
    _isListening = false;
    _speechToText.stop();
    emit(VoiceReminderInitial());
  }
}
