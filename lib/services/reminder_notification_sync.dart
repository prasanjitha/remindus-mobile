import 'dart:async';

import 'package:remindus/models/medicine_store_model.dart';
import 'package:remindus/services/reminder_service.dart';
import 'package:remindus/models/base_reminder_model.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:remindus/services/local_notification_service.dart';

class ReminderNotificationSync {
  final NotificationService _notificationService = NotificationService();
  final ReminderService _reminderService = ReminderService();

  StreamSubscription? _subscription;
  StreamSubscription? _refillSubscription;

  void start(String activeFamilyId, bool isAppOwner) {
 _subscription = _reminderService
      .getLatestTwoUpcoming(activeFamilyId: activeFamilyId)
      .listen((List<ReminderModel> reminders) {

        _syncNotifications(reminders, isAppOwner);
      });

    _refillSubscription = _reminderService.getRefillAlerts(
      activeFamilyId: activeFamilyId,
    ).listen(
      _syncRefillNotifications,
    );
  }

  Future<void> _syncNotifications(List<ReminderModel> reminders, bool isAppOwner) async {
    try {
      await AwesomeNotifications().cancelAllSchedules();

      for (final reminder in reminders) {
        final scheduledDate = reminder.scheduledAt!.toDate();
        String message = '';
        if (reminder.type == 'Medicine') {
          message =
              'You have to take ${reminder.medicineName} for ${reminder.dose} now';
        } else if (reminder.type == 'Meeting') {
          message = 'You have a  ${reminder.title} now';
        }

        await _notificationService.scheduleNotification(
          id: reminder.reminderId.hashCode,
          hour: scheduledDate.hour,
          minute: scheduledDate.minute,
          title: reminder.title!,
          body: reminder.medicineName ?? '',
          day: scheduledDate.day,
          month: scheduledDate.month,
          reminderId: reminder.reminderId,
          message: message,
          dose: reminder.dose,
          isAppOwner: isAppOwner,
        );
      }
    } catch (e) {
      print('Error scheduling notifications: $e');
    }
  }

Future<void> _syncRefillNotifications(
    List<MedicineStoreModel> refillMedicines,
  ) async {
    try {
      DateTime now = DateTime.now();
      
      DateTime startOfToday = DateTime(now.year, now.month, now.day);

      for (int i = 0; i < refillMedicines.length; i++) {
        final medicine = refillMedicines[i];

        bool alreadyNotified = medicine.isNotified ?? false;
        
        DateTime? lastNotified = medicine.lastNotifiedAt;

        if (alreadyNotified && lastNotified != null && lastNotified.isAfter(startOfToday)) {
          continue; 
        }

     
        DateTime scheduledTime = now.add(Duration(minutes: i + 1));
        

        await _notificationService.scheduleNotification(
          id: medicine.medicineStoreId.hashCode,
          hour: scheduledTime.hour,
          minute: scheduledTime.minute,
          day: scheduledTime.day,
          month: scheduledTime.month,
          title: 'Stock Empty!',
          body: medicine.name ?? '',
          message: '${medicine.name} is out of stock. Please refill your store.',
          reminderId: medicine.medicineStoreId,
          dose: '', 
          
        );
      }
    } catch (e) {
    }
  }

  void dispose() {
    _subscription?.cancel();
    _refillSubscription?.cancel();
    _subscription = null;
    _refillSubscription = null;
  }
}
