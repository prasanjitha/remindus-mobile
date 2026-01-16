import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:remindus/generated/assets.dart';
import '../../blocs/authentication/authentication_bloc.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();

    context.read<AuthenticationBloc>().add(CheckAuthStatusEvent());

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

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
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              Assets.bgColorMap,
              fit: BoxFit.cover,
              opacity: const AlwaysStoppedAnimation(0.6),
            ),
          ),
          Center(
            child: Image.asset(
              Assets.logoIcon,
              width: 38,
              height: 38,
            ),
          ),
        ],
      ),
    );
  }
}
