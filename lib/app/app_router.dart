import 'package:flutter/material.dart';

import 'package:remindus/screens/authentication/send_otp_screen.dart';
import 'package:remindus/screens/authentication/siginin_screen.dart';
import 'package:remindus/screens/authentication/signup_screen.dart';
import 'package:remindus/screens/authentication/verify_email_screen.dart';
import 'package:remindus/screens/onboarding/get_started_screen.dart';
import 'package:remindus/screens/onboarding/onboarding_one_screen.dart';
import 'package:remindus/screens/onboarding/onboarding_three_screen%20.dart';
import 'package:remindus/screens/onboarding/onboarding_two_screen.dart';
import 'package:remindus/screens/tab/main_tab_screen.dart';
import 'package:remindus/screens/vaccination/vaccination_list_screen.dart';

class AppRoutes {
  static const home = '/home';
  static const getStarted = '/get-started';
  static const signup = '/signup';
  static const login = '/login';
  static const onboardingOne = '/onboarding-one';
  static const onboardingTwo = '/onboarding-two';
  static const onboardingThree = '/onboarding-three';
  static const verifyEmail = '/verify-email';
  static const sentOtp = '/sent-otp';

  static const verifyPhone = '/verify-phone';
  static const vaccinationList = '/vaccination-list';

  static Map<String, WidgetBuilder> routes = {
    home: (_) => const MainTabScreen(),
    getStarted: (_) => GetStartedScreen(),
    signup: (_) => SignUpScreen(),
    login: (_) => LoginScreen(),
    onboardingOne: (_) => const OnboardingOneScreen(),
    onboardingTwo: (_) => const OnboardingTwoScreen(),
    onboardingThree: (_) => const OnboardingThreeScreen(),
    verifyEmail: (_) => VerifyEmailPage(email: ''),

    verifyPhone: (_) => const VerifyPhoneScreen(),
    vaccinationList: (_) => const VaccinationListScreen(),
  };
}
