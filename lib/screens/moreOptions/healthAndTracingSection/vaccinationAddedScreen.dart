import 'package:flutter/material.dart';
import 'package:remindus/generated/assets.dart';
import 'package:remindus/theme/app_colors.dart';
import 'package:remindus/widgets/custom_button.dart';
import 'package:remindus/widgets/main_header_appbar.dart';

class VaccinationAddedScreen extends StatelessWidget {
  final String vaccine;
  final DateTime fromDate;
  final DateTime toDate;
  final String frequency;

  const VaccinationAddedScreen({
    super.key,
    required this.vaccine,
    required this.fromDate,
    required this.toDate,
    required this.frequency,
  });

  String _formatDate(DateTime date) {
    return date.toString().split(" ")[0];
  }

  Widget _infoBox({
    required String label,
    required String value,
    required String icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        const SizedBox(height: 6),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.black26),
          ),
          child: Row(
            children: [
              Image.asset(icon, height: 22),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  value,
                  style: const TextStyle(fontSize: 16, color: Colors.black),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

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
                  "Vaccination Added",
                  style: TextStyle(
                    fontWeight: FontWeight.w400,
                    color: appColors.textPrimary,
                    fontSize: 28.0,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Your details have been successfully recorded",
                  style: TextStyle(
                    fontWeight: FontWeight.w400,
                    color: appColors.textSecondary,
                    fontSize: 16.0,
                  ),
                ),

                const SizedBox(height: 40),

                _infoBox(
                  label: "Vaccine",
                  value: vaccine,
                  icon: Assets.vaccineIconBlack,
                ),

                _infoBox(
                  label: "Date received",
                  value: _formatDate(fromDate),
                  icon: Assets.calendar2Icon,
                ),

                _infoBox(
                  label: "Frequency",
                  value:
                      frequency, // Now uses the frequency directly as display text
                  icon: Assets.calenderFavIcon,
                ),

                _infoBox(
                  label: "Next dose due",
                  value: _formatDate(toDate),
                  icon: Assets.calendar2Icon,
                ),
              ],
            ),
          ),
        ],
      ),

      bottomNavigationBar: Container(
        color: const Color(0xFFFAFAFA),
        padding: const EdgeInsets.all(20),
        child: AppButton(
          text: 'Confirm',
          height: 50,
          backgroundColor: const Color(0xFF0168FF),
          textColor: Colors.white,
          onPressed: () {
            // Navigate back to the ViewVaccineReminder screen
            // Pop twice: once for this screen, once for AddVaccinationRecordScreen
            Navigator.pop(context);
            Navigator.pop(context);
            print("Confirmed vaccination added");
          },
        ),
      ),
    );
  }
}
