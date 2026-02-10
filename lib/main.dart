import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:remindus/services/encryption_service.dart';

import 'package:remindus/app/app_router.dart';
import 'package:remindus/app/auth_wrapper.dart';
import 'package:remindus/theme/dark_theme.dart';
import 'package:remindus/theme/light_theme.dart';
import 'package:remindus/blocs/user/user_bloc.dart';
import 'package:remindus/blocs/theme/theme_cubit.dart';
import 'package:remindus/blocs/theme/theme_state.dart';
import 'package:remindus/blocs/reminders/reminders_bloc.dart';
import 'package:remindus/blocs/vaccination/vaccination_bloc.dart';
import 'package:remindus/services/local_notification_service.dart';
import 'package:remindus/blocs/medicalstore/medical_store_bloc.dart';
import 'package:remindus/blocs/authentication/authentication_bloc.dart';
import 'package:remindus/repositories/reminder/reminder_repository.dart';
import 'package:remindus/repositories/guardian/guardian_repositories.dart';
import 'package:remindus/repositories/connection/connection_repositories.dart';
import 'package:remindus/repositories/vaccination/vaccination_repository.dart';
import 'package:remindus/repositories/medicalstore/medical_store_repository.dart';
import 'package:remindus/repositories/authentication/authentication_repository.dart';

void main() async {
  await dotenv.load(fileName: ".env");
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await EncryptionService().init();
  NotificationService notificationService = NotificationService();
  await notificationService.initialize();

  runApp(const MyApp());
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
    var vaccinationRepository = VaccinationRepository();
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider(create: (context) => authRepository),
        RepositoryProvider(create: (context) => connectionRepository),
        RepositoryProvider(create: (context) => reminderRepository),
        RepositoryProvider(create: (context) => medicalStoreRepository),
        RepositoryProvider(create: (context) => medicalStoreRepository),
        RepositoryProvider(create: (context) => guardianRepository),
        RepositoryProvider(create: (context) => vaccinationRepository),

        BlocProvider(
          create: (_) => UserBloc(
            auth: FirebaseAuth.instance,
            guardianRepository: guardianRepository,
            firestore: FirebaseFirestore.instance,
            authRepository: authRepository,
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
          BlocProvider<VaccinationBloc>(
            create: (context) =>
                VaccinationBloc(repository: vaccinationRepository),
          ),
          BlocProvider<ThemeCubit>(create: (context) => ThemeCubit()),
        ],
        child: BlocBuilder<ThemeCubit, ThemeState>(
          builder: (context, themeState) {
            return MaterialApp(
              useInheritedMediaQuery: true,
              debugShowCheckedModeBanner: false,
              theme: lightMode,
              darkTheme: darkMode,
              themeMode: themeState.themeMode,
              home: const AuthWrapper(),
              routes: AppRoutes.routes,
            );
          },
        ),
      ),
    );
  }
}
