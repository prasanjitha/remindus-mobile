import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/authentication/authentication_bloc.dart';

class PhoneAuthPage extends StatefulWidget {
  const PhoneAuthPage({super.key});

  @override
  State<PhoneAuthPage> createState() => _PhoneAuthPageState();
}

class _PhoneAuthPageState extends State<PhoneAuthPage> {
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  String _verificationId = "";
  bool _codeSent = false;

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Phone Verification"),
        backgroundColor: Colors.green,
        elevation: 0,
      ),
      body: BlocConsumer<AuthenticationBloc, AuthenticationState>(
        listener: (context, state) {
          if (state is OtpSentState) {
            setState(() {
              _codeSent = true;
              _verificationId = state.verificationId;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("OTP Sent Successfully!")),
            );
          }
          if (state is AuthenticationSuccessState && state.isAuthenticated) {
            Navigator.pushReplacementNamed(context, '/home');
          }
          if (state is ErrorState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.exception.message)),
            );
          }
          if (state is NoInternetConnectionState) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("No Internet Connection!")),
            );
          }
        },
        builder: (context, state) {
          bool isLoading = (state is LoadingState && state.isLoading);

          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(Icons.vibration, size: 80, color: Colors.green),
                const SizedBox(height: 20),
                Text(
                  _codeSent ? "Enter OTP Code" : "Register with Phone",
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Text(
                  _codeSent
                      ? "Enter the 6-digit code sent to your phone"
                      : "Enter your phone number with country code (+94)",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey[600]),
                ),
                const SizedBox(height: 30),

                if (!_codeSent)
                  TextField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      labelText: "Phone Number",
                      hintText: "+947XXXXXXXX",
                      prefixIcon: const Icon(Icons.phone),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  )
                else
                  TextField(
                    controller: _otpController,
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    decoration: InputDecoration(
                      labelText: "OTP Code",
                      hintText: "123456",
                      prefixIcon: const Icon(Icons.lock_outline),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),

                const SizedBox(height: 20),

                ElevatedButton(
                  onPressed: isLoading
                      ? null
                      : () {
                          if (!_codeSent) {
                            context.read<AuthenticationBloc>().add(
                                  SendOtpEvent(phoneNumber: _phoneController.text.trim()),
                                );
                          } else {
                            context.read<AuthenticationBloc>().add(
                                  VerifyOtpEvent(
                                    verificationId: _verificationId,
                                    smsCode: _otpController.text.trim(),
                                  ),
                                );
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : Text(_codeSent ? "Verify & Login" : "Send OTP",
                          style: const TextStyle(fontSize: 16, color: Colors.white)),
                ),

                if (_codeSent && !isLoading)
                  TextButton(
                    onPressed: () => setState(() => _codeSent = false),
                    child: const Text("Change Phone Number"),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}