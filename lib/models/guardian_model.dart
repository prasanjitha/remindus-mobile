import 'package:equatable/equatable.dart';

class GuardianModel extends Equatable {
  final String? id;
  final String? name;
  final String? email;
  final String? relationship;
  final String? accessLevel;
  final String? profileImageUrl;

  const GuardianModel({
    this.id,
    this.name,
    this.email,
    this.relationship,
    this.accessLevel,
    this.profileImageUrl,
  });

  // Create a copy of the model with updated fields
  GuardianModel copyWith({
    String? id,
    String? name,
    String? email,
    String? relationship,
    String? accessLevel,
    String? checkStatus,
  }) {
    return GuardianModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      relationship: relationship ?? this.relationship,
      accessLevel: accessLevel ?? this.accessLevel,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
    );
  }

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'relationship': relationship,
      'accessLevel': accessLevel,
      'profileImageUrl': profileImageUrl,
    };
  }

  // Create from Firestore Map
  factory GuardianModel.fromMap(Map<String, dynamic> map) {
    return GuardianModel(
      id: map['id'] as String?,
      name: map['name'] as String?,
      email: map['email'] as String?,
      relationship: map['relationship'] as String?,
      accessLevel: map['accessLevel'] as String?,
      profileImageUrl: map['profileImageUrl'] as String?,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    email,
    relationship,
    accessLevel,
    profileImageUrl,
  ];
}
