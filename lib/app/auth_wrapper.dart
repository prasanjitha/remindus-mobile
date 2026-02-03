import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:remindus/repositories/authentication/authentication_repository.dart';
import 'package:remindus/screens/authentication/siginin_screen.dart';
import 'package:remindus/screens/tab/main_tab_screen.dart';

import '../screens/onboarding/get_started_screen.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  final AuthRepository _authRepository = AuthRepository();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Show loading while checking auth state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // User is authenticated
        if (snapshot.hasData && snapshot.data != null) {
          return FutureBuilder<bool>(
            future: _authRepository.getLocalRememberMe(),
            builder: (context, rememberMeSnapshot) {
              // Show loading while checking remember me status
              if (rememberMeSnapshot.connectionState ==
                  ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }

              // Check remember me status
              final rememberMe = rememberMeSnapshot.data ?? false;

              if (rememberMe) {
                // User has remember me enabled, go to MainTabScreen
                return const MainTabScreen();
              } else {
                // User doesn't have remember me enabled, go to SignIn screen
                return LoginScreen();
              }
            },
          );
        }

        // User is not authenticated, show SignIn screen
        return GetStartedScreen();
      },
    );
  }
}
