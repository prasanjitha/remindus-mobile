import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:remindus/blocs/user/user_bloc.dart';
import 'package:remindus/generated/assets.dart';
import 'package:remindus/repositories/reminder/reminder_repository.dart';
import 'package:remindus/screens/tab/main_tab_screen.dart';
import 'package:remindus/screens/tab/watch_connect_now_screen.dart';
import 'package:remindus/theme/app_colors.dart';
import 'package:remindus/widgets/custom_button.dart';
import 'package:remindus/widgets/main_header_appbar.dart';

class HealthCheckupScreen extends StatefulWidget {
  const HealthCheckupScreen({super.key});

  @override
  State<HealthCheckupScreen> createState() => _HealthCheckupScreenState();
}

class _HealthCheckupScreenState extends State<HealthCheckupScreen> {
  final ReminderRepository _reminderRepository = ReminderRepository();

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;
    final activeFamilyId = context.select<UserBloc, String?>((bloc) {
      final state = bloc.state;
      return (state is UserLoadedState) ? state.activeFamilyId : null;
    });

    final isAppOwner = context.select<UserBloc, bool>((bloc) {
      final state = bloc.state;
      return state is UserLoadedState ? state.isAppowner : false;
    });

    return Scaffold(
      backgroundColor: appColors.bgColor,
      body: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: Stack(
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
                            builder: (context) =>
                                MainTabScreen(initialIndex: 3),
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

                    _buildDeviceCard(context, isAppOwner),
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
                    _buildVitalGrid(activeFamilyId!),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeviceCard(BuildContext context, bool isAdmin) {
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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Apple Watch',
                          style: TextStyle(
                            fontSize: 20.0,
                            fontWeight: FontWeight.w400,
                            color: context.appColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          'Syncing:',
                          style: TextStyle(
                            color: context.appColors.placeholder,
                            fontSize: 14.0,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            ' Heart rate, blood pressure...',
                            style: TextStyle(
                              color: context.appColors.textSecondary,
                              fontSize: 14.0,
                              fontWeight: FontWeight.w400,
                            ),
                            textAlign: TextAlign.start,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 2),

                    Row(
                      children: [
                        Text(
                          'Last sync:',
                          style: TextStyle(
                            color: context.appColors.placeholder,
                            fontSize: 14.0,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            ' 2 min ago',
                            style: TextStyle(
                              color: context.appColors.textSecondary,
                              fontSize: 14.0,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (isAdmin)
                Text(
                  'Connected',
                  style: TextStyle(
                    color: Color(0xFF4A7C59),
                    fontSize: 14.0,
                    fontWeight: FontWeight.w400,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          if (isAdmin)
            AppButton(
              text: 'Manage Connection',
              onPressed: () {
                // Handle manage connection action
              },
              backgroundColor: context.appColors.primary,
            ),
        ],
      ),
    );
  }

  Widget _buildVitalGrid(String familyId) {
    return StreamBuilder<DocumentSnapshot>(
      stream: _reminderRepository.getHealthStatusStream(familyId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data == null) {
          return const CircularProgressIndicator();
        }

        // Data natham default values pennanna
        var data = snapshot.data?.data() as Map<String, dynamic>? ?? {};

        String heartRate = data['heartRate'] ?? 'N/A';
        String bp = data['bloodPressure'] ?? 'N/A';
        String bloodGroup = data['bloodGroup'] ?? 'N/A';

        // Allergies List ekak widiyata thiyana nisa string ekakata convert karanna
        Map<String, dynamic>? allergiesMap = data['allergies'];
        String allergiesText = 'None';
        if (allergiesMap != null && allergiesMap.isNotEmpty) {
          allergiesText = allergiesMap.values
              .expand((e) => e as List)
              .join(', ');
        }

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
              value: heartRate,
            ),
            VitalCard(
              iconpath: Assets.bloodPressureIcon,
              title: 'Blood Pressure',
              value: bp,
            ),
            VitalCard(
              iconpath: Assets.bloodTypeIcon,
              title: 'Blood Type',
              value: bloodGroup,
            ),
            VitalCard(
              iconpath: Assets.alertSquareIcon,
              title: 'Allergies',
              value: allergiesText,
            ),
          ],
        );
      },
    );
  }
}

class VitalCard extends StatelessWidget {
  final String iconpath;
  final String title;
  final String value;

  const VitalCard({
    super.key,
    required this.iconpath,
    required this.title,
    required this.value,
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
            child: Image.asset(iconpath, width: 24.0, height: 24.0),
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
          _buildHealthValueTile(
            title,
            value,
            title == "Blood Pressure"
                ? getBPStatus(value)
                : title == "Heart Rate"
                ? getHeartRateStatus(value)
                : "",
            context.appColors,
          ),
        ],
      ),
    );
  }

  Widget _buildHealthValueTile(
    String label,
    String value,
    String status,
    AppColors appColors,
  ) {
    Color statusColor = status == "Normal" ? Colors.green : Colors.redAccent;

    return Flexible(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(
          children: [
            Text(
              value,
              style: TextStyle(fontSize: 18, color: appColors.textPrimary),
            ),
            const SizedBox(width: 10),
            if (status.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: statusColor),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String getBPStatus(String value) {
    if (value.isEmpty) return "";
    try {
      final String numericOnly = value.replaceAll(RegExp(r'[^0-9/]'), '');
      final parts = numericOnly.split('/');
      int systolic = int.parse(parts[0].trim());

      if (systolic >= 140) return "High";
      if (systolic >= 120) return "Elevated";
      return "Normal";
    } catch (e) {
      log("Error parsing BP: $e");
      return "";
    }
  }

  String getHeartRateStatus(String value) {
    if (value.isEmpty) return "";
    int? rate = int.tryParse(value);
    if (rate == null) return "";

    if (rate > 100) return "High";
    if (rate < 60) return "Low";
    return "Normal";
  }
}
