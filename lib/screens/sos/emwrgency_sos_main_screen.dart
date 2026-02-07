import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:remindus/screens/tab/main_tab_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';

import 'package:remindus/generated/assets.dart';
import 'package:remindus/theme/app_colors.dart';
import 'package:remindus/blocs/user/user_bloc.dart';
import 'package:remindus/widgets/contact_title.dart';
import 'package:remindus/widgets/main_header_appbar.dart';
import 'package:remindus/models/emergency_contact_model.dart';
import 'package:remindus/widgets/app_gradient_background.dart';
import 'package:remindus/services/emergency_contact_service.dart';
import 'package:remindus/screens/sos/add_emergency_contact_screen.dart';

class EmergencySOSScreen extends StatefulWidget {
  const EmergencySOSScreen({Key? key}) : super(key: key);

  @override
  State<EmergencySOSScreen> createState() => _EmergencySOSScreenState();
}

class _EmergencySOSScreenState extends State<EmergencySOSScreen>
    with SingleTickerProviderStateMixin {
  bool _showLocationSharing = false;
  late AnimationController _progressController;
  final EmergencyContactService _emergencyContactService =
      EmergencyContactService();

  Stream<List<EmergencyContact>>? _contactsStream;

  List<EmergencyContact> _cachedContacts = [];

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    _progressController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _initiateEmergencyCall();
      }
    });
  }

  String? _lastFamilyId;

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  void _resetButton() {
    setState(() {
      _showLocationSharing = false;
      _progressController.reset();
    });
  }

  void _initiateEmergencyCall() {
    final String phoneNumber = _cachedContacts.isNotEmpty
        ? (_cachedContacts.first.phone ?? "999")
        : "999";
    _makePhoneCall(phoneNumber);
    setState(() {
      _showLocationSharing = true;
    });
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    try {
      await FlutterPhoneDirectCaller.callNumber(phoneNumber);
    } catch (e) {
      debugPrint("Error making direct call: $e");
      // Fallback to url_launcher if direct call fails
      final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
      if (await canLaunchUrl(launchUri)) {
        await launchUrl(launchUri);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;
    final userState = context.watch<UserBloc>().state;
    if (userState is UserLoadedState) {
      if (_lastFamilyId != userState.activeFamilyId ||
          _contactsStream == null) {
        _lastFamilyId = userState.activeFamilyId;
        _contactsStream = _emergencyContactService.getEmergencyContacts(
          _lastFamilyId!,
        );
      }
    } else {}

    final canEdit = userState is UserLoadedState ? userState.isAdmin : false;

    return AppGradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20.0,
                        vertical: 20.0,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          MainHeaderAppBar(
                            onClose: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      MainTabScreen(initialIndex: 3),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 20),
                          _buildHeader(appColors),
                          if (canEdit) ...[
                            const SizedBox(height: 60),
                            Center(child: _buildSOSButton(appColors)),
                            const SizedBox(height: 20),
                            _buildInstructions(appColors),
                          ],
                          _buildContactsSection(appColors),
                        ],
                      ),
                    ),
                  ),
                  if (canEdit) _buildBottomAddButton(appColors),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Sub Widgets ---

  Widget _buildHeader(AppColors appColors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Emergency SOS",
          style: TextStyle(
            fontWeight: FontWeight.w400,
            color: appColors.textPrimary,
            fontSize: 28,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          "Get help when you need it most",
          style: TextStyle(
            fontWeight: FontWeight.w400,
            color: appColors.textPrimary,
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  Widget _buildInstructions(AppColors appColors) {
    if (_showLocationSharing) return const SizedBox.shrink();
    return Center(
      child: Text(
        'Press and hold the button below for\n3 seconds to call for help',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 16.0, color: appColors.textSecondary),
      ),
    );
  }

  Widget _buildContactsSection(AppColors appColors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Emergency Contacts',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w400,
            color: appColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        if (_contactsStream == null)
          const Center(child: CircularProgressIndicator())
        else
          StreamBuilder<List<EmergencyContact>>(
            stream: _contactsStream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20.0),
                    child: CircularProgressIndicator(),
                  ),
                );
              }
              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    "Something went wrong",
                    style: TextStyle(color: appColors.errorRed),
                  ),
                );
              }

              // Cache the contacts for the SOS button to use
              if (snapshot.hasData) {
                _cachedContacts = snapshot.data!;
              }

              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return _buildEmptyState(appColors);
              }

              return Column(
                children: snapshot.data!
                    .map(
                      (contact) => ContactTile(
                        contact: contact,
                        appColors: appColors,
                        onEdit: () => _navigateToEdit(contact),
                        onCall: () => _makePhoneCall(contact.phone ?? ''),
                      ),
                    )
                    .toList(),
              );
            },
          ),
      ],
    );
  }

  Widget _buildEmptyState(AppColors appColors) {
    return Container(
      padding: const EdgeInsets.all(20),
      width: double.infinity,
      decoration: BoxDecoration(
        color: appColors.bgColor.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: appColors.textSecondary.withOpacity(0.2)),
      ),
      child: const Center(child: Text("No emergency contacts added yet.")),
    );
  }

  Widget _buildBottomAddButton(AppColors appColors) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
      width: double.infinity,
      color: Colors.transparent,
      child: ElevatedButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const AddEmergencyContactScreen(),
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: appColors.primary,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: Text(
          'Add Emergency Contact',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: appColors.bgColor,
          ),
        ),
      ),
    );
  }

  void _navigateToEdit(EmergencyContact contact) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            AddEmergencyContactScreen(isEditFlow: true, contact: contact),
      ),
    );
  }

  // --- SOS Button Logic ---
  Widget _buildSOSButton(AppColors appColors) {
    if (_showLocationSharing) {
      // Use cached contacts instead of StreamBuilder to avoid broadcast stream timing issue
      final contacts = _cachedContacts;

      final String displayPhone = contacts.isNotEmpty
          ? (contacts.first.phone ?? "999")
          : "999";
      return Column(
        children: [
          // Ambulance Icon
          _buildCircularIcon(
            appColors.errorRed!,
            Assets.healthAmbulanceIcon,
            appColors.bgColor,
          ),
          const SizedBox(height: 24),
          // Action buttons row
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Call button with phone number
              GestureDetector(
                onTap: () => _makePhoneCall(displayPhone),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFE0E1),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.phone, color: appColors.errorRed, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        displayPhone,
                        style: TextStyle(
                          color: appColors.textMainBtn,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Cancel button
              GestureDetector(
                onTap: _resetButton,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFE0E1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.close,
                    color: appColors.textMainBtn,
                    size: 24,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            'Tap the phone number to call.\nTap X to cancel.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: appColors.textPrimary,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      );
    }

    return GestureDetector(
      onLongPressStart: (_) => _progressController.forward(),
      onLongPressEnd: (_) => _progressController.reverse(),
      child: AnimatedBuilder(
        animation: _progressController,
        builder: (context, child) {
          return Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 155,
                height: 155,
                child: CircularProgressIndicator(
                  value: _progressController.value,
                  strokeWidth: 6,
                  backgroundColor: Colors.red.withOpacity(0.1),
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.red),
                ),
              ),
              _buildCircularIcon(
                _progressController.value > 0
                    ? Colors.red.withOpacity(0.7)
                    : Colors.red,
                Assets.healthAmbulanceIcon,
                appColors.bgColor,
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCircularIcon(Color bgColor, String iconPath, Color iconColor) {
    return Container(
      width: 140,
      height: 140,
      decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
      child: Center(
        child: Image.asset(iconPath, width: 60, height: 60, color: iconColor),
      ),
    );
  }
}
