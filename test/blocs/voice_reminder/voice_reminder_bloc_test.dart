import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:remindus/blocs/voice_reminder/voice_reminder_bloc.dart';
import 'package:remindus/blocs/voice_reminder/voice_reminder_event.dart';
import 'package:remindus/blocs/voice_reminder/voice_reminder_state.dart';
import 'package:remindus/repositories/reminder/reminder_repository.dart';
import 'package:remindus/services/openai_service.dart';
import 'package:remindus/models/base_reminder_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MockOpenAIService extends Mock implements OpenAIService {}

class MockReminderRepository extends Mock implements ReminderRepository {}

void main() {
  late VoiceReminderBloc voiceReminderBloc;
  late MockOpenAIService mockOpenAIService;
  late MockReminderRepository mockReminderRepository;

  setUp(() {
    mockOpenAIService = MockOpenAIService();
    mockReminderRepository = MockReminderRepository();
    voiceReminderBloc = VoiceReminderBloc(
      openAIService: mockOpenAIService,
      reminderRepository: mockReminderRepository,
    );
  });

  tearDown(() {
    voiceReminderBloc.close();
  });

  test('initial state is VoiceReminderInitial', () {
    expect(voiceReminderBloc.state, VoiceReminderInitial());
  });

  blocTest<VoiceReminderBloc, VoiceReminderState>(
    'emits VoiceReminderListening when UpdateVoiceText is added',
    build: () => voiceReminderBloc,
    act: (bloc) => bloc.add(const UpdateVoiceText('hello')),
    expect: () => [const VoiceReminderListening(partialText: 'hello')],
  );

  blocTest<VoiceReminderBloc, VoiceReminderState>(
    'emits [VoiceReminderProcessing, VoiceReminderLoaded] when ProcessVoiceInput is added and succeeds',
    build: () {
      when(() => mockOpenAIService.extractReminderDetails(any())).thenAnswer(
        (_) async => {
          'title': 'Take water',
          'date': '2026-01-29',
          'time': '10:00 AM',
          'type': 'General',
        },
      );
      return voiceReminderBloc;
    },
    act: (bloc) => bloc.add(
      const ProcessVoiceInput('remind me to take water tomorrow at 10am'),
    ),
    expect: () => [
      VoiceReminderProcessing(),
      isA<VoiceReminderLoaded>().having((s) => s.title, 'title', 'Take water'),
    ],
  );

  blocTest<VoiceReminderBloc, VoiceReminderState>(
    'emits [VoiceReminderProcessing, VoiceReminderError] when ProcessVoiceInput is empty',
    build: () => voiceReminderBloc,
    act: (bloc) => bloc.add(const ProcessVoiceInput('')),
    expect: () => [
      VoiceReminderProcessing(),
      const VoiceReminderError("No voice detected. Please try again."),
    ],
  );

  blocTest<VoiceReminderBloc, VoiceReminderState>(
    'emits VoiceReminderInitial when StopListening is added',
    build: () => voiceReminderBloc,
    act: (bloc) => bloc.add(StopListening()),
    expect: () => [VoiceReminderInitial()],
  );

  blocTest<VoiceReminderBloc, VoiceReminderState>(
    'emits VoiceReminderSaved when ConfirmReminder succeeds',
    build: () {
      registerFallbackValue(ReminderModel());
      when(
        () => mockReminderRepository.addReminder(
          reminder: any(named: 'reminder'),
          activeFamilyId: any(named: 'activeFamilyId'),
        ),
      ).thenAnswer((_) async => true);
      return voiceReminderBloc;
    },
    act: (bloc) => bloc.add(
      ConfirmReminder(
        title: 'Water',
        date: DateTime.now(),
        time: '10:00 AM',
        activeFamilyId: 'user123',
      ),
    ),
    expect: () => [VoiceReminderSaved()],
  );
}
