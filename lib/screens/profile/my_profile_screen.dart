import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:remindus/blocs/user/user_bloc.dart';
import 'package:remindus/generated/assets.dart';
import 'package:remindus/models/guardian_model.dart';
import 'package:remindus/screens/profile/add_guardian_screen.dart';
import 'package:remindus/theme/app_colors.dart';
import 'package:remindus/widgets/common-header.dart';
import 'package:remindus/widgets/custom_button.dart';

import 'package:remindus/widgets/profile/guardian_tile.dart';
import 'package:remindus/widgets/profile/profile_footer.dart';

class MyProfileScreen extends StatefulWidget {
  const MyProfileScreen({super.key});

  @override
  State<MyProfileScreen> createState() => _MyProfileScreenState();
}

class _MyProfileScreenState extends State<MyProfileScreen> {
  @override
  void initState() {
    super.initState();
    // context.read<UserBloc>().add(LoadUserEvent());
  }

  // Widget _buildFamilySwitcher(BuildContext context) {
  //   return BlocBuilder<UserBloc, UserState>(
  //     builder: (context, state) {
  //       log("UserBloc state: ${state.runtimeType}");

  //       if (state is UserLoadingState) {
  //         log("888888888888888888888888888888887777777777777777");
  //         return const Center(child: CircularProgressIndicator());
  //       }

  //       if (state is UserErrorState) {
  //         return Text("Error: ${state.message}");
  //       }

  //       if (state is UserLoadedState) {
  //         return Column(
  //           crossAxisAlignment: CrossAxisAlignment.start,
  //           children: [
  //             const Text(
  //               "Switch Family",
  //               style: TextStyle(fontWeight: FontWeight.bold),
  //             ),
  //             const SizedBox(height: 8),
  //             DropdownButton<String>(
  //               // දැනට active වෙලා තියෙන ID එක තෝරන්න
  //               value: state.activeFamilyId,
  //               isExpanded: true,
  //               items: state.joinedFamilies.map((familyMap) {
  //                 // familyMap කියන්නේ {'id': '...', 'name': '...'}
  //                 final String id = familyMap['id'];
  //                 final String name = familyMap['name'];

  //                 return DropdownMenuItem<String>(
  //                   value: id,
  //                   child: Text(id == state.userId ? "🏠 My Home" : "👥 $name"),
  //                 );
  //               }).toList(),
  //               onChanged: (selectedId) {
  //                 if (selectedId != null &&
  //                     selectedId != state.activeFamilyId) {
  //                       log("lllllllllllllllllllllllllllllllllllllllllll activeFamilyId ${selectedId}");
  //                   context.read<UserBloc>().add(
  //                     SwitchActiveFamilyEvent(familyId: selectedId),
  //                   );
  //                 }
  //               },
  //             ),
  //           ],
  //         );
  //       }

  //       return const SizedBox();
  //     },
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    final canEdit = context.select<UserBloc, bool>((bloc) {
      final state = bloc.state;
      if (state is UserLoadedState) {
        return state.isAdmin;
      }
      return false;
    });

    log("canEdit in MyProfileScreen9999999999999999999999999999999990: $canEdit");

    String activeFamilyId = '';

    final appColors = context.appColors;
    return BlocBuilder<UserBloc, UserState>(
      builder: (context, state) {
        if (state is UserLoadingState || state is UserInitialState) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // State eka UserLoadedState nam witharak oyaage profile content eka pennanna
        if (state is UserLoadedState) {
          activeFamilyId = state.activeFamilyId;
          log("user iD ${state.userId}");
          log("user name ${state.userName}");
          log("activeFamilyId8888888888 ${state.activeFamilyId}");
          return Scaffold(
            backgroundColor: appColors.bgColor,
            body: SizedBox(
              width: double.infinity,
              height: double.infinity,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Image.asset(
                      Assets.bgColorMap,
                      fit: BoxFit.cover,
                      opacity: const AlwaysStoppedAnimation(0.6),
                    ),
                  ),
                  SingleChildScrollView(
                    padding: const EdgeInsets.only(top: 30.0),
                    child: Column(
                      children: [
                        CommonHeader(),
                        // _buildFamilySwitcher(context),
                        const SizedBox(height: 10.0),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Wrap(
                                crossAxisAlignment: WrapCrossAlignment.center,
                                spacing: 4,
                                runSpacing: 2,
                                children: [
                                  Text(
                                    'My Profile',
                                    style: TextStyle(
                                      fontSize: 28.0,
                                      fontWeight: FontWeight.w400,
                                      color: context.appColors.textPrimary,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10.0),
                              Wrap(
                                crossAxisAlignment: WrapCrossAlignment.center,
                                spacing: 4,
                                runSpacing: 2,
                                children: [
                                  Text(
                                    'Your account and connected users',
                                    style: TextStyle(
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.w400,
                                      color: context.appColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 40.0),

                              Text(
                                'Connected Guardians',
                                style: TextStyle(
                                  fontSize: 20.0,
                                  fontWeight: FontWeight.w400,
                                  color: context.appColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 10.0),

                              StreamBuilder<QuerySnapshot>(
                                stream: FirebaseFirestore.instance
                                    .collection('users')
                                    .doc(activeFamilyId)
                                    .collection('guardians')
                                    .orderBy('createdAt', descending: true)
                                    .snapshots(),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return const Center(
                                      child: CircularProgressIndicator(),
                                    );
                                  }

                                  if (!snapshot.hasData ||
                                      snapshot.data!.docs.isEmpty) {
                                    return const Center(
                                      child: Text('No guardians added'),
                                    );
                                  }

                                  final guardians = snapshot.data!.docs;

                                  return ListView.builder(
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    itemCount: guardians.length,
                                    itemBuilder: (context, index) {
                                      return Builder(
                                        builder: (innerContext) {
                                          final data =
                                              guardians[index].data()
                                                  as Map<String, dynamic>;
                                          return GuardianTile(
                                            canEdit: canEdit,
                                            guardianModel: GuardianModel(
                                              id: data['guardianId'],
                                              name: data['name'],
                                              relationship:
                                                  data['relationship'],
                                              accessLevel: data['accessLevel'],
                                              email: data['email'],
                                            ),
                                            checkStatus: "",
                                          );
                                        },
                                      );
                                    },
                                  );
                                },
                              ),

                              const SizedBox(height: 12),
                              if (canEdit)
                                AppButton(
                                  text: 'Add Dependent User',
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const AddGuardianScreen(),
                                      ),
                                    );
                                  },
                                  backgroundColor: appColors.primary,
                                ),
                              const SizedBox(height: 24),

                              ProfileFooter(
                                name: state.userName,
                                email: state.email,
                                phone: '+44 xxxx xxx xx',
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      },
    );
  }
}
