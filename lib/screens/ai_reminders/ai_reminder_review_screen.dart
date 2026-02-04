import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:remindus/blocs/ai_reminder/ai_reminder_bloc.dart';
import 'package:remindus/blocs/ai_reminder/ai_reminder_event.dart';
import 'package:remindus/blocs/ai_reminder/ai_reminder_state.dart';
import 'package:remindus/generated/assets.dart';
import 'package:remindus/screens/ai_reminders/scan_prescription_screen.dart';
import 'package:remindus/theme/app_colors.dart';
import 'package:remindus/widgets/app_gradient_background.dart';
import 'package:remindus/widgets/app_text_field.dart';
import 'package:remindus/widgets/custom_button.dart';
import 'package:remindus/repositories/reminder/ai_reminder_repository.dart';
import 'package:remindus/services/ai_reminder_service.dart';
import 'package:remindus/widgets/main_header_appbar.dart';
import 'package:remindus/screens/ai_reminders/reminder_confirmation_screen.dart';
import 'package:remindus/services/permission_service.dart';
import 'package:remindus/widgets/dialog/notification_permission_dialog.dart';

class AiReminderReviewScreen extends StatelessWidget {
  final String activeFamilyId;
  final String? imagePath;

  const AiReminderReviewScreen({
    Key? key,
    required this.activeFamilyId,
    this.imagePath,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;
    return BlocProvider(
      create: (context) => AiReminderBloc(
        aiService: AiReminderService(),
        repository: AiReminderRepository(),
      )..add(LoadAiReminders(imagePath: imagePath)),
      child: Scaffold(
        backgroundColor: appColors.bgColor,

        body: AppGradientBackground(
          child: BlocConsumer<AiReminderBloc, AiReminderState>(
            listener: (context, state) {
              if (state is AiReminderError) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(state.message)));
              } else if (state is AiReminderSaved) {
                // Navigate to confirmation screen
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        ReminderConfirmationScreen(reminders: state.reminders),
                  ),
                );
              }
            },
            builder: (context, state) {
              if (state is AiReminderLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is AiReminderLoaded) {
                return _buildReviewForm(
                  context,
                  state,
                  appColors,
                  activeFamilyId,
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(AppColors appColors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Confirm Reminder",
          style: TextStyle(
            fontWeight: FontWeight.w400,
            color: appColors.textPrimary,
            fontSize: 28,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          "Select reminder type and fill the blanks",
          style: TextStyle(
            fontWeight: FontWeight.w400,
            color: appColors.textPrimary,
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  Widget _buildReviewForm(
    BuildContext context,
    AiReminderLoaded state,
    AppColors appColors,
    String activeFamilyId,
  ) {
    final reminder = state.currentItem;
    final isLastItem = state.currentIndex == state.reminders.length - 1;

    // Controllers initialized with current item data
    // Note: In a real app we might want to keep these in the state or use a hook to avoid recreating them on every rebuild
    // if the state updates essentially. But since we are rebuilding with NEW content for the NEXT item,
    // we actually WANT to recreate them or update them.
    // However, `AppTextField` takes a controller. If we create new controllers here,
    // typing might be issues if this widget rebuilds on every keystroke.
    // But we are only dispatching UpdateCurrentReminder on change, so it WILL rebuild.
    // Ideally we should use a stronger form handling approach, but for now:

    // We will use Keyed subtree or just keys for fields to ensure they update when index changes.
    final keySuffix = state.currentIndex.toString();

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 50.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MainHeaderAppBar(
            onClose: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      ScanPrescriptionScreen(activeFamilyId: activeFamilyId),
                ),
              );
            },
          ),
          const SizedBox(height: 10),
          _buildHeader(appColors),
          Text(
            "Review Item ${state.currentIndex + 1} of ${state.reminders.length}",
            style: TextStyle(
              color: context.appColors.textSecondary,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: context.appColors.primaryLight,
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.0),
                    color: context.appColors.primary,
                  ),
                  child: Center(
                    child: Image.asset(
                      Assets.pillIcon,
                      height: 24,
                      width: 24,
                      color: appColors.bgColor,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  reminder.type?.toUpperCase() ?? "UNKNOWN",
                  style: TextStyle(
                    color: context.appColors.textPrimary,
                    fontWeight: FontWeight.w400,
                    fontSize: 16.0,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Common Fields
          AppTextField(
            key: ValueKey('title_$keySuffix'),
            label: "Title",
            hintText: "Enter title",
            prefixIconPath: Assets.subtitleIcon, // Use valid asset
            controller: TextEditingController(text: reminder.title),
            onChanged: (val) {
              context.read<AiReminderBloc>().add(
                UpdateCurrentReminder(reminder.copyWith(title: val)),
              );
            },
          ),
          const SizedBox(height: 16),

          if (reminder.type == 'medicine') ...[
            AppTextField(
              key: ValueKey('medName_$keySuffix'),
              label: "Medicine Name",
              hintText: "Enter medicine name",
              prefixIconPath: Assets.pillsTabletIcon,
              controller: TextEditingController(text: reminder.medicineName),
              onChanged: (val) {
                context.read<AiReminderBloc>().add(
                  UpdateCurrentReminder(reminder.copyWith(medicineName: val)),
                );
              },
            ),
            const SizedBox(height: 16),
            AppTextField(
              key: ValueKey('dose_$keySuffix'),
              label: "Dose",
              hintText: "e.g., 1 Tablet",
              prefixIconPath: Assets.listNumberIcon,
              controller: TextEditingController(text: reminder.dose),
              onChanged: (val) {
                context.read<AiReminderBloc>().add(
                  UpdateCurrentReminder(reminder.copyWith(dose: val)),
                );
              },
            ),
            const SizedBox(height: 16),
            AppTextField(
              key: ValueKey('startDate_$keySuffix'),
              label: "Start Date",
              hintText: "YYYY-MM-DD",
              prefixIconPath: Assets.dateTimeIcon,
              controller: TextEditingController(
                text: reminder.date != null
                    ? reminder.date!.toDate().toIso8601String().split('T')[0]
                    : "",
              ),
              readOnly: true,
              onTap: () async {
                DateTime initialDate =
                    reminder.date?.toDate() ?? DateTime.now();
                final DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: initialDate,
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2101),
                );
                if (picked != null && context.mounted) {
                  context.read<AiReminderBloc>().add(
                    UpdateCurrentReminder(
                      reminder.copyWith(date: Timestamp.fromDate(picked)),
                    ),
                  );
                }
              },
            ),
            const SizedBox(height: 16),
            AppTextField(
              key: ValueKey('duration_$keySuffix'),
              label: "Duration",
              hintText: "e.g., 1 week",
              prefixIconPath: Assets.dateTimeIcon,
              controller: TextEditingController(text: reminder.duration),
              onChanged: (val) {
                context.read<AiReminderBloc>().add(
                  UpdateCurrentReminder(reminder.copyWith(duration: val)),
                );
              },
            ),
            const SizedBox(height: 16),

            // When to take?
            Text(
              "When to take?",
              style: TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: 14,
                color: context.appColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildCheckbox(
                  context,
                  "Morning",
                  reminder.whenToTake?.contains("Morning") ?? false,
                  (val) {
                    List<String> current = List.from(reminder.whenToTake ?? []);
                    if (val == true) {
                      if (!current.contains("Morning")) current.add("Morning");
                    } else {
                      current.remove("Morning");
                    }
                    context.read<AiReminderBloc>().add(
                      UpdateCurrentReminder(
                        reminder.copyWith(whenToTake: current),
                      ),
                    );
                  },
                ),
                const SizedBox(width: 12),
                _buildCheckbox(
                  context,
                  "Night",
                  reminder.whenToTake?.contains("Night") ?? false,
                  (val) {
                    List<String> current = List.from(reminder.whenToTake ?? []);
                    if (val == true) {
                      if (!current.contains("Night")) current.add("Night");
                    } else {
                      current.remove("Night");
                    }
                    context.read<AiReminderBloc>().add(
                      UpdateCurrentReminder(
                        reminder.copyWith(whenToTake: current),
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildCheckbox(
                  context,
                  "Afternoon",
                  reminder.whenToTake?.contains("Afternoon") ?? false,
                  (val) {
                    List<String> current = List.from(reminder.whenToTake ?? []);
                    if (val == true) {
                      if (!current.contains("Afternoon"))
                        current.add("Afternoon");
                    } else {
                      current.remove("Afternoon");
                    }
                    context.read<AiReminderBloc>().add(
                      UpdateCurrentReminder(
                        reminder.copyWith(whenToTake: current),
                      ),
                    );
                  },
                ),
                const SizedBox(width: 2),
                _buildCheckbox(
                  context,
                  "Evening",
                  reminder.whenToTake?.contains("Evening") ?? false,
                  (val) {
                    List<String> current = List.from(reminder.whenToTake ?? []);
                    if (val == true) {
                      if (!current.contains("Evening")) current.add("Evening");
                    } else {
                      current.remove("Evening");
                    }
                    context.read<AiReminderBloc>().add(
                      UpdateCurrentReminder(
                        reminder.copyWith(whenToTake: current),
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Doses (Schedule)
            if (reminder.schedule != null && reminder.schedule!.isNotEmpty) ...[
              Text(
                "Doses",
                style: TextStyle(
                  fontWeight: FontWeight.w400,
                  fontSize: 14,
                  color: context.appColors.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 2,
                children: reminder.schedule!.asMap().entries.map((entry) {
                  int index = entry.key;
                  Map<String, dynamic> slot = entry.value;
                  String time = slot['time'] ?? '';
                  return SizedBox(
                    width: (MediaQuery.of(context).size.width - 48) / 2,
                    child: AppTextField(
                      key: ValueKey('schedule_${index}_$keySuffix'),
                      label: "",
                      hintText: "00:00 AM",
                      prefixIconPath: Assets.alarmClockIcon,
                      controller: TextEditingController(text: time),
                      readOnly: true,
                      onTap: () async {
                        TimeOfDay initialTime = TimeOfDay.now();
                        try {
                          if (time.contains(":")) {
                            final parts = time.split(RegExp(r'[:\s]'));
                            if (parts.length >= 2) {
                              int hour = int.parse(parts[0]);
                              int minute = int.parse(parts[1]);
                              if (parts.length > 2) {
                                String period = parts[2]; // AM or PM
                                if (period.toUpperCase() == 'PM' && hour != 12)
                                  hour += 12;
                                if (period.toUpperCase() == 'AM' && hour == 12)
                                  hour = 0;
                              }
                              initialTime = TimeOfDay(
                                hour: hour,
                                minute: minute,
                              );
                            }
                          }
                        } catch (e) {
                          // ignore parsing error
                        }

                        final TimeOfDay? picked = await showTimePicker(
                          context: context,
                          initialTime: initialTime,
                        );

                        if (picked != null && context.mounted) {
                          // Format back to string
                          final localizations = MaterialLocalizations.of(
                            context,
                          );
                          String formattedTime = localizations.formatTimeOfDay(
                            picked,
                            alwaysUse24HourFormat: false,
                          );

                          // Deep copy schedule
                          List<Map<String, dynamic>> newSchedule = List.from(
                            reminder.schedule!.map(
                              (m) => Map<String, dynamic>.from(m),
                            ),
                          );
                          newSchedule[index]['time'] = formattedTime;
                          context.read<AiReminderBloc>().add(
                            UpdateCurrentReminder(
                              reminder.copyWith(schedule: newSchedule),
                            ),
                          );
                        }
                      },
                      onChanged:
                          (
                            val,
                          ) {}, // No-op for manual typing if readOnly is true
                    ),
                  );
                }).toList(),
              ),
            ],
          ],

          if (reminder.type == 'meeting') ...[
            AppTextField(
              key: ValueKey('meetingDate_$keySuffix'),
              label: "Date",
              hintText: "YYYY-MM-DD",
              prefixIconPath: Assets.dateTimeIcon,
              controller: TextEditingController(
                text: reminder.date != null
                    ? reminder.date!.toDate().toIso8601String().split('T')[0]
                    : "",
              ),
              readOnly: true,
              onTap: () async {
                DateTime initialDate =
                    reminder.date?.toDate() ?? DateTime.now();
                final DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: initialDate,
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2101),
                );
                if (picked != null && context.mounted) {
                  context.read<AiReminderBloc>().add(
                    UpdateCurrentReminder(
                      reminder.copyWith(date: Timestamp.fromDate(picked)),
                    ),
                  );
                }
              },
            ),
            const SizedBox(height: 16),
            AppTextField(
              key: ValueKey('time_$keySuffix'),
              label: "Time",
              hintText: "e.g., 04:30 PM",
              prefixIconPath: Assets.dateTimeIcon,
              controller: TextEditingController(text: reminder.time),
              onChanged: (val) {
                context.read<AiReminderBloc>().add(
                  UpdateCurrentReminder(reminder.copyWith(time: val)),
                );
              },
            ),
          ],

          const SizedBox(height: 32),

          Row(
            children: [
              Expanded(
                flex: 1,
                child: AppButton(
                  text: "Edit",
                  backgroundColor: context.appColors.primaryLightBlue!
                      .withOpacity(0.6),
                  textColor: context.appColors.textPrimary,
                  onPressed: () {},
                ),
              ),
              const SizedBox(width: 12),
              if (state.currentIndex < state.reminders.length - 1)
                Expanded(
                  flex: 2,
                  child: AppButton(
                    text: "Next",
                    onPressed: () {
                      context.read<AiReminderBloc>().add(NextReminderItem());
                    },
                    backgroundColor: context.appColors.primary,
                  ),
                ),

              if (isLastItem)
                Expanded(
                  flex: 2,
                  child: AppButton(
                    text: "Confirm",
                    onPressed: () async {
                      bool allowed = await PermissionService()
                          .checkNotificationPermission();
                      if (allowed) {
                        if (context.mounted) {
                          context.read<AiReminderBloc>().add(
                            SaveAllReminders(activeFamilyId),
                          );
                        }
                      } else {
                        if (context.mounted) {
                          NotificationPermissionDialog.show(
                            context,
                            onAllowed: () {
                              context.read<AiReminderBloc>().add(
                                SaveAllReminders(activeFamilyId),
                              );
                            },
                          );
                        }
                      }
                    },
                    backgroundColor: context.appColors.primary,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCheckbox(
    BuildContext context,
    String label,
    bool value,
    Function(bool?) onChanged,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: context.appColors.textSecondary.withOpacity(0.1),
          ),
        ),
        child: Row(
          children: [
            Checkbox(
              value: value,
              onChanged: onChanged,
              activeColor: context.appColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ), // Rounded checkbox
            ),
            Text(label, style: TextStyle(color: context.appColors.textPrimary)),
          ],
        ),
      ),
    );
  }
}
