import 'package:flutter/material.dart';
import 'package:remindus/services/permission_service.dart';
import 'package:remindus/theme/app_colors.dart';
import 'package:remindus/widgets/custom_button.dart';

class NotificationPermissionDialog extends StatelessWidget {
  final VoidCallback onAllowed;

  const NotificationPermissionDialog({super.key, required this.onAllowed});

  static void show(BuildContext context, {required VoidCallback onAllowed}) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => NotificationPermissionDialog(onAllowed: onAllowed),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;
    return Dialog(
      backgroundColor: appColors.bgColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40.0,
              height: 40.0,
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: appColors.primary.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.notifications_active_outlined,
                color: appColors.primary,
                size: 24.0,
              ),
            ),
            const SizedBox(height: 20.0),
            Text(
              "Enable Notifications",
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.w400,
                color: appColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12.0),
            Text(
              "To ensure you never miss your reminders, please enable notifications for this app.",
              style: TextStyle(fontSize: 14.0, color: appColors.textSecondary),
            ),
            const SizedBox(height: 20.0),
            Row(
              children: [
                Expanded(
                  child: AppButton(
                    height: 54,
                    text: "Allow",
                    onPressed: () async {
                      Navigator.pop(context);
                      bool granted = await PermissionService()
                          .ensureNotificationPermission();
                      if (granted) {
                        onAllowed();
                      }
                    },
                    backgroundColor: appColors.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AppButton(
                    height: 54,
                    text: "Don't Allow",
                    textColor: appColors.textPrimary,
                    onPressed: () => Navigator.pop(context),
                    backgroundColor: appColors.primary.withOpacity(0.12),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
