import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:remindus/blocs/user/user_bloc.dart';
import 'package:remindus/generated/assets.dart';
import 'package:remindus/helpers/delete_dialog_helper.dart';
import 'package:remindus/models/emergency_contact_model.dart';
import 'package:remindus/screens/sos/emwrgency_sos_main_screen.dart';
import 'package:remindus/services/emergency_contact_service.dart';
import 'package:remindus/theme/app_colors.dart';
import 'package:remindus/widgets/app_gradient_background.dart';
import 'package:remindus/widgets/app_text_field.dart';
import 'package:remindus/widgets/custom_button.dart';
import 'package:remindus/widgets/main_header_appbar.dart';

class AddEmergencyContactScreen extends StatefulWidget {
  final bool isEditFlow;
  final EmergencyContact? contact;

  const AddEmergencyContactScreen({
    Key? key,
    this.isEditFlow = false,
    this.contact,
  }) : super(key: key);

  @override
  State<AddEmergencyContactScreen> createState() =>
      _AddEmergencyContactScreenState();
}

class _AddEmergencyContactScreenState extends State<AddEmergencyContactScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  late final TextEditingController _fullNameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _emailController;

  final EmergencyContactService _service = EmergencyContactService();
  bool _isSaving = false;
  String? _selectedRelationship;

  final List<String> _relationships = [
    'Parent',
    'Sibling',
    'Spouse',
    'Child',
    'Friend',
    'Guardian',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    _fullNameController = TextEditingController(text: widget.contact?.fullName);
    _phoneController = TextEditingController(text: widget.contact?.phone);
    _emailController = TextEditingController(text: widget.contact?.email);
    _selectedRelationship = widget.contact?.relationship;
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  // --- Logic Methods ---

  Future<void> _onSavePressed(String activeFamilyId) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    try {
      final contactData = EmergencyContact(
        emergencyContactId: widget.contact?.emergencyContactId,
        familyId: activeFamilyId,
        fullName: _fullNameController.text.trim(),
        relationship: _selectedRelationship,
        phone: _phoneController.text.trim(),
        email: _emailController.text.trim(),
        active: true,
        updatedAt: DateTime.now(),
        createdAt: widget.contact?.createdAt ?? DateTime.now(),
      );

      final success = widget.isEditFlow
          ? await _service.updateEmergencyContact(contactData, activeFamilyId)
          : await _service.addEmergencyContact(contactData, activeFamilyId);

      if (success && mounted) Navigator.pop(context);
    } catch (e) {
      debugPrint("Save Error: $e");
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _onRemovePressed(String activeFamilyId) {
    DialogHelper.showDeleteConfirmation(
      context: context,
      title: "Delete Contact Details?",
      subtitle:
          "This will permanently remove your contact details.\nThis action is permanent.",
      onDelete: () async {
        await _service.deleteEmergencyContact(
          activeFamilyId,
          widget.contact!.emergencyContactId!,
        );
      },
      dismissDialogTitle: "Contact Details Removed",
      dismissDialogSubTitle:
          "The contact details has been successfully removed.",
      dismissButtonText: "  Back to SOS ",
      onDeleteSuccess: () {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const EmergencySOSScreen()),
          (route) => false,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;
    final activeFamilyId = context.select<UserBloc, String?>((bloc) {
      final state = bloc.state;
      return (state is UserLoadedState) ? state.activeFamilyId : null;
    });

    return AppGradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        resizeToAvoidBottomInset: false,
        body: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Stack(
            children: [
              SafeArea(
                child: Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 30),
                              const MainHeaderAppBar(),
                              const SizedBox(height: 20),
                              _buildTitle(appColors),
                              const SizedBox(height: 40),
                              _buildFormFields(appColors),
                            ],
                          ),
                        ),
                      ),
                    ),
                    _buildActionButtons(appColors, activeFamilyId ?? ''),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTitle(AppColors appColors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.isEditFlow ? "Update Contact" : "Add Emergency Contact",
          style: TextStyle(
            fontWeight: FontWeight.w400,
            color: appColors.textPrimary,
            fontSize: 28,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          "Add someone who can help in emergency",
          style: TextStyle(
            fontWeight: FontWeight.w400,
            color: appColors.textPrimary,
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  Widget _buildFormFields(AppColors appColors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppTextField(
          controller: _fullNameController,
          label: "Full Name",
          hintText: "Please enter full name",
          prefixIconPath: Assets.profileIcon,
          validator: (v) =>
              (v == null || v.isEmpty) ? 'Please enter name' : null,
        ),
        const SizedBox(height: 20),
        const Text(
          'Relationship to you',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        _buildRelationshipDropdown(appColors),
        const SizedBox(height: 20),
        AppTextField(
          controller: _phoneController,
          label: "Phone number",
          hintText: 'Add phone number',
          prefixIconPath: Assets.phoneIcon,
          keyboardType: TextInputType.phone,
          validator: (v) =>
              (v == null || v.isEmpty) ? 'Enter phone number' : null,
        ),
        const SizedBox(height: 20),
        AppTextField(
          controller: _emailController,
          label: "Email address",
          hintText: "Add guardian's email",
          prefixIconPath: Assets.emailIcon,
          keyboardType: TextInputType.emailAddress,
          validator: (v) {
            if (v == null || v.isEmpty) return 'Enter email';
            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(v))
              return 'Invalid email';
            return null;
          },
        ),
        const SizedBox(height: 30),
      ],
    );
  }

  Widget _buildRelationshipDropdown(AppColors appColors) {
    return DropdownButtonFormField<String>(
      value: _selectedRelationship,
      decoration: InputDecoration(
        hintText: 'Select Relationship',
        prefixIcon: const Icon(Icons.people_outline),
        filled: true,
        fillColor: appColors.bgColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
      ),
      items: _relationships
          .map((r) => DropdownMenuItem(value: r, child: Text(r)))
          .toList(),
      onChanged: (val) => setState(() => _selectedRelationship = val),
      validator: (val) => (val == null) ? 'Select relationship' : null,
    );
  }

  Widget _buildActionButtons(AppColors appColors, String familyId) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppButton(
            isLoading: _isSaving,
            text: widget.isEditFlow ? 'Update Contact' : 'Save Contact',
            onPressed: () => _onSavePressed(familyId),
            backgroundColor: appColors.primary,
          ),
          if (widget.isEditFlow) ...[
            const SizedBox(height: 12),
            AppButton(
              isLoading: false,
              text: 'Remove Contact',
              onPressed: () => _onRemovePressed(familyId),
              backgroundColor: const Color(0xFFFFE0E1),
              textColor: appColors.textMainBtn,
            ),
          ],
        ],
      ),
    );
  }
}
