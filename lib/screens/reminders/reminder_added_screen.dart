import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:remindus/blocs/reminders/reminders_bloc.dart';
import 'package:remindus/screens/tab/main_tab_screen.dart';

import 'package:remindus/theme/app_colors.dart';
import 'package:remindus/generated/assets.dart';
import 'package:remindus/widgets/custom_button.dart';
import 'package:remindus/models/base_reminder_model.dart';
import 'package:remindus/widgets/app_gradient_background.dart';
import 'package:remindus/widgets/main_header_appbar.dart';

class ReminderAddedScreen extends StatelessWidget {
  final ReminderModel reminder;
  final String activeFamilyId;

  const ReminderAddedScreen({
    super.key,
    required this.reminder,
    required this.activeFamilyId,
  });

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;
    return AppGradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Padding(
          padding: const EdgeInsets.only(
            top: 50.0,
            left: 20.0,
            right: 20.0,
            bottom: 20.0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MainHeaderAppBar(
                onClose: () {
                  _goToHome(context, reminder, activeFamilyId);
                },
              ),
              const SizedBox(height: 20.0),

              Text(
                "Reminder Added!",
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
              if (reminder.type == "Medicine")
                Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: appColors.bgColor,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Image.asset(
                            Assets.roundedBorderIcon,
                            width: 24,
                            height: 24,
                          ),
                          Image.asset(Assets.pillIcon, width: 24, height: 24),
                        ],
                      ),
                      const SizedBox(height: 6),

                      Text(
                        reminder!.title ?? "Medicine",
                        style: TextStyle(
                          fontWeight: FontWeight.w400,
                          color: appColors.textPrimary,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Text(
                            reminder!.medicineName ?? "Medicine",
                            style: TextStyle(
                              fontWeight: FontWeight.w400,
                              color: appColors.textPrimary,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            " - ",
                            style: TextStyle(
                              fontWeight: FontWeight.w400,
                              color: appColors.textPrimary,
                            ),
                          ),
                          Text(
                            reminder.dose ?? "Tablet",
                            style: TextStyle(
                              fontWeight: FontWeight.w400,
                              color: appColors.textPrimary,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),

                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.start,
                        alignment: WrapAlignment.start,
                        spacing: 4,
                        runSpacing: 4,
                        children: [
                          Text(
                            reminder.frequency == "Pick a date range"
                                ? (reminder.dateRange ?? "")
                                : (reminder.frequency ?? ""),
                            style: TextStyle(
                              fontWeight: FontWeight.w400,
                              color: appColors.textPrimary,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            " - ",
                            style: TextStyle(
                              fontWeight: FontWeight.w400,
                              color: appColors.textPrimary,
                            ),
                          ),
                          Text(
                            reminder.whenToTake?.join(", ") ?? "",
                            style: TextStyle(
                              fontWeight: FontWeight.w400,
                              color: appColors.textPrimary,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

              if (reminder!.type == "Meeting")
                Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: appColors.bgColor,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Image.asset(
                            Assets.roundedBorderIcon,
                            width: 24,
                            height: 24,
                          ),
                          Image.asset(
                            Assets.calenderAddIcon,
                            width: 24,
                            height: 24,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      Text(
                        reminder.title ?? "Medicine",
                        style: TextStyle(
                          fontWeight: FontWeight.w400,
                          color: appColors.textPrimary,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 4,
                        runSpacing: 4,
                        children: [
                          Text(
                            reminder.date != null
                                ? DateFormat(
                                    'yyyy/MM/dd',
                                  ).format(reminder.date!.toDate())
                                : (reminder.time ?? "Time"),
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: appColors.textPrimary,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            " - ",
                            style: TextStyle(
                              fontWeight: FontWeight.w400,
                              color: appColors.textPrimary,
                            ),
                          ),
                          Text(
                            reminder.time ?? "Time",
                            style: TextStyle(
                              fontWeight: FontWeight.w400,
                              color: appColors.textPrimary,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 20.0),
              AppButton(
                text: 'Done',
                backgroundColor: appColors.primary,
                onPressed: () => _goToHome(context, reminder, activeFamilyId),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _goToHome(
    BuildContext context,
    ReminderModel newReminder,
    String activeFamilyId,
  ) {
    context.read<ReminderBloc>().add(
      AddMeetingsReminderEvent(
        reminderMeetingsModel: newReminder,
        activeFamilyId: activeFamilyId,
      ),
    );
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => const MainTabScreen(initialIndex: 1),
      ),
      (route) => false,
    );
  }
}
