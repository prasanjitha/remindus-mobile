import 'package:intl/intl.dart';
import 'package:flutter/material.dart';

import 'package:remindus/generated/assets.dart';
import 'package:remindus/theme/app_colors.dart';
import 'package:remindus/widgets/app_text_field.dart';

class AddReminderMeeting extends StatefulWidget {
  final TextEditingController titleController;
  final DateTime? selectedDate;
  final TimeOfDay? selectedTime;
  final VoidCallback onSelectDate;
  final VoidCallback onSelectTime;
  final String selectedAmPm;
  final Function(String) onAmPmChanged;
  final ValueChanged<TimeOfDay> onTimeChanged;

  const AddReminderMeeting({
    super.key,
    required this.titleController,
    required this.selectedDate,
    required this.selectedTime,
    required this.onSelectDate,
    required this.onSelectTime,
    required this.selectedAmPm,
    required this.onAmPmChanged,
    required this.onTimeChanged,
  });

  @override
  State<AddReminderMeeting> createState() => _AddReminderMeetingState();
}

class _AddReminderMeetingState extends State<AddReminderMeeting> {
  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: widget.selectedTime ?? TimeOfDay.now(),
    );
    if (picked != null) {
      widget.onTimeChanged(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppTextField(
            controller: widget.titleController,
            hintText: 'Title',
            prefixIconPath: Assets.subtitleIcon,
            label: 'Appointment title',
            isPassword: false,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a title';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),

          Text(
            'Pick a Date',
            style: TextStyle(
              fontWeight: FontWeight.w400,
              color: appColors.textPrimary,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),

          GestureDetector(
            onTap: widget.onSelectDate,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: appColors.bgColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Image.asset(Assets.calenderAddIcon, width: 20, height: 20),
                  const SizedBox(width: 12),
                  Text(
                    widget.selectedDate != null
                        ? DateFormat.yMd().format(widget.selectedDate!)
                        : 'No date selected',
                    style: TextStyle(
                      color: appColors.textSecondary,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          Text(
            'Time',
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
                          widget.selectedTime == null
                              ? 'Select time'
                              : widget.selectedTime!.format(context),
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
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildAmPmButton(String period, BuildContext context) {
    final appColors = context.appColors;

    final currentPeriod =
        widget.selectedTime != null && widget.selectedTime!.hour >= 12
        ? 'PM'
        : 'AM';
    final isSelected = currentPeriod == period;

    return InkWell(
      onTap: () {
        if (widget.selectedTime != null) {
          int hour = widget.selectedTime!.hour;
          int minute = widget.selectedTime!.minute;

          if (period == 'AM' && hour >= 12) {
            hour -= 12;
          } else if (period == 'PM' && hour < 12) {
            hour += 12;
          }

          widget.onTimeChanged(TimeOfDay(hour: hour, minute: minute));
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
        decoration: BoxDecoration(
          color: isSelected
              ? appColors.primary.withOpacity(0.16)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          period,
          style: TextStyle(
            color: isSelected ? appColors.primary : appColors.textPrimary,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w400,
            fontSize: 16.0,
          ),
        ),
      ),
    );
  }
}
