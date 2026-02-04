import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:intl/intl.dart';
import 'elevenlabs_service.dart';

class NotificationService {
  // Initialize with listeners
  Future<void> initialize() async {
    await AwesomeNotifications().initialize('resource://drawable/logo', [
      NotificationChannel(
        channelKey: 'silent_voice_v1',
        channelName: 'Voice Notifications',
        channelDescription: 'Default notification channel',
        defaultColor: Color(0xFF9D50DD),
        ledColor: Colors.white,
        importance: NotificationImportance.Max,
        channelShowBadge: true,
        playSound: false,
        enableVibration: false,
      ),
    ], debug: true);

    // Request permissions
    await AwesomeNotifications().requestPermissionToSendNotifications();

    // Set up listeners
    await AwesomeNotifications().setListeners(
      onActionReceivedMethod: onActionReceivedMethod,
      onNotificationCreatedMethod: onNotificationCreatedMethod,
      onNotificationDisplayedMethod: onNotificationDisplayedMethod,
      onDismissActionReceivedMethod: onDismissActionReceivedMethod,
    );
  }

  // Triggered when notification is CREATED (scheduled or immediate)
  @pragma("vm:entry-point")
  static Future<void> onNotificationCreatedMethod(
    ReceivedNotification receivedNotification,
  ) async {}

  // Triggered when notification is DISPLAYED to user
  @pragma("vm:entry-point")
  static Future<void> onNotificationDisplayedMethod(
    ReceivedNotification receivedNotification,
  ) async {
    final payload = receivedNotification.payload ?? {};
    final reminderId = payload['reminderId'] ?? '';
    final medicineName = payload['medicineName'] ?? '';
    final dose = payload['dose'] ?? '';
    final userId = FirebaseAuth.instance.currentUser?.uid;
    final String isAppOwnerStr = payload['isAppOwner'] ?? 'false';
    final String isAppOwner = isAppOwnerStr;
    if (isAppOwner == 'true') {
      Future.delayed(const Duration(seconds: 30), () async {
        if (medicineName.isNotEmpty) {
          await deductMedicineStock(
            userId: userId!,
            medicineName: medicineName,
            dose: dose,
          );
          await updateMedicineNotificationStatus(
            userId: userId,
            medicineName: medicineName,
          );
        }
      });
      await yourCustomFunction(receivedNotification);
      if (userId != null) {
        await markReminderAsRead(userId: userId, reminderId: reminderId);
      }
    }
  }

  // Triggered when user TAPS the notification
  @pragma("vm:entry-point")
  static Future<void> onActionReceivedMethod(
    ReceivedAction receivedAction,
  ) async {}

  // Triggered when user DISMISSES the notification
  @pragma("vm:entry-point")
  static Future<void> onDismissActionReceivedMethod(
    ReceivedAction receivedAction,
  ) async {
    // Handle notification dismissal
  }

  static Future<void> yourCustomFunction(
    ReceivedNotification notification,
  ) async {
    final String message =
        notification.payload?['message'] ?? "You have a new notification";

    // Try ElevenLabs first
    try {
      await ElevenLabsService.speakText(message);
    } catch (e) {
      // Fallback to basic FlutterTts if ElevenLabs fails
      FlutterTts flutterTts = FlutterTts();
      await flutterTts.speak(message);
    }
  }

