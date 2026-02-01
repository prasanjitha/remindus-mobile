import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:remindus/blocs/user/user_bloc.dart';
import 'package:remindus/generated/assets.dart';
import 'package:remindus/theme/app_colors.dart';
import 'package:remindus/widgets/app_gradient_background.dart';
import 'package:remindus/widgets/app_text_field.dart';
import 'package:remindus/widgets/custom_button.dart';
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
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
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
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  CommonHeaderWithBack(
                    onMainLogoTap: () => Navigator.pop(context),
                  ),
                  const SizedBox(height: 30),
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
                  const SizedBox(height: 50),
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
                  const Spacer(),
                  BlocBuilder<UserBloc, UserState>(
                    builder: (context, state) {
                      return AppButton(
                        text: "Update",
                        isLoading: state is UserUpdateLoadingState,
                        backgroundColor: context.appColors.primary,
                        onPressed: () {
                          context.read<UserBloc>().add(
                            UpdateUserProfileEvent(
                              name: _nameController.text,
                              phone: _phoneController.text,
                            ),
                          );
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
