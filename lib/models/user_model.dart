import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String? uid;
  final String? name;
  final String? email;
  final String? phone;
  final String? familyName;
  final String? activeFamilyId;
  // මෙතන List<dynamic> කරන්න මොකද Firestore එකෙන් එන්නේ Maps list එකක් නිසා
  final List<dynamic>? joinedFamilies;
  final String? accessLevel;
  final Timestamp? createdAt;

  UserModel({
    this.uid,
    this.name,
    this.email,
    this.phone,
    this.familyName,
    this.activeFamilyId,
    this.joinedFamilies,
    this.accessLevel,
    this.createdAt,
  });

  factory UserModel.fromMap(Map<String, dynamic>? map) {
    if (map == null) return UserModel();

    return UserModel(
      uid: map['uid'] as String?,
      name: map['name'] as String?,
      email: map['email'] as String?,
      phone: map['phone'] as String?,
      familyName: map['familyName'] as String?,
      activeFamilyId: map['activeFamilyId'] as String?,
      joinedFamilies: map['joinedFamilies'] as List<dynamic>?,
      accessLevel: map['accessLevel'] as String?,
      createdAt: map['createdAt'] as Timestamp?,
    );
  }
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'phone': phone,
      'familyName': familyName,
      'activeFamilyId': activeFamilyId,
      'joinedFamilies': joinedFamilies,
      'accessLevel': accessLevel,
      'createdAt': createdAt,
    };
  }
}