  static Future<void> markReminderAsRead({
    required String userId,
    required String reminderId,
  }) async {
    try {
      final docRef = FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('reminders')
          .doc(reminderId);

      final snapshot = await docRef.get();
      if (!snapshot.exists) return;

      final data = snapshot.data() as Map<String, dynamic>;
      final String? frequency = data['frequency'];
      final Timestamp? scheduledAt = data['scheduledAt'];
      final String? type = data['type'];
      final List<dynamic>? whenToTake = data['whenToTake'];
      final String? dateRange = data['dateRange'];

      if (scheduledAt != null) {
        DateTime nextSchedule = scheduledAt.toDate();

        if (type == "Vaccination") {
          DateTime? nextSchedule;

          if (frequency == "Annual Booster") {
            nextSchedule = scheduledAt.toDate().add(const Duration(days: 365));
          } else if (frequency == "Decade Booster") {
            // Precise 10 years
            DateTime current = scheduledAt.toDate();
            nextSchedule = DateTime(
              current.year + 10,
              current.month,
              current.day,
              current.hour,
              current.minute,
            );
          } else if (frequency == "6 Months") {
            DateTime current = scheduledAt.toDate();
            nextSchedule = DateTime(
              current.year,
              current.month + 6,
              current.day,
              current.hour,
              current.minute,
            );
          }

          if (nextSchedule != null) {
            final Timestamp? nextDoseDue = data['nextDoseDue'];

            // Priority: if nextSchedule < nextDoseDue, use nextSchedule. Otherwise use nextDoseDue.
            if (nextDoseDue != null) {
              DateTime due = nextDoseDue.toDate();
              if (nextSchedule.isAfter(due)) {
                nextSchedule = due;
              }
            }

            await docRef.update({
              'scheduledAt': Timestamp.fromDate(nextSchedule),
              'time': DateFormat.jm().format(nextSchedule),
              'isRead': false,
              'updatedAt': FieldValue.serverTimestamp(),
            });
            return;
          }

          // If "Single Course" or no specific logic for frequency, just mark as read
          await docRef.update({
            'isRead': true,
            'updatedAt': FieldValue.serverTimestamp(),
          });
          return;
        }

        if (type == "Medicine" &&
            whenToTake != null &&
            whenToTake.isNotEmpty &&
            dateRange != null) {
          // Parse dateRange for end date
          DateTime? endDate;
          try {
            final parts = dateRange.split(' - ');
            if (parts.length == 2) {
              endDate = DateFormat('MMM d, yyyy').parse(parts[1]);
              // Set to end of day
              endDate = DateTime(
                endDate.year,
                endDate.month,
                endDate.day,
                23,
                59,
                59,
              );
            }
          } catch (e) {}

          // Map slots to indices based on total count to match user requirements
          int getSlotIdx(String slot, int total) {
            if (slot == "Morning") return 0;
            if (slot == "Afternoon") return 1;
            if (slot == "Evening") return 2;
            if (slot == "Night") {
              return (total == 4) ? 3 : 2;
            }
            return 0;
          }

          // Find current slot index based on scheduledAt hour
          int currentSlotIndexInDay = -1;
          int hour = nextSchedule.hour;
          if (hour == 7)
            currentSlotIndexInDay = 0;
          else if (hour == 13)
            currentSlotIndexInDay = 1;
          else if (hour == 19)
            currentSlotIndexInDay = 2;
          else if (hour == 1)
            currentSlotIndexInDay = 3;

          // If current hour doesn't match standard, find the closest standard hour
          if (currentSlotIndexInDay == -1) {
            if (hour >= 4 && hour < 10)
              currentSlotIndexInDay = 0;
            else if (hour >= 10 && hour < 16)
              currentSlotIndexInDay = 1;
            else if (hour >= 16 && hour < 22)
              currentSlotIndexInDay = 2;
            else
              currentSlotIndexInDay = 3;
          }

          // Get active slot indices from whenToTake list
          List<int> activeIndices = whenToTake
              .map((s) => getSlotIdx(s.toString(), whenToTake.length))
              .toList();
          activeIndices = activeIndices
              .toSet()
              .toList(); // Remove duplicates if any
          activeIndices.sort();

          if (activeIndices.isNotEmpty) {
            // Find current index within activeIndices
            int currentIdx = activeIndices.indexOf(currentSlotIndexInDay);
            if (currentIdx == -1) {
              // Not found, find the first index that is AFTER currentSlotIndexInDay
              currentIdx = activeIndices.indexWhere(
                (idx) => idx >= currentSlotIndexInDay,
              );
              if (currentIdx == -1) currentIdx = activeIndices.length - 1;
            }

            int nextIdxInActive = (currentIdx + 1) % activeIndices.length;
            int currentSlotIdx = activeIndices[currentIdx];
            int nextSlotIdx = activeIndices[nextIdxInActive];

            int increments = nextSlotIdx - currentSlotIdx;
            if (nextIdxInActive <= currentIdx) {
              increments += 4; // Wrap around to next day
            }

            int hoursToNext = increments * 6;
            nextSchedule = nextSchedule.add(Duration(hours: hoursToNext));

            // Check if within dateRange
            if (endDate != null && nextSchedule.isAfter(endDate)) {
              await docRef.update({
                'isRead': true,
                'updatedAt': FieldValue.serverTimestamp(),
              });
              return;
            }

            // Update with next dose
            await docRef.update({
              'scheduledAt': Timestamp.fromDate(nextSchedule),
              'time': DateFormat.jm().format(nextSchedule),
              'isRead': false,
              'updatedAt': FieldValue.serverTimestamp(),
            });
            return;
          }
        }

        // Default frequency logic
        if (frequency != null && frequency != 'None' && frequency.isNotEmpty) {
          switch (frequency) {
            case 'Every day':
              nextSchedule = nextSchedule.add(const Duration(days: 1));
              break;
            case 'Once a week':
            case '1 Week':
              nextSchedule = nextSchedule.add(const Duration(days: 7));
              break;
            case 'Every two weeks':
            case '2 Weeks':
              nextSchedule = nextSchedule.add(const Duration(days: 14));
              break;
            case 'Once a month':
            case '1 Month':
              nextSchedule = DateTime(
                nextSchedule.year,
                nextSchedule.month + 1,
                nextSchedule.day,
                nextSchedule.hour,
                nextSchedule.minute,
              );
              break;
            case '2 Months':
              nextSchedule = DateTime(
                nextSchedule.year,
                nextSchedule.month + 2,
                nextSchedule.day,
                nextSchedule.hour,
                nextSchedule.minute,
              );
              break;
            default:
              await docRef.update({
                'isRead': true,
                'updatedAt': FieldValue.serverTimestamp(),
              });
              return;
          }

          await docRef.update({
            'scheduledAt': Timestamp.fromDate(nextSchedule),
            'isRead': false,
            'updatedAt': FieldValue.serverTimestamp(),
          });
        } else {
          await docRef.update({
            'isRead': true,
            'updatedAt': FieldValue.serverTimestamp(),
          });
        }
      }
    } catch (e) {}
  }

