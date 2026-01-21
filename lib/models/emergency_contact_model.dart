import 'package:cloud_firestore/cloud_firestore.dart';

class EmergencyContact {
   String? emergencyContactId;
   String? familyId;
   String? fullName;
   String? relationship;
   String? phone;
   String? email;
   bool? active;
   DateTime? createdAt;
   DateTime? updatedAt;

  EmergencyContact({
    this.emergencyContactId,
    this.familyId,
    this.fullName,
    this.relationship,
    this.phone,
    this.email,
    this.active,
    this.createdAt,
    this.updatedAt,
  });

  
  Map<String, dynamic> toMap() {
    return {
      'emergencyContactId': emergencyContactId,
      'familyId': familyId,
      'fullName': fullName,
      'relationship': relationship,
      'phone': phone,
      'email': email,
      'active': active ?? true, 
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : FieldValue.serverTimestamp(),
    };
  }

  factory EmergencyContact.fromMap(Map<String, dynamic> map, String id) {
    return EmergencyContact(
      emergencyContactId: id,
      familyId: map['familyId'] as String?,
      fullName: map['fullName'] as String?,
      relationship: map['relationship'] as String?,
      phone: map['phone'] as String?,
      email: map['email'] as String?,
      active: map['active'] as bool?,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate(),
    );
  }
}