import 'package:flutter/material.dart';
import 'package:remindus/generated/assets.dart';
import 'package:remindus/theme/app_colors.dart';
import 'package:remindus/widgets/custom_button.dart';
import 'package:remindus/widgets/main_header_appbar.dart';
import 'package:remindus/screens/moreOptions/healthAndTracingSection/addVaccinationReminder.dart';

class ManageVaccinationScreen extends StatelessWidget {
  final String vaccine;
  final String dateReceived;
  final String nextDose;
  final String frequency;

  const ManageVaccinationScreen({
    super.key,
    required this.vaccine,
    required this.dateReceived,
    required this.nextDose,
    required this.frequency,
  });

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;

    return Scaffold(
      backgroundColor: appColors.bgColor,
      body: Stack(
        children: [
          // Background
          Positioned.fill(
            child: Image.asset(
              Assets.bgColorMap,
              fit: BoxFit.cover,
              opacity: const AlwaysStoppedAnimation(.5),
            ),
          ),

          SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MainHeaderAppBar(),
                const SizedBox(height: 20),

                Text(
                  "Manage Vaccination",
                  style: TextStyle(
                    fontWeight: FontWeight.w400,
                    color: appColors.textPrimary,
                    fontSize: 28,
                  ),
                ),
                const SizedBox(height: 8),

                Text(
                  "Edit your vaccination records",
                  style: TextStyle(
                    fontWeight: FontWeight.w400,
                    color: appColors.textSecondary,
                    fontSize: 16,
                  ),
                ),

                const SizedBox(height: 40),

                _ReadOnlyField(
                  label: "Select vaccine",
                  icon: Assets.vaccineSyringeIcon,
                  value: vaccine,
                ),

                _ReadOnlyField(
                  label: "Date received",
                  icon: Assets.calendar2Icon,
                  value: dateReceived,
                ),

                _ReadOnlyField(
                  label: "Frequency",
                  icon: Assets.calenderFavIcon,
                  value: frequency,
                ),

                _ReadOnlyField(
                  label: "Next dose due",
                  icon: Assets.calendar2Icon,
                  value: nextDose,
                ),

                const SizedBox(height: 100),
              ],
            ),
          ),
        ],
      ),

      bottomNavigationBar: Container(
        color: const Color(0xFFFAFAFA),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppButton(
              text: 'Edit Vaccination Record',
              height: 50,
              backgroundColor: const Color(0xFF0168FF),
              textColor: Colors.white,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddVaccinationRecordScreen(
                      vaccine: vaccine,
                      dateReceived: DateTime.parse(dateReceived),
                      nextDose: DateTime.parse(nextDose),
                      frequency: frequency,
                      isEdit: true,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            AppButton(
              text: 'Remove Vaccination Record',
              height: 50,
              backgroundColor: Colors.red.shade100,
              textColor: Colors.red,
              onPressed: () {
                _showDeleteConfirmation(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Remove Vaccination"),
        content: const Text(
          "Are you sure you want to remove this vaccination record?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text("Remove", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class _ReadOnlyField extends StatelessWidget {
  final String label;
  final String icon;
  final String value;

  const _ReadOnlyField({
    required this.label,
    required this.icon,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              Image.asset(icon, height: 22),
              const SizedBox(width: 12),
              Expanded(
                child: Text(value, style: const TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}
