import 'package:remindus/models/base_reminder_model.dart';
import 'package:remindus/models/voice_notification_model.dart';


abstract class BaseReminderRepositories {
Future<bool> addReminder({required ReminderModel reminder});

   Future<bool> addVoiceNotification({
    required VoiceNotificationModel voiceNotificationModel,
  });

  Future<bool> updateReminder({required ReminderModel reminder, required String reminderId,required String activeFamilyId});
}
