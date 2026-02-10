import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:remindus/blocs/user/user_bloc.dart';
import 'package:remindus/generated/assets.dart';
import 'package:remindus/repositories/reminder/reminder_repository.dart';
import 'package:remindus/screens/tab/main_tab_screen.dart';
import 'package:remindus/screens/tab/watch_connect_now_screen.dart';
import 'package:remindus/theme/app_colors.dart';
import 'package:remindus/utils/health_utils.dart';
import 'package:remindus/widgets/app_gradient_background.dart';
import 'package:remindus/widgets/custom_button.dart';
import 'package:remindus/widgets/health_status_indicator.dart';
import 'package:remindus/widgets/main_header_appbar.dart';
import 'package:remindus/screens/tab/heart_rate_screen.dart';
import 'package:remindus/screens/tab/blood_pressure_screen.dart';
import 'package:remindus/screens/tab/blood_type_screen.dart';
import 'package:remindus/screens/tab/manage_allergies_screen.dart';

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

    return AppGradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: SafeArea(
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
                          builder: (context) => MainTabScreen(initialIndex: 3),
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
    return StreamBuilder<Map<String, dynamic>>(
      stream: _reminderRepository.getHealthStatusStream(familyId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data == null) {
          return const CircularProgressIndicator();
        }

        // Data natham default values pennanna
        var data = snapshot.data ?? {};

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
              status: HealthUtils.getHeartRateStatus(heartRate),
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
              value: bp,
              status: HealthUtils.getBloodPressureStatus(bp),
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
              value: bloodGroup,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => BloodTypeScreen(
                      initialBloodType: bloodGroup == 'N/A' ? null : bloodGroup,
                    ),
                  ),
                );
              },
            ),
            VitalCard(
              iconpath: Assets.alertSquareIcon,
              title: 'Allergies',
              value: allergiesText,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const ManageAllergiesScreen(),
                  ),
                );
              },
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
  final HealthStatus? status;
  final VoidCallback onTap;

  const VitalCard({
    super.key,
    required this.iconpath,
    required this.title,
    required this.value,
    required this.onTap,
    this.status,
  });

  @override
  Widget build(BuildContext context) {
    final isAppOwner = context.select<UserBloc, bool>((bloc) {
      final state = bloc.state;
      return state is UserLoadedState ? state.isAppowner : false;
    });
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
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: [
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 18,
                      color: context.appColors.textPrimary,
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
          if (isAppOwner)
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
