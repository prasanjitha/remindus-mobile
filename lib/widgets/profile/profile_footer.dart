import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:remindus/blocs/user/user_bloc.dart';
import 'package:remindus/generated/assets.dart';
import 'package:remindus/helpers/snackbar_helper.dart';
import 'package:remindus/screens/authentication/siginin_screen.dart';
import 'package:remindus/screens/profile/change_password_screen.dart';
import 'package:remindus/screens/profile/edit_profile_screen.dart';
import 'package:remindus/theme/app_colors.dart';
import 'package:remindus/app/app_router.dart';
import 'package:remindus/widgets/shimmer_image.dart';

class ProfileFooter extends StatelessWidget {
  final String name;
  final String email;
  final String phone;
  final String? profileImageUrl;

  const ProfileFooter({
    super.key,
    required this.name,
    required this.email,
    required this.phone,
    this.profileImageUrl,
  });

  @override
  Widget build(BuildContext context) {
    final appColor = context.appColors;
    final isAppOwner = context.select<UserBloc, bool>((bloc) {
      final state = bloc.state;
      return state is UserLoadedState ? state.isAppowner : false;
    });

    return Card(
      color: appColor.bgColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ListTile(
              leading: CircleAvatar(
                radius: 26.0,
                backgroundColor: appColor.primary,
                child: profileImageUrl != null
                    ? ShimmerImage(
                        imageUrl: profileImageUrl!,
                        borderRadius: BorderRadius.circular(26),
                        width: 52,
                        height: 52,
                      )
                    : Text(
                        name.isNotEmpty ? name[0].toUpperCase() : '',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: appColor.bgColor,
                          fontSize: 32.0,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
              ),
              title: Text(
                name,
                style: TextStyle(
                  fontWeight: FontWeight.w400,
                  color: appColor.textPrimary,
                  fontSize: 20.0,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Email: $email',
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                      color: appColor.textSecondary,
                      fontSize: 14.0,
                    ),
                  ),
                  Text(
                    'Phone: $phone',
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                      color: appColor.textSecondary,
                      fontSize: 14.0,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            if (isAppOwner)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _FooterAction(
                    iconPath: Assets.quickActionIcon,
                    label: 'Edit Profile',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const EditProfileScreen(),
                        ),
                      );
                    },
                  ),
                  _FooterAction(
                    iconPath: Assets.passwordChangeIcon,
                    label: 'Password',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ChangePasswordScreen(),
                        ),
                      );
                    },
                  ),
                  _FooterAction(
                    iconPath: Assets.logOutIcon,
                    label: 'Log out',
                    onTap: () async {
                      try {
                        await FirebaseAuth.instance.signOut();
                        if (!context.mounted) return;
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                            builder: (context) => LoginScreen(),
                          ),
                          (route) => false,
                        );
                      } catch (e) {
                        if (context.mounted) {
                          SnackbarHelper.showError(context, e.toString());
                        }
                      }
                    },
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _FooterAction extends StatelessWidget {
  final String iconPath;
  final String label;
  final VoidCallback onTap;

  const _FooterAction({
    required this.iconPath,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final appColor = context.appColors;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: appColor.bgColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: appColor.textSecondary.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Image.asset(iconPath, width: 32.0, height: 32.0),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w400,
                color: appColor.textPrimary,
                fontSize: 14.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
