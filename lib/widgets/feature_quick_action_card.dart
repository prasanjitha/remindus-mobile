import 'package:flutter/material.dart';
import 'package:remindus/theme/app_colors.dart';

class QuickActionCard extends StatelessWidget {
  final String title;
  final String iconPath;
  final VoidCallback onTap;

  const QuickActionCard({
    super.key,
    required this.title,
    required this.iconPath,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 85.0,
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: appColors.bgColor,
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 32,
              width: 32,
              padding: const EdgeInsets.all(4.0),
              decoration: BoxDecoration(
                color: appColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Image.asset(
                iconPath,
                color: appColors.primary,
                width: 20.0,
                height: 20.0,
              ),
            ),
            const SizedBox(height: 8.0),
            Flexible(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 16.0,
              
                  fontWeight: FontWeight.w400,
                  color: appColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
