import 'package:flutter/material.dart';
import 'package:remindus/theme/app_colors.dart';
import 'package:remindus/widgets/app_gradient_background.dart';
import 'package:remindus/widgets/main_header_appbar.dart';
import 'package:remindus/widgets/custom_button.dart';

class TermsAndConditionsScreen extends StatelessWidget {
  const TermsAndConditionsScreen({super.key});

  Widget _buildHeader(String title, String subTitle, AppColors appColors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w400,
            color: appColors.textPrimary,
            fontSize: 28,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          subTitle,
          style: TextStyle(
            fontWeight: FontWeight.w400,
            color: appColors.textPrimary,
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColors>()!;

    return AppGradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                const MainHeaderAppBar(),
                const SizedBox(height: 30),
                _buildHeader(
                  "Terms & Conditions",
                  "Rules and guidelines for using RemindUs.",
                  appColors,
                ),
                const SizedBox(height: 30),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionTitle("1. Acceptance of Terms", appColors),
                        _buildSectionContent(
                          "By using RemindUs, you agree to comply with and be bound by these terms and conditions. If you do not agree, please do not use the application.",
                          appColors,
                        ),
                        _buildSectionTitle("2. User Responsibility", appColors),
                        _buildSectionContent(
                          "Users are responsible for the accuracy of health data entered. RemindUs is a tool to assist with reminders and tracking, but it is not a substitute for professional medical advice.",
                          appColors,
                        ),
                        _buildSectionTitle("3. Account Security", appColors),
                        _buildSectionContent(
                          "You are responsible for maintaining the confidentiality of your account credentials and for all activities that occur under your account.",
                          appColors,
                        ),
                        _buildSectionTitle(
                          "4. Service Modifications",
                          appColors,
                        ),
                        _buildSectionContent(
                          "We reserve the right to modify or discontinue the service at any time without prior notice. We will not be liable for any such modifications or interruptions.",
                          appColors,
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
                AppButton(
                  text: "Close",
                  onPressed: () => Navigator.pop(context),
                  backgroundColor: appColors.primary,
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, AppColors appColors) {
    return Padding(
      padding: const EdgeInsets.only(top: 24.0, bottom: 8.0),
      child: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w500,
          color: appColors.textPrimary,
          fontSize: 20,
        ),
      ),
    );
  }

  Widget _buildSectionContent(String content, AppColors appColors) {
    return Text(
      content,
      style: TextStyle(
        color: appColors.textPrimary.withOpacity(0.8),
        fontSize: 16,
        height: 1.5,
      ),
    );
  }
}
