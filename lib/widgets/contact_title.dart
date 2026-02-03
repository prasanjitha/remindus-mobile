import 'package:flutter/material.dart';

import 'package:remindus/theme/app_colors.dart';
import 'package:remindus/generated/assets.dart';
import 'package:remindus/models/emergency_contact_model.dart';

class ContactTile extends StatelessWidget {
  final EmergencyContact contact;
  final AppColors appColors;
  final VoidCallback onEdit;
  final VoidCallback onCall;

  const ContactTile({
    required this.contact,
    required this.appColors,
    required this.onEdit,
    required this.onCall,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: appColors.bgColor,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: appColors.primary,
            radius: 20,
            child: Text(
              (contact.fullName ?? "U")[0].toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  contact.fullName ?? 'Unknown',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: appColors.textPrimary,
                  ),
                ),
                Text(
                  '${contact.phone ?? ''} • ${contact.relationship ?? ''}',
                  style: TextStyle(
                    fontSize: 13,
                    color: appColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Image.asset(
              Assets.pencilEditIcon,
              width: 22,
              color: appColors.textPrimary,
            ),
            onPressed: onEdit,
          ),
          IconButton(
            icon: Image.asset(
              Assets.phoneButtonIcon,
              width: 22,
              color: appColors.textPrimary,
            ),
            onPressed: onCall,
          ),
        ],
      ),
    );
  }
}
