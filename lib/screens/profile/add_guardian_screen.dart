import 'dart:convert';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:remindus/blocs/user/user_bloc.dart';

import 'package:remindus/generated/assets.dart';
import 'package:remindus/helpers/delete_dialog_helper.dart';
import 'package:remindus/models/guardian_model.dart';
import 'package:remindus/screens/profile/add_guardient_success_screen.dart';
import 'package:remindus/theme/app_colors.dart';
import 'package:remindus/widgets/custom_button.dart';
import 'package:remindus/widgets/app_text_field.dart';
import 'package:remindus/widgets/main_header_appbar.dart';
import 'package:remindus/helpers/relationship_helpers.dart';

enum AccessLevel { viewOnly, fullControl }

class AddGuardianScreen extends StatefulWidget {
  final GuardianModel? guardianModel;
  final bool? isEditFlow;
  const AddGuardianScreen({
    super.key,
    this.guardianModel,
    this.isEditFlow = false,
  });

  @override
  State<AddGuardianScreen> createState() => _AddGuardianScreenState();
}

class _AddGuardianScreenState extends State<AddGuardianScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  String? selectedRelationship;
  String? selectedAccessLevel;
  String? activeFamilyId;
  User? user = FirebaseAuth.instance.currentUser;
  String currentUserRole = AccessLevel.viewOnly.name;
  List joinedFamilies = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (widget.isEditFlow == true && widget.guardianModel != null) {
      log("Editing Guardian: ${widget.guardianModel!.email}");
      nameController.text = widget.guardianModel!.name ?? '';
      emailController.text = widget.guardianModel!.email ?? '';
      selectedRelationship = widget.guardianModel!.relationship;
      selectedAccessLevel = widget.guardianModel!.accessLevel;
    }
  }

  // Future<void> _addMember(String dependentUser, String depPermission) async {
  //   setState(() {
  //     _isLoading = true;
  //   });
  //   String email = dependentUser;
  //   if (email.isEmpty) return;

  //   var query = await FirebaseFirestore.instance
  //       .collection('users')
  //       .where('email', isEqualTo: email)
  //       .get();

  //   final currentUserDoc = await FirebaseFirestore.instance
  //       .collection('users')
  //       .doc(user?.uid)
  //       .get();

  //   final currentFamilyName = currentUserDoc.data()?['familyName'] ?? 'Unknown';

  //   if (query.docs.isNotEmpty) {
  //     String depUid = query.docs.first.id;

  //     if (activeFamilyId == null) {
  //       final userState = context.read<UserBloc>().state;
  //       if (userState is UserLoadedState) {
  //         activeFamilyId = userState.activeFamilyId;
  //       } else {
  //         log("Active family ID is null and user state is not loaded.");
  //         setState(() {
  //           _isLoading = false;
  //         });
  //         return;
  //       }
  //     }

  //     await FirebaseFirestore.instance.collection('users').doc(depUid).update({
  //       'joinedFamilies': FieldValue.arrayUnion([
  //         {'id': activeFamilyId, 'name': currentFamilyName},
  //       ]),
  //       'activeFamilyId': activeFamilyId,
  //       'permissions.$activeFamilyId': depPermission,
  //     });
  //     await saveGuardian(
  //       userId: user!.uid,
  //       guardianName: nameController.text.trim(),
  //       guardianEmail: emailController.text.trim(),
  //       relationship: selectedRelationship!,
  //       accessLevel: selectedAccessLevel!,
  //     );
  //     if (mounted) {
  //       setState(() {
  //         _isLoading = false;
  //       });

  //       // need to send email notification to the added member
  //       // sendInviteEmail(email);
  //     }
  //   } else {
  //     _showInviteDialog(email);
  //   }
  // }

  // --- EmailJS Invite ---
  // Future<void> sendInviteEmail(String receiverEmail) async {
  //   final url = Uri.parse('https://api.emailjs.com/api/v1.0/email/send');
  //   try {
  //     await http.post(
  //       url,
  //       headers: {'Content-Type': 'application/json'},
  //       body: json.encode({
  //         'service_id': dotenv.env['EMAILJS_SERVICE_ID'],
  //         'template_id': dotenv.env['EMAILJS_TEMPLATE_ID'],
  //         'user_id': dotenv.env['EMAILJS_USER_ID'],
  //         'accessToken': dotenv.env['EMAILJS_ACCESS_TOKEN'],
  //         'template_params': {
  //           'to_email': receiverEmail,
  //           'family_id': activeFamilyId,
  //         },
  //       }),
  //     );
  //   } catch (e) {
  //     log("Email Error: $e");
  //   }
  // }

  // void _showInviteDialog(String email) {
  //   showDialog(
  //     context: context,
  //     builder: (context) => AlertDialog(
  //       backgroundColor: context.appColors.bgColor,
  //       title: const Text("User Not Found"),
  //       content: Text("$email is not on RemindUs. Send invitation?"),
  //       actions: [
  //         TextButton(
  //           onPressed: () {
  //             Navigator.pop(context);
  //             setState(() {
  //               _isLoading = false;
  //             });
  //           },
  //           child: const Text("No"),
  //         ),
  //         ElevatedButton(
  //           onPressed: () {
  //             Navigator.pop(context);
  //             sendInviteEmail(email);
  //           },
  //           child: const Text("Invite"),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  // // save guardient data to firebase
  // Future<void> saveGuardian({
  //   required String userId,
  //   required String guardianName,
  //   required String guardianEmail,
  //   required String relationship,
  //   required String accessLevel,
  // }) async {
  //   try {
  //     final currentUserEmail = FirebaseAuth.instance.currentUser?.email;

  //     if (currentUserEmail != null &&
  //         guardianEmail.trim().toLowerCase() ==
  //             currentUserEmail.trim().toLowerCase()) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(
  //           content: Text(
  //             "You cannot add yourself as a guardian",
  //             style: TextStyle(color: Colors.white, fontSize: 14.0),
  //           ),
  //           backgroundColor: Colors.redAccent,
  //           behavior: SnackBarBehavior.floating,
  //         ),
  //       );
  //       return;
  //     }

  //     final guardianCollection = FirebaseFirestore.instance
  //         .collection('users')
  //         .doc(userId)
  //         .collection('guardians');

  //     final existingGuardian = await guardianCollection
  //         .where('email', isEqualTo: guardianEmail.trim())
  //         .limit(1)
  //         .get();

  //     if (existingGuardian.docs.isNotEmpty) {
  //       final docId = existingGuardian.docs.first.id;
  //       await guardianCollection.doc(docId).update({
  //         'name': guardianName,
  //         'relationship': relationship,
  //         'accessLevel': accessLevel,
  //         'updatedAt': FieldValue.serverTimestamp(),
  //       });
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(
  //           content: Text(
  //             "Guardian updated successfully",
  //             style: TextStyle(color: Colors.white, fontSize: 14.0),
  //           ),
  //           backgroundColor: Colors.green,
  //           behavior: SnackBarBehavior.floating,
  //         ),
  //       );
  //       Navigator.of(context).pushReplacement(
  //         MaterialPageRoute(
  //           builder: (context) => AddGuardientSuccessScreen(
  //             guardianName: nameController.text.trim(),
  //             accessLevel: selectedAccessLevel!,
  //             relationship: selectedRelationship!,
  //           ),
  //         ),
  //       );
  //     } else {
  //       final docRef = guardianCollection.doc();
  //       await docRef.set({
  //         'guardianId': docRef.id,
  //         'name': guardianName,
  //         'email': guardianEmail.trim(),
  //         'relationship': relationship,
  //         'accessLevel': accessLevel,
  //         'createdAt': FieldValue.serverTimestamp(),
  //       });
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(
  //           content: Text(
  //             "New guardian added successfully",
  //             style: TextStyle(color: Colors.white, fontSize: 14.0),
  //           ),
  //           backgroundColor: Colors.green,
  //           behavior: SnackBarBehavior.floating,
  //         ),
  //       );
  //       Navigator.of(context).pushReplacement(
  //         MaterialPageRoute(
  //           builder: (context) => AddGuardientSuccessScreen(
  //             guardianName: nameController.text.trim(),
  //             accessLevel: selectedAccessLevel!,
  //             relationship: selectedRelationship!,
  //           ),
  //         ),
  //       );
  //     }
  //   } catch (e) {
  //     rethrow;
  //   }
  // }

  void _showInviteDialog(BuildContext context, String email) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text("User Not Found"),
        content: Text("$email is not on the app. Send invitation?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<UserBloc>().add(
                SendInviteEvent(email: email, activeFamilyId: activeFamilyId!),
              );
            },
            child: const Text("Invite"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;
    log("Current Selected Level in Build111111111: $selectedAccessLevel");
    return Scaffold(
      backgroundColor: appColors.bgColor,
      body: BlocConsumer<UserBloc, UserState>(
        listener: (context, state) {
          if (state is UserErrorState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.redAccent,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }

          if (state is UserSuccessState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
              ),
            );
            context.read<UserBloc>().add(LoadUserEvent());
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => AddGuardientSuccessScreen(
                  guardianModel: GuardianModel(
                    name: state.guardianName,
                    relationship: state.relationship,
                    accessLevel: state.accessLevel,
                  ),
                ),
              ),
            );
          }

          if (state is GuardianUpdateSuccessState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("Guardian details updated successfully!"),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
              ),
            );
            context.read<UserBloc>().add(LoadUserEvent());
          }

          if (state is UserDeleteLoadingState) {
            // ScaffoldMessenger.of(context).showSnackBar(
            //   SnackBar(
            //     content: Text(
            //       "Deleting guardian...",
            //       style: TextStyle(color: appColors.bgColor),
            //     ),
            //     backgroundColor: appColors.errorRed,
            //     behavior: SnackBarBehavior.floating,
            //   ),
            // );

            context.read<UserBloc>().add(LoadUserEvent());
          }

          if (state is UserNotFoundState) {
            _showInviteDialog(context, state.email);
          }

          if (state is InviteSentSuccessState) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Invitation sent successfully!"),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
              ),
            );
            Navigator.of(context).popUntil((route) => route.isFirst);
          }
        },
        builder: (context, state) {
          if (state is UserLoadedState) {
            activeFamilyId = state.activeFamilyId;
            log("Active Family ID in Add Guardian Screen: $activeFamilyId");
          }
          return GestureDetector(
            onTap: () {
              FocusScope.of(context).unfocus();
            },
            child: SafeArea(
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
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20.0,
                      vertical: 16.0,
                    ),
                    child: Form(
                      key: _formKey,
                      autovalidateMode: AutovalidateMode.disabled,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          MainHeaderAppBar(
                            onClose: () {
                              Navigator.of(context).pop();
                            },
                          ),
                          const SizedBox(height: 20.0),

                          Text(
                            "Add Guardian",
                            style: TextStyle(
                              fontWeight: FontWeight.w400,
                              color: appColors.textPrimary,
                              fontSize: 28.0,
                            ),
                          ),
                          const SizedBox(height: 8.0),
                          Text(
                            "Invite someone to help manage your health",
                            style: TextStyle(
                              fontWeight: FontWeight.w400,
                              color: appColors.textSecondary,
                              fontSize: 16.0,
                            ),
                          ),
                          const SizedBox(height: 32),
                          AppTextField(
                            controller: nameController,
                            hintText: 'Add guardian\'s name',
                            prefixIconPath: Assets.profileIcon,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter a name';
                              }
                              return null;
                            },
                            isPassword: false,

                            label: "Guardian's name",
                          ),
                          const SizedBox(height: 20.0),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: DropdownButtonFormField<String>(
                              dropdownColor: appColors.bgColor,
                              value: selectedRelationship,
                              borderRadius: BorderRadius.circular(12),
                              decoration: InputDecoration(
                                hintText: 'Select relationship',
                                filled: true,
                                fillColor: appColors.bgColor,
                                prefixIcon: Icon(Icons.people_outline),

                                // suffixIcon: Icon(Icons.arrow_forward_ios_outlined),
                                border: InputBorder.none,
                              ),
                              items: RelationshipHelper.getAll().map((
                                relation,
                              ) {
                                return DropdownMenuItem<String>(
                                  value: relation,
                                  child: Text(relation),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  selectedRelationship = value;
                                });
                              },
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please select a relationship';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(height: 20.0),
                          AppTextField(
                            controller: emailController,
                            hintText: 'Add guardian\'s email',
                            prefixIconPath: Assets.emailIcon,
                            label: "Email address",
                            isPassword: false,

                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please enter an email address';
                              }

                              final emailRegex = RegExp(
                                r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
                              );

                              if (!emailRegex.hasMatch(value.trim())) {
                                return 'Please enter a valid email address';
                              }

                              return null;
                            },
                          ),

                          const SizedBox(height: 40.0),

                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Select Access Level',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  accessLevelCard(
                                    context: context,
                                    isSelected:
                                        selectedAccessLevel ==
                                        AccessLevel.viewOnly.name,
                                    iconPath: Assets.quickActionKeyIcon,
                                    title: 'View Only',
                                    subtitle: 'Cannot modify items',
                                    onTap: () {
                                      setState(() {
                                        selectedAccessLevel =
                                            AccessLevel.viewOnly.name;
                                       
                                      });
                                    },
                                  ),
                                  const SizedBox(width: 12),
                                  accessLevelCard(
                                    context: context,
                                    isSelected:
                                        selectedAccessLevel ==
                                        AccessLevel.fullControl.name,
                                    iconPath: Assets.quickActionEyeIcon,
                                    title: 'Full Control',
                                    subtitle: 'Add, edit, or delete items',
                                    onTap: () {
                                      log(  "Full Control Selected");
                                      setState(() {
                                        selectedAccessLevel =
                                            AccessLevel.fullControl.name;
    log("Current Selected Level in 22222222222222: $selectedAccessLevel");

                                      });
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),

                          Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: appColors.lightRed,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: EdgeInsets.all(12.0),
                            child: Row(
                              children: [
                                Image.asset(
                                  Assets.warningIcon,
                                  width: 24,
                                  height: 24,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    "Only one person can manage medication reminders at a time.",
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                      color: appColors.textSecondary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 32),
                          state is GuardianAddLoadingState ||
                                  state is UserUpdateLoadingState
                              ? Container(
                                  height: 56.0,
                                  width: double.infinity,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: appColors.primary,
                                    borderRadius: BorderRadius.circular(12.0),
                                  ),

                                  child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      appColors.bgColor,
                                    ),
                                  ),
                                )
                              : AppButton(
                                  text: widget.isEditFlow == true
                                      ? "Update Guardian Details"
                                      : "Add Guardian",
                                  onPressed: () {
                                    // 1. Validation (දෙකටම පොදුයි)
                                    final isFormValid =
                                        _formKey.currentState?.validate() ??
                                        false;
                                    if (!isFormValid) return;

                                    if (selectedAccessLevel == null) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            "Please select an access level",
                                          ),
                                          backgroundColor: Colors.redAccent,
                                          behavior: SnackBarBehavior.floating,
                                        ),
                                      );
                                      return;
                                    }

                                    // 2. Edit Flow ද නැද්ද කියලා මෙතනදී චෙක් කරන්න
                                    if (widget.isEditFlow == true) {
                                      log(
                                        "Updating Guardian Details... ${widget.guardianModel!.id}",
                                      );
                                      log(
                                        "Updating Guardian Details... ${widget.guardianModel!.name}",
                                      );
                                      log(
                                        "Updating Guardian Details... ${widget.guardianModel!.email}",
                                      );
                                      log(
                                        "Updating Guardian Details... ${widget.guardianModel!.relationship}",
                                      );
                                      log(
                                        "Updating Guardian Details... ${widget.guardianModel!.accessLevel}",
                                      );
                                      log(
                                        "Updating Guardian Details... ${activeFamilyId}",
                                      );
                                      log("Selected Access Level: $selectedAccessLevel");
                                      // Update Logic
                                      context.read<UserBloc>().add(
                                        UpdateGuardianEvent(
                                          updatedGuardianData: GuardianModel(
                                            id: widget.guardianModel!.id,
                                            name: nameController.text.trim(),
                                            email: emailController.text.trim(),
                                            relationship: selectedRelationship!,
                                            accessLevel: selectedAccessLevel!,
                                          ),
                                          activeFamilyId: activeFamilyId ?? '',
                                          guardianId: widget.guardianModel!.id!,
                                        ),
                                      );
                                    } else {
                                      // Add Logic
                                      context.read<UserBloc>().add(
                                        AddNewGuardianEvent(
                                          guardianEmail: emailController.text
                                              .trim(),
                                          guardianName: nameController.text
                                              .trim(),
                                          relationship: selectedRelationship!,
                                          accessLevel: selectedAccessLevel!,
                                          activeFamilyId: activeFamilyId ?? '',
                                        ),
                                      );
                                    }
                                  },
                                  backgroundColor: appColors.primary,
                                ),
                          const SizedBox(height: 10.0),
                          if (widget.isEditFlow == true)
                            state is UserDeleteLoadingState
                                ? Container(
                                    height: 56.0,
                                    width: double.infinity,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: appColors.errorRed,
                                      borderRadius: BorderRadius.circular(12.0),
                                    ),

                                    child: CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        appColors.bgColor,
                                      ),
                                    ),
                                  )
                                : AppButton(
                                    text: "Delete Guardian",
                                    onPressed: () {
                                      // Delete Logic

                                      DialogHelper.showDeleteConfirmation(
                                        context: context,
                                        title: "Remove Guardian?",
                                        subtitle:
                                            "This guardian will no longer have access to this family account.",
                                        onDelete: () {
                                          context.read<UserBloc>().add(
                                            DeleteGuardianEvent(
                                              guardianId:
                                                  widget.guardianModel!.id!,
                                              activeFamilyId:
                                                  activeFamilyId ?? '',
                                            ),
                                          );
                                        },
                                        dismissDialogTitle: "Guardian Removed",
                                        dismissDialogSubTitle:
                                            "The guardian profile has been successfully removed from your account.",
                                        dismissButtonText: "Back to Profile",
                                        onDeleteSuccess: () {
                                          context.read<UserBloc>().add(
                                            LoadUserEvent(),
                                          );

                                          Navigator.of(
                                            context,
                                          ).popUntil((route) => route.isFirst);
                                        },
                                      );
                                    },
                                    backgroundColor: appColors.errorRed,
                                    textColor: appColors.bgColor,
                                  ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget accessLevelCard({
    required bool isSelected,
    required String iconPath,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required BuildContext context,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(minHeight: 140),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isSelected
                ? context.appColors.primary.withOpacity(0.16)
                : context.appColors.bgColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: isSelected
                      ? context.appColors.primary
                      : context.appColors.textSecondary.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Image.asset(
                  iconPath,
                  width: 32,
                  height: 32,
                  color: isSelected
                      ? context.appColors.bgColor
                      : context.appColors.primary,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: context.appColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: context.appColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
