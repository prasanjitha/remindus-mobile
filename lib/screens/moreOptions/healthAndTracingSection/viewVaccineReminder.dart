import 'package:flutter/material.dart';
import 'package:remindus/generated/assets.dart';
import 'package:remindus/widgets/custom_button.dart';

class ViewVaccineReminder extends StatefulWidget {
  const ViewVaccineReminder({super.key});

  @override
  State<ViewVaccineReminder> createState() => _ViewVaccineReminderState();
}

class _ViewVaccineReminderState extends State<ViewVaccineReminder> {
  // @override
  // void initState() {
  //   super.initState();
  //   addVaccine();
  // }

  // List<Map<String, String>> vaccines = [];
  List<Map<String, String>> vaccines = [
    {"name": "Flu Vaccine", "last": "Oct 15, 2025", "next": "Oct 2026"},
    {"name": "COVID-19 Booster", "last": "Sep 2025", "next": "Mar 2026"},
  ];

  void addVaccine() {
    setState(() {
      vaccines.add({
        "name": "Flu Vaccine",
        "last": "Oct 15, 2025",
        "next": "Oct 2026",
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(175),
        child: Container(
          margin: const EdgeInsets.only(
            top: 50,
            left: 22,
            right: 22,
            // bottom: 22,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Image.asset(Assets.logoIcon, height: 32),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.black),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                "Immunizations",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF242424),
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                "Manage your vaccination records",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF242424),
                ),
              ),
              const SizedBox(height: 22),
              Divider(thickness: 1, height: 1, color: Color(0xFFF0F0F0)),
            ],
          ),
        ),
      ),

      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                            Container(
                              padding: const EdgeInsets.all(4),
                              // color: const Color(0xFFF5F5F5),
                              child: Row(
                                children: [
                                  Image.asset(
                                    Assets.vaccineSyringeIcon,
                                    height: 24,
                                    width: 24,
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 12),

                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
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
                          ],
                        ),
                      );
                    },
                  ),
          ),

          Container(
            color: const Color(0xFFFAFAFA),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: AppButton(
                text: 'Add New Vaccination Record',
                backgroundColor: Colors.blueAccent,
                textColor: Colors.white,
                onPressed: addVaccine,
                height: 50,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
