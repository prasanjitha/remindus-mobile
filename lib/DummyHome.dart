import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:remindus/blocs/authentication/authentication_bloc.dart';
import 'package:remindus/generated/assets.dart';
import 'package:remindus/theme/app_colors.dart';
import 'package:remindus/widgets/custom_button.dart';

class DummyHome extends StatelessWidget {
  const DummyHome({super.key});

  @override
  Widget build(BuildContext context) {
    void loginWithGoogle(BuildContext context) async {
      context.read<AuthenticationBloc>().add(SignOutEvent());
      Navigator.pushReplacementNamed(context, '/get-started');
    }

    final appColors = context.appColors;
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(Assets.logoIcon),
              Text(
                'RemindUS',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: appColors.primary,
                ),
              ),
              Text(
                "Hi,We're under development. Feature Coming Soon",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: AppButton(
            text: 'Log Out',
            backgroundColor: appColors.primary,
            textColor: Colors.white,
            onPressed: () {
              loginWithGoogle(context);
            },
          ),
        ),
      ),
    );
  }
}
