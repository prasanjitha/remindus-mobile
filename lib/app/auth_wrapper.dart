import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:remindus/blocs/user/user_bloc.dart';
import 'package:remindus/screens/splash/splash_screen.dart';
import 'package:remindus/screens/authentication/siginin_screen.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SplashScreen();
        }
        if (snapshot.hasData) {
          context.read<UserBloc>().add(LoadUserEvent());
          // return const MainTabScreen();
          return LoginScreen();
        }

        return const SplashScreen();
      },
    );
  }
}
