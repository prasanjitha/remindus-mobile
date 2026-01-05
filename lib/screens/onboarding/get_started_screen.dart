import 'package:flutter/material.dart';
import 'package:remindus/screens/onboarding/onboarding_one_screen.dart';

import '../../widgets/custom_button.dart';
import 'package:remindus/generated/assets.dart';
import 'package:remindus/theme/app_colors.dart';

class GetStartedScreen extends StatelessWidget {
  const GetStartedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage(Assets.getStartedImg),
                fit: BoxFit.cover, 
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Stay Connected\nWith Care That Matters",
                          style: Theme.of(context).textTheme.displayLarge
                              ?.copyWith(color: context.appColors.textPrimary),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "A simple and secure way to stay in touch, set reminders, and keep track of health together.",
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(color: context.appColors.textSecondary),
                        ),
                        const SizedBox(height: 40),

                        AppButton(
                          text: "Create Account",
                          backgroundColor: context.appColors.primaryLight,
                          textColor: context.appColors.textPrimary,
                          onPressed: () {
                            Navigator.pushNamed(context, '/onboarding-one');
                          },
                        ),
                        const SizedBox(height: 12),

                        AppButton(
                          text: "Login",
                          backgroundColor: context.appColors.primary,
                          onPressed: () {
                            Navigator.pushNamed(context, '/login');
                             
                          },
                        ),

                        const SizedBox(height: 24),

                        Center(
                          child: Text.rich(
                            TextSpan(
                              text: "By continuing, you agree to our ",
                              children: [
                                TextSpan(
                                  text: "Terms",
                                  style:  TextStyle(
                                    color: context.appColors.primary,
                                  ),
                                ),
                                  TextSpan(
                                  text: " & ",
                                  style:  TextStyle(
                                    color: context.appColors.textPrimary,
                                  ),
                                ),
                                  TextSpan(
                                  text: "Privacy Policy",
                                  style:  TextStyle(
                                    color: context.appColors.primary,
                                  ),
                                ),
                              ],
                            ),
                            textAlign: TextAlign.center,
                            style:  TextStyle(
                              fontFamily: 'Figtree',
                              fontSize: 12,
                              color:  context.appColors.textPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
