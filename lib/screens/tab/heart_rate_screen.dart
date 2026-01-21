import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:remindus/blocs/user/user_bloc.dart';

import 'package:remindus/generated/assets.dart';
import 'package:remindus/helpers/snackbar_helper.dart';
import 'package:remindus/models/base_reminder_model.dart';
import 'package:remindus/repositories/reminder/reminder_repository.dart';
import 'package:remindus/screens/tab/watch_connected_screen.dart';
import 'package:remindus/theme/app_colors.dart';
import 'package:remindus/widgets/custom_button.dart';
import 'package:remindus/widgets/app_text_field.dart';
import 'package:remindus/widgets/common_header_with_back.dart';

class HeartRateAddSceen extends StatefulWidget {
  const HeartRateAddSceen({super.key});

  @override
  State<HeartRateAddSceen> createState() => _HeartRateAddSceenState();
}

class _HeartRateAddSceenState extends State<HeartRateAddSceen> {
  final ReminderRepository _reminderRepository = ReminderRepository();

  final TextEditingController _heartRateController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final FocusNode _bpFocusNode = FocusNode();
  bool _isFocused = false;
  bool _isLoading = false;

  String selectedFrequency = 'Every two weeks';

  TimeOfDay? selectedTime;
  final List<String> frequencies = [
    'Every day',
    'Every two weeks',
    'Once a week',
    'Once a month',
  ];

