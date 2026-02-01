import 'dart:developer';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:remindus/blocs/reminders/reminders_bloc.dart';
import 'package:remindus/blocs/user/user_bloc.dart';
import 'package:remindus/generated/assets.dart';
import 'package:remindus/helpers/medicine_helper.dart';
import 'package:remindus/models/base_reminder_model.dart';
import 'package:remindus/models/voice_notification_model.dart';
import 'package:remindus/screens/reminders/confirm_reminder_screen.dart';
import 'package:remindus/screens/reminders/meeting/add_reminder_meeting.dart';
import 'package:remindus/screens/reminders/meeting/confirm_reminder_meeting.dart';
import 'package:remindus/theme/app_colors.dart';
import 'package:remindus/widgets/app_text_field.dart';
import 'package:remindus/widgets/custom_button.dart';
import 'package:remindus/widgets/main_header_appbar.dart';

class AddReminderScreen extends StatefulWidget {
  final ReminderModel? existingReminder;
  final bool? isEditReminder;
  const AddReminderScreen({
    Key? key,
    this.existingReminder,
    this.isEditReminder = false,
  }) : super(key: key);

  @override
  State<AddReminderScreen> createState() => _AddReminderScreenState();
}

class _AddReminderScreenState extends State<AddReminderScreen> {
  //medicine specific fields
  String selectedType = 'Medicine';
  TextEditingController titleController = TextEditingController();
  TextEditingController medicineNameController = TextEditingController();
  TextEditingController doseController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  TimeOfDay? selectedTime;

  //Meetings specific fields
  TextEditingController meetingTitleController = TextEditingController();
  DateTime? meetingDate;
  TimeOfDay? meetingTime;
  String meetingAmPm = 'AM';
  final GlobalKey<FormState> _meetingFormKey = GlobalKey<FormState>();

  String selectedDuration = '1 Week';
  DateTimeRange? dateRange;
  String selectedTimeOfDay = 'Morning';
  bool morningChecked = false;
  bool afternoonChecked = false;
  bool eveningChecked = false;
  bool nightChecked = true;

