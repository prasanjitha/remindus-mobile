import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:remindus/generated/assets.dart';
import 'package:remindus/screens/authentication/siginin_screen.dart';
import 'package:remindus/theme/app_colors.dart';
import 'package:remindus/widgets/custom_button.dart';

class ResetSuccessDialog extends StatelessWidget {
  final String message;
  const ResetSuccessDialog({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 3.6, sigmaY: 3.6),
      child: AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: context.appColors.bgColor,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: appColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Image.asset(Assets.mailOpenLoveIcon),
            ),
            const SizedBox(height: 20.0),
            Text(
              "Reset Email Sent",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w400,
                color: appColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              message,
              style: TextStyle(color: appColors.textSecondary, fontSize: 14.0),
            ),
            const SizedBox(height: 20),
            AppButton(
              text: "Continue",
              backgroundColor: appColors.primary,
              onPressed: () {
                FirebaseAuth.instance.signOut();
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => LoginScreen()),
                  (route) => false,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
