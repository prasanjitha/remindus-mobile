import 'dart:io';

import 'package:flutter/material.dart';
import 'package:remindus/theme/app_colors.dart'; // Ensure this points to your extension file

class OnboardBottomCard extends StatelessWidget {
  final String title;
  final String description;
  final String imagePath;
  final int currentIndex;
  final int totalSteps;
  final VoidCallback onNext;
  final VoidCallback onSkip;
  final String netBtnText;
  final String skipBtnText;

  const OnboardBottomCard({
    super.key,
    required this.title,
    required this.description,
    required this.imagePath,
    required this.currentIndex,
    required this.totalSteps,
    required this.onNext,
    required this.onSkip,
    this.netBtnText = "Next",
    this.skipBtnText = "Skip",
  });

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;

    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(
        left: 8.0,
        right: 8.0,
        top: 8.0,
        bottom: Platform.isIOS ? 16.0 : 8.0,
      ),
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: context.appColors.bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Logo/Icon
          Image.asset(
            imagePath,
            width: 40,
            height: 40,
            fit: BoxFit.cover,
          ),
          const SizedBox(height: 20),

          // Heading
          Text(
            title,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w400,
                  color: appColors.textPrimary,
                  fontSize: 28.0,
                ),
          ),
          const SizedBox(height: 16),

          // Subtext
          Text(
            description,
            style: TextStyle(
              fontSize: 16,
              color: appColors.textSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 20),

          // Page Indicators
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              totalSteps,
              (index) => _buildIndicator(
                isActive: index == currentIndex,
                activeColor: appColors.primary,
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onSkip,
                  style: OutlinedButton.styleFrom(
                    backgroundColor: appColors.primaryLight,
                    side: BorderSide.none,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    skipBtnText,
                    style: TextStyle(
                      color: appColors.textSecondary,
                      fontSize: 16.0,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: onNext,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: appColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    netBtnText,
                    style: TextStyle(
                      color: appColors.bgColor,
                      fontSize: 16.0,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIndicator({required bool isActive, required Color activeColor}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      height: 4,
      width: 12,
      decoration: BoxDecoration(
        color: isActive ? activeColor : const Color(0xFFE0E0E0),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}