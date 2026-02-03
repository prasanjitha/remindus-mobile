import 'dart:async';
import 'dart:ui';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:remindus/generated/assets.dart';
import 'package:remindus/screens/authentication/send_otp_screen.dart';
import 'package:remindus/screens/authentication/signup_screen.dart';
import 'package:remindus/theme/app_colors.dart';
import 'package:remindus/widgets/app_gradient_background.dart';
import 'package:remindus/widgets/app_text_field.dart';
import 'package:remindus/widgets/custom_button.dart';

class VerifyEmailPage extends StatefulWidget {
  final String? email;
  VerifyEmailPage({Key? key, required this.email}) : super(key: key);

  @override
  _VerifyEmailPageState createState() => _VerifyEmailPageState();
}

class _VerifyEmailPageState extends State<VerifyEmailPage> {
  bool isEmailVerified = false;
  bool canResendEmail = true;
  Timer? timer;
  final _emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    isEmailVerified = user?.emailVerified ?? false;

    if (!isEmailVerified && user != null) {
      timer = Timer.periodic(
        const Duration(seconds: 3),
        (_) => checkEmailVerified(),
      );
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  Future sendVerificationEmail() async {
    try {
      final user = FirebaseAuth.instance.currentUser!;
      await user.sendEmailVerification();

      setState(() => canResendEmail = false);
      await Future.delayed(const Duration(seconds: 5));
      setState(() => canResendEmail = true);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  Future checkEmailVerified() async {
    await FirebaseAuth.instance.currentUser?.reload();

    if (FirebaseAuth.instance.currentUser!.emailVerified) {
      timer?.cancel();
      showDialog(
        context: context,
        barrierDismissible: true,
        barrierColor: Colors.black.withOpacity(0.1),
        builder: (BuildContext context) {
          return BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 3.5, sigmaY: 3.5),
            child: AlertDialog(
              backgroundColor: context.appColors.bgColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    padding: const EdgeInsets.all(6.0),
                    decoration: BoxDecoration(
                      color: context.appColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Image.asset(
                      Assets.mailOpenLoveIcon,
                      width: 24.0,
                      height: 24.0,
                    ),
                  ),
                  const SizedBox(height: 20.0),
                  Text(
                    "Email Verified!",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w400,
                      color: context.appColors.textPrimary,
                    ),
                  ),

                  const SizedBox(height: 12),
                  Text(
                    "Your account is now secure and ready to use. Let's set up your profile.",
                    style: TextStyle(
                      color: context.appColors.textSecondary,
                      fontSize: 14.0,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 20),
                  AppButton(
                    text: "Continue",
                    backgroundColor: context.appColors.primary,
                    onPressed: () {
                      FirebaseAuth.instance.signOut();
                      Navigator.of(context).pop();
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) => const VerifyPhoneScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) => AppGradientBackground(
    child: Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: context.appColors.bgColor,
        title: Image.asset(Assets.logoIcon, width: 28, height: 26),
        leading: IconButton(
          onPressed: () {
            // FirebaseAuth.instance.signOut();
            // Navigator.of(context).pushReplacement(
            //   MaterialPageRoute(builder: (context) => SignUpScreen()),
            // );
            checkEmailVerified();
          },
          icon: const Icon(Icons.arrow_back),
        ),
        actions: [
          IconButton(
            onPressed: () {
              FirebaseAuth.instance.signOut();
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => SignUpScreen()),
              );
            },
            icon: const Icon(Icons.close, size: 24.0),
          ),
        ],
        centerTitle: true,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Verify Your Email',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w400,
                    color: context.appColors.textPrimary,
                  ),
                ),
                Text(
                  'We’ve sent a verification link to your email address.',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: context.appColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            height: 2.0,
            decoration: BoxDecoration(color: context.appColors.surfceSecondary),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 32.0,
                  padding: const EdgeInsets.all(6.0),
                  decoration: BoxDecoration(
                    color: context.appColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.center,
                  child: Image.asset(
                    Assets.linkIcon,
                    width: 20.0,
                    height: 20.0,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 20),

                Text(
                  'Check Your Inbox',
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.w400,
                    color: context.appColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Tap the link in your inbox to activate your account.\nDon\'t see it? Check your Spam or Junk folders. ',
                  style: TextStyle(
                    color: context.appColors.textSecondary,
                    fontSize: 14.0,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 28),
                Container(
                  width: double.infinity,
                  height: 2.0,
                  decoration: BoxDecoration(
                    color: context.appColors.surfceSecondary,
                  ),
                ),
                const SizedBox(height: 28),
                AppTextField(
                  readOnly: true,
                  controller: _emailController,
                  label: "Entered email address",
                  hintText: widget.email ?? "smaple@gmail.com",
                  prefixIconPath: Assets.emailIcon,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    final emailRegExp = RegExp(
                      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                    );
                    if (!emailRegExp.hasMatch(value)) {
                      return 'Please enter a valid email address';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 8),

                Row(
                  children: [
                    Text(
                      'Didn\'t receive the email?',
                      style: TextStyle(
                        color: context.appColors.textSecondary,
                        fontSize: 14.0,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    TextButton(
                      // onPressed: canResendEmail ? sendVerificationEmail : null,
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              "We’ve sent a verification link to your email address",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14.0,
                              ),
                            ),
                            backgroundColor: Colors.green,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      child: Text(
                        'Resend Link',
                        style: TextStyle(
                          fontSize: 14.0,
                          fontWeight: FontWeight.w600,
                          color: canResendEmail
                              ? context.appColors.primary
                              : context.appColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
