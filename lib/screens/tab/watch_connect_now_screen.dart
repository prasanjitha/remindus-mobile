import 'package:flutter/material.dart';
import 'package:remindus/generated/assets.dart';
import 'package:remindus/screens/tab/blood_pressure_screen.dart';
import 'package:remindus/screens/tab/blood_type_screen.dart';
import 'package:remindus/screens/tab/heart_rate_screen.dart';
import 'package:remindus/screens/tab/manage_allergies_screen.dart';
import 'package:remindus/screens/tab/watch_connected_screen.dart';
import 'package:remindus/theme/app_colors.dart';
import 'package:remindus/widgets/custom_button.dart';
import 'package:remindus/widgets/main_header_appbar.dart';

class WatchConnceNowScreen extends StatelessWidget {
  const WatchConnceNowScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;
    return Scaffold(
      backgroundColor: appColors.bgColor,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              Assets.bgColorMap,
              fit: BoxFit.cover,
              opacity: const AlwaysStoppedAnimation(0.6),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MainHeaderAppBar(
                    onClose: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const HealthCheckupScreen(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 20),

                  Text(
                    "Health Checkup",
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                      color: appColors.textPrimary,
                      fontSize: 28.0,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    "Track your vital health information",
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                      color: appColors.textSecondary,
                      fontSize: 16.0,
                    ),
                  ),
                  const SizedBox(height: 40.0),

                  _buildDeviceCard(context),
                  const SizedBox(height: 24),
                  Text(
                    'Vital Signs',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w400,
                      color: appColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildVitalGrid(context),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeviceCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.appColors.bgColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 76.0,
                height: 76.0,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: context.appColors.primary.withOpacity(0.1),
                ),
                child: ClipOval(child: Image.asset(Assets.appleWatchIcon)),
              ),

              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Conncet Apple Watch',
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.w400,
                      color: context.appColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Automatically track activities.',
                    style: TextStyle(
                      color: context.appColors.textSecondary,
                      fontSize: 14.0,
                      fontWeight: FontWeight.w400,
                    ),
                    textAlign: TextAlign.start,
                  ),
                  SizedBox(height: 2),

                  Text(
                    'Your personal data remains private.',
                    style: TextStyle(
                      color: context.appColors.textSecondary,
                      fontSize: 14.0,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          AppButton(
            text: 'Conncet Now',
            onPressed: () {},
            backgroundColor: context.appColors.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildVitalGrid(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.4,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        VitalCard(
          iconpath: Assets.healthIcon,
          title: 'Heart Rate',
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const HeartRateAddSceen(),
              ),
            );
          },
        ),
        VitalCard(
          iconpath: Assets.bloodPressureIcon,
          title: 'Blood Pressure',
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const BloodPressureScreen(),
              ),
            );
          },
        ),
        VitalCard(
          iconpath: Assets.bloodTypeIcon,
          title: 'Blood Type',
          onTap: () {
            // Navigate to Blood Type Screen
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const BloodTypeScreen()),
            );
          },
        ),
        VitalCard(
          iconpath: Assets.alertSquareIcon,
          title: 'Allergies',
          onTap: () {
            // Navigate to Manage Allergies Screen
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const ManageAllergiesScreen(),
              ),
            );
          },
        ),
      ],
    );
  }
}

class VitalCard extends StatelessWidget {
  final String iconpath;
  final String title;
  final VoidCallback onTap;

  const VitalCard({
    super.key,
    required this.iconpath,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.appColors.bgColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Image.asset(
              iconpath,
              width: 24.0,
              height: 24.0,
              color: context.appColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.w400,
              color: context.appColors.textPrimary,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8.0),
          GestureDetector(
            onTap: onTap,
            child: Text(
              "+ Add Now",
              style: TextStyle(
                fontWeight: FontWeight.w400,
                color: context.appColors.primary,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