  @override
  void initState() {
    super.initState();
    _bpFocusNode.addListener(() {
      setState(() {
        _isFocused = _bpFocusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _bpFocusNode.dispose();
    super.dispose();
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

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedTime ?? TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() => selectedTime = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;
    final activeFamilyId = context.select<UserBloc, String?>((bloc) {
      final state = bloc.state;
      return (state is UserLoadedState) ? state.activeFamilyId : null;
    });
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: appColors.bgColor,
        body: SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: Stack(
            children: [
              Positioned.fill(
                child: Image.asset(
                  Assets.bgColorMap,
                  fit: BoxFit.cover,
                  opacity: const AlwaysStoppedAnimation(0.6),
                ),
              ),
              Form(
                key: _formKey,
                child: SafeArea(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CommonHeaderWithBack(
                          onMainLogoTap: () {
                            Navigator.of(context).pop();
                          },
                        ),
                        const SizedBox(height: 20),

                        Wrap(
                          alignment: WrapAlignment.start,
                          crossAxisAlignment: WrapCrossAlignment.start,
                          children: [
                            Text(
                              "Heart Rate Monitoring",
                              style: TextStyle(
                                fontWeight: FontWeight.w400,
                                color: appColors.textPrimary,
                                fontSize: 28.0,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8.0),
                        Wrap(
                          alignment: WrapAlignment.start,
                          crossAxisAlignment: WrapCrossAlignment.start,
                          children: [
                            Text(
                              "Keep track of your pulse and resting heart rate",
                              style: TextStyle(
                                fontWeight: FontWeight.w400,
                                color: appColors.textSecondary,
                                fontSize: 16.0,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 40.0),
                        Stack(
                          children: [
                            AppTextField(
                              focusNode: _bpFocusNode,
                              controller: _heartRateController,
                              label: "Heart Rate",
                              hintText: "Add heart rate",
                              prefixIconPath: Assets.bloodPressureIcon,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your blood pressure';
                                }
                                return null;
                              },
                              onChanged: (value) {
                                setState(() {});
                              },
                            ),
                            if (_isFocused)
                              Positioned(
                                right: 20,
                                top: 46,
                                child: Container(
                                  height: 24.0,
                                  decoration: BoxDecoration(
                                    color: appColors.primaryLightBlue,
                                    borderRadius: BorderRadius.circular(6.0),
                                  ),
                                  child: Center(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8.0,
                                      ),
                                      child: Text(
                                        'bpm',
                                        style: TextStyle(
                                          color: appColors.textPrimary,
                                          fontWeight: FontWeight.w400,
                                          fontSize: 14.0,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 20.0),

                        Text(
                          'Frequency',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            color: appColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 12),

                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                childAspectRatio: 3.5,
                                crossAxisSpacing: 10,
                                mainAxisSpacing: 10,
                              ),
                          itemCount: frequencies.length,
                          itemBuilder: (context, index) {
                            return _buildFrequencyOption(
                              frequencies[index],
                              context,
                            );
                          },
                        ),

                        const SizedBox(height: 20.0),
                        Text(
                          'Reminder time',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            color: appColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8.0),

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
                                            : selectedTime!.format(context),
                                        style: const TextStyle(fontSize: 16),
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
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // AppButton(
                //   text: 'Done',
                //   onPressed: () {
                //     _validateAndSubmit();
                //   },
                //   backgroundColor: context.appColors.primaryLightBlue,
                // ),
                const SizedBox(height: 12.0),
                AppButton(
                  isLoading: _isLoading,
                  text: 'Set Up Reminder',
                  onPressed: () async {
                    // _validateAndSubmit(activeFamilyId!);
                    _handleHealthUpdate(activeFamilyId!);
                  },
                  backgroundColor: context.appColors.primary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleHealthUpdate(String activeFamilyId) async {
    setState(() => _isLoading = true);
    try {
      bool success = await _reminderRepository.updateFamilyHealthData(
        familyId: activeFamilyId!,
        heartRate: _heartRateController.text.trim(),
      );

      if (success) {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => const HealthCheckupScreen()),
        );
      } else {
        throw Exception('Update failed');
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _validateAndSubmit(String activeFamilyId) async {
    try {
      ReminderRepository _reminderRepository = ReminderRepository();
      bool isFormValid = _formKey.currentState!.validate();
      if (selectedFrequency.isEmpty) {
        SnackbarHelper.showError(context, "Please select a frequency");
        return;
      }

      // 3. Validate Time Selection
      if (selectedTime == null) {
        SnackbarHelper.showError(context, "Please select a reminder time");
        return;
      }

      if (isFormValid) {
        setState(() {
          _isLoading = true;
        });
        DateTime now = DateTime.now();
        DateTime firstReminderDateTime = DateTime(
          now.year,
          now.month,
          now.day,
          selectedTime!.hour,
          selectedTime!.minute,
        );

        if (firstReminderDateTime.isBefore(now)) {
          firstReminderDateTime = firstReminderDateTime.add(
            const Duration(days: 1),
          );
        }
        int loopCount = 0;
        Duration interval = const Duration(days: 1);

        // --- Frequency Logic ---
        switch (selectedFrequency) {
          case 'Every day':
            loopCount = 7;
            interval = const Duration(days: 1);
            break;
          case 'Every two weeks':
            loopCount = 2;
            interval = const Duration(days: 14);
            break;
          case 'Once a week':
            loopCount = 4;
            interval = const Duration(days: 7);
            break;
          case 'Once a month':
            loopCount = 2;
            interval = const Duration(days: 30);
            break;
        }
        bool allSuccess = true;
        for (int i = 0; i < loopCount; i++) {
          DateTime scheduledDate = firstReminderDateTime.add(interval * i);

          final newReminder = ReminderModel(
            type: "Heart Rate",
            title: "Heart Rate Check",
            heartRate: _heartRateController.text.trim(),
            time: "${selectedTime!.format(context)}",
            isRead: false,
            duration: selectedFrequency,
            createdAt: FieldValue.serverTimestamp(),
            scheduledAt: Timestamp.fromDate(scheduledDate),
            date: Timestamp.fromDate(scheduledDate),
          );
          bool result = await _reminderRepository.addReminder(
            reminder: newReminder,
            activeFamilyId: activeFamilyId!,
          );
          if (!result) allSuccess = false;
        }

        if (allSuccess) {
          setState(() {
            _isLoading = false;
          });
          SnackbarHelper.showSuccess(
            context,
            "$loopCount Reminders set up successfully!",
          );
          Navigator.pop(context);
        } else {
          setState(() {
            _isLoading = false;
          });
          SnackbarHelper.showError(context, "Some reminders failed to save.");
        }
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      SnackbarHelper.showError(context, "An error occurred: $e");
    }
  }

  Widget _buildFrequencyOption(String title, BuildContext context) {
    final appColors = context.appColors;
    return GestureDetector(
      onTap: () => setState(() => selectedFrequency = title),
      child: Container(
        decoration: BoxDecoration(
          color: appColors.bgColor,
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          children: [
            Radio<String>(
              value: title,
              groupValue: selectedFrequency,
              activeColor: appColors.primary,
              onChanged: (value) {
                setState(() => selectedFrequency = value!);
              },
            ),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  color: appColors.textPrimary,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
