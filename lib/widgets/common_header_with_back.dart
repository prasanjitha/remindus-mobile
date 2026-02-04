import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:remindus/blocs/user/user_bloc.dart';
import 'package:remindus/generated/assets.dart';
import 'package:remindus/theme/app_colors.dart';
import 'package:remindus/widgets/shimmer_image.dart';

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

    final userState = context.watch<UserBloc>().state;
    String initial = "U";
    String? profileImageUrl;

    if (userState is UserLoadedState) {
      initial = userState.userName.isNotEmpty
          ? userState.userName[0].toUpperCase()
          : "U";
      profileImageUrl = userState.profileImageUrl;
    }

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
        Image.asset(
          Assets.notificationIcon,
          width: 24.0,
          height: 24.0,
          color: appColors.textPrimary,
        ),
        const SizedBox(width: 10.0),
        GestureDetector(
          onTap: onProfileTap,
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: appColors.primary,
              shape: BoxShape.circle,
            ),
            child: profileImageUrl != null
                ? ShimmerImage(
                    imageUrl: profileImageUrl,
                    width: 32,
                    height: 32,
                    borderRadius: BorderRadius.circular(16),
                    errorWidget: Center(
                      child: Text(
                        initial,
                        style: TextStyle(
                          color: appColors.bgColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  )
                : Center(
                    child: Text(
                      initial,
                      style: TextStyle(
                        color: appColors.bgColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}
