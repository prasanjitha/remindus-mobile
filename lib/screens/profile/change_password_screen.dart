import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:remindus/blocs/user/user_bloc.dart';
import 'package:remindus/generated/assets.dart';
import 'package:remindus/theme/app_colors.dart';
import 'package:remindus/widgets/app_gradient_background.dart';
import 'package:remindus/widgets/app_text_field.dart';
import 'package:remindus/widgets/custom_button.dart';
import 'package:remindus/widgets/common_header_with_back.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _reEnterNewPasswordController = TextEditingController();

  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureReEnter = true;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _reEnterNewPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.appColors.bgColor,
      body: AppGradientBackground(
        child: SafeArea(
          child: BlocListener<UserBloc, UserState>(
            listener: (context, state) {
              if (state is PasswordChangeSuccessState) {
                context.read<UserBloc>().add(LoadUserEvent());
                Navigator.pop(context);
              } else if (state is UserErrorState) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(state.message)));
              }
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  CommonHeaderWithBack(
                    onMainLogoTap: () => Navigator.pop(context),
                  ),
                  const SizedBox(height: 30),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Change Password",
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w400,
                            color: context.appColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "Make sure it's different from your current password.",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            color: context.appColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 50),
                  AppTextField(
                    label: "Current Password",
                    hintText: "Enter current password",
                    prefixIconPath: Assets.passwordIcon,
                    controller: _currentPasswordController,
                    isPassword: _obscureCurrent,
                    suffixIcon: Icon(
                      _obscureCurrent ? Icons.visibility_off : Icons.visibility,
                      color: context.appColors.placeholder,
                      size: 20,
                    ),

                    onSuffixTap: () {
                      setState(() {
                        _obscureCurrent = !_obscureCurrent;
                      });
                    },
                  ),
                  const SizedBox(height: 20),
                  AppTextField(
                    label: "New Password",
                    hintText: "Enter new password",
                    prefixIconPath: Assets.passwordIcon,
                    controller: _newPasswordController,
                    isPassword: _obscureNew,
                    suffixIcon: Icon(
                      _obscureNew ? Icons.visibility_off : Icons.visibility,
                      color: context.appColors.textPrimary,
                      size: 20,
                    ),
                    onSuffixTap: () {
                      setState(() {
                        _obscureNew = !_obscureNew;
                      });
                    },
                  ),
                  const SizedBox(height: 20),
                  AppTextField(
                    label: "Re-enter New Password",
                    hintText: "Re-enter new password",
                    prefixIconPath: Assets.passwordIcon,
                    controller: _reEnterNewPasswordController,
                    isPassword: _obscureReEnter,
                    suffixIcon: Icon(
                      _obscureReEnter ? Icons.visibility_off : Icons.visibility,
                      color: context.appColors.textPrimary,
                      size: 20,
                    ),
                    onSuffixTap: () {
                      setState(() {
                        _obscureReEnter = !_obscureReEnter;
                      });
                    },
                  ),
                  const Spacer(),
                  BlocBuilder<UserBloc, UserState>(
                    builder: (context, state) {
                      return AppButton(
                        text: "Update",
                        isLoading: state is UserUpdateLoadingState,
                        backgroundColor: context.appColors.primary,
                        onPressed: () {
                          if (_newPasswordController.text !=
                              _reEnterNewPasswordController.text) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Passwords do not match"),
                              ),
                            );
                            return;
                          }
                          context.read<UserBloc>().add(
                            ChangePasswordEvent(
                              currentPassword: _currentPasswordController.text,
                              newPassword: _newPasswordController.text,
                            ),
                          );
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
