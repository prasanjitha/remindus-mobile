import 'package:flutter/material.dart';

class AppGradientBackground extends StatelessWidget {
  final Widget child;

  const AppGradientBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFF97D5E2).withOpacity(0.15),
            const Color(0xFF9E5EDC).withOpacity(0.15),
            const Color(0xFF88B1DB).withOpacity(0.15),
            const Color(0xFFFD9B6C).withOpacity(0.15),
          ],
          stops: const [0.0, 0.3, 0.6, 1.0],
        ),
      ),
      child: child,
    );
  }
}
