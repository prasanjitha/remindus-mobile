import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:remindus/generated/assets.dart';
import 'package:remindus/helpers/snackbar_helper.dart';
import 'package:remindus/theme/app_colors.dart';
import 'package:remindus/blocs/user/user_bloc.dart';
import 'package:remindus/widgets/custom_button.dart';
import 'package:remindus/widgets/main_header_appbar.dart';
import 'package:remindus/screens/food-tacker/food_tracker_home_screen.dart';
import 'package:remindus/widgets/shimmer_image.dart';

// ScannedFood Model
class ScannedFood {
  final String name;
  final String brand;
  final int calories;
  final double carbs;
  final double protein;
  final double fat;
  final String imageUrl;

  ScannedFood({
    required this.name,
    required this.brand,
    required this.calories,
    required this.carbs,
    required this.protein,
    required this.fat,
    required this.imageUrl,
  });
}

class BarcodeScannerScreen extends StatefulWidget {
  const BarcodeScannerScreen({super.key});

  @override
  State<BarcodeScannerScreen> createState() => _BarcodeScannerScreenState();
}

class _BarcodeScannerScreenState extends State<BarcodeScannerScreen> {
  bool _isScanning = true;
  bool _isLoading = false;
  bool _isTorchOn = false;
  MobileScannerController cameraController = MobileScannerController();
  FoodItem? scannedFoodItem;

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }

  Future<void> _getProductInfo(String barcode, String activeFamilyId) async {
    setState(() {
      _isScanning = false;
      _isLoading = true;
    });

    final url = Uri.parse(
      'https://world.openfoodfacts.org/api/v0/product/$barcode.json',
    );

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['status'] == 1) {
          final product = data['product'];
          String name = product['product_name'] ?? 'Unknown Product';
          String brand = product['brands'] ?? 'Unknown Brand';
          var kcal = product['nutriments']?['energy-kcal_100g'] ?? 0;
          var carbs = product['nutriments']?['carbohydrates_100g'] ?? 0;
          var protein = product['nutriments']?['proteins_100g'] ?? 0;
          var fat = product['nutriments']?['fat_100g'] ?? 0;

          String imageUrl =
              product['image_front_url'] ??
              product['image_url'] ??
              'https://via.placeholder.com/150';

          final result = ScannedFood(
            name: name,
            brand: brand,
            calories: kcal.toInt(),
            carbs: carbs.toDouble(),
            protein: protein.toDouble(),
            fat: fat.toDouble(),
            imageUrl: imageUrl,
          );

          if (mounted) {
            setState(() {
              scannedFoodItem = FoodItem(
                name: name,
                brand: brand,
                calories: kcal.toInt(),
                carbs: carbs.toDouble(),
                protein: protein.toDouble(),
                fat: fat.toDouble(),
                imagePath: imageUrl,
              );
            });
            _saveToFirebase(result, activeFamilyId);
          }
        } else {
          _showError("Product not found in database.");
        }
      } else {
        _showError("Server error. Try again.");
      }
    } catch (e) {
      _showError("Network error. Check your internet.");
    } finally {
      setState(() {
        _isScanning = true;
        _isLoading = false;
      });
    }
  }

  Future<void> _saveToFirebase(ScannedFood food, String activeFamilyId) async {
    try {
      if (activeFamilyId != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(activeFamilyId)
            .collection('foodScans')
            .add({
              'name': food.name,
              'brand': food.brand,
              'calories': food.calories,
              'carbs': food.carbs,
              'protein': food.protein,
              'fat': food.fat,
              'imageUrl': food.imageUrl,
              'scannedAt': FieldValue.serverTimestamp(),
            });

        if (mounted) {
          SnackbarHelper.showSuccess(context, "Data saved successfully!");
        }
      } else {
        _showError("User not logged in.");
      }
    } catch (e) {
      _showError("Error saving data: $e");
    }
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 2),
        ),
      );
    }
    setState(() {
      _isScanning = true;
      _isLoading = false;
    });
  }

  Widget _buildHeader(AppColors appColors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Add Nutrition Information",
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w400,
            color: appColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          "Point your camera at the barcode",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: appColors.textPrimary,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;
    final isActiveFamilyId = context.select<UserBloc, String>((bloc) {
      final state = bloc.state;
      return state is UserLoadedState ? state.isActiveFamilyId : '';
    });

    return Scaffold(
      backgroundColor: appColors.bgColor,
      body: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: Stack(
          children: [
            // Background Image
            Positioned.fill(
              child: Image.asset(
                Assets.bgColorMap,
                fit: BoxFit.cover,
                opacity: const AlwaysStoppedAnimation(0.6),
              ),
            ),

            // Use SingleChildScrollView here
            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20.0,
                  vertical: 50.0,
                ),
                child: Column(
                  children: [
                    const MainHeaderAppBar(),
                    const SizedBox(height: 24),
                    _buildHeader(appColors),
                    const SizedBox(height: 40),

                    // Removed "Expanded" - replaced with a fixed height container for the scanner
                    if (scannedFoodItem == null)
                      SizedBox(
                        height: 400.0, // This keeps the scanner area consistent
                        child: Stack(
                          children: [
                            if (!_isLoading)
                              ClipRRect(
                                // Added to keep the camera view rounded/clean
                                borderRadius: BorderRadius.circular(16),
                                child: MobileScanner(
                                  controller: cameraController,
                                  onDetect: (capture) {
                                    if (!_isScanning || _isLoading) return;
                                    final List<Barcode> barcodes =
                                        capture.barcodes;
                                    for (final barcode in barcodes) {
                                      if (barcode.rawValue != null) {
                                        _getProductInfo(
                                          barcode.rawValue!,
                                          isActiveFamilyId,
                                        );
                                        break;
                                      }
                                    }
                                  },
                                ),
                              ),

                            // Loading state
                            if (_isLoading)
                              Container(
                                decoration: BoxDecoration(
                                  color: appColors.bgColor,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Center(
                                  child: CircularProgressIndicator(
                                    color: appColors.primary,
                                  ),
                                ),
                              ),

                            // Scanner Overlay Content
                            if (!_isLoading)
                              Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      width: 80,
                                      height: 80,
                                      decoration: BoxDecoration(
                                        color: const Color(
                                          0xFFE8F5E9,
                                        ).withOpacity(0.8),
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: const Icon(
                                        Icons.qr_code_scanner,
                                        size: 48,
                                        color: Color(0xFF4CAF50),
                                      ),
                                    ),
                                    const SizedBox(height: 24),
                                    Text(
                                      'Scan Your Food',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Scan the barcode for nutrition info',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.white70,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                            // Torch Button
                            if (!_isLoading)
                              Positioned(
                                top: 20,
                                right: 20,
                                child: IconButton(
                                  onPressed: () async {
                                    await cameraController.toggleTorch();
                                    setState(() => _isTorchOn = !_isTorchOn);
                                  },
                                  icon: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.9),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      _isTorchOn
                                          ? Icons.flash_on
                                          : Icons.flash_off,
                                      color: _isTorchOn
                                          ? Colors.amber
                                          : Colors.grey,
                                      size: 24,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),

                    // Scanned result area
                    if (scannedFoodItem != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 20),
                        child: FoodItemCard(
                          foodItem: scannedFoodItem!,
                          onDelete: () {},
                        ),
                      ),

                    // Bottom spacing to ensure items aren't cut off when scrolling
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(
          left: 20.0,
          right: 20.0,
          bottom: 20.0,
          top: 10.0,
        ),
        child: AppButton(
          text: scannedFoodItem != null ? "Done" : "Scan Barcode",
          backgroundColor: appColors.primary,
          onPressed: () {
            if (_isLoading) return;
            Navigator.pop(context);
          },
        ),
      ),
    );
  }
}

class FoodItemCard extends StatelessWidget {
  final FoodItem foodItem;
  final VoidCallback onDelete;

  const FoodItemCard({
    super.key,
    required this.foodItem,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: appColors.bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          ShimmerImage(
            imageUrl: foodItem.imagePath,
            width: 54,
            height: 54,
            borderRadius: BorderRadius.circular(16),
            errorWidget: Container(
              width: 54,
              height: 54,
              color: Colors.grey[200],
              child: const Icon(Icons.fastfood, color: Colors.grey),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  foodItem.name,
                  style: TextStyle(fontSize: 18, color: appColors.textPrimary),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      foodItem.brand,
                      style: TextStyle(
                        fontSize: 14,
                        color: appColors.textSecondary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '• ${foodItem.calories} kcal',
                      style: TextStyle(fontSize: 14, color: appColors.primary),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 8,
                  runSpacing: 12,
                  children: [
                    _buildNutritionChip(
                      label: 'Carbs',
                      value: '${foodItem.carbs.toStringAsFixed(1)}g',
                      color: Colors.orange,
                    ),
                    _buildNutritionChip(
                      label: 'Protein',
                      value: '${foodItem.protein.toStringAsFixed(1)}g',
                      color: Colors.blue,
                    ),
                    _buildNutritionChip(
                      label: 'Fat',
                      value: '${foodItem.fat.toStringAsFixed(1)}g',
                      color: Colors.red,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNutritionChip({
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        '$label: $value',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: color,
        ),
      ),
    );
  }
}
