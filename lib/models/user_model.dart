import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String? uid;
  final String? name;
  final String? email;
  final String? familyName;
  final String? activeFamilyId;
  final List<String>? joinedFamilies;
  final String? accessType;
  final Timestamp? createdAt;

  UserModel({
    this.uid,
    this.name,
    this.email,
    this.familyName,
    this.activeFamilyId,
    this.joinedFamilies,
    this.accessType,
    this.createdAt,
  });

  factory UserModel.fromMap(Map<String, dynamic>? map) {
    if (map == null) return UserModel();
    return UserModel(
      uid: map['uid'] as String?,
      name: map['name'] as String?,
      email: map['email'] as String?,
      familyName: map['familyName'] as String?,
      activeFamilyId: map['activeFamilyId'] as String?,
      joinedFamilies: map['joinedFamilies'] is List 
          ? List<String>.from(map['joinedFamilies']) 
          : null,
      accessType: map['accessType'] as String?,
      createdAt: map['createdAt'] as Timestamp?,
    );
  }
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'familyName': familyName,
      'activeFamilyId': activeFamilyId,
      'joinedFamilies': joinedFamilies,
      'accessType': accessType,
      'createdAt': createdAt,
    };
  }
}