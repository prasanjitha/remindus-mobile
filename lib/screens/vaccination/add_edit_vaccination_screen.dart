import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:remindus/blocs/reminders/reminders_bloc.dart';
import 'package:remindus/blocs/user/user_bloc.dart';
import 'package:remindus/blocs/vaccination/vaccination_bloc.dart';
import 'package:remindus/generated/assets.dart';
import 'package:remindus/helpers/custom_dialog_helpers.dart';
import 'package:remindus/helpers/snackbar_helper.dart';
import 'package:remindus/models/base_reminder_model.dart';
import 'package:remindus/models/vaccination_record.dart';

import 'package:remindus/screens/vaccination/vaccination_list_screen.dart';

import 'package:remindus/screens/vaccination/vaccine_confirm_screen.dart';
import 'package:remindus/theme/app_colors.dart';
import 'package:remindus/widgets/app_text_field.dart';
import 'package:remindus/widgets/custom_button.dart';
import 'package:intl/intl.dart';
import 'package:remindus/widgets/app_gradient_background.dart';
import 'package:remindus/widgets/main_header_appbar.dart';

class AddEditVaccinationScreen extends StatefulWidget {
  final VaccinationRecord? record;

  const AddEditVaccinationScreen({super.key, this.record});

  @override
  State<AddEditVaccinationScreen> createState() =>
      _AddEditVaccinationScreenState();
}

class _AddEditVaccinationScreenState extends State<AddEditVaccinationScreen> {
  late TextEditingController _customVaccineController;
  late TextEditingController _dateReceivedController;
  late TextEditingController _nextDoseController;
  DateTime? _selectedDateReceived;
  DateTime? _selectedNextDose;
  String? _selectedFrequency;
  String? _selectedVaccine;
  VaccinationRecord? _lastSubmittedRecord;

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

    // Initialize vaccine selection
    final existingVaccine = widget.record?.vaccineName ?? "";
    if (existingVaccine.isNotEmpty &&
        _vaccineOptions.contains(existingVaccine)) {
      _selectedVaccine = existingVaccine;
      _customVaccineController = TextEditingController();
    } else if (existingVaccine.isNotEmpty) {
      _selectedVaccine = "Others";
      _customVaccineController = TextEditingController(text: existingVaccine);
    } else {
      _customVaccineController = TextEditingController();
    }

    _selectedDateReceived = widget.record?.dateReceived;
    _selectedNextDose = widget.record?.nextDoseDue;
    _selectedFrequency = widget.record?.frequency;

    _dateReceivedController = TextEditingController(
      text: _selectedDateReceived != null
          ? DateFormat('MM/dd/yyyy').format(_selectedDateReceived!)
          : "",
    );
    _nextDoseController = TextEditingController(
      text: _selectedNextDose != null
          ? DateFormat('MM/dd/yyyy').format(_selectedNextDose!)
          : "",
    );
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

    // Generate or reuse reminderId to link vaccination with its reminder
    final String finalReminderId =
        widget.record?.reminderId ??
        FirebaseFirestore.instance
            .collection('users')
            .doc(userState.activeFamilyId)
            .collection('reminders')
            .doc()
            .id;

    final newRecord = VaccinationRecord(
      id: widget.record?.id,
      vaccineName: finalVaccineName,
      dateReceived: _selectedDateReceived,
      frequency: _selectedFrequency,
      nextDoseDue: _selectedNextDose,
      activeFamilyId: userState.activeFamilyId,
      reminderId: finalReminderId,
    );

    _lastSubmittedRecord = newRecord;

    // Calculate scheduled date for reminder
    DateTime scheduledDate = _calculateReminderDate();

    // Set time to 11:04 AM
    DateTime scheduledDateTime = DateTime(
      scheduledDate.year,
      scheduledDate.month,
      scheduledDate.day,
      08, // 11:04 AM
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
      title: reminderTitle,
      type: "Vaccination",
      frequency: _selectedFrequency,
      createdAt: FieldValue.serverTimestamp(),
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
      // Add new vaccination (with its linked reminderId)
      context.read<VaccinationBloc>().add(AddVaccinationEvent(newRecord));

      // Add/Create new reminder with the generated ID
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

      // Update the existing reminder using the saved reminderId
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

    // Calculate next date based on frequency from date received or today
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
        // For single course, use next dose due directly
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
        // If no frequency selected, use next dose due
        calculatedDate = _selectedNextDose!;
    }

