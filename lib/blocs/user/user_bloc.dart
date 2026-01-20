import 'dart:async';
import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:remindus/models/guardian_model.dart';
import 'package:remindus/repositories/guardian/guardian_repositories.dart';
import 'package:remindus/screens/profile/add_guardian_screen.dart';

part 'user_event.dart';
part 'user_state.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  GuardianRepository guardianRepository;

  UserBloc({
    required FirebaseAuth auth,
    required FirebaseFirestore firestore,
    required this.guardianRepository,
  }) : _auth = auth,
       _firestore = firestore,
       super(UserInitialState()) {
    on<LoadUserEvent>(_onLoadUser);
    on<SwitchActiveFamilyEvent>(_onSwitchFamily);

    // Guardian add kirima handle kirima
    on<AddNewGuardianEvent>(_onAddNewGuardian);

    // Email invitation eka yawima handle kirima
    on<SendInviteEvent>(_onSendInvite);

    on<UpdateGuardianEvent>(_onUpdateGuardian);

    on<DeleteGuardianEvent>(_onDeleteGuardian);
  }

  Future<void> _onDeleteGuardian(
    DeleteGuardianEvent event,
    Emitter<UserState> emit,
  ) async {
    emit(const UserDeleteLoadingState());
    try {
      final bool isDeleted = await guardianRepository.deleteGuardian(
        event.guardianId,
        event.activeFamilyId,
      );
      if (isDeleted) {
        emit(const GuardianDeleteSuccessState());
      } else {
        emit(const UserErrorState("Failed to delete guardian data."));
      }
    } catch (e) {
      emit(UserErrorState(e.toString()));
    }
  }

  Future<void> _onUpdateGuardian(
    UpdateGuardianEvent event,
    Emitter<UserState> emit,
  ) async {
    emit(const UserUpdateLoadingState());
    try {
      final bool isUpdated = await guardianRepository.updateGuardianData(
        event.guardianId,
        event.updatedGuardianData,
        event.activeFamilyId,
      );
      if (isUpdated) {
        emit(const GuardianUpdateSuccessState());
      } else {
        emit(const UserErrorState("Failed to update guardian data."));
      }
    } catch (e) {
      emit(UserErrorState(e.toString()));
    }
  }

  Future<void> _onAddNewGuardian(
    AddNewGuardianEvent event,
    Emitter<UserState> emit,
  ) async {
    emit(const GuardianAddLoadingState());
    try {
      // Repository eken String message ekak return wenna hadanna
      final String successMessage = await guardianRepository.addMember(
        event.guardianEmail,
        event.accessLevel,
        event.guardianName,
        event.relationship,
        event.activeFamilyId,
      );

      emit(
        UserSuccessState(
          message: successMessage,
          guardianName: event.guardianName,
          accessLevel: event.accessLevel,
          relationship: event.relationship,
        ),
      );
      emit(const GuardianAddSuccessState());
    } catch (e) {
      // "USER_NOT_FOUND" throw wunoth special state ekak denawa dialog eka pennanna
      if (e.toString().contains("USER_NOT_FOUND")) {
        emit(UserNotFoundState(event.guardianEmail));
      } else {
        // Anith onaama error ekak (self-add error eka wage) meken yanawa
        emit(UserErrorState(e.toString().replaceAll("Exception: ", "")));
      }
    }
  }

  Future<void> _onSendInvite(
    SendInviteEvent event,
    Emitter<UserState> emit,
  ) async {
    emit(const UserLoadingState());
    try {
      await guardianRepository.sendInviteEmail(
        event.email,
        event.activeFamilyId,
      );
      emit(const InviteSentSuccessState());
    } catch (e) {
      emit(UserErrorState(e.toString()));
    }
  }

 Future<void> _onSwitchFamily(
    SwitchActiveFamilyEvent event,
    Emitter<UserState> emit,
  ) async {
  final user = _auth.currentUser;
  if (user != null) {
    // 1. Loading පෙන්වන්න (මෙතන Loader එක පටන් ගන්නවා)
    emit(const UserLoadingState()); 

    try {
      // 2. Firestore update එක විතරක් කරන්න.
      // Update වුණු ගමන් _onLoadUser එකේ තියෙන snapshots() එක මේක අහු කරගෙන 
      // automatic අලුත් UserLoadedState එකක් emit කරයි.
      await _firestore.collection('users').doc(user.uid).update({
        'activeFamilyId': event.familyId,
      });

      // මෙතන අමුතුවෙන් UserLoadedState එකක් emit කරන්න අවශ්‍ය නැහැ.
      // මොකද forEach එක ඒක කරනවා.
      
    } catch (e) {
      emit(UserErrorState("Failed to switch: ${e.toString()}"));
    }
  }
}

  // Future<void> _onLoadUser(LoadUserEvent event, Emitter<UserState> emit) async {
  //   final user = _auth.currentUser;
  //   if (user == null) {
  //     emit(const UserErrorState('User not logged in'));
  //     return;
  //   }

  //   emit(UserLoadingState());

  //   await emit.forEach<DocumentSnapshot>(
  //     _firestore.collection('users').doc(user.uid).snapshots(),
  //     onData: (doc) {
  //       if (!doc.exists) return const UserErrorState("User data not found");

  //       final data = doc.data() as Map<String, dynamic>? ?? {};
  //       final activeFamilyId = data['activeFamilyId'];
  //       final rawJoinedFamilies =
  //           data['joinedFamilies'] as List<dynamic>? ?? [];
  //       final permissions = data['permissions'];

  //       if (activeFamilyId == null) {
  //         return const UserErrorState('Incomplete family data');
  //       }

  //       // --- Map List එකක් ලෙස දත්ත සකසා ගැනීම ---
  //       final List<Map<String, dynamic>> joinedFamilies = rawJoinedFamilies.map(
  //         (item) {
  //           if (item is Map) {
  //             // අලුත් ක්‍රමය: {'id': '...', 'name': '...'}
  //             return Map<String, dynamic>.from(item);
  //           } else {
  //             // පරණ ක්‍රමය: 'id_string' පමණක් ඇත්නම් (Fallback)
  //             return {
  //               'id': item.toString(),
  //               'name': item.toString() == user.uid
  //                   ? "My Home"
  //                   : "Shared Family",
  //             };
  //           }
  //         },
  //       ).toList();

  //       String role;
  //       if (activeFamilyId == user.uid) {
  //         role = AccessLevel.fullControl.name;
  //       } else {
  //         final perms = Map<String, dynamic>.from(permissions ?? {});
  //         role = perms[activeFamilyId] ?? AccessLevel.viewOnly.name;
  //       }

  //       return UserLoadedState(
  //         userId: user.uid,
  //         activeFamilyId: activeFamilyId,
  //         joinedFamilies: joinedFamilies,
  //         currentUserRole: role,
  //         userName: data['name'] ?? 'No Name',
  //         email: data['email'] ?? 'No Email',
  //         phone: data['phone'] ?? 'No Phone',
  //       );
  //     },
  //     onError: (error, stackTrace) => UserErrorState(error.toString()),
  //   );
  // }
