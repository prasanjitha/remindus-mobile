import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:remindus/blocs/user/user_bloc.dart';
import 'package:remindus/blocs/voice_reminder/voice_reminder_bloc.dart';
import 'package:remindus/blocs/voice_reminder/voice_reminder_event.dart';
import 'package:remindus/blocs/voice_reminder/voice_reminder_state.dart';
import 'package:remindus/screens/voice_reminder/voice_reminder_screen.dart';
import 'package:remindus/theme/app_colors.dart';

class MockVoiceReminderBloc
    extends MockBloc<VoiceReminderEvent, VoiceReminderState>
    implements VoiceReminderBloc {}

class MockUserBloc extends MockBloc<UserEvent, UserState> implements UserBloc {}

void main() {
  late MockVoiceReminderBloc mockVoiceReminderBloc;
  late MockUserBloc mockUserBloc;

  setUp(() {
    mockVoiceReminderBloc = MockVoiceReminderBloc();
    mockUserBloc = MockUserBloc();

    // Default states
    when(() => mockVoiceReminderBloc.state).thenReturn(VoiceReminderInitial());
    when(() => mockUserBloc.state).thenReturn(UserInitialState());
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      theme: ThemeData(
        extensions: [
          // If you use custom theme extensions, you might need to mock them.
          // But usually, standard Material components will work.
        ],
      ),
      home: BlocProvider<UserBloc>.value(
        value: mockUserBloc,
        child: VoiceReminderScreen(voiceReminderBloc: mockVoiceReminderBloc),
      ),
    );
  }

  testWidgets('renders initial view correctly', (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pump(); // Ensure animations start/settle

    expect(find.text('Add Voice Reminder'), findsOneWidget);
    expect(find.text('Tap to add your voice'), findsOneWidget);
  });

  testWidgets('renders listening view when state is VoiceReminderListening', (
    WidgetTester tester,
  ) async {
    when(
      () => mockVoiceReminderBloc.state,
    ).thenReturn(const VoiceReminderListening(partialText: 'taking water'));

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pump();

    expect(find.text('Listening...'), findsNothing);
    expect(find.text('taking water'), findsOneWidget);
  });
}
