import 'package:flutter/material.dart';
import 'package:remindus/generated/assets.dart';
import 'package:remindus/theme/app_colors.dart';
import 'package:remindus/widgets/custom_button.dart';
import 'package:remindus/widgets/main_header_appbar.dart';
import 'package:remindus/screens/moreOptions/healthAndTracingSection/vaccinationAddedScreen.dart';

class AddVaccinationRecordScreen extends StatefulWidget {
  final String? vaccine;
  final DateTime? dateReceived;
  final DateTime? nextDose;
  final String? frequency;
  final bool isEdit;

  const AddVaccinationRecordScreen({
    super.key,
    this.vaccine,
    this.dateReceived,
    this.nextDose,
    this.frequency,
    this.isEdit = false,
  });

  @override
  State<AddVaccinationRecordScreen> createState() =>
      _AddVaccinationRecordScreenState();
}

class _AddVaccinationRecordScreenState
    extends State<AddVaccinationRecordScreen> {
  String? selectedVaccine;
  String? selectedDose;
  String? frequency;
  DateTime? fromDate;
  DateTime? toDate;

  bool showValidationErrors = false;

  List<String> vaccines = ["Covid Shield", "MMR", "Hepatitis B", "Tetanus"];

  @override
  void initState() {
    super.initState();
    // Initialize with existing values if editing
    if (widget.isEdit) {
      selectedVaccine = widget.vaccine;
      fromDate = widget.dateReceived;
      toDate = widget.nextDose;
      frequency = widget.frequency;
    }
  }

  Future<void> pickFromDate() async {
    final date = await showDatePicker(
      context: context,
      firstDate: DateTime(2010),
      lastDate: DateTime(2040),
      initialDate: fromDate ?? DateTime.now(),
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
      initialDate: toDate ?? DateTime.now(),
    );
    if (date != null) {
      setState(() => toDate = date);

      print("Due date: ${date.toString().split(" ")[0]}");
    }
  }

  bool _validateForm() {
    return selectedVaccine != null &&
        fromDate != null &&
        toDate != null &&
        frequency != null;
  }

  void _handleSubmit() {
    if (_validateForm()) {
      print("Vaccination button pressed");
      print("Vaccine: $selectedVaccine");
      print("From Date: $fromDate");
      print("To Date: $toDate");
      print("Frequency: $frequency");

      if (widget.isEdit) {
        // If editing, pop back to previous screen
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Vaccination record updated successfully'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        // If adding new, navigate to confirmation screen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => VaccinationAddedScreen(
              vaccine: selectedVaccine!,
              fromDate: fromDate!,
              toDate: toDate!,
              frequency: frequency!,
            ),
          ),
        );
      }
    } else {
      setState(() {
        showValidationErrors = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all required fields'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Color _getBorderColor(bool hasError) {
    if (showValidationErrors && hasError) {
      return Colors.red;
    }
    return Colors.black26;
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
                  widget.isEdit ? "Edit Vaccination" : "Add Vaccination",
                  style: TextStyle(
                    fontWeight: FontWeight.w400,
                    color: appColors.textPrimary,
                    fontSize: 28.0,
                  ),
                ),
                const SizedBox(height: 8.0),
                Text(
                  widget.isEdit
                      ? "Update your immunization details"
                      : "Record your immunization details",
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
                    border: Border.all(
                      color: _getBorderColor(selectedVaccine == null),
                      width: showValidationErrors && selectedVaccine == null
                          ? 1.5
                          : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Image.asset(Assets.vaccineIconBlack, height: 22),
                      const SizedBox(width: 10),
                      Expanded(
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            isExpanded: true,
                            menuMaxHeight: 300,
                            hint: const Text("Vaccine type"),
                            value: selectedVaccine,
                            icon: const Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 16,
                            ),
                            selectedItemBuilder: (BuildContext context) {
                              return vaccines.map((String value) {
                                return Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(value),
                                );
                              }).toList();
                            },
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
                      border: Border.all(
                        color: _getBorderColor(fromDate == null),
                        width: showValidationErrors && fromDate == null
                            ? 1.5
                            : 1,
                      ),
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
                            style: TextStyle(
                              fontSize: 16,
                              color: fromDate == null
                                  ? Colors.black54
                                  : Colors.black,
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
                            margin: const EdgeInsets.only(
                              right: 4,
                              bottom: 8,
                              top: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: _getBorderColor(frequency == null),
                                width: showValidationErrors && frequency == null
                                    ? 1.5
                                    : 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Radio(
                                  value: "Annual Booster",
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
                            margin: const EdgeInsets.only(
                              left: 4,
                              bottom: 8,
                              top: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: _getBorderColor(frequency == null),
                                width: showValidationErrors && frequency == null
                                    ? 1.5
                                    : 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Radio(
                                  value: "Decade Booster",
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
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: _getBorderColor(frequency == null),
                          width: showValidationErrors && frequency == null
                              ? 1.5
                              : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Radio(
                            value: "Single Course",
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
                      border: Border.all(
                        color: _getBorderColor(toDate == null),
                        width: showValidationErrors && toDate == null ? 1.5 : 1,
                      ),
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
                            style: TextStyle(
                              fontSize: 16,
                              color: toDate == null
                                  ? Colors.black54
                                  : Colors.black,
                            ),
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
          text: widget.isEdit
              ? 'Update Vaccination Record'
              : 'Add Vaccination Record',
          height: 50,
          backgroundColor: const Color(0xFF0168FF),
          textColor: Colors.white,
          onPressed: _handleSubmit,
        ),
      ),
    );
  }
}
