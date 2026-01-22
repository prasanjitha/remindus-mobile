import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:remindus/blocs/user/user_bloc.dart';
import 'package:remindus/generated/assets.dart';
import 'package:remindus/models/emergency_contact_model.dart';
import 'package:remindus/screens/sos/add_emergency_contact_screen.dart';
import 'package:remindus/services/emergency_contact_service.dart';
import 'package:remindus/theme/app_colors.dart';
import 'package:remindus/widgets/contact_title.dart';
import 'package:remindus/widgets/main_header_appbar.dart';
import 'package:url_launcher/url_launcher.dart';

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

  // Stream එක variable එකකට ගැනීමෙන් අනවශ්‍ය rebuilds වළකී (Best Practice)
  Stream<List<EmergencyContact>>? _contactsStream;

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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userState = context.read<UserBloc>().state;
      if (userState is UserLoadedState) {
        setState(() {
          _contactsStream = _emergencyContactService.getEmergencyContacts(
            userState.activeFamilyId,
          );
        });
      }
    });
  }

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
    setState(() {
      _showLocationSharing = true;
    });
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
    try {
      if (await canLaunchUrl(launchUri)) {
        await launchUrl(launchUri);
      } else {
        log("Could not launch $phoneNumber");
      }
    } catch (e) {
      log("Error launching call: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;
    final canEdit = context.select<UserBloc, bool>((bloc) {
      final state = bloc.state;
      return state is UserLoadedState ? state.isAdmin : false;
    });
    return Scaffold(
      backgroundColor: appColors.bgColor,
      body: Stack(
        children: [
          // 1. Background Layer
          Positioned.fill(
            child: Image.asset(
              Assets.bgColorMap,
              fit: BoxFit.cover,
              opacity: const AlwaysStoppedAnimation(0.6),
            ),
          ),

          // 2. Main UI Layer
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
                        const MainHeaderAppBar(),
                        const SizedBox(height: 20),
                        _buildHeader(appColors),
                        if (canEdit) ...[
                          const SizedBox(height: 60),
                          Center(child: _buildSOSButton(appColors)),
                          const SizedBox(height: 20),
                          _buildInstructions(appColors),
                        ],
                        const SizedBox(height: 50),
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
        border: Border.all(color: appColors.textSecondary!.withOpacity(0.2)),
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
      return Column(
        children: [
          SizedBox(
            width: 250,
            height: 140,
            child: Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: [
                _buildCircularIcon(
                  appColors.errorRed!,
                  Assets.healthAmbulanceIcon,
                  appColors.bgColor!,
                ),
                Positioned(
                  right: 0,
                  child: _buildSmallActionButton(
                    Icons.close,
                    const Color(0xFFFFE0E1),
                    appColors.textPrimary!,
                    _resetButton,
                  ),
                ),
                Positioned(
                  left: -20,
                  child: _buildSmallActionButton(
                    null,
                    const Color(0xFFFFE0E1),
                    appColors.textPrimary!,
                    () => _makePhoneCall("999"),
                    label: "999",
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'To stop sharing your location with listed\naccounts, click the \'x\' button on the right.',
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
                appColors.bgColor!,
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

  Widget _buildSmallActionButton(
    IconData? icon,
    Color bgColor,
    Color contentColor,
    VoidCallback onTap, {
    String? label,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
        child: icon != null
            ? Icon(icon, color: contentColor, size: 24)
            : Text(
                label!,
                style: TextStyle(
                  color: contentColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
              ),
      ),
    );
  }
}
