import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:remindus/generated/assets.dart';
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
    bool useRootNavigator = true,
  }) {
    final appColors = context.appColors;
    showDialog(
      context: context,
      useRootNavigator: useRootNavigator,
      barrierColor: Colors.black.withOpacity(0.3),
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: appColors.bgColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
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
                  style: TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.w600,
                    color: appColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12.0),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 14.0,
                    color: appColors.textSecondary,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24.0),
                Row(
                  children: [
                    Expanded(
                      child: AppButton(
                        height: 54,
                        text: actionButtonText,
                        backgroundColor:
                            actionButtonColor ?? appColors.errorRed,
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
    required String type,
    bool isLoading = false,
    bool useRootNavigator = true,
  }) {
    final appColors = context.appColors;
    showDialog(
      context: context,
      useRootNavigator: useRootNavigator,
      barrierColor: Colors.black.withOpacity(0.3),
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: appColors.bgColor,
          insetPadding: const EdgeInsets.symmetric(horizontal: 24.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (type == "delete")
                  _buildStaticIcon(context)
                else
                  _buildSuccessIcon(context),
                const SizedBox(height: 20.0),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.w600,
                    color: appColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12.0),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 14.0,
                    color: appColors.textSecondary,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24.0),
                AppButton(
                  isLoading: isLoading,
                  text: buttonText,
                  onPressed: onBackPressed,
                  backgroundColor: appColors.primary,
                  textColor: Colors.white,
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
        color: context.appColors.errorRed!.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Image.asset(
        Assets.deleteIcon,
        height: 30,
        width: 30,
        color: context.appColors.errorRed,
      ),
    );
  }

  static Widget _buildSuccessIcon(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.appColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        Icons.check_circle_outline,
        size: 30,
        color: context.appColors.primary,
      ),
    );
  }
}
