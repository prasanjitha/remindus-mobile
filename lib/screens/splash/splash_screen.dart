import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:remindus/generated/assets.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../../blocs/authentication/authentication_bloc.dart';
import 'package:remindus/widgets/app_gradient_background.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  String _version = "";

  @override
  void initState() {
    super.initState();
    context.read<AuthenticationBloc>().add(CheckAuthStatusEvent());

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    final PackageInfo packageInfo = await PackageInfo.fromPlatform();
    if (mounted) {
      setState(() {
        _version = packageInfo.version;
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppGradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                Assets.bgColorMap,
                fit: BoxFit.cover,
                opacity: const AlwaysStoppedAnimation(0.6),
              ),
            ),
            Center(child: Image.asset(Assets.logoIcon, width: 38, height: 38)),
            if (_version.isNotEmpty)
              Positioned(
                bottom: 20,
                left: 0,
                right: 0,
                child: Center(
                  child: Text(
                    "Version $_version",
                    style: const TextStyle(
                      color: Colors.black54,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
