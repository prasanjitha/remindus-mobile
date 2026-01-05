import 'package:flutter/material.dart';

import 'package:remindus/generated/assets.dart';
import 'package:remindus/widgets/zoomed_image.dart';
import 'package:remindus/widgets/onboard_bottom_card.dart';

class OnboardingTwoScreen extends StatelessWidget {
  const OnboardingTwoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          ZoomedImage(
            imagePath: Assets.onboardingTwo,
            scale: 1.36,
            alignment: const Alignment(0.6, 0.6),
          ),

          Align(
            alignment: Alignment.bottomCenter,
            child: OnboardBottomCard(
              title: "See How You're Doing",
              description:
                  "Track your medications, heart rate, and daily steps all in one place.",
              imagePath: Assets.logoIcon,
              currentIndex: 1,
              totalSteps: 3,
              onNext: () {
                Navigator.pushNamed(context, '/onboarding-three');
              },
              onSkip: () {
                Navigator.pushNamed(context, '/signup');
              },
            ),
          ),
        ],
      ),
    );
  }
}