    // If calculated date is earlier than next dose due, use calculated date
    // Otherwise use next dose due
    if (_selectedNextDose != null &&
        calculatedDate.isAfter(_selectedNextDose!)) {
      return _selectedNextDose!;
    }

    return calculatedDate;
  }

  void _deleteRecord() {
    final userState = context.read<UserBloc>().state;
    if (widget.record?.id == null || userState is! UserLoadedState) return;

    // Capture the bloc from the current context
    final vaccinationBloc = context.read<VaccinationBloc>();

    showDialog(
      context: context,
      barrierDismissible: false, // Prevent dismissing while loading
      builder: (dialogContext) {
        final appColors = context.appColors;
        return BlocBuilder<VaccinationBloc, VaccinationState>(
          bloc: vaccinationBloc, // Explicitly use the captured bloc
          builder: (context, state) {
            final isDeleting = state is VaccinationDeletedLoading;

            return Dialog(
              backgroundColor: appColors.bgColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: appColors.errorRed?.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Image.asset(
                        Assets.deleteIcon,
                        height: 30,
                        width: 30,
                        color: appColors.errorRed,
                      ),
                    ),
                    const SizedBox(height: 20.0),
                    Text(
                      "Remove Vaccination Record?",
                      style: TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.w600,
                        color: appColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12.0),
                    Text(
                      "Are you sure you want to remove this record? This action is permanent.",
                      style: TextStyle(
                        fontSize: 14.0,
                        color: appColors.textSecondary,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 24.0),
                    Row(
                      children: [
                        Expanded(
                          child: AppButton(
                            height: 54,
                            text: "Remove",
                            backgroundColor: appColors.errorRed,
                            isLoading: isDeleting,
                            onPressed: isDeleting
                                ? () {}
                                : () {
                                    vaccinationBloc.add(
                                      DeleteVaccinationEvent(
                                        recordId: widget.record!.id!,
                                        activeFamilyId:
                                            userState.activeFamilyId,
                                        reminderId: widget.record?.reminderId,
                                      ),
                                    );
                                  },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: AppButton(
                            height: 54,
                            text: "Cancel",
                            textColor: appColors.textPrimary,
                            backgroundColor: appColors.primary.withOpacity(0.2),
                            onPressed: isDeleting
                                ? () {}
                                : () => Navigator.pop(dialogContext),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
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
    final isEdit = widget.record != null;
    final title = isEdit ? "Manage Vaccination" : "Add Vaccination";
    final subTitle = isEdit
        ? "Edit your vaccination records"
        : "Record your immunization details";

    return AppGradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: BlocListener<VaccinationBloc, VaccinationState>(
          listener: (context, state) {
            if (state is VaccinationDeletedSuccess) {
              Navigator.of(context).pop();
              CustomDialogs.showSuccess(
                type: "delete",
                context: context,
                useRootNavigator: false,
                title: "Vaccination Record Removed",
                subtitle: "The record has been successfully removed.",
                buttonText: "Back to Vaccines",
                onBackPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const VaccinationListScreen(),
                    ),
                    (route) => false,
                  );
                },
              );
            }

            if (state is VaccinationOperationSuccess) {
              if (widget.record == null && _lastSubmittedRecord != null) {
                // No manual _isLoading update needed
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) =>
                        VaccineConfirmScreen(record: _lastSubmittedRecord!),
                  ),
                );
              } else {
                Navigator.of(context).pop(); // Close Screen for Edit
              }
            } else if (state is VaccinationError) {
              SnackbarHelper.showError(context, state.message);
            }
          },
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
                  builder: (context, state) {
                    final isLoading = state is VaccinationLoading;
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AppButton(
                          text: isEdit
                              ? "Save Vaccination Details"
                              : "Add Vaccination Record",
                          onPressed: () {
                            _saveRecord();
                          },
                          backgroundColor: appColors.primary,
                          isLoading: isLoading,
                        ),
                        if (isEdit) ...[
                          const SizedBox(height: 20),
                          AppButton(
                            text: "Remove Vaccination Record",
                            onPressed: state is VaccinationLoading
                                ? () {}
                                : _deleteRecord,
                            backgroundColor:
                                appColors.lightRed ??
                                Colors.red.withOpacity(0.1),
                            textColor: appColors.errorRed ?? Colors.red,
                            isLoading: state is VaccinationDeletedLoading,
                          ),
                        ],
                      ],
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
