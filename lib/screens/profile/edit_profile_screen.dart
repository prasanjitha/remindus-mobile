import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'package:remindus/generated/assets.dart';
import 'package:remindus/theme/app_colors.dart';
import 'package:remindus/blocs/user/user_bloc.dart';
import 'package:remindus/widgets/custom_button.dart';
import 'package:remindus/widgets/shimmer_image.dart';
import 'package:remindus/widgets/app_text_field.dart';
import 'package:remindus/widgets/app_gradient_background.dart';
import 'package:remindus/widgets/common_header_with_back.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  String? _profileImageUrl;
  File? _selectedImage;
  bool _isUploading = false;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();

    final userState = context.read<UserBloc>().state;
    if (userState is UserLoadedState) {
      _nameController.text = userState.userName;
      _emailController.text = userState.email;
      _phoneController.text = userState.phone;
      _profileImageUrl = userState.profileImageUrl;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
    }
  }

  Future<String?> _uploadImage(String uid) async {
    if (_selectedImage == null) return _profileImageUrl;

    setState(() {
      _isUploading = true;
    });

    try {
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('profile_images')
          .child('$uid.jpg');

      await storageRef.putFile(_selectedImage!);
      final downloadUrl = await storageRef.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Image upload failed: $e")));
      return null;
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.appColors.bgColor,
      body: AppGradientBackground(
        child: SafeArea(
          child: BlocListener<UserBloc, UserState>(
            listener: (context, state) {
              if (state is ProfileUpdateSuccessState) {
                context.read<UserBloc>().add(LoadUserEvent());
                Navigator.pop(context);
              } else if (state is UserErrorState) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(state.message)));
              }
            },
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  CommonHeaderWithBack(
                    onMainLogoTap: () => Navigator.pop(context),
                  ),
                  const SizedBox(height: 20),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Edit Profile",
                          style: TextStyle(
                            fontSize: 28.0,
                            fontWeight: FontWeight.w400,
                            color: context.appColors.textPrimary,
                          ),
                        ),
                        const SizedBox(width: 10.0),
                        Text(
                          "Manage your profile information",
                          style: TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.w400,
                            color: context.appColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  GestureDetector(
                    onTap: _pickImage,
                    child: Stack(
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: context.appColors.primary.withOpacity(0.1),
                            border: Border.all(
                              color: context.appColors.primary,
                              width: 2,
                            ),
                          ),
                          child: ClipOval(
                            child: _selectedImage != null
                                ? Image.file(
                                    _selectedImage!,
                                    fit: BoxFit.cover,
                                    width: 100,
                                    height: 100,
                                  )
                                : (_profileImageUrl != null
                                      ? ShimmerImage(
                                          imageUrl: _profileImageUrl!,
                                          width: 100,
                                          height: 100,
                                          fit: BoxFit.cover,
                                        )
                                      : Center(
                                          child: Text(
                                            _nameController.text.isNotEmpty
                                                ? _nameController.text[0]
                                                      .toUpperCase()
                                                : "?",
                                            style: TextStyle(
                                              fontSize: 40,
                                              fontWeight: FontWeight.bold,
                                              color: context.appColors.primary,
                                            ),
                                          ),
                                        )),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: context.appColors.primary,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.camera_alt,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  AppTextField(
                    label: "Name",
                    hintText: "Enter your name",
                    prefixIconPath: Assets.profileIcon,
                    controller: _nameController,
                  ),
                  const SizedBox(height: 20),
                  AppTextField(
                    label: "Email",
                    hintText: "Email address",
                    prefixIconPath: Assets.emailIcon,
                    controller: _emailController,
                    readOnly: true,
                  ),
                  const SizedBox(height: 20),
                  AppTextField(
                    label: "Phone Number",
                    hintText: "Enter your phone number",
                    prefixIconPath: Assets.phoneIcon,
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 50),
                  BlocBuilder<UserBloc, UserState>(
                    builder: (context, state) {
                      return AppButton(
                        text: "Update",
                        isLoading:
                            state is UserUpdateLoadingState || _isUploading,
                        backgroundColor: context.appColors.primary,
                        onPressed: () async {
                          final userState = context.read<UserBloc>().state;
                          if (userState is UserLoadedState) {
                            final imageUrl = await _uploadImage(
                              userState.userId,
                            );
                            if (imageUrl != null || _selectedImage == null) {
                              context.read<UserBloc>().add(
                                UpdateUserProfileEvent(
                                  name: _nameController.text,
                                  phone: _phoneController.text,
                                  profileImageUrl: imageUrl,
                                ),
                              );
                            }
                          }
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
