import 'package:intl/intl.dart';
import 'package:flutter/material.dart';

import 'package:remindus/theme/app_colors.dart';
import 'package:remindus/generated/assets.dart';
import 'package:remindus/widgets/custom_button.dart';
import 'package:remindus/models/base_reminder_model.dart';
import 'package:remindus/widgets/main_header_appbar.dart';

class ReminderAddedScreen extends StatelessWidget {
final List<ReminderModel> allReminders;

  const ReminderAddedScreen({super.key, required this.allReminders});

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;
    final reminderModelData = allReminders.isNotEmpty ? allReminders.first : null;
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              Assets.bgColorMap,
              fit: BoxFit.cover,
              opacity: const AlwaysStoppedAnimation(0.6),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(
              top: 50.0,
              left: 20.0,
              right: 20.0,
              bottom: 20.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MainHeaderAppBar(onClose: () => _goToHome(context)),
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
                if (reminderModelData!.type == "Medicine")
                  Expanded(
                    child: ListView.builder(
                      itemCount: allReminders.length,
                      padding: const EdgeInsets.only(bottom: 20),
                      physics: const BouncingScrollPhysics(),
                      itemBuilder: (context, index) {
                        final scheduleItem = allReminders[index].schedule!.first;
                        final String date = scheduleItem['date'] ?? "";
                        final List<String> times = List<String>.from(
                          scheduleItem['times'] ?? [],
                        );
                        return Column(
                          children: times.map((currentTime) {
                            return Container(
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
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Image.asset(
                                        Assets.roundedBorderIcon,
                                        width: 24,
                                        height: 24,
                                      ),
                                      Image.asset(
                                        Assets.pillIcon,
                                        width: 24,
                                        height: 24,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),

                                  Row(
                                    children: [
                                      Text(
                                        reminderModelData!.title ?? "Medicine",
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
                                        reminderModelData.medicineName ??
                                            "Medicine",
                                        style: TextStyle(
                                          fontWeight: FontWeight.w400,
                                          color: appColors.textPrimary,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      Text(
                                        date.toString(),
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
                                        currentTime,
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
                                        reminderModelData.dose ?? "Dose",
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
                            );
                          }).toList(),
                        );
                      },
                    ),
                  ),
                if (reminderModelData!.type == "Meeting")
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
                          reminderModelData.title ?? "Medicine",
                          style: TextStyle(
                            fontWeight: FontWeight.w400,
                            color: appColors.textPrimary,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Text(
                              reminderModelData.date != null
                                  ? DateFormat(
                                      'yyyy/MM/dd',
                                    ).format(reminderModelData.date!.toDate())
                                  : (reminderModelData.time ?? "Time"),
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
                              reminderModelData.time ?? "Time",
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
                  onPressed: () => _goToHome(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _goToHome(BuildContext context) {
    Navigator.of(context).popUntil((route) => route.isFirst);
  }
}
