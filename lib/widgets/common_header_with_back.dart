import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:remindus/blocs/user/user_bloc.dart';
import 'package:remindus/generated/assets.dart';
import 'package:remindus/theme/app_colors.dart';
import '../../models/user_model.dart';
import '../../services/reminder_service.dart';

class CommonHeaderWithBack extends StatelessWidget {
  final VoidCallback? onProfileTap;
  final VoidCallback? onMainLogoTap;
  const CommonHeaderWithBack({
    super.key,
    this.onProfileTap,
    this.onMainLogoTap,
  });

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;

    //     final user = context.select<UserBloc, UserModel?>((bloc) {
    //   final state = bloc.state;
    //   return state is UserLoadedState ? state.user : null;
    // });

    // final String initial =
    //     (user?.name != null && user!.name!.isNotEmpty)
    //         ? user.name![0].toUpperCase()
    //         : 'U';

    return Row(
      children: [
        GestureDetector(
          onTap: onMainLogoTap,
          child: Icon(
            Icons.arrow_back,
            color: appColors.textPrimary,
            size: 20.0,
          ),
        ),
        const Spacer(),

        Image.asset(Assets.notificationIcon, width: 24.0, height: 24.0),
        const SizedBox(width: 10.0),

        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: appColors.primary,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              "K",
              style: TextStyle(
                color: appColors.bgColor,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
