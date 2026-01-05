import 'package:flutter/material.dart';

import 'package:remindus/generated/assets.dart';
import 'package:remindus/widgets/zoomed_image.dart';
import 'package:remindus/widgets/onboard_bottom_card.dart';

class OnboardingThreeScreen extends StatelessWidget {
  const OnboardingThreeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          ZoomedImage(
            imagePath: Assets.onboardingThree,
            scale: 1,
            alignment: const Alignment(0.6, 0.6),
          ),

          Align(
            alignment: Alignment.bottomCenter,
            child: OnboardBottomCard(
              title: "Your Family Stays Close",
              description:
                  "Share your health updates with loved ones, and they can set reminders for you as well.",
              imagePath: Assets.logoIcon,
              currentIndex: 2,
              totalSteps: 3,
              netBtnText: 'Continue',
              skipBtnText: 'Back',
              onNext: () {
                Navigator.pushNamed(context, '/signup');
              },
              onSkip: () {
                Navigator.pushNamed(context, '/onboarding-two');
              },
            ),
          ),
        ],
      ),
    );
  }
}
