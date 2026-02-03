import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:remindus/blocs/user/user_bloc.dart';
import 'package:remindus/generated/assets.dart';
import 'package:remindus/repositories/reminder/reminder_repository.dart';
import 'package:remindus/screens/tab/blood_pressure_screen.dart';
import 'package:remindus/screens/tab/blood_type_screen.dart';
import 'package:remindus/screens/tab/heart_rate_screen.dart';
import 'package:remindus/screens/tab/manage_allergies_screen.dart';
import 'package:remindus/screens/tab/watch_connected_screen.dart';
import 'package:remindus/theme/app_colors.dart';
import 'package:remindus/utils/health_utils.dart';
import 'package:remindus/widgets/app_gradient_background.dart';
import 'package:remindus/widgets/health_status_indicator.dart';
import 'package:remindus/widgets/main_header_appbar.dart';

class WatchConnceNowScreen extends StatefulWidget {
  const WatchConnceNowScreen({super.key});

  @override
  State<WatchConnceNowScreen> createState() => _WatchConnceNowScreenState();
}

class _WatchConnceNowScreenState extends State<WatchConnceNowScreen> {
  int? _heartRate;

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;
    return AppGradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MainHeaderAppBar(
                  onClose: () {
                    Navigator.pop(context);
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
                BlocBuilder<UserBloc, UserState>(
                  builder: (context, state) {
                    if (state is UserLoadedState) {
                      return StreamBuilder<DocumentSnapshot>(
                        stream: ReminderRepository().getHealthStatusStream(
                          state.activeFamilyId,
                        ),
                        builder: (context, snapshot) {
                          final healthData =
                              snapshot.data?.data() as Map<String, dynamic>?;
                          return _buildVitalGrid(context, healthData);
                        },
                      );
                    }
                    return _buildVitalGrid(context, null);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showAllergiesPopup(BuildContext context, List<String> allergies) {
    showDialog(
      context: context,
      builder: (context) {
        final appColors = context.appColors;
        return AlertDialog(
          backgroundColor: appColors.bgColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            "Selected Allergies",
            style: TextStyle(color: appColors.textPrimary),
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: allergies.map((allergy) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Row(
                      children: [
                        Icon(
                          Icons.check_circle_outline,
                          size: 18,
                          color: appColors.primary,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            allergy,
                            style: TextStyle(
                              color: appColors.textPrimary,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Close", style: TextStyle(color: appColors.primary)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDeviceCard(BuildContext context) {
    // Only enable for iOS devices as requested
    if (!Platform.isIOS) {
      return const SizedBox.shrink();
    }

    final appColors = context.appColors;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: appColors.bgColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, 4),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 60.0,
                height: 60.0,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: appColors.primary.withOpacity(0.1),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Image.asset(
                    Assets.appleWatchIcon,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Heart Rate',
                      style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.w500,
                        color: appColors.textPrimary,
                      ),
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        if (_heartRate != null)
                          Text(
                            '$_heartRate bpm',
                            style: TextStyle(
                              color: appColors.primary,
                              fontSize: 24.0,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        const SizedBox(width: 8),
                        if (_heartRate != null)
                          HealthStatusIndicator(
                            status: HealthUtils.getHeartRateStatus(_heartRate),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _heartRate = 48;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: appColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    "+ Add Now",
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: appColors.primary,
                      fontSize: 14,
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

  Widget _buildVitalGrid(
    BuildContext context,
    Map<String, dynamic>? healthData,
  ) {
    String? heartRateValue = healthData?['heartRate'];
    String? bloodPressureValue = healthData?['bloodPressure'];
    String? bloodTypeValue = healthData?['bloodGroup'];

    // Collect and format allergy names
    List<String> allAllergies = [];
    if (healthData?['allergies'] != null) {
      final allergiesMap = healthData!['allergies'] as Map<String, dynamic>;
      for (var list in allergiesMap.values) {
        if (list is List) {
          allAllergies.addAll(list.map((e) => e.toString()));
        }
      }
    }

    String? allergyDisplay;
    if (allAllergies.isNotEmpty) {
      if (allAllergies.length <= 2) {
        allergyDisplay = allAllergies.join(", ");
      } else {
        allergyDisplay =
            "${allAllergies.take(2).join(", ")} +${allAllergies.length - 2} more";
      }
    }

    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        VitalCard(
          iconpath: Assets.healthIcon,
          title: 'Heart Rate',
          value: heartRateValue,
          status: HealthUtils.getHeartRateStatus(heartRateValue),
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
          value: bloodPressureValue,
          status: HealthUtils.getBloodPressureStatus(bloodPressureValue),
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
          value: bloodTypeValue,
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
          value: allergyDisplay,
          onValueTap: allAllergies.length > 2
              ? () => _showAllergiesPopup(context, allAllergies)
              : null,
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
  final VoidCallback? onValueTap;
  final String? value;
  final HealthStatus? status;

  const VitalCard({
    super.key,
    required this.iconpath,
    required this.title,
    required this.onTap,
    this.onValueTap,
    this.value,
    this.status,
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
          if (value != null)
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: onValueTap,
                      child: Text(
                        value.toString(),
                        style: TextStyle(
                          fontWeight: FontWeight.w400,
                          color: context.appColors.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    if (status != null && status != HealthStatus.unknown) ...[
                      const SizedBox(width: 8),
                      HealthStatusIndicator(status: status!, compact: true),
                    ],
                  ],
                ),
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
