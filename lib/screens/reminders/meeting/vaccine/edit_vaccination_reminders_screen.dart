import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:remindus/generated/assets.dart';
import 'package:remindus/theme/app_colors.dart';
import 'package:remindus/blocs/user/user_bloc.dart';
import 'package:remindus/widgets/custom_button.dart';
import 'package:remindus/widgets/app_text_field.dart';
import 'package:remindus/helpers/snackbar_helper.dart';
import 'package:remindus/models/vaccination_record.dart';
import 'package:remindus/widgets/main_header_appbar.dart';
import 'package:remindus/models/base_reminder_model.dart';
import 'package:remindus/blocs/reminders/reminders_bloc.dart';
import 'package:remindus/widgets/app_gradient_background.dart';
import 'package:remindus/blocs/vaccination/vaccination_bloc.dart';

class EditVaccinationReminderScreen extends StatefulWidget {
  final ReminderModel? record;

  const EditVaccinationReminderScreen({super.key, this.record});

  @override
  State<EditVaccinationReminderScreen> createState() =>
      _EditVaccinationReminderScreenState();
}

class _EditVaccinationReminderScreenState
    extends State<EditVaccinationReminderScreen> {
  late TextEditingController _customVaccineController;
  late TextEditingController _dateReceivedController;
  late TextEditingController _nextDoseController;
  DateTime? _selectedDateReceived;
  DateTime? _selectedNextDose;
  String? _selectedFrequency;
  String? _selectedVaccine;

  // Vaccine dropdown options
  final List<String> _vaccineOptions = [
    "Pfizer-BioNTech",
    "AstraZeneca",
    "Moderna",
    "Novavax",
    "Janssen",
    "Valneva",
    "Others",
  ];

  // Frequency options with Others
  final List<String> _frequencies = [
    "Annual Booster",
    "Decade Booster",
    "Single Course",
    "6 Months",
  ];

  @override
  void initState() {
    super.initState();
    _customVaccineController = TextEditingController();
    _dateReceivedController = TextEditingController();
    _nextDoseController = TextEditingController();

    if (widget.record?.vaccinationData != null) {
      final vData = widget.record!.vaccinationData!;
      _selectedVaccine = _vaccineOptions.contains(vData.vaccineName)
          ? vData.vaccineName
          : "Others";
      if (_selectedVaccine == "Others") {
        _customVaccineController.text = vData.vaccineName ?? "";
      }
      _selectedDateReceived = vData.dateReceived;
      if (_selectedDateReceived != null) {
        _dateReceivedController.text = DateFormat(
          'MM/dd/yyyy',
        ).format(_selectedDateReceived!);
      }
      _selectedFrequency = vData.frequency;
      _selectedNextDose = vData.nextDoseDue;
      if (_selectedNextDose != null) {
        _nextDoseController.text = DateFormat(
          'MM/dd/yyyy',
        ).format(_selectedNextDose!);
      }
    }
  }

  @override
  void dispose() {
    _customVaccineController.dispose();
    _dateReceivedController.dispose();
    _nextDoseController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(
    BuildContext context,
    TextEditingController controller,
    Function(DateTime) onDateSelected,
  ) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
      builder: (context, child) {
        final appColors = context.appColors;
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: appColors.primary,
              onPrimary: Colors.white,
              surface: appColors.bgColor,
              onSurface: appColors.textPrimary,
            ),
            dialogBackgroundColor: appColors.bgColor,
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      if (mounted) {
        setState(() {
          controller.text = DateFormat('MM/dd/yyyy').format(picked);
        });
      }
      onDateSelected(picked);
    }
  }

  void _updateNextDoseDueDate() {
    if (_selectedDateReceived == null || _selectedFrequency == null) return;

    DateTime baseDate = _selectedDateReceived!;
    DateTime? calculatedDate;

    switch (_selectedFrequency) {
      case "Annual Booster":
        calculatedDate = DateTime(
          baseDate.year + 1,
          baseDate.month,
          baseDate.day,
        );
        break;
      case "Decade Booster":
        calculatedDate = DateTime(
          baseDate.year + 10,
          baseDate.month,
          baseDate.day,
        );
        break;
      case "6 Months":
        calculatedDate = DateTime(
          baseDate.year,
          baseDate.month + 6,
          baseDate.day,
        );
        break;
      case "Single Course":
        // Usually no next dose for single course
        return;
    }

    if (calculatedDate != null) {
      setState(() {
        _selectedNextDose = calculatedDate;
        _nextDoseController.text = DateFormat(
          'MM/dd/yyyy',
        ).format(calculatedDate!);
      });
    }
  }

  void _saveRecord() {
    final userState = context.read<UserBloc>().state;
    if (userState is! UserLoadedState) {
      SnackbarHelper.showError(context, "User info not loaded");
      return;
    }

    // Only next dose due is required
    if (_selectedNextDose == null) {
      SnackbarHelper.showError(context, "Please select next dose due date");
      return;
    }

    // Determine final vaccine name
    String finalVaccineName;
    if (_selectedVaccine == "Others") {
      finalVaccineName = _customVaccineController.text.trim();
    } else {
      finalVaccineName = _selectedVaccine ?? "";
    }

    // Generate or reuse reminderId and vaccinationId
    final String finalReminderId =
        widget.record?.reminderId ??
        FirebaseFirestore.instance
            .collection('users')
            .doc(userState.activeFamilyId)
            .collection('reminders')
            .doc()
            .id;

    String? finalVaccinationId = widget.record?.vaccinationData?.id;

    // Fix: If vaccination ID is missing in reminder (legacy data), try to find it in the loaded vaccinations
    if (finalVaccinationId == null && widget.record?.reminderId != null) {
      final vaccinationState = context.read<VaccinationBloc>().state;
      if (vaccinationState is VaccinationLoaded) {
        for (var record in vaccinationState.records) {
          if (record.reminderId == widget.record?.reminderId) {
            finalVaccinationId = record.id;
            break;
          }
        }
      }
    }

    final newRecord = VaccinationRecord(
      id: finalVaccinationId,
      vaccineName: finalVaccineName,
      dateReceived: _selectedDateReceived,
      frequency: _selectedFrequency,
      nextDoseDue: _selectedNextDose,
      activeFamilyId: userState.activeFamilyId,
      reminderId: finalReminderId,
    );

    // Calculate scheduled date for reminder
    DateTime scheduledDate = _calculateReminderDate();

    // Set time to 08:00 AM (as in previous code)
    DateTime scheduledDateTime = DateTime(
      scheduledDate.year,
      scheduledDate.month,
      scheduledDate.day,
      08,
      00,
    );

    // Create reminder title: "Hey, {username} today your {vaccine name} get date"
    String userName = userState.userName.isNotEmpty
        ? userState.userName
        : "User";
    String reminderTitle =
        "Hey, $userName today your ${finalVaccineName.isNotEmpty ? finalVaccineName : 'vaccine'} get date";

    // Create the reminder
    final vaccinationReminder = ReminderModel(
      reminderId: finalReminderId,
      title: reminderTitle,
      type: "Vaccination",
      frequency: _selectedFrequency,
      createdAt: widget.record?.createdAt ?? FieldValue.serverTimestamp(),
      updatedAt: FieldValue.serverTimestamp(),
      vaccinationData: newRecord,
      isRead: false,
      time: DateFormat.jm().format(scheduledDateTime),
      scheduledAt: Timestamp.fromDate(scheduledDateTime),
      nextDoseDue: _selectedNextDose != null
          ? Timestamp.fromDate(_selectedNextDose!)
          : null,
    );

    // Save/Update vaccination record and reminder
    if (widget.record == null) {
      // Add new vaccination
      context.read<VaccinationBloc>().add(AddVaccinationEvent(newRecord));

      // Add new reminder
      context.read<ReminderBloc>().add(
        UpdateMeetingsReminderEvent(
          reminderMeetingsModel: vaccinationReminder,
          reminderId: finalReminderId,
          activeFamilyId: userState.activeFamilyId,
        ),
      );
    } else {
      // Update existing vaccination
      context.read<VaccinationBloc>().add(UpdateVaccinationEvent(newRecord));

      // Update the existing reminder
      context.read<ReminderBloc>().add(
        UpdateMeetingsReminderEvent(
          reminderMeetingsModel: vaccinationReminder,
          reminderId: finalReminderId,
          activeFamilyId: userState.activeFamilyId,
        ),
      );
    }

    //
  }

  /// Calculate the reminder date based on frequency and next dose due
  DateTime _calculateReminderDate() {
    DateTime now = DateTime.now();
    DateTime today = DateTime(now.year, now.month, now.day);

    // If date received is after today, use date received
    if (_selectedDateReceived != null) {
      DateTime dateReceived = DateTime(
        _selectedDateReceived!.year,
        _selectedDateReceived!.month,
        _selectedDateReceived!.day,
      );
      if (dateReceived.isAfter(today)) {
        // Compare with next dose due - use earlier date
        if (_selectedNextDose != null &&
            _selectedNextDose!.isBefore(dateReceived)) {
          return _selectedNextDose!;
        }
        return dateReceived;
      }
    }

    DateTime baseDate = _selectedDateReceived ?? today;
    DateTime calculatedDate;

    switch (_selectedFrequency) {
      case "Annual Booster":
        calculatedDate = DateTime(
          baseDate.year + 1,
          baseDate.month,
          baseDate.day,
        );
        break;
      case "Decade Booster":
        calculatedDate = DateTime(
          baseDate.year + 10,
          baseDate.month,
          baseDate.day,
        );
        break;
      case "Single Course":
        calculatedDate = _selectedNextDose!;
        break;
      case "6 Months":
        calculatedDate = DateTime(
          baseDate.year,
          baseDate.month + 6,
          baseDate.day,
        );
        break;
      default:
        calculatedDate = _selectedNextDose!;
    }

    if (_selectedNextDose != null &&
        calculatedDate.isAfter(_selectedNextDose!)) {
      return _selectedNextDose!;
    }

    return calculatedDate;
  }

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
    final title = "Update Vaccination";
    final subTitle = "Edit your vaccination records";

    return AppGradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: MultiBlocListener(
          listeners: [
            BlocListener<VaccinationBloc, VaccinationState>(
              listener: (context, state) {
                if (state is VaccinationError) {
                  SnackbarHelper.showError(context, state.message);
                }
              },
            ),
            BlocListener<ReminderBloc, ReminderState>(
              listener: (context, state) {
                if (state is ReminderUpdatedSuccessState) {
                  if (state.isReminderUpdatedSuccess) {
                    Navigator.of(context).pop();
                  } else {
                    SnackbarHelper.showError(
                      context,
                      "Failed to update reminder",
                    );
                  }
                }
              },
            ),
          ],
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(
                    left: 20.0,
                    right: 20.0,
                    top: 50.0,
                    bottom: 20.0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const MainHeaderAppBar(),
                      const SizedBox(height: 20),
                      _buildHeader(title, subTitle, appColors),
                      const SizedBox(height: 32),

                      // Vaccine dropdown
                      Text(
                        "Select Vaccine",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: appColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: appColors.bgColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: appColors.surfceSecondary),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedVaccine,
                            hint: Text(
                              "Choose vaccine type",
                              style: TextStyle(
                                color: appColors.textSecondary,
                                fontSize: 14,
                              ),
                            ),
                            isExpanded: true,
                            icon: Icon(
                              Icons.keyboard_arrow_down,
                              color: appColors.textSecondary,
                            ),
                            dropdownColor: appColors.bgColor,
                            items: _vaccineOptions.map((vaccine) {
                              return DropdownMenuItem<String>(
                                value: vaccine,
                                child: Text(
                                  vaccine,
                                  style: TextStyle(
                                    color: appColors.textPrimary,
                                    fontSize: 14,
                                  ),
                                ),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedVaccine = value;
                                if (value != "Others") {
                                  _customVaccineController.clear();
                                }
                              });
                            },
                          ),
                        ),
                      ),

                      // Custom vaccine name field (shown when "Others" is selected)
                      if (_selectedVaccine == "Others") ...[
                        const SizedBox(height: 16),
                        AppTextField(
                          label: "Enter Vaccine Name",
                          hintText: "Type your vaccine name",
                          controller: _customVaccineController,
                          prefixIconPath: Assets.vaccinationO1Icon,
                        ),
                      ],
                      const SizedBox(height: 20),

                      GestureDetector(
                        onTap: () => _selectDate(
                          context,
                          _dateReceivedController,
                          (date) {
                            setState(() => _selectedDateReceived = date);
                            _updateNextDoseDueDate();
                          },
                        ),
                        child: AbsorbPointer(
                          child: AppTextField(
                            label: "Date received",
                            hintText: "Add received date",
                            controller: _dateReceivedController,
                            prefixIconPath: Assets.dateTimeIcon,
                            readOnly: true,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Frequency Radio Buttons
                      Text(
                        "Frequency",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: appColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Custom Radio Group
                      GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 2,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: 2.5,
                        children: _frequencies.map((freq) {
                          final isSelected = _selectedFrequency == freq;
                          return GestureDetector(
                            onTap: () {
                              setState(() => _selectedFrequency = freq);
                              _updateNextDoseDueDate();
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? appColors.primary.withOpacity(0.1)
                                    : appColors.bgColor,
                                border: Border.all(
                                  color: isSelected
                                      ? appColors.primary
                                      : appColors.surfceSecondary,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment
                                    .center, // Center the content
                                children: [
                                  Icon(
                                    isSelected
                                        ? Icons.radio_button_checked
                                        : Icons.radio_button_unchecked,
                                    color: isSelected
                                        ? appColors.primary
                                        : appColors.textSecondary,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Flexible(
                                    // Prevents text overflow if the word is too long
                                    child: Text(
                                      freq,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: isSelected
                                            ? appColors.primary
                                            : appColors.textSecondary,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),

                      const SizedBox(height: 20),

                      if (_selectedFrequency == "Single Course")
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: appColors.primary.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: appColors.primary.withOpacity(0.1),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: appColors.primary,
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                "No follow-up needed",
                                style: TextStyle(
                                  color: appColors.textPrimary,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        )
                      else
                        GestureDetector(
                          onTap: () =>
                              _selectDate(context, _nextDoseController, (date) {
                                setState(() => _selectedNextDose = date);
                              }),
                          child: AbsorbPointer(
                            child: AppTextField(
                              label: "Next dose due",
                              hintText: "Schedule next dose",
                              controller: _nextDoseController,
                              prefixIconPath: Assets.dateTimeIcon,
                              readOnly: true,
                            ),
                          ),
                        ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: BlocBuilder<VaccinationBloc, VaccinationState>(
                  builder: (context, vacState) {
                    return BlocBuilder<ReminderBloc, ReminderState>(
                      builder: (context, remState) {
                        final isLoading =
                            vacState is VaccinationLoading ||
                            (remState is IsReminderLoadingState &&
                                remState.isReminderLoading);
                        return AppButton(
                          text: "Update Vaccination",
                          onPressed: () {
                            _saveRecord();
                          },
                          backgroundColor: appColors.primary,
                          isLoading: isLoading,
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
