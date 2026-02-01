import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:remindus/blocs/user/user_bloc.dart';
import 'package:remindus/models/base_reminder_model.dart';
import 'package:remindus/services/reminder_service.dart';
import 'package:remindus/theme/app_colors.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  final ReminderService _service = ReminderService();
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, List<ReminderModel>> _remindersByDate = {};
  List<ReminderModel> _allReminders = [];

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
  }

  DateTime _normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  List<ReminderModel> _getRemindersForDay(DateTime day) {
    final normalizedDay = _normalizeDate(day);
    return _remindersByDate[normalizedDay] ?? [];
  }

  void _organizeRemindersByDate(List<ReminderModel> reminders) {
    _remindersByDate.clear();
    for (var reminder in reminders) {
      if (reminder.scheduledAt != null) {
        final date = _normalizeDate(reminder.scheduledAt!.toDate());
        if (_remindersByDate[date] == null) {
          _remindersByDate[date] = [];
        }
        _remindersByDate[date]!.add(reminder);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;
    final activeFamilyId = context.select<UserBloc, String?>((bloc) {
      final state = bloc.state;
      return (state is UserLoadedState) ? state.activeFamilyId : null;
    });

    return Scaffold(
      backgroundColor: appColors.bgColor,
      appBar: AppBar(
        backgroundColor: appColors.bgColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: appColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Reminder Calendar',
          style: TextStyle(
            color: appColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body: activeFamilyId == null
          ? const Center(child: CircularProgressIndicator())
          : StreamBuilder<List<ReminderModel>>(
              stream: _service.getAllReminders(activeFamilyId: activeFamilyId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return const Center(child: Text("Something went wrong"));
                }

                _allReminders = snapshot.data ?? [];
                _organizeRemindersByDate(_allReminders);

                return Column(
                  children: [
                    _buildCalendar(appColors),
                    const SizedBox(height: 16),
                    _buildSelectedDateHeader(appColors),
                    const SizedBox(height: 8),
                    Expanded(child: _buildReminderList(appColors)),
                  ],
                );
              },
            ),
    );
  }

  Widget _buildCalendar(dynamic appColors) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: appColors.bgColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TableCalendar<ReminderModel>(
        firstDay: DateTime.utc(2020, 1, 1),
        lastDay: DateTime.utc(2030, 12, 31),
        focusedDay: _focusedDay,
        selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
        eventLoader: _getRemindersForDay,
        calendarFormat: CalendarFormat.month,
        startingDayOfWeek: StartingDayOfWeek.monday,
        onDaySelected: (selectedDay, focusedDay) {
          setState(() {
            _selectedDay = selectedDay;
            _focusedDay = focusedDay;
          });
        },
        onPageChanged: (focusedDay) {
          _focusedDay = focusedDay;
        },
        calendarStyle: CalendarStyle(
          // Today
          todayDecoration: BoxDecoration(
            color: appColors.primary.withOpacity(0.3),
            shape: BoxShape.circle,
          ),
          todayTextStyle: TextStyle(
            color: appColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
          // Selected
          selectedDecoration: BoxDecoration(
            color: appColors.primary,
            shape: BoxShape.circle,
          ),
          selectedTextStyle: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
          // Default
          defaultTextStyle: TextStyle(color: appColors.textPrimary),
          weekendTextStyle: TextStyle(color: appColors.textSecondary),
          outsideTextStyle: TextStyle(
            color: appColors.textSecondary.withOpacity(0.5),
          ),
          // Marker
          markerDecoration: BoxDecoration(
            color: appColors.primary,
            shape: BoxShape.circle,
          ),
          markerSize: 6,
          markersMaxCount: 3,
        ),
        headerStyle: HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,
          titleTextStyle: TextStyle(
            color: appColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
          leftChevronIcon: Icon(
            Icons.chevron_left,
            color: appColors.textPrimary,
          ),
          rightChevronIcon: Icon(
            Icons.chevron_right,
            color: appColors.textPrimary,
          ),
        ),
        daysOfWeekStyle: DaysOfWeekStyle(
          weekdayStyle: TextStyle(
            color: appColors.textSecondary,
            fontWeight: FontWeight.w600,
          ),
          weekendStyle: TextStyle(
            color: appColors.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildSelectedDateHeader(dynamic appColors) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Icon(Icons.event, color: appColors.primary, size: 20),
          const SizedBox(width: 8),
          Text(
            _selectedDay != null
                ? DateFormat('EEEE, MMMM d, yyyy').format(_selectedDay!)
                : 'Select a date',
            style: TextStyle(
              color: appColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReminderList(dynamic appColors) {
    if (_selectedDay == null) {
      return Center(
        child: Text(
          'Select a date to view reminders',
          style: TextStyle(color: appColors.textSecondary, fontSize: 16),
        ),
      );
    }

    final reminders = _getRemindersForDay(_selectedDay!);

    if (reminders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_busy,
              size: 64,
              color: appColors.textSecondary.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No reminders for this day',
              style: TextStyle(color: appColors.textSecondary, fontSize: 16),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: reminders.length,
      itemBuilder: (context, index) {
        final reminder = reminders[index];
        return _buildReminderCard(reminder, appColors);
      },
    );
  }

  Widget _buildReminderCard(ReminderModel reminder, dynamic appColors) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: appColors.bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: appColors.primary.withOpacity(0.2), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: reminder.isRead == true
                      ? appColors.textSecondary
                      : appColors.primary,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  reminder.title ??
                      (reminder.type == "Medicine" ? "Medicine" : "Meeting"),
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: appColors.textPrimary,
                    fontSize: 16,
                  ),
                ),
              ),
              if (reminder.isRead == true)
                Icon(
                  Icons.check_circle,
                  color: appColors.textSecondary,
                  size: 20,
                ),
            ],
          ),
          if (reminder.type == "Medicine" && reminder.medicineName != null) ...[
            const SizedBox(height: 8),
            Text(
              reminder.medicineName!,
              style: TextStyle(color: appColors.textSecondary, fontSize: 14),
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.access_time, size: 16, color: appColors.textSecondary),
              const SizedBox(width: 6),
              Text(
                reminder.time ?? "Time not set",
                style: TextStyle(color: appColors.textSecondary, fontSize: 14),
              ),
              if (reminder.type == "Medicine" && reminder.dose != null) ...[
                const SizedBox(width: 16),
                Icon(
                  Icons.medication,
                  size: 16,
                  color: appColors.textSecondary,
                ),
                const SizedBox(width: 6),
                Text(
                  reminder.dose!,
                  style: TextStyle(
                    color: appColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
