import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:remindus/generated/assets.dart';
import 'package:remindus/models/vaccination_record.dart';
import 'package:remindus/screens/vaccination/vaccination_list_screen.dart';
import 'package:remindus/theme/app_colors.dart';
import 'package:remindus/widgets/app_gradient_background.dart';
import 'package:remindus/widgets/custom_button.dart';
import 'package:remindus/widgets/main_header_appbar.dart';

class VaccineConfirmScreen extends StatelessWidget {
  final VaccinationRecord record;

  const VaccineConfirmScreen({super.key, required this.record});

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
    final appColors = context.appColors;

    return AppGradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 20.0,
                horizontal: 24.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MainHeaderAppBar(
                    onClose: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const VaccinationListScreen(),
                        ),
                        (route) => false,
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  _buildHeader(
                    "Vaccination Added",
                    "Your details have been successfully recorded",
                    appColors,
                  ),

                  const SizedBox(height: 32),

                  _buildReadOnlyField(
                    context,
                    "Select vaccine",
                    record.vaccineName ?? "N/A",
                    Assets.vaccinationO1Icon,
                  ),
                  const SizedBox(height: 20),

                  _buildReadOnlyField(
                    context,
                    "Date received",
                    record.dateReceived != null
                        ? DateFormat('MM/dd/yyyy').format(record.dateReceived!)
                        : "N/A",
                    Assets.dateTimeIcon,
                  ),
                  const SizedBox(height: 20),

                  _buildReadOnlyField(
                    context,
                    "Frequency",
                    record.frequency ?? "N/A",
                    Assets.calendarFavoriteIcon,
                  ),
                  const SizedBox(height: 20),

                  _buildReadOnlyField(
                    context,
                    "Next dose due",
                    record.nextDoseDue != null
                        ? DateFormat('MM/dd/yyyy').format(record.nextDoseDue!)
                        : "N/A",
                    Assets.dateTimeIcon,
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.all(24.0),
          child: AppButton(
            text: "Confirm",
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) => const VaccinationListScreen(),
                ),
                (route) => false,
              );
            },
            backgroundColor: appColors.primary,
            textColor: appColors.bgColor,
          ),
        ),
      ),
    );
  }

  Widget _buildReadOnlyField(
    BuildContext context,
    String label,
    String value,
    String iconPath,
  ) {
    final appColors = context.appColors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: appColors.textPrimary.withOpacity(0.7),
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.black.withOpacity(0.05)),
          ),
          child: Row(
            children: [
              Image.asset(
                iconPath,
                height: 22,
                width: 22,
                color: const Color(0xFF1D2939),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  value,
                  style: const TextStyle(
                    color: Color(0xFF1D2939),
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
