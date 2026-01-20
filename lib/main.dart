import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:device_preview_plus/device_preview_plus.dart';

import 'package:remindus/app/app_router.dart';
import 'package:remindus/app/auth_wrapper.dart';
import 'package:remindus/blocs/user/user_bloc.dart';
import 'package:remindus/repositories/guardian/guardian_repositories.dart';
import 'package:remindus/theme/dark_theme.dart';
import 'package:remindus/theme/light_theme.dart';
import 'package:remindus/blocs/reminders/reminders_bloc.dart';
import 'package:remindus/services/local_notification_service.dart';
import 'package:remindus/screens/authentication/siginin_screen.dart';
import 'package:remindus/blocs/medicalstore/medical_store_bloc.dart';
import 'package:remindus/blocs/authentication/authentication_bloc.dart';
import 'package:remindus/repositories/reminder/reminder_repository.dart';
import 'package:remindus/repositories/connection/connection_repositories.dart';
import 'package:remindus/repositories/medicalstore/medical_store_repository.dart';
import 'package:remindus/repositories/authentication/authentication_repository.dart';

void main() async {
  await dotenv.load(fileName: ".env");
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Initialize notification service
  NotificationService notificationService = NotificationService();
  await notificationService.initialize();

  runApp(
    DevicePreview(
      // Enable preview only in debug mode
      enabled: !kReleaseMode,
      builder: (context) => const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    var authRepository = AuthRepository();
    var connectionRepository = ConnectionRepository();
    var reminderRepository = ReminderRepository();
    var medicalStoreRepository = MedicalStoreRepository();
    var guardianRepository = GuardianRepository();
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider(create: (context) => authRepository),
        RepositoryProvider(create: (context) => connectionRepository),
        RepositoryProvider(create: (context) => reminderRepository),
        RepositoryProvider(create: (context) => medicalStoreRepository),
        RepositoryProvider(create: (context) => guardianRepository),


        BlocProvider(
          create: (_) => UserBloc(
            auth: FirebaseAuth.instance,
            guardianRepository: guardianRepository,
            firestore: FirebaseFirestore.instance,
          )..add(LoadUserEvent()),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthenticationBloc>(
            create: (context) => AuthenticationBloc(
              authRepository: authRepository,
              connectionRepository: connectionRepository,
            ),
          ),

          BlocProvider<ReminderBloc>(
            create: (context) => ReminderBloc(
              reminderRepository: reminderRepository,
              connectionRepository: connectionRepository,
            ),
          ),
          BlocProvider<MedicalStoreBloc>(
            create: (context) => MedicalStoreBloc(
              medicalStoreRepository: medicalStoreRepository,
              connectionRepository: connectionRepository,
            ),
          ),
        ],
        child: MaterialApp(
          useInheritedMediaQuery: true,
          locale: DevicePreview.locale(context),
          builder: DevicePreview.appBuilder,
          debugShowCheckedModeBanner: false,
          theme: lightMode,
          darkTheme: darkMode,
          themeMode: ThemeMode.system,
          // home: const MainTabScreen(),
          home: const AuthWrapper(),
          routes: AppRoutes.routes,
          onUnknownRoute: (settings) => MaterialPageRoute(
            builder: (context) => LoginScreen(),
            settings: settings,
          ),
        ),
      ),
    );
  }
}