  @override
  void dispose() {
    titleController.dispose();
    medicineNameController.dispose();
    doseController.dispose();
    meetingTitleController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: meetingDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        meetingDate = picked;
      });
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  late bool _isEditingMedical;
  late bool _isEditingMeeting;

  @override
  void initState() {
    super.initState();

    log("existingReminder:  ${widget.existingReminder}");

    log(
      "isEditReminder: ${widget.isEditReminder}, existingReminder: ${widget.existingReminder}",
    );

    if (widget.isEditReminder == true && widget.existingReminder != null) {
      selectedType = widget.existingReminder!.type ?? 'Medicine';

      _isEditingMedical = selectedType == 'Medicine';
      _isEditingMeeting = selectedType == 'Meeting';

      if (_isEditingMeeting) {
        // Title
        meetingTitleController.text = widget.existingReminder!.title ?? '';

        // Date
        final timestamp = widget.existingReminder!.date;
        if (timestamp != null) {
          meetingDate = timestamp.toDate();
        }

        // Time
        final timeString = widget.existingReminder!.time;
        if (timeString != null) {
          meetingTime = _getTimeOfDayFromString(timeString);
          if (meetingTime != null) {
            meetingAmPm = meetingTime!.hour >= 12 ? 'PM' : 'AM';
          }
        }
      }

      // Initialize controllers with existing data if editing
      titleController.text = widget.existingReminder!.title ?? '';
      medicineNameController.text = widget.existingReminder!.medicineName ?? '';
      doseController.text = widget.existingReminder!.dose ?? '';
      selectedDuration = widget.existingReminder!.duration ?? '1 Week';

      morningChecked = widget.existingReminder!.morning ?? false;
      afternoonChecked = widget.existingReminder!.afternoon ?? false;
      eveningChecked = widget.existingReminder!.evening ?? false;
      nightChecked = widget.existingReminder!.night ?? false;

      final reminderTime = widget.existingReminder!.time;
      if (reminderTime != null) {
        selectedTime = _getTimeOfDayFromString(reminderTime);
      }

      final dateRangeString = widget.existingReminder!.dateRange;
      if (dateRangeString != null) {
        if (dateRangeString.contains('-')) {
          try {
            final parts = dateRangeString.split('-');
            final startString = parts[0].trim();
            final endString = parts[1].trim();

            final startDate = DateFormat('MMM dd, yyyy').parse(startString);
            final endDate = DateFormat('MMM dd, yyyy').parse(endString);

            dateRange = DateTimeRange(start: startDate, end: endDate);
          } catch (e) {
            log("Error parsing date range: $e");
          }
        } else {
          try {
            final date = DateFormat('yyyy/MM/dd').parse(dateRangeString);
            dateRange = DateTimeRange(start: date, end: date);
          } catch (e) {
            log("Error parsing single date: $e");
          }
        }
      }
    } else {
      selectedType = 'Medicine';
      _isEditingMedical = false;
      _isEditingMeeting = false;
      selectedDuration = '1 Week';
      nightChecked = true;
    }
  }

  TimeOfDay? _getTimeOfDayFromString(String timeString) {
    try {
      final parts = timeString.split(RegExp(r'[:\s]'));
      if (parts.length < 3) {
        // Fallback for formats without AM/PM or space
        final timeParts = timeString.split(':');
        int hour = int.parse(timeParts[0]);
        int minute = int.parse(timeParts[1].replaceAll(RegExp(r'[^0-9]'), ''));
        return TimeOfDay(hour: hour, minute: minute);
      }
      int hour = int.parse(parts[0]);
      final int minute = int.parse(parts[1]);
      final String period = parts[2];

      if (period.toUpperCase() == 'PM' && hour != 12) hour += 12;
      if (period.toUpperCase() == 'AM' && hour == 12) hour = 0;

      return TimeOfDay(hour: hour, minute: minute);
    } catch (e) {
      log("Error parsing time string: $timeString, $e");
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;
    final isAppOwner = context.select<UserBloc, bool>((bloc) {
      final state = bloc.state;
      return state is UserLoadedState ? state.isAppowner : false;
    });
    final isActiveFamilyId = context.select<UserBloc, String>((bloc) {
      final state = bloc.state;
      return state is UserLoadedState ? state.isActiveFamilyId : '';
    });
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor: appColors.bgColor,
        body: BlocConsumer<ReminderBloc, ReminderState>(
          listener: (context, state) {
            if (state is ReminderAddedSuccessState) {
              log("heloooo");
              // Navigator.push(
              //   context,
              //   MaterialPageRoute(
              //     builder: (context) =>
              //         ConfirmReminderScreen(reminderData: reminderData),
              //   ),
              // );
            }
            if (state is ReminderUpdatedSuccessState) {
              log("Reminder updated successfully");
              Navigator.pop(context);
            }
          },
          builder: (context, state) {
            final _isLoading = state is IsReminderLoadingState;
            _isEditingMedical =
                widget.isEditReminder == true &&
                widget.existingReminder != null &&
                widget.existingReminder!.type == 'Medicine';
            _isEditingMeeting =
                widget.isEditReminder == true &&
                widget.existingReminder != null &&
                widget.existingReminder!.type == 'Meeting';
            return Stack(
              children: [
                Positioned.fill(
                  child: Image.asset(
                    Assets.bgColorMap,
                    fit: BoxFit.cover,
                    opacity: const AlwaysStoppedAnimation(0.6),
                  ),
                ),
                SafeArea(
                  child: SingleChildScrollView(
                    physics: BouncingScrollPhysics(),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20.0,
                        vertical: 50.0,
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            MainHeaderAppBar(),
                            const SizedBox(height: 20.0),

                            Text(
                              _isEditingMedical
                                  ? "Edit Medication"
                                  : (_isEditingMeeting
                                        ? "Edit Meeting"
                                        : "Add Reminder"),
                              style: TextStyle(
                                fontWeight: FontWeight.w400,
                                color: appColors.textPrimary,
                                fontSize: 28.0,
                              ),
                            ),
                            const SizedBox(height: 8.0),
                            Text(
                              _isEditingMedical
                                  ? "Update your medicine details"
                                  : (_isEditingMeeting
                                        ? "Update your meeting details"
                                        : "Schedule when to take your medicine"),
                              style: TextStyle(
                                fontWeight: FontWeight.w400,
                                color: appColors.textSecondary,
                                fontSize: 16.0,
                              ),
                            ),
                            const SizedBox(height: 32),
                            if (!widget.isEditReminder!)
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildTypeButton(
                                      'Medicine',
                                      Assets.pillIcon,
                                      context,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: _buildTypeButton(
                                      'Meeting',
                                      Assets.calenderAddIcon,
                                      context,
                                    ),
                                  ),
                                ],
                              ),
                            if (_isEditingMedical)
                              _buildTypeButton(
                                'Medicine',
                                Assets.pillIcon,
                                context,
                              ),
                            if (_isEditingMeeting)
                              _buildTypeButton(
                                'Meeting',
                                Assets.calenderAddIcon,
                                context,
                              ),
                            const SizedBox(height: 25),

                            if (selectedType == 'Meeting') ...[
                              Form(
                                key: _meetingFormKey,
                                child: AddReminderMeeting(
                                  titleController: meetingTitleController,
                                  selectedDate: meetingDate,
                                  selectedTime: meetingTime,
                                  onSelectDate: () => _selectDate(context),
                                  onSelectTime: _selectTime,
                                  selectedAmPm: meetingAmPm,
                                  onAmPmChanged: (value) {
                                    setState(() {
                                      meetingAmPm = value;
                                    });
                                  },
                                  onTimeChanged: (time) {
                                    setState(() {
                                      meetingTime = time;
                                    });
                                  },
                                ),
                              ),
                              const SizedBox(height: 20),
                            ],

                            // Title
                            if (selectedType == 'Medicine')
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  AppTextField(
                                    controller: titleController,
                                    hintText: 'ABCD ABCD',
                                    prefixIconPath: Assets.subtitleIcon,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter a title';
                                      }
                                      return null;
                                    },
                                    isPassword: false,
                                    label: "Title",
                                  ),
                                  const SizedBox(height: 20),

                                  // Medicine Name
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Medicine name",
                                        style: TextStyle(
                                          fontWeight: FontWeight.w400,
                                          color: appColors.textPrimary,
                                          fontSize: 16,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Autocomplete<String>(
                                        optionsBuilder:
                                            (
                                              TextEditingValue textEditingValue,
                                            ) {
                                              if (textEditingValue.text == '') {
                                                return const Iterable<
                                                  String
                                                >.empty();
                                              }
                                              return MedicineHelper.getSortedSuggestions()
                                                  .where((String option) {
                                                    return option
                                                        .toLowerCase()
                                                        .contains(
                                                          textEditingValue.text
                                                              .toLowerCase(),
                                                        );
                                                  });
                                            },
                                        onSelected: (String selection) {
                                          medicineNameController.text =
                                              selection;
                                        },

                                        fieldViewBuilder:
                                            (
                                              context,
                                              textEditingController,
                                              focusNode,
                                              onFieldSubmitted,
                                            ) {
                                              if (medicineNameController
                                                      .text
                                                      .isNotEmpty &&
                                                  textEditingController
                                                      .text
                                                      .isEmpty) {
                                                textEditingController.text =
                                                    medicineNameController.text;
                                              }
                                              textEditingController.addListener(
                                                () {
                                                  medicineNameController.text =
                                                      textEditingController
                                                          .text;
                                                },
                                              );

                                              return TextField(
                                                controller:
                                                    textEditingController,
                                                focusNode: focusNode,
                                                decoration: InputDecoration(
                                                  hintText:
                                                      'Enter Medicine name',
                                                  prefixIcon: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                          12.0,
                                                        ),
                                                    child: Image.asset(
                                                      Assets.pillsTabletIcon,
                                                      width: 20,
                                                      height: 20,
                                                    ),
                                                  ),
                                                  filled: true,
                                                  fillColor: Colors.white,
                                                  contentPadding:
                                                      const EdgeInsets.symmetric(
                                                        vertical: 15,
                                                        horizontal: 15,
                                                      ),
                                                  enabledBorder:
                                                      OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              12,
                                                            ),
                                                        borderSide: BorderSide(
                                                          color: appColors
                                                              .textSecondary
                                                              .withOpacity(0.1),
                                                        ),
                                                      ),
                                                  focusedBorder:
                                                      OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              12,
                                                            ),
                                                        borderSide: BorderSide(
                                                          color:
                                                              appColors.primary,
                                                        ),
                                                      ),
                                                ),
                                              );
                                            },
                                        optionsViewBuilder:
                                            (context, onSelected, options) {
                                              return Align(
                                                alignment: Alignment.topLeft,
                                                child: Material(
                                                  elevation: 4.0,
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                  child: Container(
                                                    width:
                                                        MediaQuery.of(
                                                          context,
                                                        ).size.width -
                                                        40,
                                                    decoration: BoxDecoration(
                                                      color: Colors.white,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            12,
                                                          ),
                                                    ),
                                                    child: ListView.builder(
                                                      padding: EdgeInsets.zero,
                                                      shrinkWrap: true,
                                                      itemCount: options.length,
                                                      itemBuilder:
                                                          (
                                                            BuildContext
                                                            context,
                                                            int index,
                                                          ) {
                                                            final String
                                                            option = options
                                                                .elementAt(
                                                                  index,
                                                                );
                                                            return ListTile(
                                                              title: Text(
                                                                option,
                                                              ),
                                                              onTap: () =>
                                                                  onSelected(
                                                                    option,
                                                                  ),
                                                            );
                                                          },
                                                    ),
                                                  ),
                                                ),
                                              );
                                            },
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 20.0),

                                  // Dose
                                  AppTextField(
                                    controller: doseController,
                                    hintText: '2 Tablets',
                                    prefixIconPath: Assets.listNumberIcon,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter dose';
                                      }
                                      return null;
                                    },
                                    isPassword: false,
                                    label: "Dose",
                                  ),
                                  const SizedBox(height: 16),

                                  // Duration
                                  Text(
                                    'Duration',
                                    style: TextStyle(
                                      fontSize: 16.0,
                                      color: appColors.textSecondary,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      _buildDurationButton('1 Week', context),
                                      const SizedBox(width: 8),
                                      _buildDurationButton('2 Weeks', context),
                                      const SizedBox(width: 8),
                                      _buildDurationButton('1 Month', context),
                                      const SizedBox(width: 8),
                                      _buildDurationButton('2 Months', context),
                                    ],
                                  ),

                                  const SizedBox(height: 8),
                                  InkWell(
                                    onTap: _selectDateRange,
                                    child: Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: Colors.grey[300]!,
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Text(
                                            dateRange == null
                                                ? 'Pick a Date Range'
                                                : '${DateFormat('MM/dd/yy').format(dateRange!.start)} - ${DateFormat('MM/dd/yy').format(dateRange!.end)}',
                                            style: TextStyle(
                                              color: appColors.textSecondary,
                                              fontSize: 16,
                                              fontWeight: FontWeight.normal,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  // When to take?
                                  Text(
                                    'When to take?',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w400,
                                      fontSize: 16,
                                      color: appColors.textSecondary,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      Expanded(
                                        flex: 1,
                                        child: _buildTimeCheckbox(
                                          'Morning',
                                          morningChecked,
                                          (val) {
                                            setState(
                                              () => morningChecked = val!,
                                            );
                                          },
                                          context,
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        flex: 1,
                                        child: _buildTimeCheckbox(
                                          'Afternoon',
                                          afternoonChecked,
                                          (val) {
                                            setState(
                                              () => afternoonChecked = val!,
                                            );
                                          },
                                          context,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      // _buildTimeCheckbox(
                                      //   'Evening',
                                      //   eveningChecked,
                                      //   (val) {
                                      //     setState(() => eveningChecked = val!);
                                      //   },
                                      //   context,
                                      // ),
                                      Expanded(
                                        flex: 1,
                                        child: _buildTimeCheckbox(
                                          'Night',
                                          nightChecked,
                                          (val) {
                                            setState(() => nightChecked = val!);
                                          },
                                          context,
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(flex: 1, child: SizedBox()),
                                    ],
                                  ),
                                  const SizedBox(height: 20.0),
                                  // Time Picker
                                  Text(
                                    'First dose',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w400,
                                      fontSize: 16,
                                      color: appColors.textSecondary,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: appColors.bgColor,
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: InkWell(
                                            onTap: _selectTime,
                                            child: Row(
                                              children: [
                                                Image.asset(
                                                  Assets.alarmClockIcon,
                                                  width: 20.0,
                                                  height: 20.0,
                                                ),
                                                const SizedBox(width: 12),
                                                Text(
                                                  selectedTime == null
                                                      ? '08:00'
                                                      : selectedTime!.format(
                                                          context,
                                                        ),
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        _buildAmPmButton('AM', context),
                                        const SizedBox(width: 8),
                                        _buildAmPmButton('PM', context),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '*',
                                        style: TextStyle(
                                          fontSize: 14.0,
                                          color: appColors.textSecondary,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                      const SizedBox(width: 6.0),
                                      Expanded(
                                        child: Text(
                                          'Pres your first dose time and will automatically schedule for rest too.',
                                          style: TextStyle(
                                            fontSize: 14.0,
                                            color: appColors.textSecondary,
                                            fontWeight: FontWeight.w400,
                                          ),
                                          maxLines: 2,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 24),
                                ],
                              ),

                            // Save Reminder Button
                            if (_isLoading)
                              Container(
                                height: 56,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: appColors.primary,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const CircularProgressIndicator(
                                  color: Colors.white,
                                ),
                              )
                            else
                              AppButton(
                                text: _isEditingMedical || _isEditingMeeting
                                    ? 'Update Reminder'
                                    : 'Save Reminder',
                                onPressed:
                                    _isEditingMedical || _isEditingMeeting
                                    ? () => _goToUpdateReminder(
                                        context,
                                        isAppOwner,
                                        isActiveFamilyId,
                                      )
                                    : () => _goToConfirmScreen(context),
                                backgroundColor: appColors.primary,
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _goToUpdateReminder(
    BuildContext context,
    bool isAppOwner,
    String activeFamilyId,
  ) {
    if (widget.isEditReminder != true || widget.existingReminder == null)
      return;

    if (selectedType == 'Medicine') {
      if (dateRange == null) return _showError("Please select a date range");
      if (selectedTime == null)
        return _showError("Please select first dose time");
      if (!_formKey.currentState!.validate()) return;

      String formattedRange =
          "${DateFormat.yMMMd().format(dateRange!.start)} - ${DateFormat.yMMMd().format(dateRange!.end)}";
      String firstDoseTimeStr = selectedTime!.format(context);

      List<Map<String, dynamic>> scheduleList = _generateMedicineSchedule(
        firstDoseTimeStr,
      );

      DateTime scheduledDateTime = DateTime(
        dateRange!.start.year,
        dateRange!.start.month,
        dateRange!.start.day,
        selectedTime!.hour,
        selectedTime!.minute,
      );

      final reminderMedicineModel = ReminderModel(
        title: titleController.text.trim(),
        type: selectedType,
        medicineName: medicineNameController.text.trim(),
        dose: doseController.text.trim(),
        duration: selectedDuration,
        dateRange: formattedRange,
        morning: morningChecked,
        afternoon: afternoonChecked,
        evening: eveningChecked,
        night: nightChecked,
        createdAt:
            widget.existingReminder!.createdAt ?? FieldValue.serverTimestamp(),
        isRead: false,
        time: firstDoseTimeStr,
        updatedAt: FieldValue.serverTimestamp(),
        schedule: scheduleList,
        notificationId: widget.existingReminder!.notificationId,
        scheduledAt: Timestamp.fromDate(scheduledDateTime),
      );

      context.read<ReminderBloc>().add(
        UpdateMeetingsReminderEvent(
          reminderMeetingsModel: reminderMedicineModel,
          reminderId: widget.existingReminder!.reminderId ?? '',
          activeFamilyId: activeFamilyId,
        ),
      );
    } else if (selectedType == 'Meeting') {
      log("1");
      if (meetingDate == null) return _showError("Please select a date");
      if (meetingTime == null) return _showError("Please select a time");
      if (!_meetingFormKey.currentState!.validate()) return;

      DateTime meetingDateTime = DateTime(
        meetingDate!.year,
        meetingDate!.month,
        meetingDate!.day,
        meetingTime!.hour,
        meetingTime!.minute,
      );
      log("2");

      final reminderMeetingsModel = ReminderModel(
        notificationId: widget.existingReminder!.notificationId,
        title: meetingTitleController.text.trim(),
        type: selectedType,
        createdAt:
            widget.existingReminder!.createdAt ?? FieldValue.serverTimestamp(),
        date: Timestamp.fromDate(
          DateTime(meetingDate!.year, meetingDate!.month, meetingDate!.day),
        ),
        dateTime: Timestamp.fromDate(meetingDateTime),
        scheduledAt: Timestamp.fromDate(meetingDateTime),
        isRead: false,
        time: meetingTime!.format(context),
        updatedAt: FieldValue.serverTimestamp(),
      );
      log("reminderMeetingsModel-> ${reminderMeetingsModel.toString()}");
      context.read<ReminderBloc>().add(
        UpdateMeetingsReminderEvent(
          reminderMeetingsModel: reminderMeetingsModel,
          reminderId: widget.existingReminder!.reminderId ?? '',
          activeFamilyId: activeFamilyId,
        ),
      );
      log("3");

      // Voice notification update
      String message =
          'Hello! Your meeting "${reminderMeetingsModel.title}" is starting now. Please be ready.';
      context.read<ReminderBloc>().add(
        SetVoiceNotificationEvent(
          voiceNotificationModel: VoiceNotificationModel(
            id: reminderMeetingsModel.notificationId ?? 0,
            body: message,
            hour: meetingDateTime.hour,
            minute: meetingDateTime.minute,
            title: 'Meeting Reminder',
            day: meetingDateTime.day,
            month: meetingDateTime.month,
          ),
          isAppOwner: isAppOwner,
        ),
      );
    }
  }

  Widget _buildTypeButton(String type, String iconPath, BuildContext context) {
    final isSelected = selectedType == type;
    final appColors = context.appColors;
    return InkWell(
      onTap: () => setState(() => selectedType = type),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: isSelected
              ? appColors.primary.withOpacity(0.1)
              : appColors.bgColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 32.0,
              height: 32.0,
              decoration: BoxDecoration(
                color: isSelected
                    ? appColors.primary
                    : appColors.surfceSecondary,
                borderRadius: BorderRadius.circular(8.0),
              ),

              child: Padding(
                padding: const EdgeInsets.all(6.0),
                child: Image.asset(
                  iconPath,
                  width: 20.0,
                  height: 20.0,
                  color: isSelected ? appColors.bgColor : appColors.textPrimary,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              type,
              style: TextStyle(
                color: appColors.textPrimary,
                fontWeight: FontWeight.normal,
                fontSize: 16.0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDurationButton(String duration, BuildContext context) {
    final isSelected = selectedDuration == duration;
    final appColors = context.appColors;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => selectedDuration = duration),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? appColors.primary.withOpacity(0.16)
                : appColors.bgColor,
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Center(
            child: Text(
              duration,
              style: TextStyle(
                color: appColors.textPrimary,
                fontSize: 16.0,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTimeCheckbox(
    String label,
    bool value,
    Function(bool?) onChanged,
    BuildContext context,
  ) {
    return Container(
      height: 48.0,
      decoration: BoxDecoration(
        color: context.appColors.bgColor,
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.all(12.0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => onChanged(!value),
            child: Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: value ? context.appColors.primary : Colors.transparent,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: value
                      ? context.appColors.primary
                      : context.appColors.textSecondary,
                  width: 2,
                ),
              ),
              child: value
                  ? Icon(Icons.check, size: 16, color: Colors.white)
                  : null,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: context.appColors.textPrimary,
              fontSize: 16.0,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmPmButton(String period, BuildContext context) {
    final appColors = context.appColors;
    final currentPeriod = selectedTime != null && selectedTime!.hour >= 12
        ? 'PM'
        : 'AM';
    final isSelected = currentPeriod == period;
    return InkWell(
      onTap: () {
        if (selectedTime != null) {
          setState(() {
            int newHour = selectedTime!.hour;
            if (period == 'AM' && newHour >= 12) {
              newHour -= 12;
            } else if (period == 'PM' && newHour < 12) {
              newHour += 12;
            }
            selectedTime = TimeOfDay(
              hour: newHour,
              minute: selectedTime!.minute,
            );
          });
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
        decoration: BoxDecoration(
          color: isSelected
              ? appColors.primary.withOpacity(0.16)
              : appColors.bgColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          period,
          style: TextStyle(
            color: appColors.textPrimary,
            fontWeight: FontWeight.w400,
            fontSize: 16.0,
          ),
        ),
      ),
    );
  }

  Future<void> _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDateRange: dateRange,
    );
    if (picked != null) {
      setState(() => dateRange = picked);
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedTime ?? TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() => selectedTime = picked);
    }
  }

  void _goToConfirmScreen(BuildContext context) async {
    final auth = FirebaseAuth.instance;
    final userId = auth.currentUser?.uid;

    if (userId == null) {
      _showError('You must be logged in to save reminders');
      return;
    }

    if (selectedType == 'Meeting') {
      if (!_meetingFormKey.currentState!.validate()) return;
      if (meetingDate == null) return _showError('Please select a date');
      if (meetingTime == null) return _showError('Please select a time');

      DateTime meetingDateTime = DateTime(
        meetingDate!.year,
        meetingDate!.month,
        meetingDate!.day,
        meetingTime!.hour,
        meetingTime!.minute,
      );

      final reminderMeetingsModel = ReminderModel(
        title: meetingTitleController.text.trim(),
        type: selectedType,
        createdAt: FieldValue.serverTimestamp(),
        date: Timestamp.fromDate(
          DateTime(meetingDate!.year, meetingDate!.month, meetingDate!.day),
        ),
        dateTime: Timestamp.fromDate(meetingDateTime),
        isRead: false,
        time: meetingTime!.format(context),
        updatedAt: FieldValue.serverTimestamp(),
      );

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ConfirmReminderMeetingScreen(
            reminderModel: reminderMeetingsModel,
          ),
        ),
      );
    } else {
      // Medicine Validation
      if (!_formKey.currentState!.validate()) return;
      if (dateRange == null) return _showError("Please select a date range");
      if (!morningChecked &&
          !afternoonChecked &&
          !eveningChecked &&
          !nightChecked) {
        return _showError("Please select at least one time of day");
      }
      if (selectedTime == null)
        return _showError("Please select first dose time");

      // Formatting Logic
      String formattedRange =
          "${DateFormat.yMMMd().format(dateRange!.start)} - ${DateFormat.yMMMd().format(dateRange!.end)}";
      String firstDoseTimeStr = selectedTime!.format(context);

      List<Map<String, dynamic>> scheduleList = _generateMedicineSchedule(
        firstDoseTimeStr,
      );

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ConfirmReminderScreen(
            reminderModelData: ReminderModel(
              title: titleController.text.trim(),
              type: selectedType,
              medicineName: medicineNameController.text.trim(),
              dose: doseController.text.trim(),
              duration: selectedDuration,
              dateRange: formattedRange,
              morning: morningChecked,
              afternoon: afternoonChecked,
              evening: eveningChecked,
              night: nightChecked,
              createdAt: FieldValue.serverTimestamp(),
              isRead: false,
              time: firstDoseTimeStr,
              updatedAt: FieldValue.serverTimestamp(),
              schedule: scheduleList,
            ),
          ),
        ),
      );
    }
  }

  List<Map<String, dynamic>> _generateMedicineSchedule(
    String firstDoseTimeStr,
  ) {
    List<Map<String, dynamic>> scheduleList = [];

    if (dateRange == null) return scheduleList;

    // Calculate the number of days between start and end date
    int daysCount = dateRange!.end.difference(dateRange!.start).inDays + 1;

    for (int i = 0; i < daysCount; i++) {
      DateTime currentDate = dateRange!.start.add(Duration(days: i));
      String formattedDate = DateFormat('yyyy/MM/dd').format(currentDate);
      List<String> timesForDay = [];

      String addHours(String startTime, int hours) {
        try {
          DateTime temp = DateFormat.jm().parse(startTime);
          return DateFormat.jm().format(temp.add(Duration(hours: hours)));
        } catch (e) {
          return startTime;
        }
      }

      if (morningChecked) {
        timesForDay.add(firstDoseTimeStr);
      }

      if (afternoonChecked) {
        String t = morningChecked
            ? addHours(firstDoseTimeStr, 6)
            : firstDoseTimeStr;
        timesForDay.add(t);
      }

      if (eveningChecked) {
        int offset = (morningChecked && afternoonChecked) ? 12 : 6;
        timesForDay.add(addHours(firstDoseTimeStr, offset));
      }

      if (nightChecked) {
        int offset = 0;
        if (morningChecked && afternoonChecked) {
          offset = 12;
        } else if (morningChecked || afternoonChecked) {
          offset = 12;
        }

        String t = (offset == 0)
            ? firstDoseTimeStr
            : addHours(firstDoseTimeStr, offset);
        timesForDay.add(t);
      }

      scheduleList.add({
        'date': formattedDate,
        'times': timesForDay,
        'status': 'pending',
      });
    }
    return scheduleList;
  }
}
