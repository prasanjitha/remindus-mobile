import 'package:flutter/material.dart';

class AppGradientBackground extends StatelessWidget {
  final Widget child;

  const AppGradientBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFE8F6F8), // Softened #97D5E2
            Color(0xFFF1E9F9), // Softened #9E5EDC
            Color(0xFFE9F1F8), // Softened #88B1DB
            Color(0xFFFFF2EC), // Softened #FD9B6C
          ],
          stops: [0.0, 0.4, 0.7, 1.0],
        ),
      ),
      child: child,
    );
  }
}
