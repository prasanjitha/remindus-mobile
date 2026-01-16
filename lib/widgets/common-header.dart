import 'package:flutter/material.dart';
import 'package:remindus/generated/assets.dart';
import 'package:remindus/theme/app_colors.dart';
import '../../models/user_model.dart';
import '../../services/reminder_service.dart';

class CommonHeader extends StatelessWidget {
  const CommonHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final reminderService = ReminderService();
    final appColors = context.appColors;

    return Container(
      padding: const EdgeInsets.only(top: 30, left: 20, right: 20, bottom: 20),
      child: Row(
        children: [
          Image.asset(Assets.logoIcon, width: 28.0, height: 28.0),
          const Spacer(),

          Image.asset(Assets.notificationIcon, width: 24.0, height: 24.0),
          const SizedBox(width: 10.0),

          GestureDetector(
            onTap: () {},
            child: Container(
              width: 32.0,
              height: 32.0,
              decoration: BoxDecoration(
                color: appColors.primary,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: StreamBuilder<UserModel>(
                  stream: reminderService.getUserData(),
                  builder: (context, snapshot) {
                    final user = snapshot.data;
                    final String initial =
                        (user?.name != null && user!.name!.isNotEmpty)
                        ? user.name![0].toUpperCase()
                        : 'U';

                    return Text(
                      initial,
                      style: TextStyle(
                        color: appColors.bgColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
