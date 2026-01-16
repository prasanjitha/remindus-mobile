import 'package:flutter/material.dart';
import 'package:remindus/generated/assets.dart';
import 'package:remindus/screens/authentication/siginin_screen.dart';
import 'package:remindus/theme/app_colors.dart';

class ForgotPasswordHeader extends StatelessWidget {
  const ForgotPasswordHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Image.asset(Assets.logoIcon, width: 28, height: 28),
              IconButton(
                onPressed: () {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => LoginScreen()),
                    (route) => false,
                  );
                },
                icon: Icon(Icons.close, size: 28, color: appColors.textPrimary),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            'Forget Password',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w400,
              color: appColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Enter your email to receive a reset code.',
            style: TextStyle(fontSize: 16, color: appColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