  static Future<void> updateMedicineNotificationStatus({
    required String userId,
    required String medicineName,
  }) async {
    try {
      String formattedName = medicineName.trim().toLowerCase().replaceAll(
        ' ',
        '',
      );

      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('medicinesStore')
          .where('name', isEqualTo: formattedName)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final docId = querySnapshot.docs.first.id;

        await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('medicinesStore')
            .doc(docId)
            .update({
              'isNotified': true,
              'lastNotifiedAt': FieldValue.serverTimestamp(),
            });
      }
    } catch (e) {}
  }

  static Future<void> deductMedicineStock({
    required String userId,
    required String medicineName,
    required String dose,
  }) async {
    try {
      String formattedName = medicineName.trim().toLowerCase().replaceAll(
        ' ',
        '',
      );

      int doseAmount =
          int.tryParse(dose.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;

      if (doseAmount == 0) return;
      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('medicinesStore')
          .where('name', isEqualTo: formattedName)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        return;
      }

      final doc = querySnapshot.docs.first;
      final docId = doc.id;

      String currentQtyStr = doc.data()['quantity'] ?? "0";
      int currentQty =
          int.tryParse(currentQtyStr.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;

      if (currentQty >= doseAmount) {
        int newQty = currentQty - doseAmount;

        String status;
        if (newQty > 10) {
          status = "wellStocked";
        } else if (newQty > 0 && newQty <= 10) {
          status = "lowRemaining";
        } else {
          status = "refill";
        }

        await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('medicinesStore')
            .doc(docId)
            .update({
              'quantity': newQty.toString(),
              'status': status,
              'updatedAt': FieldValue.serverTimestamp(),
            });
      }
    } catch (e) {}
  }

  // Schedule a notification
  Future<void> scheduleNotification({
    required int id,
    required int hour,
    required int minute,
    required String title,
    required String body,
    int? day,
    int? month,
    String? reminderId,
    String? message,
    String? dose,
    bool? isAppOwner,
  }) async {
    try {
      NotificationCalendar schedule = NotificationCalendar(
        hour: hour,
        minute: minute,
        second: 0,
        millisecond: 0,
        repeats: false,
        day: day,
        month: month,
        allowWhileIdle: true,
      );
      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: id,
          channelKey: 'silent_voice_v1',
          title: title,
          body: body,
          notificationLayout: NotificationLayout.Default,
          payload: {
            'reminderId': reminderId,
            'message': message,
            'dose': dose,
            'medicineName': body,
            'isAppOwner': isAppOwner.toString(),
          },
        ),
        schedule: schedule,
      );
    } catch (e) {}
  }

  // Show immediate notification
  Future<void> showNotification() async {
    try {
      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: 2,
          channelKey: 'silent_voice_v1',
          title: 'Immediate Notification',
          body: 'This shows immediately!',
        ),
      );
    } catch (e) {}
  }

  Future<void> showInstantNotification({
    required int id,
    required String title,
    required String body,
    Map<String, String>? payload,
  }) async {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: id,
        channelKey: 'basic_channel',
        title: title,
        body: body,
        payload: payload,
        notificationLayout: NotificationLayout.Default,
      ),
    );
  }

  Future<void> cancelAllNotifications() async {
    await AwesomeNotifications().cancelAllSchedules();
  }
}
