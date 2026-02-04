import 'package:flutter/material.dart';
import 'package:remindus/generated/assets.dart';
import 'package:remindus/theme/app_colors.dart';
import 'package:remindus/widgets/app_gradient_background.dart';
import 'package:remindus/widgets/main_header_appbar.dart';
import 'package:remindus/widgets/custom_button.dart';

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});

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
                  "About RemindUs",
                  "Your reliable companion for health and medication reminders.",
                  appColors,
                ),
                const SizedBox(height: 30),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "RemindUs is designed to help you and your family manage medications, vaccinations, and health check-ups with ease. Our goal is to ensure that no important health task is ever missed.",
                          style: TextStyle(
                            color: appColors.textPrimary.withOpacity(0.8),
                            fontSize: 16,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          "Contact Us",
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: appColors.textPrimary,
                            fontSize: 20,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Image.asset(
                            Assets.phoneIcon,
                            height: 24,
                            width: 24,
                            color: appColors.primary,
                          ),
                          title: Text(
                            "+447475893452",
                            style: TextStyle(color: appColors.textPrimary),
                          ),
                        ),
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Image.asset(
                            Assets.emailIcon,
                            height: 24,
                            width: 24,
                            color: appColors.primary,
                          ),
                          title: Text(
                            "remindus56@gmail.com",
                            style: TextStyle(color: appColors.textPrimary),
                          ),
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
}
