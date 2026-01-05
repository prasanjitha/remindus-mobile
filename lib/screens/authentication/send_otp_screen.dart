import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:remindus/blocs/authentication/authentication_bloc.dart';
import 'package:remindus/generated/assets.dart';
import 'package:remindus/screens/authentication/verify_phone_screen.dart';
import 'package:remindus/theme/app_colors.dart';
import 'package:remindus/widgets/app_text_field.dart';
import 'package:remindus/widgets/custom_button.dart'; // ඔබේ theme එකට අනුව path එක බලන්න
// ඔබ හදා ඇති Widgets මෙහි import කරන්න
// import 'package:your_project/widgets/app_text_field.dart';
// import 'package:your_project/widgets/app_button.dart';

class VerifyPhoneScreen extends StatefulWidget {
  const VerifyPhoneScreen({super.key});

  @override
  State<VerifyPhoneScreen> createState() => _VerifyPhoneScreenState();
}

class _VerifyPhoneScreenState extends State<VerifyPhoneScreen> {
  String _verificationId = "";
  bool _isLoading = false;
  final _phoneController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;
    return Scaffold(
      backgroundColor: appColors.bgColor,
      body: BlocConsumer<AuthenticationBloc, AuthenticationState>(
        listener: (context, state) {
          if (state is OtpSentState) {
            setState(() {
              _verificationId = state.verificationId;
              _isLoading = false;
            });
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    OtpVerificationScreen(verificationId: _verificationId,
                    phoneNumber: _phoneController.text.trim(),
                    ),
              ),
            );
          }
          if (state is LoadingState) {
            setState(() {
              _isLoading = true;
            });
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
          return Padding(
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
                        'Verify Phone Number',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w400,
                          color: appColors.textPrimary,
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
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      Text(
                        "We'll send you a one-time code to confirm your number.",
                        style: TextStyle(
                          fontSize: 16,
                          color: context.appColors.textSecondary,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 32),
                      AppTextField(
                        label: 'Phone number',
                        hintText: '+44',
                        prefixIconPath: Assets.phoneIcon,
                        controller: _phoneController,
                      ),
                      const SizedBox(height: 32),
                      AppButton(
                        isLoading: _isLoading,
                        text: 'Send OTP',
                        textColor: appColors.bgColor,
                        backgroundColor: appColors.primary,
                        onPressed: () {
                          BlocProvider.of<AuthenticationBloc>(context).add(
                            SendOtpEvent(
                              phoneNumber: _phoneController.text.trim(),
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
}
