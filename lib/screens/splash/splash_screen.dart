import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:remindus/generated/assets.dart';
import '../../blocs/authentication/authentication_bloc.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    context.read<AuthenticationBloc>().add(CheckAuthStatusEvent());
    _navigateToNext();
  }

  void _navigateToNext() {
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/get-started');
      }
    });
  }

@override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF97D5E2), 
              Color(0xFF88B1DB),
              Color(0xFF9E5EDC), 
              Color(0xFFFD9B6C), 
            ],
            stops: [0.0, 0.3, 0.6, 1.0], 
          ),
        ),
        child: Center(
          child: Image.asset(
            Assets.logoIcon, 
            width: 38,
            height: 38,

          ),
        ),
      ),
    );
  }
}
