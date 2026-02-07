import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:remindus/widgets/shimmer_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:remindus/generated/assets.dart';
import 'package:remindus/theme/app_colors.dart';
import 'package:remindus/blocs/user/user_bloc.dart';
import 'package:remindus/models/guardian_model.dart';
import 'package:remindus/widgets/custom_button.dart';
import 'package:remindus/widgets/common-header.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:remindus/widgets/profile/guardian_tile.dart';
import 'package:remindus/widgets/profile/profile_footer.dart';
import 'package:remindus/screens/profile/add_guardian_screen.dart';

class MyProfileScreen extends StatefulWidget {
  const MyProfileScreen({super.key});

  @override
  State<MyProfileScreen> createState() => _MyProfileScreenState();
}

class _MyProfileScreenState extends State<MyProfileScreen> {
  String _version = "";

  @override
  void initState() {
    super.initState();
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    final PackageInfo packageInfo = await PackageInfo.fromPlatform();
    if (mounted) {
      setState(() {
        _version = packageInfo.version;
      });
    }
  }

  Widget _buildFamilySwitcher(BuildContext context) {
    return BlocBuilder<UserBloc, UserState>(
      builder: (context, state) {
        if (state is UserLoadingState) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is UserLoadedState) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 6),
              Text(
                "Click and switch between your guarded members",
                style: TextStyle(
                  fontSize: 14,
                  color: context.appColors.textSecondary,
                ),
              ),
              const SizedBox(height: 16),

              SizedBox(
                height: 100,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: state.joinedFamilies.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(width: 20),
                  itemBuilder: (context, index) {
                    final familyMap = state.joinedFamilies[index];
                    final String id = familyMap['id'];
                    final String name = familyMap['name'];
                    final bool isSelected = id == state.activeFamilyId;
                    return GestureDetector(
                      onTap: () {
                        if (!isSelected) {
                          context.read<UserBloc>().add(
                            SwitchActiveFamilyEvent(familyId: id),
                          );
                        }
                      },
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            padding: EdgeInsets.all(isSelected ? 3 : 0),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSelected
                                    ? Colors.blue
                                    : Colors.transparent,
                                width: 2,
                              ),
                            ),
                            child: CircleAvatar(
                              radius: 28,
                              backgroundColor: isSelected
                                  ? Colors.blue
                                  : Colors.blue.shade100,
                              child: familyMap['profileImageUrl'] != null
                                  ? ShimmerImage(
                                      imageUrl: familyMap['profileImageUrl'],
                                      borderRadius: BorderRadius.circular(28),
                                      width: 56,
                                      height: 56,
                                    )
                                  : Text(
                                      name[0].toUpperCase(),
                                      style: TextStyle(
                                        color: isSelected
                                            ? Colors.white
                                            : Colors.blue.shade700,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                      ),
                                    ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            name[0].toUpperCase() +
                                name.substring(1).toLowerCase(),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: isSelected
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              color: isSelected
                                  ? Colors.blue
                                  : context.appColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        }
        return const SizedBox();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final canEdit = context.select<UserBloc, bool>((bloc) {
      final state = bloc.state;
      if (state is UserLoadedState) {
        return state.isAdmin;
      }
      return false;
    });

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
                                    state.isAppowner
                                        ? 'My Profile'
                                        : "${state.userName}'s Profile",
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
                                state.isAppowner ? 'My Family' : 'Guardian For',
                                style: TextStyle(
                                  fontSize: 20.0,
                                  fontWeight: FontWeight.w400,
                                  color: context.appColors.textPrimary,
                                ),
                              ),

                              _buildFamilySwitcher(context),
                              const SizedBox(height: 10.0),
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
                                phone: state.phone,
                                profileImageUrl: state.profileImageUrl,
                              ),
                              if (_version.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 20.0,
                                  ),
                                  child: Center(
                                    child: Text(
                                      "App Version $_version",
                                      style: TextStyle(
                                        fontSize: 12.0,
                                        color: context.appColors.textSecondary,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ),
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
