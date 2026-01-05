import 'package:device_preview_plus/device_preview_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:remindus/DummyHome.dart';
import 'package:remindus/blocs/authentication/authentication_bloc.dart';
import 'package:remindus/repositories/authentication/authentication_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:remindus/repositories/connection/connection_repositories.dart';
import 'package:remindus/screens/authentication/phone_authpage_screen.dart';
import 'package:remindus/screens/authentication/send_otp_screen.dart';
import 'package:remindus/screens/authentication/siginin_screen.dart';
import 'package:remindus/screens/authentication/signup_screen.dart';
import 'package:remindus/screens/authentication/verify_phone_screen.dart';
import 'package:remindus/screens/onboarding/get_started_screen.dart';
import 'package:remindus/screens/onboarding/onboarding_one_screen.dart';
import 'package:remindus/screens/onboarding/onboarding_three_screen%20.dart';
import 'package:remindus/screens/onboarding/onboarding_two_screen.dart';
import 'package:remindus/screens/splash/splash_screen.dart';
import 'package:remindus/theme/dark_theme.dart';
import 'package:remindus/theme/light_theme.dart';
import 'package:remindus/home_page.dart';

void main() async {
  await dotenv.load(fileName: ".env");
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp( DevicePreview(
      // Enable preview only in debug mode
      enabled: !kReleaseMode,
      builder: (context) => const MyApp(), 
    ),);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    var authRepository = AuthRepository();
    var connectionRepository = ConnectionRepository();
    return MultiRepositoryProvider(
      providers: [RepositoryProvider(create: (context) => authRepository)],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthenticationBloc>(
            create: (context) => AuthenticationBloc(
              authRepository: authRepository,
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
          home: const SplashScreen(),
          routes: {
            '/home': (context) => const DummyHome(),
            '/get-started': (context) => GetStartedScreen(),
            '/signup': (context) => SignUpScreen(),
            '/login': (context) => LoginScreen(),
            '/onboarding-one': (context) => const OnboardingOneScreen(),
            '/onboarding-two': (context) => const OnboardingTwoScreen(),
            '/onboarding-three': (context) => const OnboardingThreeScreen(),
            },
          onUnknownRoute: (settings) => MaterialPageRoute(
            builder: (context) => LoginScreen(),
            settings: settings,
          ),
        ),
      ),
    );
  }
}
