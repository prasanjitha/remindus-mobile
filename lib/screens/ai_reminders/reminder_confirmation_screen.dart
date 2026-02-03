import 'package:intl/intl.dart';

import 'package:flutter/material.dart';
import 'package:remindus/generated/assets.dart';
import 'package:remindus/models/base_reminder_model.dart';
import 'package:remindus/theme/app_colors.dart';
import 'package:remindus/widgets/app_gradient_background.dart';
import 'package:remindus/widgets/custom_button.dart';
import 'package:remindus/widgets/main_header_appbar.dart';

class ReminderConfirmationScreen extends StatelessWidget {
  final List<ReminderModel> reminders;

  const ReminderConfirmationScreen({Key? key, required this.reminders})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;
    final isMedical =
        reminders.isNotEmpty && (reminders.first.type == 'medicine');

    return Scaffold(
      backgroundColor: appColors.bgColor,
      body: AppGradientBackground(
        child: Column(
          children: [
            const SizedBox(height: 50),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: MainHeaderAppBar(
                onClose: () {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    _buildHeader(appColors),
                    const SizedBox(height: 30),
                    Expanded(
                      child: isMedical
                          ? _buildMedicalList(context, reminders)
                          : _buildMeetingCard(
                              context,
                              reminders.isNotEmpty ? reminders.first : null,
                            ),
                    ),
                    const SizedBox(height: 20),
                    AppButton(
                      text: "Done",
                      onPressed: () {
                        Navigator.of(
                          context,
                        ).popUntil((route) => route.isFirst);
                      },
                      backgroundColor: appColors.primary,
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(AppColors appColors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        Text(
          "Reminder Added!",
          style: TextStyle(
            fontWeight: FontWeight.w400,
            color: appColors.textPrimary,
            fontSize: 28,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "Select reminder type and fill the blanks",
          style: TextStyle(
            fontWeight: FontWeight.w400,
            color: appColors.textSecondary,
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  Widget _buildMedicalList(BuildContext context, List<ReminderModel> items) {
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        return _buildMedicalCard(context, items[index]);
      },
    );
  }

  Widget _buildMedicalCard(BuildContext context, ReminderModel item) {
    final appColors = context.appColors;
    String dateStr = "";
    if (item.date != null) {
      dateStr = DateFormat('MMM dd, yyyy').format(item.date!.toDate());
    }

    String timeStr = item.time ?? "";
    if (timeStr.isEmpty && item.schedule != null) {
      timeStr = item.schedule!.map((s) => s['time'].toString()).join(", ");
    }

    String dose = item.dose ?? "1 Tablet";

    List<String> parts = [];
    if (dateStr.isNotEmpty) parts.add(dateStr);
    if (timeStr.isNotEmpty) parts.add(timeStr);
    if (dose.isNotEmpty) parts.add(dose);

    String subtitle = parts.join(" • ");

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: appColors.primary, width: 2),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "${item.title} - ${item.medicineName}",
                  style: TextStyle(
                    color: appColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: appColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Image.asset(
            Assets.linkIcon,
            width: 20,
            height: 20,
            color: appColors.textSecondary,
          ),
        ],
      ),
    );
  }

  Widget _buildMeetingCard(BuildContext context, ReminderModel? item) {
    if (item == null) return const SizedBox.shrink();

    final appColors = context.appColors;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: appColors.primaryLight,
              shape: BoxShape.circle,
            ),
            child: Image.asset(
              Assets.calendar2Icon,
              width: 32,
              height: 32,
              color: appColors.primary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            item.title ?? "Meeting",
            style: TextStyle(
              color: appColors.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            item.time ?? "--:--",
            style: TextStyle(
              color: appColors.primary,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          if (item.date != null)
            Text(
              // Assuming date is compatible timestamp print
              item.date!.toDate().toString().split(' ')[0],
              style: TextStyle(color: appColors.textSecondary, fontSize: 14),
            ),
        ],
      ),
    );
  }
}
