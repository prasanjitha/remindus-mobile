part of 'user_bloc.dart';

abstract class UserEvent extends Equatable {
  const UserEvent();

  @override
  List<Object?> get props => [];
}

class LoadUserEvent extends UserEvent {}

class SendInviteEvent extends UserEvent {
  final String email;
  final String activeFamilyId;
  final String curentUserName;
  final String guardianName;

  const SendInviteEvent({
    required this.email,
    required this.activeFamilyId,
    required this.curentUserName,
    required this.guardianName,
  });

  @override
  List<Object?> get props => [
    email,
    activeFamilyId,
    curentUserName,
    guardianName,
  ];
}

class SwitchActiveFamilyEvent extends UserEvent {
  final String familyId;

  const SwitchActiveFamilyEvent({required this.familyId});

  @override
  List<Object?> get props => [familyId];
}

class UpdateGuardianEvent extends UserEvent {
  final String guardianId;
  final GuardianModel updatedGuardianData;
  final String activeFamilyId;

  const UpdateGuardianEvent({
    required this.guardianId,
    required this.updatedGuardianData,
    required this.activeFamilyId,
  });

  @override
  List<Object?> get props => [guardianId, updatedGuardianData, activeFamilyId];
}

class DeleteGuardianEvent extends UserEvent {
  final String guardianId;
  final String activeFamilyId;

  const DeleteGuardianEvent({
    required this.guardianId,
    required this.activeFamilyId,
  });

  @override
  List<Object?> get props => [guardianId, activeFamilyId];
}

class AddNewGuardianEvent extends UserEvent {
  final String guardianName;
  final String guardianEmail;
  final String relationship;
  final String accessLevel;
  final String activeFamilyId;

  const AddNewGuardianEvent({
    required this.guardianName,
    required this.guardianEmail,
    required this.relationship,
    required this.accessLevel,
    required this.activeFamilyId,
  });

  @override
  List<Object?> get props => [
    guardianName,
    guardianEmail,
    relationship,
    accessLevel,
    activeFamilyId,
  ];
}

class UpdateUserProfileEvent extends UserEvent {
  final String name;
  final String phone;
  final String? profileImageUrl;

  const UpdateUserProfileEvent({
    required this.name,
    required this.phone,
    this.profileImageUrl,
  });

  @override
  List<Object?> get props => [name, phone, profileImageUrl];
}

class ChangePasswordEvent extends UserEvent {
  final String currentPassword;
  final String newPassword;

  const ChangePasswordEvent({
    required this.currentPassword,
    required this.newPassword,
  });

  @override
  List<Object?> get props => [currentPassword, newPassword];
}
