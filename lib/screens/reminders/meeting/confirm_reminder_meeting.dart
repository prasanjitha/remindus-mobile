import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:remindus/blocs/reminders/reminders_bloc.dart';
import 'package:remindus/blocs/user/user_bloc.dart';
import 'package:remindus/generated/assets.dart';
import 'package:remindus/models/base_reminder_model.dart';
import 'package:remindus/screens/reminders/reminder_added_screen.dart';
import 'package:remindus/theme/app_colors.dart';
import 'package:remindus/widgets/custom_button.dart';
import 'package:remindus/widgets/main_header_appbar.dart';

class ConfirmReminderMeetingScreen extends StatefulWidget {
  final ReminderModel reminderModel;
  const ConfirmReminderMeetingScreen({super.key, required this.reminderModel});

  @override
  State<ConfirmReminderMeetingScreen> createState() =>
      _ConfirmReminderMeetingScreenState();
}

class _ConfirmReminderMeetingScreenState
    extends State<ConfirmReminderMeetingScreen> {
  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;
    final DateTime dateTime = widget.reminderModel.date!.toDate();
    return Scaffold(
      backgroundColor: appColors.bgColor,
      body: Container(
        height: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(Assets.bgColorMap),
            fit: BoxFit.cover,
            opacity: 0.6,
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
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
                          widget.reminderModel.type == 'Meeting'
                              ? Assets.pillIcon
                              : Assets.calenderAddIcon,
                          color: appColors.bgColor,
                          width: 20,
                          height: 20,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        widget.reminderModel.type!,
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
                  widget.reminderModel.title!,
                  context,
                  Assets.subtitleIcon,
                ),
                if (widget.reminderModel.date != null)
                  _buildInfoRow(
                    'Pick a Date',
                    "${dateTime.day}-${dateTime.month}-${dateTime.year}",
                    context,
                    Assets.calendar2Icon,
                  ),

                Text(
                  'Time',
                  style: TextStyle(
                    fontWeight: FontWeight.w400,
                    color: appColors.textSecondary,
                    fontSize: 16.0,
                  ),
                ),
                const SizedBox(height: 8),

                Container(
                  width: double.infinity,
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
                        widget.reminderModel.time != null
                            ? widget.reminderModel.time.toString()
                            : '09:00 AM',
                        style: TextStyle(
                          fontSize: 16.0,
                          color: appColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
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
        ),
      ),
    );
  }

  Future<void> _confirmReminder(BuildContext context) async {
    try {
      int notifId = DateTime.now().millisecondsSinceEpoch.remainder(100000);
      final scheduledAt = Timestamp.fromDate(
        DateTime(
          widget.reminderModel.dateTime!.toDate().year,
          widget.reminderModel.dateTime!.toDate().month,
          widget.reminderModel.dateTime!.toDate().day,
          widget.reminderModel.dateTime!.toDate().hour,
          widget.reminderModel.dateTime!.toDate().minute,
        ),
      );
      final updatedReminder = widget.reminderModel.copyWith(
        notificationId: notifId,
        scheduledAt: scheduledAt,
      );
      context.read<ReminderBloc>().add(
        AddMeetingsReminderEvent(
          reminderMeetingsModel: updatedReminder,
          activeFamilyId: context.read<UserBloc>().state is UserLoadedState
              ? (context.read<UserBloc>().state as UserLoadedState)
                    .activeFamilyId
              : '',
        ),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) =>
              ReminderAddedScreen(allReminders: [widget.reminderModel]),
        ),
      );
    } catch (e, stackTrace) {
      print('Error confirming reminder: $e');
    }
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
}
