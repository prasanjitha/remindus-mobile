import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:remindus/generated/assets.dart';
import 'package:remindus/theme/app_colors.dart';
import 'package:remindus/widgets/app_gradient_background.dart';
import 'package:remindus/widgets/custom_button.dart';
import 'package:remindus/widgets/app_text_field.dart';
import 'package:remindus/widgets/forgot_password_header.dart';
import 'package:remindus/widgets/dialog/reset_success_dialog.dart';
import 'package:remindus/blocs/authentication/authentication_bloc.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _submitted = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _onResetPressed(BuildContext context) {
    setState(() => _submitted = true);
    if (_formKey.currentState!.validate()) {
      context.read<AuthenticationBloc>().add(
        ResetPasswordEvent(email: _emailController.text.trim()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;

    return AppGradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: BlocConsumer<AuthenticationBloc, AuthenticationState>(
          listener: (context, state) {
            if (state is SusseccMessageState) {
              _showSuccessDialog(context, state.message);
            }
            if (state is ErrorState) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.exception.message),
                  backgroundColor: Colors.redAccent,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          },
          builder: (context, state) {
            final isLoading = state is LoadingState && state.isLoading;

            return SafeArea(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const ForgotPasswordHeader(),

                    const SizedBox(height: 20),
                    Divider(color: appColors.surfceSecondary, thickness: 2),
                    const SizedBox(height: 20),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Column(
                        children: [
                          Form(
                            key: _formKey,
                            autovalidateMode: _submitted
                                ? AutovalidateMode.onUserInteraction
                                : AutovalidateMode.disabled,
                            child: AppTextField(
                              controller: _emailController,
                              label: "Email address",
                              hintText: "Your email address",
                              prefixIconPath: Assets.emailIcon,
                              validator: (value) => _validateEmail(value),
                            ),
                          ),
                          const SizedBox(height: 28),
                          _buildSubmitButton(isLoading, appColors),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSubmitButton(bool isLoading, dynamic appColors) {
    if (isLoading) {
      return Container(
        height: 56,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: appColors.primary,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const CircularProgressIndicator(color: Colors.white),
      );
    }
    return AppButton(
      text: "Send Reset Email",
      onPressed: () => _onResetPressed(context),
      backgroundColor: appColors.primary,
      textColor: appColors.bgColor,
    );
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'Please enter your email';
    final emailRegExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegExp.hasMatch(value))
      return 'Please enter a valid email address';
    return null;
  }

  void _showSuccessDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => ResetSuccessDialog(message: message),
    );
  }
}
