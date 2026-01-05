import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'base_authentication.dart';



class AuthRepository extends BaseAuthRepositories {

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  @override
  Future<UserCredential?> signUpWithEmailAndPassword(
      {required String name, required String email, required String password}) async {
        try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: email,
            password: password,
          );

      String uid = userCredential.user!.uid;

      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'uid': uid,
        'name': name,
        'email': email,
        'familyName':
            "$name's Family",
        'activeFamilyId': uid,
        'joinedFamilies': [uid],
        'accessType': 'owner',
      });
    }on FirebaseAuthException catch (error) {
      log('SignUp Error: ${error.message}');
    }
     catch (e) {
      log("Error: $e");
    }
        return null;
  }

  @override
  Future<UserCredential?> signInWithEmailAndPassword(
      {required String email, required String password}) async {
    try {
      final credential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      return credential;
    } on FirebaseAuthException catch (error) {
      log('SignIn Error: ${error.message}');
    } catch (error) {
      rethrow;
    }
    return null;
  }

  @override
  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required Function(String) onCodeSent,
    required Function(FirebaseAuthException) onFailed,
  }) async {
    log( "Code sent to $phoneNumber");
    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) async {
        await FirebaseAuth.instance.signInWithCredential(credential);
      },
      verificationFailed: onFailed,
      codeSent: (String verificationId, int? resendToken) {
        log( "Code sent to $phoneNumber, verificationId: $verificationId");
        onCodeSent(verificationId);
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
  }
  
  @override
  Future<UserCredential> signInWithOtp(String verificationId, String smsCode) async {
    PhoneAuthCredential credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: smsCode,
    );
    return await FirebaseAuth.instance.signInWithCredential(credential);
  }



Future<UserCredential?> signInWithGoogle() async {
  try {
    final GoogleSignInAccount? googleUser =
        await _googleSignIn.signIn();

    if (googleUser == null) return null;

    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final UserCredential userCredential =
        await _auth.signInWithCredential(credential);

    final User? user = userCredential.user;
    log("userCredential: $userCredential");
     log( "user: $user");

    if (user == null) return null;

    final String uid = user.uid;
    final String name = user.displayName ?? '';
    final String email = user.email ?? '';

    final DocumentReference userDoc =
        FirebaseFirestore.instance.collection('users').doc(uid);

    final DocumentSnapshot docSnapshot = await userDoc.get();

    if (!docSnapshot.exists) {
      await userDoc.set({
        'uid': uid,
        'name': name,
        'email': email,
        'familyName': "$name's Family",
        'activeFamilyId': uid,
        'joinedFamilies': [uid],
        'accessType': 'owner',
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


  @override
  Future<void> handleAuthentication() async {
  }
}
