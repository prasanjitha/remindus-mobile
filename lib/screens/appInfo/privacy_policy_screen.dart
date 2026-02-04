import 'package:flutter/material.dart';
import 'package:remindus/theme/app_colors.dart';
import 'package:remindus/widgets/app_gradient_background.dart';
import 'package:remindus/widgets/main_header_appbar.dart';
import 'package:remindus/widgets/custom_button.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

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
                  "Privacy Policy",
                  "Understanding how we protect your data.",
                  appColors,
                ),
                const SizedBox(height: 30),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionTitle(
                          "1. Information Collection",
                          appColors,
                        ),
                        _buildSectionContent(
                          "RemindUs collects health-related information such as medication names, vaccination records, and heart rate data to provide personalized reminders and health tracking features.",
                          appColors,
                        ),
                        _buildSectionTitle("2. Data Usage", appColors),
                        _buildSectionContent(
                          "Your data is used solely to provide and improve our services, including scheduling reminders and sharing information with your designated guardians.",
                          appColors,
                        ),
                        _buildSectionTitle("3. Information Sharing", appColors),
                        _buildSectionContent(
                          "We do not sell your personal data. Information is only shared with guardians you explicitly authorize within the app.",
                          appColors,
                        ),
                        _buildSectionTitle("4. Data Security", appColors),
                        _buildSectionContent(
                          "We use industry-standard security measures to protect your information, including encryption and secure cloud storage through Firebase.",
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
