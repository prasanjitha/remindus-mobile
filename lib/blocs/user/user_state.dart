part of 'user_bloc.dart';

abstract class UserState extends Equatable {
  const UserState();

  @override
  List<Object?> get props => [];
}

class UserInitialState extends UserState {}

class UserLoadingState extends UserState {
  final bool isLoading;
  const UserLoadingState({this.isLoading = true});
  @override
  List<Object?> get props => [isLoading];
}

class UserUpdateLoadingState extends UserState {
  final bool isLoading;
  const UserUpdateLoadingState({this.isLoading = true});
  @override
  List<Object?> get props => [isLoading];
}

class GuardianUpdateSuccessState extends UserState {
  const GuardianUpdateSuccessState();

  @override
  List<Object?> get props => [];
}

class GuardianAddSuccessState extends UserState {
  const GuardianAddSuccessState();

  @override
  List<Object?> get props => [];
}

class GuardianAddLoadingState extends UserState {
  final bool isLoading;
  const GuardianAddLoadingState({this.isLoading = true});
  @override
  List<Object?> get props => [isLoading];
}

class UserDeleteLoadingState extends UserState {
  final bool isLoading;
  const UserDeleteLoadingState({this.isLoading = true});
  @override
  List<Object?> get props => [isLoading];
}

class GuardianDeleteSuccessState extends UserState {
  const GuardianDeleteSuccessState();

  @override
  List<Object?> get props => [];
}

class UserLoadedState extends UserState {
  final String userId;
  final String activeFamilyId;
  final List<Map<String, dynamic>> joinedFamilies;
  final String currentUserRole;
  // Aluth fields
  final String userName;
  final String email;
  final String phone;

  const UserLoadedState({
    required this.userId,
    required this.activeFamilyId,
    required this.joinedFamilies,
    required this.currentUserRole,
    required this.userName,
    required this.email,
    required this.phone,
  });

  bool get isAppowner => userId == activeFamilyId;
  bool get isAdmin => currentUserRole == AccessLevel.fullControl.name;
  String get isActiveFamilyId => activeFamilyId;
  String get getAppOwnerId => userId;

  @override
  List<Object?> get props => [
    userId,
    activeFamilyId,
    joinedFamilies,
    currentUserRole,
    userName,
    email,
    phone,
  ];
}

class IsLoadingState extends UserState {
  final bool isLoading;
  const IsLoadingState({required this.isLoading});

  @override
  List<Object?> get props => [isLoading];
}

class UserSuccessState extends UserState {
  final String message;
  final String guardianName;
  final String accessLevel;
  final String relationship;

  const UserSuccessState({
    required this.message,
    required this.guardianName,
    required this.accessLevel,
    required this.relationship,
  });

  @override
  List<Object?> get props => [message, guardianName, accessLevel, relationship];
}

class UserNotFoundState extends UserState {
  final String email;
  const UserNotFoundState(this.email);
  @override
  List<Object?> get props => [email];
}

class InviteSentSuccessState extends UserState {
  final String message;
  const InviteSentSuccessState({
    this.message = "Invitation sent successfully!",
  });

  @override
  List<Object?> get props => [message];
}

class UserErrorState extends UserState {
  final String message;

  const UserErrorState(this.message);

  @override
  List<Object?> get props => [message];
}
