import 'package:flutter/material.dart';
import 'package:remindus/generated/assets.dart';
import 'package:remindus/widgets/onboard_bottom_card.dart';

class OnboardingOneScreen extends StatelessWidget {
  const OnboardingOneScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [

          Positioned.fill(
            child: Image.asset(
              Assets.onboardingOne,
              fit: BoxFit.cover,
            ),
          ),

          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.black54),
                  onPressed: () => Navigator.pop(context),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.black54),
                  onPressed: () {
                     Navigator.pushNamed(context, '/signup');
                  },
                ),
              ],
            ),
          ),

          Align(
            alignment: Alignment.bottomCenter,
            child: OnboardBottomCard(
              title: "Never Miss a Medication",
              description: "Friendly voice reminders at the right time, every day. Your health routine, made simple.",
              imagePath: Assets.logoIcon,
              currentIndex: 0,
              totalSteps: 3,
              onNext: () {
                Navigator.pushNamed(context, '/onboarding-two');
              },
              onSkip: () {
                Navigator.pushNamed(context, '/get-started');
              },
            ),
          ),
        ],
      ),
    );
  }
}