import 'package:flutter/material.dart';
import 'package:remindus/generated/assets.dart';

import 'package:remindus/theme/app_colors.dart';
import 'package:remindus/widgets/custom_button.dart';

class DialogHelper {
  static void showDeleteConfirmation({
    required BuildContext context,
    required String title,
    required String subtitle,
    required VoidCallback onDelete,
    required VoidCallback onDeleteSuccess,
    required String dismissButtonText,
    required String dismissDialogTitle,
    required String dismissDialogSubTitle,
  }) {
    final appColors = Theme.of(context).extension<AppColors>()!;

    showDialog(
      context: context,
      barrierDismissible: true,
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
                Container(
                  width: 40.0,
                  height: 40.0,
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    color: appColors.lightRed,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Image.asset(
                    Assets.deleteIcon,
                    width: 24.0,
                    height: 24.0,
                    color: appColors.darkRed,
                  ),
                ),
                const SizedBox(height: 20.0),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.w400,
                    color: appColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12.0),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 14.0,
                    color: appColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 20.0),
                Row(
                  children: [
                    Expanded(
                      child: AppButton(
                        height: 54,
                        text: "Delete",
                        backgroundColor: appColors.errorRed,
                        onPressed: () {
                          onDelete();
                          Navigator.pop(dialogContext);

                          Future.delayed(const Duration(milliseconds: 100), () {
                            if (context.mounted) {
                              showSuccessModal(
                                context: context,
                                onDeleteSuccess: onDeleteSuccess,
                                dismissButtonText: dismissButtonText,
                                dismissDialogTitle: dismissDialogTitle,
                                dismissDialogSubTitle: dismissDialogSubTitle,
                              );
                            }
                          });
                        },
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

  static void showSuccessModal({
    required BuildContext context,
    required VoidCallback onDeleteSuccess,
    required String dismissButtonText,
    required String dismissDialogTitle,
    required String dismissDialogSubTitle,
  }) {
    final appColors = Theme.of(context).extension<AppColors>()!;

    showDialog(
      context: context,
      builder: (context) => Dialog(
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
                  color: appColors.lightRed,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Image.asset(
                  Assets.deleteIcon,
                  width: 24.0,
                  height: 24.0,
                  color: appColors.darkRed,
                ),
              ),
              const SizedBox(height: 20.0),
              Text(
                dismissDialogTitle,
                style: TextStyle(fontSize: 20.0, color: appColors.textPrimary),
              ),
              const SizedBox(height: 12.0),
              Text(
                dismissDialogSubTitle,
                style: TextStyle(
                  fontSize: 14.0,
                  color: appColors.textSecondary,
                ),
              ),
              const SizedBox(height: 20.0),
              AppButton(
                text: dismissButtonText,
                onPressed: () {
                  onDeleteSuccess();
                },
                backgroundColor: appColors.lightRed,
                textColor: appColors.textPrimary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
