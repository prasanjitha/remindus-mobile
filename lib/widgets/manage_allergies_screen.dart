import 'package:flutter/material.dart';
import 'package:remindus/theme/app_colors.dart'; // Ensure this path is correct for your project

class ManageAllergiesHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback? onBackTap;
  final VoidCallback? onCloseTap;

  const ManageAllergiesHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.onBackTap,
    this.onCloseTap,
  });

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap: onBackTap ?? () => Navigator.of(context).pop(),
              child: Icon(Icons.arrow_back, color: appColors.textPrimary),
            ),
            GestureDetector(
              onTap: onCloseTap ?? () => Navigator.of(context).pop(),
              child: Icon(Icons.close, color: appColors.textPrimary),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          title,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w400,
            color: appColors.textPrimary,
          ),
        ),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: appColors.textSecondary,
          ),
        ),
      ],
    );
  }
}