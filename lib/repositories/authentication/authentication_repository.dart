import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:remindus/globals.dart';
import 'package:remindus/screens/profile/add_guardian_screen.dart';

import 'base_authentication.dart';

class AuthRepository extends BaseAuthRepositories {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  @override
  Future<UserCredential?> signUpWithEmailAndPassword({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      String uid = userCredential.user!.uid;

      await userCredential.user?.sendEmailVerification();

      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'uid': uid,
        'name': name,
        'email': email,
        'familyName': "$name's Family",
        'activeFamilyId': uid,
        'joinedFamilies': FieldValue.arrayUnion([
          {'id': uid, 'name': "My Account"},
        ]),
        'permissions': AccessLevel.fullControl.name,
        'accessLevel': 'owner',
      });
    } on FirebaseAuthException catch (error) {
      log('SignUp Error: ${error.message}');
    } catch (e) {
      log("Error: $e");
    }
    return null;
  }

  @override
  // In your AuthRepository implementation
  Future<UserCredential?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      return await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      // Map Firebase errors to your CustomException
      String userMessage = "An authentication error occurred.";

      if (e.code == 'user-not-found' ||
          e.code == 'wrong-password' ||
          e.code == 'invalid-credential') {
        userMessage = "The email or password you entered is incorrect.";
      } else if (e.code == 'network-request-failed') {
        userMessage = "Network error. Please check your connection.";
      }

      throw CustomException(
        message: userMessage,
        errorCode: 401,
        functionName: 'signInWithEmailAndPassword',
      );
    } catch (e) {
      throw CustomException(message: e.toString());
    }
  }

  @override
  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required Function(String) onCodeSent,
    required Function(FirebaseAuthException) onFailed,
  }) async {
    log("Code sent to $phoneNumber");
    String cleanPhoneNumber = phoneNumber.replaceAll(' ', '');
    if (cleanPhoneNumber == "+94765567654") {
      String simulatedVerificationId = "simulated_verification_id";
      onCodeSent(simulatedVerificationId);
    } else {
      return Future.error(
        "Phone authentication is not set up for this number.",
      );
    }
    // await FirebaseAuth.instance.verifyPhoneNumber(
    //   phoneNumber: phoneNumber,
    //
    //   verificationCompleted: (PhoneAuthCredential credential) async {
    //     await FirebaseAuth.instance.signInWithCredential(credential);
    //   },
    //   verificationFailed: onFailed,
    //   codeSent: (String verificationId, int? resendToken) {
    //     log("Code sent to $phoneNumber, verificationId: $verificationId");
    //     onCodeSent(verificationId);
    //   },
    //   codeAutoRetrievalTimeout: (String verificationId) {},
    // );
  }

  @override
  Future<UserCredential> signInWithOtp(
    String verificationId,
    String smsCode,
  ) async {
    try {
      final cleanSmsCode = smsCode.replaceAll(' ', '');
      if (cleanSmsCode != "204036") {
        return Future.error("Invalid OTP code.");
      }
      if (verificationId == "simulated_verification_id" &&
          cleanSmsCode == "204036") {
        return null as UserCredential;
      }
      // PhoneAuthCredential credential = PhoneAuthProvider.credential(
      //   verificationId: verificationId,
      //   smsCode: smsCode,
      // );
      // return await FirebaseAuth.instance.signInWithCredential(credential);
      return Future.error(
        "Phone authentication is not set up for this number.",
      );
    } catch (e) {
      return Future.error(e);
    }
  }

  Future<bool> signInWithOtpsmaple(
    String verificationId,
    String smsCode,
  ) async {
    try {
      final cleanSmsCode = smsCode.replaceAll(' ', '');
      if (cleanSmsCode != "204036") {
        return Future.error("Invalid OTP code.");
      }
      if (verificationId == "simulated_verification_id" &&
          cleanSmsCode == "204036") {
        return true;
      }
      // PhoneAuthCredential credential = PhoneAuthProvider.credential(
      //   verificationId: verificationId,
      //   smsCode: smsCode,
      // );
      // return await FirebaseAuth.instance.signInWithCredential(credential);
      return false;
    } catch (e) {
      return Future.error(e);
    }
  }

  Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await _auth.signInWithCredential(
        credential,
      );

      final User? user = userCredential.user;

      if (user == null) return null;

      final String uid = user.uid;
      final String name = user.displayName ?? '';
      final String email = user.email ?? '';

      final DocumentReference userDoc = FirebaseFirestore.instance
          .collection('users')
          .doc(uid);

      final DocumentSnapshot docSnapshot = await userDoc.get();

      if (!docSnapshot.exists) {
        await userDoc.set({
          'uid': uid,
          'name': name,
          'email': email,
          'familyName': "$name's Family",
          'activeFamilyId': uid,
          'joinedFamilies': FieldValue.arrayUnion([
            {'id': uid, 'name': "My Account"},
          ]),
          'accessLevel': 'owner',
          'permissions': AccessLevel.fullControl.name,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      return userCredential;
    } catch (e) {
      return null;
    }
  }

  Future<bool> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
      return true;
    } catch (e) {
      return false;
    }
  }

  // Reset Password
  @override
  Future<void> resetPassword(String email) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
    } catch (e) {
      throw CustomException(message: e.toString());
    }
  }

  @override
  Future<void> handleAuthentication() async {}

  @override
  Future<void> updateProfile({
    required String uid,
    required String name,
    required String phone,
  }) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'name': name,
        'phone': phone,
      });
    } catch (e) {
      throw CustomException(message: e.toString());
    }
  }

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      User? user = _auth.currentUser;
      if (user != null && user.email != null) {
        AuthCredential credential = EmailAuthProvider.credential(
          email: user.email!,
          password: currentPassword,
        );
        await user.reauthenticateWithCredential(credential);
        await user.updatePassword(newPassword);
      } else {
        throw CustomException(message: "User not logged in");
      }
    } on FirebaseAuthException catch (e) {
      throw CustomException(message: e.message ?? "Failed to change password");
    } catch (e) {
      throw CustomException(message: e.toString());
    }
  }
}
