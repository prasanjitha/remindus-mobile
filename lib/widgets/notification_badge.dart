import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:remindus/blocs/user/user_bloc.dart';
import 'package:remindus/services/notification_service.dart';
import 'package:remindus/theme/app_colors.dart';

class NotificationBadge extends StatelessWidget {
  final Widget child;

  const NotificationBadge({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final activeFamilyId = context.select<UserBloc, String?>((bloc) {
      final state = bloc.state;
      return (state is UserLoadedState) ? state.activeFamilyId : null;
    });

    if (activeFamilyId == null) {
      return child;
    }

    final notificationService = NotificationService();

    return Stack(
      clipBehavior: Clip.none,
      children: [
        child,
        StreamBuilder<int>(
          stream: notificationService.getUnreadCountStream(activeFamilyId),
          builder: (context, snapshot) {
            final count = snapshot.data ?? 0;

            if (count == 0) {
              return const SizedBox.shrink();
            }

            return Positioned(
              right: -6,
              top: -6,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: context.appColors.errorRed,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: context.appColors.bgColor,
                    width: 1.5,
                  ),
                ),
                constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                child: Center(
                  child: Text(
                    count > 99 ? '99+' : count.toString(),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
