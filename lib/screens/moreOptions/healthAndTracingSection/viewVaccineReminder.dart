import 'package:flutter/material.dart';
import 'package:remindus/generated/assets.dart';
import 'package:remindus/theme/app_colors.dart';
import 'package:remindus/widgets/custom_button.dart';
import 'package:remindus/widgets/main_header_appbar.dart';
import 'package:remindus/screens/moreOptions/healthAndTracingSection/addVaccinationReminder.dart';

class ViewVaccineReminder extends StatefulWidget {
  const ViewVaccineReminder({super.key});

  @override
  State<ViewVaccineReminder> createState() => _ViewVaccineReminderState();
}

class _ViewVaccineReminderState extends State<ViewVaccineReminder> {
  final List<Map<String, String>> vaccines = [
    {"name": "Flu Vaccine", "last": "Oct 15, 2025", "next": "Oct 2026"},
    {"name": "COVID-19 Booster", "last": "Sep 2025", "next": "Mar 2026"},
  ];

  void addVaccine() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddVaccinationRecordScreen()),
    );
  }

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

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    MainHeaderAppBar(),
                    const SizedBox(height: 20),

                    Text(
                      "Immunizations",
                      style: TextStyle(
                        fontWeight: FontWeight.w400,
                        color: appColors.textPrimary,
                        fontSize: 28,
                      ),
                    ),
                    const SizedBox(height: 8),

                    Text(
                      "Manage your vaccination records",
                      style: TextStyle(
                        fontWeight: FontWeight.w400,
                        color: appColors.textSecondary,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              Expanded(
                child: vaccines.isEmpty
                    ? const Center(
                        child: Text(
                          "No vaccines added yet",
                          style: TextStyle(color: Colors.black38, fontSize: 16),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: vaccines.length,
                        itemBuilder: (context, index) {
                          final v = vaccines[index];

                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black12.withOpacity(0.05),
                                  blurRadius: 10,
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Image.asset(
                                  Assets.vaccineSyringeIcon,
                                  height: 24,
                                  width: 24,
                                ),
                                const SizedBox(height: 12),

                                Text(
                                  v["name"]!,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                const SizedBox(height: 6),

                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "Last: ${v["last"]}",
                                      style: const TextStyle(
                                        color: Colors.black54,
                                        fontSize: 14,
                                      ),
                                    ),
                                    Text(
                                      "Next due: ${v["next"]}",
                                      style: const TextStyle(
                                        color: Colors.black54,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ],
      ),

      bottomNavigationBar: Container(
        color: const Color(0xFFFAFAFA),
        padding: const EdgeInsets.all(20),
        width: double.infinity,
        child: AppButton(
          text: 'Add New Vaccination Record',
          height: 50,
          backgroundColor: const Color(0xFF0168FF),
          textColor: Colors.white,
          onPressed: addVaccine,
        ),
      ),
    );
  }
}
