import 'dart:developer';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:remindus/blocs/authentication/authentication_bloc.dart';
import 'package:remindus/blocs/user/user_bloc.dart';
import 'package:remindus/generated/assets.dart';
import 'package:remindus/screens/authentication/signup_screen.dart';
import 'package:remindus/screens/forgot-password/forgot_password.dart';
import 'package:remindus/screens/tab/main_tab_screen.dart';
import 'package:remindus/widgets/app_gradient_background.dart';
import 'package:remindus/widgets/app_text_field.dart';
import 'package:remindus/widgets/custom_button.dart';
import 'package:remindus/theme/app_colors.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _submitted = false;
  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();

  final _passwordController = TextEditingController();
  bool _rememberMe = false;

  void _login(BuildContext context) async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    setState(() {
      _submitted = true;
    });

    if (_formKey.currentState!.validate()) {
      context.read<AuthenticationBloc>().add(
        SignInWithEmailAndPasswordEvent(
          email: email,
          password: password,
          rememberMe: _rememberMe,
          justLoggedIn: true,
        ),
      );
    }
  }

  final FirebaseAuth _auth = FirebaseAuth.instance;
  void _loginWithGoogle(BuildContext context) async {
    if (_auth.currentUser == null) {
      context.read<AuthenticationBloc>().add(SignInWithGoogleEvent());
    }
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
                MaterialPageRoute(builder: (context) => const MainTabScreen()),
                (route) => false,
              );
              context.read<UserBloc>().add(LoadUserEvent());
            }
          } else if (state is GoogleSignInSuccessState) {
            context.read<UserBloc>().add(LoadUserEvent());

            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const MainTabScreen()),
              (route) => false,
            );
          } else if (state is ErrorState) {
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
          final isLoading = state is LoadingState;
          final isGoogleLoading = state is GoogleLoadingState;
          return AppGradientBackground(
            child: SingleChildScrollView(
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
                            "Welcome back",
                            style: theme.textTheme.displayLarge,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            "Stay connected with care that matters",
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
                      decoration: BoxDecoration(
                        color: appColors.surfceSecondary,
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        children: [
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
                            label: "Password",
                            hintText: "Enter your password",
                            prefixIconPath: Assets.passwordIcon,
                            isPassword: true,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your password';
                              }
                              if (value.length < 6) {
                                return 'Password must be at least 6 characters';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              SizedBox(
                                height: 24,
                                width: 24,
                                child: Checkbox(
                                  side: BorderSide(
                                    color: appColors.placeholder!,
                                  ),
                                  value: _rememberMe,
                                  onChanged: (value) {
                                    setState(() {
                                      _rememberMe = value ?? false;
                                    });
                                  },
                                  activeColor: appColors.primary,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _rememberMe = !_rememberMe;
                                  });
                                },
                                child: Text(
                                  "Remember me",
                                  style: theme.textTheme.bodyLarge?.copyWith(
                                    color: appColors.textPrimary,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          Align(
                            alignment: Alignment.centerLeft,
                            child: Wrap(
                              alignment: WrapAlignment.start,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                Text(
                                  "Forget your password?",
                                  style: theme.textTheme.bodyLarge?.copyWith(
                                    color: appColors.textPrimary,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(width: 6.0),
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pushReplacement(
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            ForgotPasswordScreen(),
                                      ),
                                    );
                                  },
                                  style: TextButton.styleFrom(
                                    padding: EdgeInsets.zero,
                                    minimumSize: const Size(0, 0),
                                    tapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  child: Text(
                                    "Reset password",
                                    style: theme.textTheme.bodyLarge?.copyWith(
                                      color: context.appColors.primaryDark,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 32),

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
                              text: "Login",
                              onPressed: () => _login(context),
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
                            child: OutlinedButton(
                              onPressed: isLoading
                                  ? null
                                  : () => _loginWithGoogle(context),
                              style: OutlinedButton.styleFrom(
                                backgroundColor: appColors.primaryLight,
                                side: BorderSide.none,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: isGoogleLoading
                                  ? SizedBox(
                                      height: 24,
                                      width: 24,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: appColors.primary,
                                      ),
                                    )
                                  : Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Image.asset(
                                          Assets.googleIcon,
                                          height: 24,
                                          width: 24,
                                        ),
                                        const SizedBox(width: 12),
                                        Text(
                                          "Login with Google",
                                          style: theme.textTheme.labelLarge
                                              ?.copyWith(
                                                color: appColors.textPrimary,
                                                fontWeight: FontWeight.w400,
                                                fontSize: 16.0,
                                              ),
                                        ),
                                      ],
                                    ),
                            ),
                          ),
                          const SizedBox(height: 24),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Wrap(
                                alignment: WrapAlignment.start,
                                crossAxisAlignment: WrapCrossAlignment.start,
                                children: [
                                  Text(
                                    "Don't have an account? ",
                                    style: theme.textTheme.bodyLarge?.copyWith(
                                      fontSize: 14,
                                      color: appColors.textPrimary,
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => SignUpScreen(),
                                        ),
                                      );
                                    },
                                    style: TextButton.styleFrom(
                                      padding: EdgeInsets.zero,
                                      minimumSize: const Size(0, 0),
                                      tapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                    ),
                                    child: Text(
                                      "Create Account",
                                      style: theme.textTheme.bodyLarge
                                          ?.copyWith(
                                            color: appColors.primaryDark,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
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
            ),
          );
        },
      ),
    );
  }
}
