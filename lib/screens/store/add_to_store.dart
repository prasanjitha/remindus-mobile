import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:remindus/blocs/user/user_bloc.dart';
import 'package:remindus/widgets/shimmer_image.dart';

import 'package:remindus/generated/assets.dart';
import 'package:remindus/theme/app_colors.dart';
import 'package:remindus/widgets/custom_button.dart';
import 'package:remindus/widgets/app_text_field.dart';
import 'package:remindus/helpers/medicine_helper.dart';
import 'package:remindus/models/medicine_store_model.dart';
import 'package:remindus/screens/store/medicine_added_success.dart';
import 'package:remindus/blocs/medicalstore/medical_store_bloc.dart';

class AddMedicineToStoreScreen extends StatefulWidget {
  final MedicineStoreModel? medicineStrore;
  final bool isEditMode;
  const AddMedicineToStoreScreen({
    super.key,
    this.medicineStrore,
    this.isEditMode = false,
  });
  @override
  _AddMedicineToStoreScreenState createState() =>
      _AddMedicineToStoreScreenState();
}

class _AddMedicineToStoreScreenState extends State<AddMedicineToStoreScreen> {
  File? _selectedImage;
  bool _isUploading = false;
  final _picker = ImagePicker();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _qtyController = TextEditingController();

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<String?> _uploadImage(String userId) async {
    if (_selectedImage == null) return null;

    try {
      final fileName =
          '${DateTime.now().millisecondsSinceEpoch}_${_nameController.text.trim().toLowerCase().replaceAll(' ', '')}.jpg';
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('medicine_images')
          .child(userId)
          .child(fileName);

      final uploadTask = await storageRef.putFile(_selectedImage!);
      final downloadUrl = await uploadTask.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      return null;
    }
  }

