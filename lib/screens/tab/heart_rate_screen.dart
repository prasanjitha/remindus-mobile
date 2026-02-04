import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:remindus/blocs/user/user_bloc.dart';

import 'package:remindus/generated/assets.dart';
import 'package:remindus/helpers/snackbar_helper.dart';
import 'package:remindus/repositories/reminder/reminder_repository.dart';
import 'package:remindus/theme/app_colors.dart';
import 'package:remindus/utils/health_utils.dart';
import 'package:remindus/widgets/app_gradient_background.dart';
import 'package:remindus/widgets/custom_button.dart';
import 'package:remindus/widgets/health_status_indicator.dart';
import 'package:remindus/widgets/main_header_appbar.dart';
import 'package:remindus/widgets/app_text_field.dart';
import 'package:remindus/services/permission_service.dart';
import 'package:remindus/widgets/dialog/notification_permission_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:remindus/models/base_reminder_model.dart';

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
  bool _isLoading = false;
  bool _isInitialDataLoaded = false;

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
  }

  @override
  void dispose() {
    _heartRateController.dispose();
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

    if (activeFamilyId != null && !_isInitialDataLoaded) {
      _isInitialDataLoaded = true;

      // Fetch health status for current reading
      _reminderRepository.getHealthStatusStream(activeFamilyId).first.then((
        snapshot,
      ) {
        if (snapshot.exists) {
          final data = snapshot.data() as Map<String, dynamic>?;
          final heartRate = data?['heartRate'] as String?;
          if (heartRate != null && heartRate.isNotEmpty) {
            setState(() {
              _heartRateController.text = heartRate.replaceAll(' bpm', '');
            });
          }
        }
      });

      // Fetch latest reminder for frequency and time
      _reminderRepository
          .getLatestReminderByType(familyId: activeFamilyId, type: "Heart Rate")
          .then((reminder) {
            if (reminder != null) {
              setState(() {
                if (reminder.frequency != null) {
                  selectedFrequency = reminder.frequency!;
                }
                if (reminder.time != null) {
                  try {
                    // Assuming format "HH:mm AM/PM" or similar from .format(context)
                    final parts = reminder.time!.split(' ');
                    final timeParts = parts[0].split(':');
                    int hour = int.parse(timeParts[0]);
                    int minute = int.parse(timeParts[1]);

                    if (parts.length > 1) {
                      final amPm = parts[1].toUpperCase();
                      if (amPm == 'PM' && hour < 12) hour += 12;
                      if (amPm == 'AM' && hour == 12) hour = 0;
                    }
                    selectedTime = TimeOfDay(hour: hour, minute: minute);
                  } catch (e) {}
                }
              });
            }
          });
    }

    final userName = context.select<UserBloc, String?>((bloc) {
      final state = bloc.state;
      return (state is UserLoadedState) ? state.userName : "User";
    });
    final hasExistingData = _heartRateController.text.isNotEmpty;
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: AppGradientBackground(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: SizedBox(
            width: double.infinity,
            height: double.infinity,
            child: Form(
              key: _formKey,
              child: SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      MainHeaderAppBar(
                        onClose: () {
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
                            prefixIconPath: Assets.healthIcon,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your heart rate';
                              }
                              return null;
                            },
                            onChanged: (value) {
                              setState(() {});
                            },
                          ),
                          if (_heartRateController.text.isNotEmpty)
                            Positioned(
                              right: 20,
                              top: 46,
                              child: HealthStatusIndicator(
                                status: HealthUtils.getHeartRateStatus(
                                  _heartRateController.text,
                                ),
                                compact: true,
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
                                      color: appColors.placeholder,
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      selectedTime == null
                                          ? 'Select Time'
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
          ),
          bottomNavigationBar: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 12.0),
                  AppButton(
                    isLoading: _isLoading,
                    text: hasExistingData
                        ? 'Update Reminder'
                        : 'Set Up Reminder',
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        if (selectedTime == null) {
                          SnackbarHelper.showError(
                            context,
                            'Please select a reminder time',
                          );
                          return;
                        }

                        if (activeFamilyId != null) {
                          bool allowed = await PermissionService()
                              .checkNotificationPermission();
                          if (allowed) {
                            _handleReminderCreation(activeFamilyId, userName);
                          } else {
                            if (mounted) {
                              NotificationPermissionDialog.show(
                                context,
                                onAllowed: () {
                                  _handleReminderCreation(
                                    activeFamilyId,
                                    userName,
                                  );
                                },
                              );
                            }
                          }
                        } else {
                          SnackbarHelper.showError(
                            context,
                            'No active family member found',
                          );
                        }
                      }
                    },
                    backgroundColor: context.appColors.primary,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleReminderCreation(
    String activeFamilyId,
    String? userName,
  ) async {
    setState(() => _isLoading = true);
    try {
      final now = DateTime.now();
      DateTime scheduledDateTime = DateTime(
        now.year,
        now.month,
        now.day,
        selectedTime!.hour,
        selectedTime!.minute,
      );

      if (scheduledDateTime.isBefore(now)) {
        if (selectedFrequency == 'Every day') {
          scheduledDateTime = scheduledDateTime.add(const Duration(days: 1));
        } else if (selectedFrequency == 'Every two weeks') {
          scheduledDateTime = scheduledDateTime.add(const Duration(days: 14));
        } else if (selectedFrequency == 'Once a week') {
          scheduledDateTime = scheduledDateTime.add(const Duration(days: 7));
        } else if (selectedFrequency == 'Once a month') {
          scheduledDateTime = DateTime(
            scheduledDateTime.year,
            scheduledDateTime.month + 1,
            scheduledDateTime.day,
            scheduledDateTime.hour,
            scheduledDateTime.minute,
          );
        }
      }

      // Check for existing Heart Rate reminder
      final existingReminder = await _reminderRepository
          .getLatestReminderByType(
            familyId: activeFamilyId,
            type: "Heart Rate",
          );

      bool success = false;

      if (existingReminder != null) {
        // Update existing reminder
        final updatedReminder = existingReminder.copyWith(
          title: "Hey, ${userName ?? 'User'} time to checkup Heart Rate",
          heartRate: _heartRateController.text.trim(),
          frequency: selectedFrequency,
          time: selectedTime!.format(context),
          scheduledAt: Timestamp.fromDate(scheduledDateTime),
          updatedAt: Timestamp.now(),
        );

        success = await _reminderRepository.updateReminder(
          reminder: updatedReminder,
          reminderId: existingReminder.reminderId!,
          activeFamilyId: activeFamilyId,
        );
      } else {
        // Create new reminder
        final reminder = ReminderModel(
          title: "Hey, ${userName ?? 'User'} time to checkup Heart Rate",
          type: "Heart Rate",
          heartRate: _heartRateController.text.trim(),
          frequency: selectedFrequency,
          time: selectedTime!.format(context),
          scheduledAt: Timestamp.fromDate(scheduledDateTime),
          isRead: false,
          createdAt: Timestamp.now(),
          schedule: [],
        );

        success = await _reminderRepository.addReminder(
          reminder: reminder,
          activeFamilyId: activeFamilyId,
        );
      }

      if (success) {
        await _reminderRepository.updateFamilyHealthData(
          familyId: activeFamilyId,
          heartRate: _heartRateController.text.trim(),
        );

        if (mounted) {
          Navigator.of(context).pop();
        }
      } else {
        throw Exception('Failed to save reminder');
      }
    } catch (e) {
      if (mounted) {
        SnackbarHelper.showError(context, 'Error: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
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
