import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:remindus/blocs/user/user_bloc.dart';
import 'package:remindus/blocs/vaccination/vaccination_bloc.dart';
import 'package:remindus/generated/assets.dart';
import 'package:remindus/helpers/custom_dialog_helpers.dart';
import 'package:remindus/models/vaccination_record.dart';
import 'package:remindus/screens/vaccination/vaccination_list_screen.dart';
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
  late TextEditingController _vaccineNameController;
  late TextEditingController _dateReceivedController;
  late TextEditingController _nextDoseController;
  DateTime? _selectedDateReceived;
  DateTime? _selectedNextDose;
  String? _selectedFrequency;

  // Ideally fetched from a better place or usage of Enum, but string keys for now
  final List<String> _frequencies = [
    "Annual Booster",
    "Decade Booster",
    "Single Course",
    "6 Months",
  ];

  @override
  void initState() {
    super.initState();
    _vaccineNameController = TextEditingController(
      text: widget.record?.vaccineName ?? "",
    );
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
    _vaccineNameController.dispose();
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
      controller.text = DateFormat('MM/dd/yyyy').format(picked);
      onDateSelected(picked);
    }
  }

  void _saveRecord() {
    final userState = context.read<UserBloc>().state;
    if (userState is! UserLoadedState) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("User info not loaded")));
      return;
    }

    if (_vaccineNameController.text.trim().isEmpty) {
      // Simple validation, though all fields are optional as per user request.
      // But logic requires at least something? No, user said ALL fields optional.
      // So we can save an empty record? Technically yes, but usually vaccine name is minimum.
      // I will allow it but maybe suggest it? No, strict adherence: optional means optional.
      // But Firestore add needs an object.
    }

    final newRecord = VaccinationRecord(
      id: widget.record?.id, // Null for new, existing for edit
      vaccineName: _vaccineNameController.text.trim(),
      dateReceived: _selectedDateReceived,
      frequency: _selectedFrequency,
      nextDoseDue: _selectedNextDose,
      activeFamilyId: userState.activeFamilyId,
    );

    if (widget.record == null) {
      context.read<VaccinationBloc>().add(AddVaccinationEvent(newRecord));
    } else {
      context.read<VaccinationBloc>().add(UpdateVaccinationEvent(newRecord));
    }
  }

  void _deleteRecord() {
    final userState = context.read<UserBloc>().state;
    if (widget.record?.id == null || userState is! UserLoadedState) return;

    CustomDialogs.showConfirmation(
      context: context,
      title: "Remove Vaccination Record?",
      subtitle:
          "Are you sure you want to remove this record? This action is permanent.",
      actionButtonText: "Remove",
      onActionPressed: () {
        context.read<VaccinationBloc>().add(
          DeleteVaccinationEvent(widget.record!.id!, userState.activeFamilyId),
        );
        Navigator.pop(context); // Close dialog
        // Note: Screen closing is handled by BlocListener in build
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

    return Scaffold(
      backgroundColor: appColors.bgColor,
      body: AppGradientBackground(
        child: BlocListener<VaccinationBloc, VaccinationState>(
          listener: (context, state) {
            if (state is VaccinationOperationSuccess) {
              if (state.message.contains("Deleted")) {
                CustomDialogs.showSuccess(
                  type: "delete",
                  context: context,
                  title: "Vaccination Record Removed",
                  subtitle: "The record has been successfully removed.",
                  buttonText: "Back to Vaccines",
                  onBackPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const VaccinationListScreen(),
                      ),
                    );
                  },
                );
              } else {
                // Add/Edit success
                CustomDialogs.showSuccess(
                  type: "edit",
                  context: context,
                  title: isEdit ? "Vaccination Updated" : "Vaccination Added",
                  subtitle: isEdit
                      ? "Your details have been successfully updated"
                      : "Your details have been successfully recorded",
                  buttonText: "Confirm",
                  onBackPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const VaccinationListScreen(),
                      ),
                    );
                  },
                );
              }
            } else if (state is VaccinationError) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.message)));
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

                      LayoutBuilder(
                        builder: (context, constraints) {
                          return Autocomplete<String>(
                            initialValue: TextEditingValue(
                              text: _vaccineNameController.text,
                            ),
                            optionsBuilder:
                                (TextEditingValue textEditingValue) {
                                  if (textEditingValue.text.isEmpty) {
                                    return const Iterable<String>.empty();
                                  }
                                  return [
                                    'AstraZeneca',
                                    'Pfizer-BioNTech',
                                    'Moderna',
                                    'Johnson & Johnson',
                                    'Sinopharm',
                                    'Sinovac',
                                    'Sputnik V',
                                    'Covaxin',
                                    'Novavax',
                                    'BCG',
                                    'Hepatitis B',
                                    'Polio',
                                    'DTP',
                                    'MMR',
                                    'Varicella',
                                    'Influenza',
                                    'Pneumococcal',
                                    'Rotavirus',
                                    'HPV',
                                    'Meningococcal',
                                  ].where((String option) {
                                    return option.toLowerCase().contains(
                                      textEditingValue.text.toLowerCase(),
                                    );
                                  });
                                },
                            onSelected: (String selection) {
                              _vaccineNameController.text = selection;
                            },
                            fieldViewBuilder:
                                (
                                  BuildContext context,
                                  TextEditingController
                                  fieldTextEditingController,
                                  FocusNode fieldFocusNode,
                                  VoidCallback onFieldSubmitted,
                                ) {
                                  // Keep controllers in sync when user edits manually
                                  if (fieldTextEditingController.text !=
                                      _vaccineNameController.text) {
                                    fieldTextEditingController.text =
                                        _vaccineNameController.text;
                                  }

                                  return AppTextField(
                                    label: "Select vaccine",
                                    hintText: "Vaccine type",
                                    controller: fieldTextEditingController,
                                    focusNode: fieldFocusNode,
                                    prefixIconPath: Assets.vaccinationO1Icon,
                                    onChanged: (val) {
                                      _vaccineNameController.text = val;
                                    },
                                  );
                                },
                            optionsViewBuilder:
                                (
                                  BuildContext context,
                                  AutocompleteOnSelected<String> onSelected,
                                  Iterable<String> options,
                                ) {
                                  return Align(
                                    alignment: Alignment.topLeft,
                                    child: Material(
                                      elevation: 4.0,
                                      borderRadius: BorderRadius.circular(12),
                                      color: Colors.white,
                                      child: Container(
                                        width: constraints.maxWidth,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          color: Colors.white,
                                        ),
                                        constraints: const BoxConstraints(
                                          maxHeight: 200,
                                        ),
                                        child: ListView.builder(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 8,
                                          ),
                                          itemCount: options.length,
                                          itemBuilder:
                                              (
                                                BuildContext context,
                                                int index,
                                              ) {
                                                final String option = options
                                                    .elementAt(index);
                                                return InkWell(
                                                  onTap: () {
                                                    onSelected(option);
                                                    _vaccineNameController
                                                            .text =
                                                        option;
                                                  },
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: 16.0,
                                                          vertical: 12.0,
                                                        ),
                                                    child: Text(
                                                      option,
                                                      style: TextStyle(
                                                        color: appColors
                                                            .textPrimary,
                                                        fontSize: 14,
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              },
                                        ),
                                      ),
                                    ),
                                  );
                                },
                          );
                        },
                      ),
                      const SizedBox(height: 20),

                      GestureDetector(
                        onTap: () => _selectDate(
                          context,
                          _dateReceivedController,
                          (date) {
                            setState(() => _selectedDateReceived = date);
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
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: _frequencies.map((freq) {
                          final isSelected = _selectedFrequency == freq;
                          return GestureDetector(
                            onTap: () =>
                                setState(() => _selectedFrequency = freq),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
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
                                mainAxisSize: MainAxisSize.min,
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
                                  Text(
                                    freq,
                                    style: TextStyle(
                                      color: isSelected
                                          ? appColors.primary
                                          : appColors.textSecondary,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),

                      const SizedBox(height: 20),

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
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AppButton(
                      text: isEdit
                          ? "Save Vaccination Details"
                          : "Add Vaccination Record",
                      onPressed: _saveRecord,
                      backgroundColor: appColors.primary,
                    ),
                    if (isEdit) ...[
                      const SizedBox(height: 20),
                      AppButton(
                        text: "Remove Vaccination Record",
                        onPressed: _deleteRecord,
                        backgroundColor:
                            appColors.lightRed ?? Colors.red.withOpacity(0.1),
                        textColor: appColors.errorRed ?? Colors.red,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