  // Zoom feature using a Dialog
  void _showZoomedImage() {
    if (_selectedImage == null) return;
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          height: 400,
          child: PhotoView(
            imageProvider: FileImage(_selectedImage!),
            backgroundDecoration: const BoxDecoration(color: Colors.black),
          ),
        ),
      ),
    );
  }

  void _removeImage() {
    setState(() {
      _selectedImage = null;
      _imageUrl = null;
    });
  }

  String? _imageUrl;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (widget.medicineStrore != null && widget.isEditMode) {
      _nameController.text = widget.medicineStrore!.name;
      _qtyController.text = widget.medicineStrore!.quantity;
      _imageUrl = widget.medicineStrore!.imageUrl;
    }
  }

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;
    final activeFamiltId = context.read<UserBloc>().state is UserLoadedState
        ? (context.read<UserBloc>().state as UserLoadedState).activeFamilyId
        : FirebaseAuth.instance.currentUser?.uid;
    return BlocConsumer<MedicalStoreBloc, MedicalStoreState>(
      listener: (context, state) {
        if (state is MedicalStoreErrorState) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage),
              backgroundColor: Colors.redAccent,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      builder: (context, state) {
        final isLoading = state is IsMedicalStoreLoadingState;
        return GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: Scaffold(
            backgroundColor: appColors.bgColor,
            body: SingleChildScrollView(
              padding: const EdgeInsets.only(
                left: 20,
                right: 20,
                top: 50,
                bottom: 20,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Image.asset(Assets.logoIcon, width: 28.0, height: 28.0),

                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(Icons.close, size: 24.0),
                      ),
                    ],
                  ),
                  Text(
                    "Add to Store",
                    style: TextStyle(
                      color: appColors.textPrimary,
                      fontSize: 28,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    "Track a new medication",
                    style: TextStyle(
                      color: appColors.textPrimary,
                      fontSize: 16.0,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 40.0),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Medicine name",
                        style: TextStyle(
                          fontWeight: FontWeight.w400,
                          color: appColors.textPrimary,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Autocomplete<String>(
                        optionsBuilder: (TextEditingValue textEditingValue) {
                          if (textEditingValue.text == '') {
                            return const Iterable<String>.empty();
                          }
                          return MedicineHelper.getSortedSuggestions().where((
                            String option,
                          ) {
                            return option.toLowerCase().contains(
                              textEditingValue.text.toLowerCase(),
                            );
                          });
                        },
                        onSelected: (String selection) {
                          _nameController.text = selection;
                        },

                        fieldViewBuilder:
                            (
                              context,
                              textEditingController,
                              focusNode,
                              onFieldSubmitted,
                            ) {
                              if (_nameController.text.isNotEmpty &&
                                  textEditingController.text.isEmpty) {
                                textEditingController.text =
                                    _nameController.text;
                              }
                              textEditingController.addListener(() {
                                _nameController.text =
                                    textEditingController.text;
                              });

                              return TextField(
                                controller: textEditingController,
                                focusNode: focusNode,
                                decoration: InputDecoration(
                                  hintText: 'Enter Medicine name',
                                  prefixIcon: Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: Image.asset(
                                      Assets.pillsTabletIcon,
                                      width: 20,
                                      height: 20,
                                    ),
                                  ),
                                  filled: true,
                                  fillColor: Colors.white,
                                  contentPadding: const EdgeInsets.symmetric(
                                    vertical: 15,
                                    horizontal: 15,
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: appColors.textSecondary
                                          .withOpacity(0.1),
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: appColors.primary,
                                    ),
                                  ),
                                ),
                              );
                            },
                        optionsViewBuilder: (context, onSelected, options) {
                          return Align(
                            alignment: Alignment.topLeft,
                            child: Material(
                              elevation: 4.0,
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                width: MediaQuery.of(context).size.width - 40,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: ListView.builder(
                                  padding: EdgeInsets.zero,
                                  shrinkWrap: true,
                                  itemCount: options.length,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                        final String option = options.elementAt(
                                          index,
                                        );
                                        return ListTile(
                                          title: Text(option),
                                          onTap: () => onSelected(option),
                                        );
                                      },
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  AppTextField(
                    controller: _qtyController,
                    hintText: 'Number of Tablets',
                    prefixIconPath: Assets.listNumberIcon,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter number of tablets';
                      }
                      return null;
                    },
                    keyboardType: TextInputType.number,
                    isPassword: false,
                    label: "Quantity",
                  ),

                  const SizedBox(height: 30),

                  Container(
                    height: 200,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: appColors.bgColor,
                      border: Border.all(
                        color: appColors.textSecondary.withOpacity(0.1),
                      ),
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child:
                        (_selectedImage == null &&
                            (_imageUrl == null || _imageUrl!.isEmpty))
                        ? GestureDetector(
                            onTap: () {
                              _pickImage(ImageSource.gallery);
                            },
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(
                                  Assets.storeAddPhotoIcon,
                                  width: 40.0,
                                  height: 40.0,
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  "Add Photo",
                                  style: TextStyle(
                                    color: appColors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : Stack(
                            children: [
                              GestureDetector(
                                onTap: _showZoomedImage,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: SizedBox(
                                    width: double.infinity,
                                    height: double.infinity,
                                    child: _selectedImage != null
                                        ? Image.file(
                                            _selectedImage!,
                                            fit: BoxFit.cover,
                                          )
                                        : ShimmerImage(
                                            imageUrl: _imageUrl!,
                                            fit: BoxFit.cover,
                                          ),
                                  ),
                                ),
                              ),

                              Positioned(
                                top: 8,
                                right: 8,
                                child: GestureDetector(
                                  onTap: _removeImage,
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: const BoxDecoration(
                                      color: Colors.redAccent,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.close,
                                      color: Colors.white,
                                      size: 18,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                  ),
                  const SizedBox(height: 15),

                  // Selection Buttons
                  Row(
                    children: [
                      Expanded(
                        child: AppButton(
                          text: "Capture",
                          onPressed: () => _pickImage(ImageSource.camera),
                          backgroundColor: appColors.primary.withOpacity(0.2),
                          textColor: appColors.textPrimary,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: AppButton(
                          text: "Choose from Photos",
                          onPressed: () => _pickImage(ImageSource.gallery),
                          backgroundColor: appColors.primary.withOpacity(0.2),
                          textColor: appColors.textPrimary,
                        ),
                      ),

                      const SizedBox(width: 10),
                    ],
                  ),

                  const SizedBox(height: 40),

                  widget.isEditMode
                      ? AppButton(
                          text: "Update Medicine",
                          isLoading: _isUploading || isLoading,
                          onPressed: () async {
                            FocusScope.of(context).unfocus();

                            // Validation
                            if (_nameController.text.isNotEmpty &&
                                    _qtyController.text.isEmpty ||
                                _nameController.text.isEmpty &&
                                    _qtyController.text.isNotEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    "Please fill ${_nameController.text.isEmpty ? "Medicine Name" : "Quantity"} field",
                                  ),
                                  backgroundColor: Colors.redAccent,
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                              return;
                            }

                            setState(() {
                              _isUploading = true;
                            });

                            String? uploadedUrl;
                            if (_selectedImage != null) {
                              uploadedUrl = await _uploadImage(activeFamiltId!);
                            }

                            int qtyValue =
                                int.tryParse(_qtyController.text.trim()) ?? 0;
                            String finalStatus;

                            switch (qtyValue) {
                              case int n when n <= 0:
                                finalStatus = 'refill';
                                break;
                              case int n when n > 0 && n < 10:
                                finalStatus = 'lowRemaining';
                                break;
                              default:
                                finalStatus = 'wellStocked';
                            }
                            final medicine = MedicineStoreModel(
                              medicineStoreId: widget.isEditMode
                                  ? widget.medicineStrore?.medicineStoreId
                                  : null,
                              name: _nameController.text
                                  .trim()
                                  .toLowerCase()
                                  .replaceAll(' ', ''),
                              quantity: _qtyController.text.trim(),
                              imageUrl: uploadedUrl ?? _imageUrl,
                              status: finalStatus,
                            );

                            if (widget.isEditMode) {
                              context.read<MedicalStoreBloc>().add(
                                UpdateMedicalStoreEvent(
                                  medicine: medicine,
                                  activeFamiltId: activeFamiltId!,
                                ),
                              );
                            }

                            setState(() {
                              _isUploading = false;
                            });

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    MedicineAddedSuccessScreen(
                                      medicine: medicine,
                                    ),
                              ),
                            );
                          },
                          backgroundColor: appColors.primary,
                        )
                      : AppButton(
                          text: "Save Medicine",
                          isLoading: _isUploading || isLoading,
                          onPressed: () async {
                            FocusScope.of(context).unfocus();
                            if (_nameController.text.isNotEmpty &&
                                    _qtyController.text.isEmpty ||
                                _nameController.text.isEmpty &&
                                    _qtyController.text.isNotEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    "Please fill ${_nameController.text.isEmpty ? "Medicine Name" : "Quantity"} field",
                                  ),
                                  backgroundColor: Colors.redAccent,
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                              return;
                            }

                            setState(() {
                              _isUploading = true;
                            });

                            String? uploadedUrl;
                            if (_selectedImage != null) {
                              uploadedUrl = await _uploadImage(activeFamiltId!);
                            }

                            int qtyValue =
                                int.tryParse(_qtyController.text.trim()) ?? 0;
                            String finalStatus;

                            switch (qtyValue) {
                              case int n when n <= 0:
                                finalStatus = 'refill';
                                break;
                              case int n when n > 0 && n < 10:
                                finalStatus = 'lowRemaining';
                                break;
                              default:
                                finalStatus = 'wellStocked';
                            }

                            final medicine = MedicineStoreModel(
                              name: _nameController.text
                                  .trim()
                                  .toLowerCase()
                                  .replaceAll(' ', ''),
                              quantity: _qtyController.text.trim(),
                              imageUrl: uploadedUrl ?? "",
                              status: finalStatus,
                            );
                            context.read<MedicalStoreBloc>().add(
                              AddMedicalStoreEvent(
                                medicineStoreModel: medicine,
                                activeFamiltId: activeFamiltId!,
                              ),
                            );

                            setState(() {
                              _isUploading = false;
                            });

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    MedicineAddedSuccessScreen(
                                      medicine: medicine,
                                    ),
                              ),
                            );
                          },
                          backgroundColor: appColors.primary,
                        ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
