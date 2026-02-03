import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

abstract class BaseAuthRepositories {
  Future<UserCredential?> signUpWithEmailAndPassword({
    required String name,
    required String email,
    required String password,
  });

  Future<UserCredential?> signInWithEmailAndPassword({
    required String email,
    required String password,
  });

  Future<void> handleAuthentication();

  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required Function(String) onCodeSent,
    required Function(FirebaseAuthException) onFailed,
  });

  Future<UserCredential> signInWithOtp(String verificationId, String smsCode);

  Future<void> resetPassword(String email);

  Future<void> updateProfile({
    required String uid,
    required String name,
    required String phone,
    String? profileImageUrl,
  });

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  });

  Future<void> updateRememberMeStatus({
    required String uid,
    required bool rememberMe,
  });

  Stream<DocumentSnapshot<Map<String, dynamic>>> getUserDataStream(String uid);
}
