import 'package:flutter/material.dart';
import 'package:remindus/theme/app_colors.dart'; // Adjust path based on your project
import 'package:remindus/generated/assets.dart'; // Adjust path
import 'package:remindus/widgets/shimmer_image.dart';

class MedicineCard extends StatelessWidget {
  final String name;
  final String detail;
  final MedicineStatus status;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool isSuccess;
  final bool canEdit;
  final String? imageUrl;

  const MedicineCard({
    super.key,
    required this.name,
    required this.detail,
    required this.status,
    this.onEdit,
    this.onDelete,
    this.isSuccess = false,
    required this.canEdit,
    this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    // Accessing your custom appColors extension
    final appColors = context.appColors;

    return Container(
      margin: const EdgeInsets.only(bottom: 8.0),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: appColors.bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          // Left Side: Icon
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: status.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Image.asset(
              status.imagePath,
              width: 24.0,
              height: 24.0,
              color: status.color,
            ),
          ),
          const SizedBox(width: 16),

          // Middle: Text info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: 16,
                    color: appColors.textPrimary,
                  ),
                ),
                Text(
                  (status == MedicineStatus.refill ||
                          status == MedicineStatus.missed)
                      ? status.label
                      : detail,
                  style: TextStyle(
                    color: (status == MedicineStatus.refill)
                        ? appColors.darkRed
                        : appColors.textSecondary,
                    fontSize: 14.0,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),

          // Right Side: Image (if success) or Action Buttons (if not success)
          if (isSuccess && imageUrl != null)
            Padding(
              padding: const EdgeInsets.only(left: 12.0),
              child: ShimmerImage(
                imageUrl: imageUrl!,
                width: 44,
                height: 44,
                borderRadius: BorderRadius.circular(12),
              ),
            )
          else if (!isSuccess && canEdit == true)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (imageUrl != null)
                  Padding(
                    padding: const EdgeInsets.only(left: 12.0, right: 12.0),
                    child: ShimmerImage(
                      imageUrl: imageUrl!,
                      width: 44,
                      height: 44,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                GestureDetector(
                  onTap: onEdit,
                  child: Image.asset(
                    Assets.pencilEditIcon,
                    width: 20.0,
                    height: 20.0,
                    color: appColors.textSecondary,
                  ),
                ),
                const SizedBox(width: 10.0),
                GestureDetector(
                  onTap: onDelete,
                  child: Image.asset(
                    Assets.deleteIcon,
                    width: 20.0,
                    height: 20.0,
                    color: appColors.textSecondary,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

enum MedicineStatus { refill, missed, lowRemaining, wellStocked }

extension MedicineStatusExtension on MedicineStatus {
  String get label {
    switch (this) {
      case MedicineStatus.refill:
        return 'Refill needed';
      case MedicineStatus.missed:
        return 'You missed last night';
      case MedicineStatus.lowRemaining:
        return 'Low stock';
      case MedicineStatus.wellStocked:
        return 'Well stocked';
    }
  }

  Color get color {
    switch (this) {
      case MedicineStatus.refill:
        return Colors.red;
      case MedicineStatus.missed:
        return Colors.orange;
      case MedicineStatus.lowRemaining:
        return Colors.orangeAccent;
      case MedicineStatus.wellStocked:
        return Colors.blue;
    }
  }

  String get imagePath {
    switch (this) {
      case MedicineStatus.refill:
        return Assets.storePillOffIcon;
      case MedicineStatus.missed:
        return Assets.storeGivePillIcon;
      case MedicineStatus.lowRemaining:
        return Assets.storePillsTabletIcon;
      case MedicineStatus.wellStocked:
        return Assets.storeHealthCareIcon;
    }
  }
}
