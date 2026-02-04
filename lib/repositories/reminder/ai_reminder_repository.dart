import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:remindus/models/base_reminder_model.dart';

class AiReminderRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<ReminderModel>> saveReminders(
    List<ReminderModel> reminders,
    String activeFamilyId,
  ) async {
    WriteBatch batch = _firestore.batch();
    CollectionReference collection = _firestore
        .collection('users')
        .doc(activeFamilyId)
        .collection('reminders');

    List<ReminderModel> allSavedReminders = [];

    for (var reminder in reminders) {
      if (reminder.type == 'Medicine' &&
          reminder.duration != null &&
          reminder.schedule != null) {
        // Expansion Logic
        List<ReminderModel> expandedReminders = _expandMedicineReminder(
          reminder,
        );
        for (var expanded in expandedReminders) {
          DocumentReference docRef = collection.doc(); // Auto-ID
          ReminderModel finalExpanded = expanded.copyWith(
            reminderId: docRef.id,
          );
          allSavedReminders.add(finalExpanded);
          batch.set(docRef, finalExpanded.toMap());
        }
      } else {
        // Save as single document
        DateTime date = reminder.date?.toDate() ?? DateTime.now();
        String timeStr = reminder.time ?? '09:00 AM';
        DateTime scheduledDateTime = _combineDateAndTime(date, timeStr);

        DocumentReference docRef = collection.doc();

        ReminderModel finalReminder = reminder.copyWith(
          reminderId: docRef.id,
          scheduledAt: Timestamp.fromDate(scheduledDateTime),
        );
        allSavedReminders.add(finalReminder);

        batch.set(docRef, finalReminder.toMap());
      }
    }

    await batch.commit();
    return allSavedReminders;
  }

  List<ReminderModel> _expandMedicineReminder(ReminderModel original) {
    List<ReminderModel> expandedList = [];

    // Parse Duration
    int days = _parseDurationInDays(original.duration);
    DateTime startDate = original.date != null
        ? original.date!.toDate()
        : DateTime.now();

    // Iterate days
    for (int i = 0; i < days; i++) {
      DateTime currentDate = startDate.add(Duration(days: i));
      String dateStr = DateFormat('yyyy-MM-dd').format(currentDate);

      // Iterate doses/schedule
      if (original.schedule != null) {
        for (var slot in original.schedule!) {
          String time = slot['time'] ?? '09:00 AM';
          DateTime scheduledDateTime = _combineDateAndTime(currentDate, time);

          // Create new reminder for this specific slot
          expandedList.add(
            original.copyWith(
              date: Timestamp.fromDate(currentDate), // Specific date
              time: time, // Specific time
              dateRange: dateStr, // Optional: store date string
              scheduledAt: Timestamp.fromDate(scheduledDateTime),
              // Keep other fields
            ),
          );
        }
      }
    }

    // If no schedule or days 0, just return original?
    // Or if checking dose frequency. User said "Doses has 2 times/day".
    // I assumed generic 'schedule' field from my Service mapping.
    if (expandedList.isEmpty) {
      expandedList.add(original);
    }

    return expandedList;
  }

  int _parseDurationInDays(String? duration) {
    if (duration == null) return 1;
    String d = duration.toLowerCase();
    if (d.contains('week')) {
      // Extract number
      final RegExp regex = RegExp(r'(\d+)');
      final match = regex.firstMatch(d);
      int weeks = match != null ? int.parse(match.group(1)!) : 1;
      return weeks * 7;
    } else if (d.contains('day')) {
      final RegExp regex = RegExp(r'(\d+)');
      final match = regex.firstMatch(d);
      return match != null ? int.parse(match.group(1)!) : 1;
    } else if (d.contains('month')) {
      final RegExp regex = RegExp(r'(\d+)');
      final match = regex.firstMatch(d);
      int months = match != null ? int.parse(match.group(1)!) : 1;
      return months * 30;
    }
    return 1;
  }

  DateTime _combineDateAndTime(DateTime date, String timeStr) {
    try {
      // timeStr e.g., "09:00 AM" or "02:35 PM"
      final DateFormat formatter = DateFormat("hh:mm a");
      final DateTime dateTime = formatter.parse(timeStr);
      return DateTime(
        date.year,
        date.month,
        date.day,
        dateTime.hour,
        dateTime.minute,
      );
    } catch (e) {
      // Fallback to 9 AM if parsing fails
      return DateTime(date.year, date.month, date.day, 9, 0);
    }
  }
}
