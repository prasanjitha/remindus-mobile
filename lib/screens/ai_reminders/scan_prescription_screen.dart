import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:remindus/generated/assets.dart';
import 'package:remindus/screens/ai_reminders/ai_reminder_review_screen.dart';
import 'package:remindus/screens/tab/main_tab_screen.dart';
import 'package:remindus/theme/app_colors.dart';
import 'package:remindus/widgets/app_gradient_background.dart';
import 'package:remindus/widgets/custom_button.dart';
import 'package:remindus/widgets/main_header_appbar.dart';

class ScanPrescriptionScreen extends StatefulWidget {
  final String activeFamilyId;
  final bool isScan;
  const ScanPrescriptionScreen({
    Key? key,
    required this.activeFamilyId,
    this.isScan = true,
  }) : super(key: key);

  @override
  State<ScanPrescriptionScreen> createState() => _ScanPrescriptionScreenState();
}

class _ScanPrescriptionScreenState extends State<ScanPrescriptionScreen> {
  File? _scannedImage;
  final ImagePicker _picker = ImagePicker();

  // To handle the flow properly, we might want to check permissions or just use picker

  Future<void> _takePhoto() async {
    final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
    if (photo != null) {
      await _cropImage(photo.path);
    }
  }

  Future<void> _chooseFromGallery() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      await _cropImage(image.path);
    }
  }

  Future<void> _cropImage(String path) async {
    final croppedFile = await ImageCropper().cropImage(
      sourcePath: path,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Crop Image',
          toolbarColor: context.appColors.primary,
          toolbarWidgetColor: Colors.white,
          initAspectRatio: CropAspectRatioPreset.original,
          lockAspectRatio: false,
          activeControlsWidgetColor: context.appColors.primary,
        ),
        IOSUiSettings(title: 'Crop Image'),
      ],
    );
    if (croppedFile != null) {
      setState(() {
        _scannedImage = File(croppedFile.path);
      });
    }
  }

  void _onDone() {
    if (_scannedImage != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AiReminderReviewScreen(
            activeFamilyId: widget.activeFamilyId,
            imagePath: _scannedImage!.path,
          ),
        ),
      );
    }
  }

  Widget _buildHeader(AppColors appColors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Scan Prescription",
          style: TextStyle(
            fontWeight: FontWeight.w400,
            color: appColors.textPrimary,
            fontSize: 28,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          "Point camera at your NHS prescription",
          style: TextStyle(
            fontWeight: FontWeight.w400,
            color: appColors.textPrimary,
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;
    return Scaffold(
      backgroundColor: appColors.bgColor,
      body: AppGradientBackground(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 50.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              MainHeaderAppBar(
                onClose: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MainTabScreen(initialIndex: 0),
                    ),
                  );
                },
              ),
              const SizedBox(height: 10),
              _buildHeader(appColors),

              const SizedBox(height: 16),

              const SizedBox(height: 32),

              // Camera Area / Preview
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    widget.isScan == true ? _takePhoto() : _chooseFromGallery();
                  },
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: appColors.bgColor,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: context.appColors.primary!.withOpacity(0.3),
                        width: 2,
                      ),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        if (_scannedImage != null)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(18),
                            child: Image.file(
                              _scannedImage!,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                            ),
                          ),

                        if (_scannedImage == null)
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Image.asset(Assets.scanIcon),
                              const SizedBox(height: 16),
                              Text(
                                widget.isScan == true
                                    ? "Tap to Scan"
                                    : "Tap to Upload",
                                style: TextStyle(
                                  color: appColors.textPrimary,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Buttons
              AppButton(
                text: "Done",
                onPressed: _scannedImage != null ? _onDone : () {},
                backgroundColor: _scannedImage != null
                    ? context.appColors.primary
                    : context.appColors.primary.withOpacity(0.5),
              ),

              const SizedBox(height: 16),

              AppButton(
                text: "Choose from Photos",
                onPressed: _chooseFromGallery,
                backgroundColor: context.appColors.primaryLightBlue,
                textColor: context.appColors.textPrimary,
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
