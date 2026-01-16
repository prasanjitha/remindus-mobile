import 'package:flutter/material.dart';
import 'package:remindus/theme/app_colors.dart';
import 'package:remindus/widgets/custom_button.dart';

class CustomDialogs {
  static void showConfirmation({
    required BuildContext context,
    required String title,
    required String subtitle,
    required String actionButtonText,
    required VoidCallback onActionPressed,
    Color? actionButtonColor,
  }) {
    final appColors = context.appColors;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: appColors.bgColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStaticIcon(context), 
                const SizedBox(height: 20.0),
                Text(
                  title,
                  style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.w400, color: appColors.textPrimary),
                ),
                const SizedBox(height: 12.0),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 14.0, color: appColors.textSecondary),
                ),
                const SizedBox(height: 20.0),
                Row(
                  children: [
                    Expanded(
                      child: AppButton(
                        height: 54,
                        text: actionButtonText,
                        backgroundColor: actionButtonColor ?? appColors.errorRed,
                        onPressed: onActionPressed,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: AppButton(
                        height: 54,
                        text: "Cancel",
                        textColor: appColors.textPrimary,
                        backgroundColor: appColors.primary.withOpacity(0.2),
                        onPressed: () => Navigator.pop(dialogContext),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  static void showSuccess({
    required BuildContext context,
    required String title,
    required String subtitle,
    required String buttonText,
    required VoidCallback onBackPressed,
  }) {
    final appColors = context.appColors;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: appColors.bgColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStaticIcon(context), 
                const SizedBox(height: 20.0),
                Text(
                  title,
                  style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.w400, color: appColors.textPrimary),
                ),
                const SizedBox(height: 12.0),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 14.0, color: appColors.textSecondary),
                ),
                const SizedBox(height: 20.0),
                AppButton(
                  text: buttonText,
                  onPressed: onBackPressed,
                  backgroundColor: appColors.primary.withOpacity(0.1),
                  textColor: appColors.textPrimary,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  static Widget _buildStaticIcon(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: const Icon(Icons.delete_outline, color: Colors.red, size: 30),
    );
  }
}