Future<void> _onLoadUser(LoadUserEvent event, Emitter<UserState> emit) async {
  final user = _auth.currentUser;
  if (user == null) {
    log("user not logged in 1");
    emit(const UserErrorState('User not logged in'));
    return;
  }

  emit(const UserLoadingState());

  final userStream = _firestore.collection('users').doc(user.uid).snapshots();

  await emit.forEach<UserLoadedState>(
    userStream.asyncMap((userDoc) async {
      final userData = userDoc.data() as Map<String, dynamic>? ?? {};
      final activeFamilyId = userData['activeFamilyId'] ?? user.uid;
      final rawJoinedFamilies = userData['joinedFamilies'] as List<dynamic>? ?? [];
      final permissions = userData['permissions'] ?? {};

      // Active family details fetch kirima
      final familyDoc = await _firestore.collection('users').doc(activeFamilyId).get();
      final familyData = familyDoc.data() as Map<String, dynamic>? ?? {};

      final List<Map<String, dynamic>> joinedFamilies = rawJoinedFamilies.map((item) {
        if (item is Map) return Map<String, dynamic>.from(item);
        return {
          'id': item.toString(),
          'name': item.toString() == user.uid ? "My Home" : "Shared Family",
        };
      }).toList();

      String role;
      if (activeFamilyId == user.uid) {
        role = AccessLevel.fullControl.name;
      } else {
        final perms = Map<String, dynamic>.from(permissions);
        role = perms[activeFamilyId] ?? AccessLevel.viewOnly.name;
      }

      // Methana State eka return karanawa asyncMap eka athule
      return UserLoadedState(
        userId: user.uid,
        activeFamilyId: activeFamilyId,
        joinedFamilies: joinedFamilies,
        currentUserRole: role,
        userName: familyData['name'] ?? 'No Name',
        email: familyData['email'] ?? 'No Email',
        phone: familyData['phone'] ?? 'No Phone',
      );
    }),
    // FIX: onData eka athule kelinma return karanna, emit use karanna epa
    onData: (loadedState) => loadedState, 
    onError: (error, stackTrace) => UserErrorState(error.toString()),
  );
}
}
