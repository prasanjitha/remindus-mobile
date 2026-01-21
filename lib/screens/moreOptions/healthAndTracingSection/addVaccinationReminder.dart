import 'package:flutter/material.dart';
import 'package:remindus/generated/assets.dart';
import 'package:remindus/theme/app_colors.dart';
import 'package:remindus/widgets/custom_button.dart';
import 'package:remindus/widgets/main_header_appbar.dart';

class AddVaccinationRecordScreen extends StatefulWidget {
  const AddVaccinationRecordScreen({super.key});

  @override
  State<AddVaccinationRecordScreen> createState() =>
      _AddVaccinationRecordScreenState();
}

class _AddVaccinationRecordScreenState
    extends State<AddVaccinationRecordScreen> {
  String? selectedVaccine;
  String? selectedDose;
  String? frequency = "Once";
  DateTime? fromDate;
  DateTime? toDate;

  List<String> vaccines = ["Covid Shield", "MMR", "Hepatitis B", "Tetanus"];

  List<String> doses = ["Dose 1", "Dose 2", "Booster"];

  Future<void> pickFromDate() async {
    final date = await showDatePicker(
      context: context,
      firstDate: DateTime(2010),
      lastDate: DateTime(2040),
      initialDate: DateTime.now(),
    );
    if (date != null) {
      setState(() => fromDate = date);

      print("Received date: ${date.toString().split(" ")[0]}");
    }
  }

  Future<void> pickToDate() async {
    final date = await showDatePicker(
      context: context,
      firstDate: DateTime(2010),
      lastDate: DateTime(2040),
      initialDate: DateTime.now(),
    );
    if (date != null) {
      setState(() => toDate = date);

      print("Due date: ${date.toString().split(" ")[0]}");
    }
  }

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;
    return Scaffold(
      backgroundColor: appColors.bgColor,

      // appBar: PreferredSize(
      //   preferredSize: const Size.fromHeight(175),
      //   child: Container(
      //     margin: const EdgeInsets.only(
      //       top: 50,
      //       left: 22,
      //       right: 22,
      //       // bottom: 22,
      //     ),
      //     child: Column(
      //       crossAxisAlignment: CrossAxisAlignment.start,
      //       mainAxisSize: MainAxisSize.min,
      //       children: [
      //         Row(
      //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
      //           children: [
      //             Image.asset(Assets.logoIcon, height: 32),
      //             IconButton(
      //               icon: const Icon(Icons.close, color: Colors.black),
      //               onPressed: () => Navigator.pop(context),
      //             ),
      //           ],
      //         ),
      //         const SizedBox(height: 8),
      //         const Text(
      //           "Add Vaccination",
      //           style: TextStyle(
      //             fontSize: 28,
      //             fontWeight: FontWeight.w400,
      //             color: Color(0xFF242424),
      //           ),
      //         ),
      //         const SizedBox(height: 4),
      //         const Text(
      //           "Record your immunization details",
      //           style: TextStyle(
      //             fontSize: 16,
      //             fontWeight: FontWeight.w400,
      //             color: Color(0xFF242424),
      //           ),
      //         ),
      //         const SizedBox(height: 22),
      //         Divider(thickness: 1, height: 1, color: Color(0xFFF0F0F0)),
      //       ],
      //     ),
      //   ),
      // ),
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
                MainHeaderAppBar(
                  // onClose: () {
                  //   Navigator.push(
                  //     context,
                  //     MaterialPageRoute(
                  //       builder: (context) => const HealthCheckupScreen(),
                  //     ),
                  //   );
                  // },
                ),
                const SizedBox(height: 20),

                Text(
                  "Add Vaccination",
                  style: TextStyle(
                    fontWeight: FontWeight.w400,
                    color: appColors.textPrimary,
                    fontSize: 28.0,
                  ),
                ),
                const SizedBox(height: 8.0),
                Text(
                  "Record your immunization details",
                  style: TextStyle(
                    fontWeight: FontWeight.w400,
                    color: appColors.textSecondary,
                    fontSize: 16.0,
                  ),
                ),
                const SizedBox(height: 40.0),

                const Text("Select vaccine"),
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(top: 8, bottom: 20),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.black26),
                  ),
                  child: Row(
                    children: [
                      Image.asset(Assets.vaccineIconBlack, height: 22),
                      const SizedBox(width: 10),
                      Expanded(
                        child: DropdownButtonHideUnderline(
                          child: DropdownButtonFormField<String>(
                            isExpanded: true,
                            menuMaxHeight: 300,
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.zero,
                            ),
                            hint: const Text("Vaccine type"),
                            value: selectedVaccine,
                            icon: const Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 16,
                            ),
                            items: vaccines
                                .map(
                                  (vaccine) => DropdownMenuItem(
                                    value: vaccine,
                                    child: Text(vaccine),
                                  ),
                                )
                                .toList(),
                            onChanged: (newValue) {
                              setState(() => selectedVaccine = newValue);
                              print("Vaccine selected: $newValue");
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const Text("Date received"),
                GestureDetector(
                  onTap: pickFromDate,
                  child: Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(top: 6, bottom: 20),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.black26),
                    ),
                    child: Row(
                      children: [
                        Image.asset(Assets.calendar2Icon, height: 22),
                        const SizedBox(width: 12),

                        Expanded(
                          child: Text(
                            fromDate == null
                                ? "Add received date"
                                : fromDate.toString().split(" ")[0],
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const Text("Frequency"),
                Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            // padding: const EdgeInsets.symmetric(horizontal: 12),
                            margin: const EdgeInsets.only(
                              right: 4,
                              bottom: 8,
                              top: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.black26),
                            ),
                            child: Row(
                              // mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Radio(
                                  value: "annualBooster",
                                  groupValue: frequency,
                                  onChanged: (v) {
                                    setState(() => frequency = v as String);
                                    print("Selected frequency: $frequency");
                                  },
                                ),
                                const Text("Annual Booster"),
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            // padding: const EdgeInsets.symmetric(vertical: 10),
                            margin: const EdgeInsets.only(
                              left: 4,
                              bottom: 8,
                              top: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.black26),
                            ),
                            child: Row(
                              // mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Radio(
                                  value: "decadeBooster",
                                  groupValue: frequency,
                                  onChanged: (v) {
                                    setState(() => frequency = v as String);
                                    print("Selected frequency: $frequency");
                                  },
                                ),
                                const Text("Decade Booster"),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    Container(
                      width: double.infinity,
                      // padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.black26),
                      ),
                      child: Row(
                        // mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Radio(
                            value: "singleCourse",
                            groupValue: frequency,
                            onChanged: (v) {
                              setState(() => frequency = v as String);
                              print("Selected frequency: $frequency");
                            },
                          ),
                          const Text("Single Course"),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                const Text("Next dose due"),
                GestureDetector(
                  onTap: pickToDate,
                  child: Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(top: 6, bottom: 20),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.black26),
                    ),
                    child: Row(
                      children: [
                        Image.asset(Assets.calendar2Icon, height: 22),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            toDate == null
                                ? "Schedule next dose"
                                : toDate.toString().split(" ")[0],
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        color: const Color(0xFFFAFAFA),
        padding: const EdgeInsets.all(20),
        width: double.infinity,
        child: AppButton(
          text: 'Add Vaccination Record',
          height: 50,
          backgroundColor: const Color(0xFF0168FF),
          textColor: Colors.white,
          onPressed: () {
            print("Vaccination button pressed");
          },
        ),
      ),
    );
  }
}
