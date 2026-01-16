
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:remindus/blocs/reminders/reminders_bloc.dart';
import 'package:remindus/generated/assets.dart';
import 'package:remindus/models/base_reminder_model.dart';
import 'package:remindus/screens/reminders/reminder_added_screen.dart';
import 'package:remindus/theme/app_colors.dart';
import 'package:remindus/widgets/custom_button.dart';
import 'package:remindus/widgets/main_header_appbar.dart';

class ConfirmReminderScreen extends StatelessWidget {
  final ReminderModel reminderModelData;

  const ConfirmReminderScreen({Key? key, required this.reminderModelData})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;
    return Scaffold(
      backgroundColor: appColors.bgColor,
      body: SingleChildScrollView(
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                Assets.bgColorMap,
                fit: BoxFit.cover,
                opacity: const AlwaysStoppedAnimation(0.6),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 50.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MainHeaderAppBar(),
                  const SizedBox(height: 20),
                  Text(
                    "Confirm Reminder",
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                      color: appColors.textPrimary,
                      fontSize: 28.0,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    "Check reminder type and fill the blanks",
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                      color: appColors.textSecondary,
                      fontSize: 16.0,
                    ),
                  ),
                  const SizedBox(height: 32),

                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(12.0),
                    decoration: BoxDecoration(
                      color: appColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          padding: EdgeInsets.all(6.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: appColors.primary,
                          ),
                          child: Image.asset(
                            reminderModelData.type == 'Medicine'
                                ? Assets.pillIcon
                                : Assets.calenderAddIcon,
                            color: appColors.bgColor,
                            width: 20,
                            height: 20,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          reminderModelData.type!,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            color: appColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 25.0),

                  _buildInfoRow(
                    'Title',
                    reminderModelData.title!,
                    context,
                    Assets.subtitleIcon,
                  ),
                  _buildInfoRow(
                    'Medicine name',
                    reminderModelData.medicineName!,
                    context,
                    Assets.pillsTabletIcon,
                  ),
                  _buildInfoRow(
                    'Dose',
                    reminderModelData.dose!,
                    context,
                    Assets.listNumberIcon,
                  ),
                  _buildInfoRow(
                    'Duration',
                    reminderModelData.duration!,
                    context,
                    Assets.calendar2Icon,
                  ),

                  if (reminderModelData.dateRange != null)
                    _buildInfoRow(
                      'Date Range',
                      reminderModelData.dateRange.toString(),
                      context,
                      Assets.calendar2Icon,
                    ),
                  Text(
                    'When to take?',
                    style: TextStyle(
                      color: appColors.textSecondary,
                      fontSize: 16.0,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Column(
                    children: [
                      Row(
                       
                        children: [
                         if(reminderModelData.morning==true&& reminderModelData.afternoon==false)...[ Expanded(
                            child: reminderModelData.morning!
                                ? _buildBadge('Morning', context)
                                : const SizedBox(),
                          ),
                          const SizedBox(width: 12),],
                          Expanded(
                            child: reminderModelData.afternoon!
                                ? _buildBadge('Afternoon', context)
                                : const SizedBox(),
                          ),
                        if(reminderModelData.morning==false&& reminderModelData.afternoon==true)     Expanded(child: SizedBox()),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          // Expanded(
                          //   child: reminderModelData.evening!
                          //       ? _buildBadge('Evening', context)
                          //       : const SizedBox(),
                          // ),
                          Expanded(
                            child: reminderModelData.night!
                                ? _buildBadge('Night', context)
                                : const SizedBox(),
                          ),
                          const SizedBox(width: 12),
                          Expanded(child: SizedBox()),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  Text(
                    'Doses',
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                      color: appColors.textSecondary,
                      fontSize: 16.0,
                    ),
                  ),
                  const SizedBox(height: 8),

                  Row(
                    children: [
                      Container(
                        width: 150.0,
                        padding: EdgeInsets.all(12.0),
                        decoration: BoxDecoration(
                          color: appColors.bgColor,
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: Row(
                          children: [
                            Image.asset(
                              Assets.alarmClockIcon,
                              width: 24.0,
                              height: 24.0,
                            ),
                            const SizedBox(width: 8.0),
                            Text(
                              reminderModelData.time != null
                                  ? reminderModelData.time.toString()
                                  : '09:00 AM',
                              style: TextStyle(
                                fontSize: 16.0,
                                color: appColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                    ],
                  ),

                  const SizedBox(height: 32),

                  Row(
                    children: [
                      Expanded(
                        child: AppButton(
                          backgroundColor: appColors.primary.withOpacity(0.2),
                          text: "Edit",
                          onPressed: () => Navigator.pop(context),
                          textColor: appColors.textSecondary,
                        ),
                      ),
                      const SizedBox(width: 10.0),
                      Expanded(
                        flex: 2,
                        child: AppButton(
                          backgroundColor: appColors.primary,
                          text: "Confirm",
                          onPressed: () => _confirmReminder(context),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    String label,
    String value,
    BuildContext context,
    String assetsPath,
  ) {
    final appColors = context.appColors;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: appColors.textSecondary,
              fontSize: 16.0,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 8.0),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: appColors.bgColor,
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Row(
              children: [
                Image.asset(assetsPath, width: 24.0, height: 24.0),
                const SizedBox(width: 8.0),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16.0,
                    color: appColors.textSecondary,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(String label, BuildContext context) {
    final appColors = context.appColors;
    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: appColors.bgColor,
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: appColors.primary,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Icon(Icons.check, size: 16, color: Colors.white),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: appColors.textSecondary,
              fontSize: 16.0,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmReminder(BuildContext context) async {
    try {
      List<ReminderModel> allNewReminders = [];
      if (reminderModelData.type == 'Medicine') {
        DateTime parseTime(String dateStr, String timeStr) {
          List<String> dateParts = dateStr.split('/');
          int year = int.parse(dateParts[0]);
          int month = int.parse(dateParts[1]);
          int day = int.parse(dateParts[2]);

          int hour = int.parse(timeStr.split(':')[0]);
          int minute = int.parse(timeStr.split(':')[1].split(' ')[0]);
          bool isPM = timeStr.toLowerCase().contains('pm');

          if (isPM && hour != 12) hour += 12;
          if (!isPM && hour == 12) hour = 0;

          return DateTime(year, month, day, hour, minute);
        }

        for (var scheduleItem in reminderModelData.schedule!) {
          String currentDateStr = scheduleItem['date'];
          String baseTimeStr = scheduleItem['times'][0];
          DateTime baseDateTime = parseTime(currentDateStr, baseTimeStr);
          Map<String, int> activeSlots = {};
          if (reminderModelData.morning == true) {
            activeSlots['Morning'] = 0;
          }
          if (reminderModelData.afternoon == true) {
            activeSlots['Afternoon'] = (reminderModelData.morning == true)
                ? 6
                : 0;
          }
          if (reminderModelData.night == true) {
            if (reminderModelData.morning == true) {
              activeSlots['Night'] = 12;
            } else if (reminderModelData.afternoon == true) {
              activeSlots['Night'] = 6;
            } else {
              activeSlots['Night'] = 0;
            }
          }

          for (var entry in activeSlots.entries) {
            int offsetHours = entry.value;
            DateTime calculatedTime = baseDateTime.add(
              Duration(hours: offsetHours),
            );

            // Formatting
            int displayHour = calculatedTime.hour;
            String period = (displayHour >= 12) ? "PM" : "AM";
            int hour12 = (displayHour > 12)
                ? displayHour - 12
                : (displayHour == 0 ? 12 : displayHour);
            String formattedTime =
                "$hour12:${calculatedTime.minute.toString().padLeft(2, '0')} $period";

            Map<String, dynamic> updatedScheduleItem =
                Map<String, dynamic>.from(scheduleItem);
            updatedScheduleItem['times'] = [formattedTime];

            final newReminder = ReminderModel(
              title: reminderModelData.title,
              type: reminderModelData.type,
              medicineName: reminderModelData.medicineName,
              dose: reminderModelData.dose,
              duration: reminderModelData.duration,
              dateRange: currentDateStr,
              morning: reminderModelData.morning,
              afternoon: reminderModelData.afternoon,
              evening: false,
              night: reminderModelData.night,
              createdAt: Timestamp.now(),
              isRead: false,
              time: formattedTime,
              updatedAt: FieldValue.serverTimestamp(),
              scheduledAt: Timestamp.fromDate(calculatedTime),
              schedule: [updatedScheduleItem],
            );

            allNewReminders.add(newReminder);
            context.read<ReminderBloc>().add(
              AddMeetingsReminderEvent(reminderMeetingsModel: newReminder),
            );
            await Future.delayed(const Duration(milliseconds: 100));
          }
        }
      }
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) =>
              ReminderAddedScreen(allReminders: allNewReminders),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error saving reminder: $e')));
    }
  }
}
