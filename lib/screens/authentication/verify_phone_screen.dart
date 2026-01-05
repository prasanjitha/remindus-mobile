import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:remindus/blocs/authentication/authentication_bloc.dart';
import 'package:remindus/generated/assets.dart';
import 'package:remindus/theme/app_colors.dart';
import 'package:remindus/widgets/app_text_field.dart';
import 'package:remindus/widgets/custom_button.dart';
// import 'package:your_project/widgets/app_text_field.dart';
// import 'package:your_project/widgets/app_button.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String verificationId;
  final String phoneNumber;
  const OtpVerificationScreen({
    super.key,
    required this.verificationId,
    required this.phoneNumber,
  });

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final List<TextEditingController> _otpControllers = List.generate(
    6,
    (_) => TextEditingController(),
  );

  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  bool _isLoading = false;
  final _phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _phoneController.text = widget.phoneNumber;
  }

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;
    return Scaffold(
      backgroundColor: appColors.bgColor,
      body: BlocConsumer<AuthenticationBloc, AuthenticationState>(
        listener: (context, state) {
          if (state is AuthenticationSuccessState && state.isAuthenticated) {
            _isLoading = false;
            Navigator.pushReplacementNamed(context, '/home');
          }

          if (state is LoadingState) {
            _isLoading = state.isLoading;
          }

          if (state is ErrorState) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.exception.message)));
          }
          if (state is NoInternetConnectionState) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("No Internet Connection!")),
            );
          }
        },
        builder: (context, state) {
          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 50.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 48,
                        height: 48,
                        child: Image.asset(Assets.logoIcon),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Enter Verification Code',
                        style: TextStyle(
                          fontSize: 32.0,
                          fontWeight: FontWeight.w400,
                          color: appColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "We've sent a code by text message.",
                        style: TextStyle(
                          fontSize: 16,
                          color: appColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  height: 2.0,
                  decoration: BoxDecoration(color: appColors.surfceSecondary),
                ),

                // 1. Entered Phone Number (Read only with edit icon)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      AppTextField(
                        label: 'Entered phone number',
                        hintText: '',
                        controller: _phoneController,
                        prefixIconPath: Assets.phoneIcon,
                        suffixIcon: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Image.asset(
                            Assets.pencilEditIcon,
                            width: 24.0,
                            height: 24.0,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(height: 28.0),
                      Container(
                        width: double.infinity,
                        height: 2.0,
                        decoration: BoxDecoration(
                          color: appColors.surfceSecondary,
                        ),
                      ),
                      const SizedBox(height: 28.0),
                      const Text(
                        'Enter code',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: List.generate(6, (index) {
                          return SizedBox(
                            width: 45,
                            height: 50,
                            child: TextField(
                              controller: _otpControllers[index],
                              focusNode: _focusNodes[index],
                              textAlign: TextAlign.center,
                              keyboardType: TextInputType.number,
                              maxLength: 1,
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                counterText: '',
                              ),
                              onChanged: (value) {
                                if (value.isNotEmpty && index < 5) {
                                  FocusScope.of(
                                    context,
                                  ).requestFocus(_focusNodes[index + 1]);
                                }
                              },
                            ),
                          );
                        }),
                      ),

                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Text(
                            "Didn't receive the code? ",
                            style: TextStyle(
                              color: appColors.textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              log(_phoneController.text.trim());
                              if (_phoneController.text.trim().isNotEmpty) {
                                context.read<AuthenticationBloc>().add(
                                  SendOtpEvent(
                                    phoneNumber: _phoneController.text.trim(),
                                  ),
                                );
                              }
                            },
                            child: Text(
                              "Resend",
                              style: TextStyle(
                                color: appColors.primaryDark,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 28.0),
                      AppButton(
                        text: 'Verify & Continue',
                        isLoading: _isLoading,
                        backgroundColor: appColors.primary,
                        onPressed: () {
                          if (_otpCode.length != 6) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Please enter full OTP"),
                              ),
                            );
                            return;
                          }

                          context.read<AuthenticationBloc>().add(
                            VerifyOtpEvent(
                              verificationId: widget.verificationId,
                              smsCode: _otpCode,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  String get _otpCode => _otpControllers.map((c) => c.text).join();

  @override
  void dispose() {
    for (final controller in _otpControllers) {
      controller.dispose();
    }
    for (final node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }
}
