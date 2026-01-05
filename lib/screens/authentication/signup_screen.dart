import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:remindus/DummyHome.dart';
import 'package:remindus/blocs/authentication/authentication_bloc.dart';
import 'package:remindus/generated/assets.dart';
import 'package:remindus/home_page.dart';
import 'package:remindus/screens/authentication/siginin_screen.dart';
import 'package:remindus/theme/app_colors.dart';
import 'package:remindus/widgets/app_text_field.dart';
import 'package:remindus/widgets/custom_button.dart';

class SignUpScreen extends StatefulWidget {
  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  bool _submitted = false;
  final _formKey = GlobalKey<FormState>();

  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _showPassword = false;
  bool _showConfirmPassword = false;

  void _signUp() {
    setState(() {
      _submitted = true;
    });
    if (!_formKey.currentState!.validate()) return;

    context.read<AuthenticationBloc>().add(
      SignUpWithEmailAndPasswordEvent(
        name: _firstNameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      ),
    );
  }

  void _loginWithGoogle(BuildContext context) {
    // context.read<AuthenticationBloc>().add(SignInWithGoogleEvent());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final appColors = context.appColors;

    return Scaffold(
      backgroundColor: appColors.bgColor,
      body: BlocConsumer<AuthenticationBloc, AuthenticationState>(
        listener: (context, state) {
          if (state is AuthenticationSuccessState) {
            if (state.isAuthenticated) {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => DummyHome()),
                (route) => false,
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Authentication failed. Please try again."),
                  backgroundColor: Colors.red,
                ),
              );
            }
          } else if (state is ErrorState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.exception.message),
                backgroundColor: appColors.primary,
              ),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is LoadingState;
          return SingleChildScrollView(
            child: Form(
              autovalidateMode: _submitted
                  ? AutovalidateMode.onUserInteraction
                  : AutovalidateMode.disabled,
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 20.0,
                      right: 20.0,
                      top: 50.0,
                      bottom: 20.0,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 48,
                          height: 48,
                          child: Image.asset(Assets.logoIcon),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          "Create Account",
                          style: theme.textTheme.displayLarge,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "Set up your account to connect with essential care.",
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: appColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    height: 2.0,
                    decoration: BoxDecoration(color: appColors.surfceSecondary),
                  ),

                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        AppTextField(
                          controller: _firstNameController,
                          label: "First name",
                          hintText: "Your first name",
                          prefixIconPath: Assets.emailIcon,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your first name';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        AppTextField(
                          controller: _lastNameController,
                          label: "Last name",
                          hintText: "Your last name",
                          prefixIconPath: Assets.profileIcon,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your last name';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        AppTextField(
                          controller: _emailController,
                          label: "Email address",
                          hintText: "Your email address",
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
                        const SizedBox(height: 20),

                        AppTextField(
                          controller: _passwordController,
                          label: "Set password",
                          hintText: "8+ characters required",
                          prefixIconPath: Assets.passwordIcon,
                          isPassword: !_showPassword,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _showPassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                                   color: context.appColors.placeholder!.withOpacity(0.6),
                            ),
                            onPressed: () {
                              setState(() {
                                _showPassword = !_showPassword;
                              });
                            },
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your password';
                            }
                            if (value.length < 8) {
                              return 'Password must be at least 8 characters';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),

                        AppTextField(
                          controller: _confirmPasswordController,
                          label: "Confirm password",
                          hintText: "Confirm your password",
                          prefixIconPath: Assets.passwordIcon,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _showConfirmPassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                                  color: context.appColors.placeholder!.withOpacity(0.6),
                            ),
                            onPressed: () {
                              setState(() {
                                _showConfirmPassword = !_showConfirmPassword;
                              });
                            },
                          ),
                          isPassword: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please confirm your password';
                            }
                            if (value != _passwordController.text) {
                              return 'Passwords do not match';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 28),

                        if (isLoading)
                          Container(
                            height: 56,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: appColors.primary,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const CircularProgressIndicator(
                              color: Colors.white,
                            ),
                          )
                        else
                          AppButton(
                            text: "Create Account",
                            onPressed: () => _signUp(),
                            backgroundColor: appColors.primary,
                          ),
                        const SizedBox(height: 24),

                        Row(
                          children: [
                            Expanded(
                              child: Divider(
                                color: context.appColors.surfceSecondary,
                                thickness: 1,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              child: Text(
                                "or",
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  color: appColors.placeholder,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Divider(
                                color: context.appColors.surfceSecondary,
                                thickness: 1,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: OutlinedButton.icon(
                            onPressed: isLoading
                                ? null
                                : () => _loginWithGoogle(context),
                            icon: Image.asset(
                              Assets.googleIcon,
                              height: 24,
                              width: 24,
                            ),
                            label: Text(
                              "Countinue with Google",
                              style: theme.textTheme.labelLarge?.copyWith(
                                color: appColors.textPrimary,
                                fontWeight: FontWeight.w400,
                                fontSize: 16.0,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              backgroundColor: appColors.primaryLight,
                              side: BorderSide.none,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                   Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                     children: [
                       Wrap(
                         alignment: WrapAlignment.start,
                         crossAxisAlignment: WrapCrossAlignment.center,
                         children: [
                           Text(
                             "Already have an account? ",
                             style: theme.textTheme.bodyLarge?.copyWith(
                               fontSize: 14, 
                               color: appColors.textPrimary,
                             ),
                           ),
                           TextButton(
                             onPressed: () {
                               Navigator.push(
                                 context,
                                 MaterialPageRoute(builder: (context) =>  LoginScreen()),
                               );
                             },
                             style: TextButton.styleFrom(
                               padding: EdgeInsets.zero,
                               minimumSize: const Size(0, 0),
                               tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                             ),
                             child: Text(
                               "Login",
                               style: theme.textTheme.bodyLarge?.copyWith(
                                 color: appColors.primaryDark,
                                 fontSize: 14, 
                                 fontWeight: FontWeight.w600,
                               ),
                             ),
                           ),
                         ],
                       ),
                     ],
                   ),
                      ],
                    ),
                  ),
                   SizedBox(height: Platform.isIOS ? 20 : 0),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
