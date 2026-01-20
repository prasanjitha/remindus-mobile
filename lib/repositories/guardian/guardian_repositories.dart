import 'dart:convert';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:remindus/models/guardian_model.dart';

import 'base_guardian_repositories.dart';

class GuardianRepository extends BaseGuardianRepository {
  User? user = FirebaseAuth.instance.currentUser;

  @override
  Future<String> addMember(
    String guardianEmail,
    String selectedAccessLevel,
    String guardianName,
    String relationship,
    String activeFamilyId,
  ) async {
    log("888888888888888888888888888888888888");
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    if (currentUserId == null || currentUserId.isEmpty) {
      throw "User session expired. Please log in again.";
    }
    if (guardianEmail.isEmpty) throw "Email cannot be empty";

    var query = await FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: guardianEmail)
        .get();

    // User innawa nam process karanna
    if (query.docs.isNotEmpty) {
      final currentUserDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUserId)
          .get();

      final activeFamilyValidId = query.docs.first
          .data()['joinedFamilies'][0]['id'];
      if (currentUserDoc.id == currentUserDoc.data()?['activeFamilyId']) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(activeFamilyValidId)
            .update({
              'joinedFamilies': FieldValue.arrayUnion([
                {
                  'id': currentUserDoc.id,
                  'name': currentUserDoc.data()?['familyName'] ?? 'My Account',
                },
              ]),
              'activeFamilyId': activeFamilyId,
              'permissions.$activeFamilyId': selectedAccessLevel,
            });
      } else {
        final activeUserDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(activeFamilyId)
            .get();

        await FirebaseFirestore.instance
            .collection('users')
            .doc(activeFamilyValidId)
            .update({
              'joinedFamilies': FieldValue.arrayUnion([
                {
                  'id': activeFamilyId,
                  'name': activeUserDoc.data()?['familyName'] ?? 'My Account',
                },
              ]),
              'activeFamilyId': activeFamilyId,
              'permissions.$activeFamilyId': selectedAccessLevel,
            });
      }

      return await saveGuardian(
        userId: activeFamilyId,
        guardianName: guardianName,
        guardianEmail: guardianEmail,
        relationship: relationship,
        accessLevel: selectedAccessLevel,
      );
    } else {
      throw "USER_NOT_FOUND";
    }
  }

  // save guardian data to firebase
  Future<String> saveGuardian({
    required String userId,
    required String guardianName,
    required String guardianEmail,
    required String relationship,
    required String accessLevel,
  }) async {
    try {
      final currentUserEmail = FirebaseAuth.instance.currentUser?.email;

      if (currentUserEmail != null &&
          guardianEmail.trim().toLowerCase() ==
              currentUserEmail.trim().toLowerCase()) {
        throw "You cannot add yourself as a guardian";
      }

      log("guarrrrrrrrrrrrrrrrrrrrrrrrrrr userId $userId");

      final guardianCollection = FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('guardians');

      final existingGuardian = await guardianCollection
          .where('email', isEqualTo: guardianEmail.trim())
          .limit(1)
          .get();

      if (existingGuardian.docs.isNotEmpty) {
        final docId = existingGuardian.docs.first.id;
        await guardianCollection.doc(docId).update({
          'name': guardianName,
          'relationship': relationship,
          'accessLevel': accessLevel,
          'updatedAt': FieldValue.serverTimestamp(),
        });
        return "Guardian updated successfully";
      } else {
        final docRef = guardianCollection.doc();
        await docRef.set({
          'guardianId': docRef.id,
          'name': guardianName,
          'email': guardianEmail.trim(),
          'relationship': relationship,
          'accessLevel': accessLevel,
          'createdAt': FieldValue.serverTimestamp(),
        });
        return "New guardian added successfully";
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> sendInviteEmail(
    String receiverEmail,
    String activeFamilyId,
  ) async {
    final url = Uri.parse('https://api.emailjs.com/api/v1.0/email/send');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'service_id': dotenv.env['EMAILJS_SERVICE_ID'],
          'template_id': dotenv.env['EMAILJS_TEMPLATE_ID'],
          'user_id': dotenv.env['EMAILJS_USER_ID'],
          'accessToken': dotenv.env['EMAILJS_ACCESS_TOKEN'],
          'template_params': {
            'to_email': receiverEmail,
            'family_id': activeFamilyId,
          },
        }),
      );

      if (response.statusCode != 200) {
        throw "Failed to send invitation email";
      }
    } catch (e) {
      throw "Email Error: $e";
    }
  }

  Future<bool> updateGuardianData(
    String guardianId,
    GuardianModel updatedGuardianData,
    String activeFamilyId,
  ) async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) throw "User not logged in";

      // 1. Guardian ge document eka update kireema (Current Family path eke)
      final guardianRef = FirebaseFirestore.instance
          .collection('users')
          .doc(activeFamilyId)
          .collection('guardians')
          .doc(guardianId);

      await guardianRef.update(updatedGuardianData.toMap());

      // 2. Guardian (Dependent) ge main user document eke permission eka update kireema
      // Mulauda email eka use karala user wa hoyaganna
      var userQuery = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: updatedGuardianData.email)
          .get();

      if (userQuery.docs.isNotEmpty) {
        String depUid = userQuery.docs.first.id;

        // Permission eka update kireema
        await FirebaseFirestore.instance.collection('users').doc(depUid).update(
          {'permissions.$activeFamilyId': updatedGuardianData.accessLevel},
        );
      }

      return true;
    } catch (e) {
      log("Error updating guardian data & permissions: $e");
      return false;
    }
  }

  @override
  Future<bool> deleteGuardian(String guardianId, String activeFamilyId) async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        throw "User not logged in";
      }
      await FirebaseFirestore.instance
          .collection('users')
          .doc(activeFamilyId)
          .collection('guardians')
          .doc(guardianId)
          .delete();

      return true;
    } catch (e) {
      print("Error deleting guardian: $e");
      return false;
    }
  }
}
