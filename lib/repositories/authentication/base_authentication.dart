import 'package:firebase_auth/firebase_auth.dart';

abstract class BaseAuthRepositories {
  Future<UserCredential?> signUpWithEmailAndPassword(
      {required String name, required String email, required String password});

  Future<UserCredential?> signInWithEmailAndPassword(
      {required String email, required String password});

  Future<void> handleAuthentication();

  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required Function(String) onCodeSent,
    required Function(FirebaseAuthException) onFailed,
  });

 Future<UserCredential> signInWithOtp(String verificationId, String smsCode);
}
