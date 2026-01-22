import 'package:flutter/material.dart';
import 'food_tracker_camera_sacnner.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:remindus/generated/assets.dart';
import 'package:remindus/theme/app_colors.dart';
import 'package:remindus/blocs/user/user_bloc.dart';
import 'package:remindus/widgets/custom_button.dart';
import 'package:remindus/widgets/main_header_appbar.dart';
import 'package:remindus/helpers/delete_dialog_helper.dart';

// Model Class
class FoodItem {
  final String name;
  final String brand;
  final int calories;
  final String imagePath;

  const FoodItem({
    required this.name,
    required this.brand,
    required this.calories,
    required this.imagePath,
  });
}

class FoodTrackerScreen extends StatefulWidget {
  const FoodTrackerScreen({super.key});

  @override
  State<FoodTrackerScreen> createState() => _FoodTrackerScreenState();
}

class _FoodTrackerScreenState extends State<FoodTrackerScreen> {
  // Date variables for calculation
  late DateTime _startOfToday;
  late DateTime _startOfThisWeek;

  @override
  void initState() {
    super.initState();
    _calculateDateBoundaries();
  }

  void _calculateDateBoundaries() {
    final now = DateTime.now();
    _startOfToday = DateTime(now.year, now.month, now.day);

    // Calculate Monday of the current week
    final daysToSubtract = now.weekday - 1;
    final tempDate = now.subtract(Duration(days: daysToSubtract));
    _startOfThisWeek = DateTime(tempDate.year, tempDate.month, tempDate.day);
  }

  void _openScanner() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const BarcodeScannerScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;

    // Get active ID from Bloc
    final activeFamilyId = context.select<UserBloc, String>((bloc) {
      final state = bloc.state;
      return state is UserLoadedState ? state.isActiveFamilyId : '';
    });

    final isAppOwner = context.select<UserBloc, bool>((bloc) {
      final state = bloc.state;
      return state is UserLoadedState ? state.isAppowner : false;
    });

    return Scaffold(
      backgroundColor: appColors.bgColor,
      bottomNavigationBar: isAppOwner ? _buildBottomBar(appColors) : null,
      body: Stack(
        children: [
          // Background Image Layer
          Positioned.fill(
            child: Image.asset(
              Assets.bgColorMap,
              fit: BoxFit.cover,
              opacity: const AlwaysStoppedAnimation(0.6),
            ),
          ),

          SafeArea(
            child: StreamBuilder<QuerySnapshot>(
              // Optimized: Using a single stream for both cards and list
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(activeFamilyId)
                  .collection('foodScans')
                  .orderBy('scannedAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(child: Text('Error loading data'));
                }

                // Data processing for Calories
                int todayCals = 0;
                int weekCals = 0;
                final List<QueryDocumentSnapshot> docs =
                    snapshot.data?.docs ?? [];

                for (var doc in docs) {
                  final data = doc.data() as Map<String, dynamic>;
                  final int kcal = data['calories'] ?? 0;
                  final Timestamp? ts = data['scannedAt'] as Timestamp?;

                  if (ts != null) {
                    final scanDate = ts.toDate();
                    if (scanDate.isAfter(_startOfThisWeek)) {
                      weekCals += kcal;
                      if (scanDate.isAfter(_startOfToday)) {
                        todayCals += kcal;
                      }
                    }
                  }
                }

                return CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate([
                          const MainHeaderAppBar(),
                          const SizedBox(height: 24),
                          _buildHeader(appColors),
                          const SizedBox(height: 32),
                          _buildCalorieRow(todayCals, weekCals, appColors),
                          const SizedBox(height: 32),
                          _buildRecentTitle(appColors),
                          const SizedBox(height: 16),
                        ]),
                      ),
                    ),

                    // The List Section
                    _buildSliverList(snapshot, docs, isAppOwner),

                    // Extra padding for bottom button
                    const SliverToBoxAdapter(child: SizedBox(height: 100)),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // --- Helper Widgets ---

  Widget _buildHeader(AppColors appColors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Food Tracker",
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w400,
            color: appColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          "Monitor your nutrition intake",
          style: TextStyle(fontSize: 16, color: appColors.textPrimary),
        ),
      ],
    );
  }

  Widget _buildCalorieRow(int today, int week, AppColors appColors) {
    return Row(
      children: [
        Expanded(
          child: CalorieCard(
            iconPath: Assets.calendarTodayIcon,
            label: 'Today',
            calories: today,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: CalorieCard(
            iconPath: Assets.calendarThisWeekIcon,
            label: 'This Week',
            calories: week,
          ),
        ),
      ],
    );
  }

  Widget _buildRecentTitle(AppColors appColors) {
    return Text(
      'Recent Scans',
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w400,
        color: appColors.textPrimary,
      ),
    );
  }

  Widget _buildSliverList(
    AsyncSnapshot<QuerySnapshot> snapshot,
    List<QueryDocumentSnapshot> docs,
  bool isAppOwner,
  ) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const SliverToBoxAdapter(
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (docs.isEmpty) {
      return const SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.only(top: 40),
          child: Center(
            child: Text(
              'No food entries found.',
              style: TextStyle(color: Colors.grey),
            ),
          ),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
          final data = docs[index].data() as Map<String, dynamic>;
          final food = FoodItem(
            name: data['name'] ?? 'Unknown',
            brand: data['brand'] ?? '',
            calories: data['calories'] ?? 0,
            imagePath: data['imageUrl'] ?? '',
          );

          return FoodItemCard(
            isAppOwner: isAppOwner,
            foodItem: food,
            onDelete: () => _confirmDelete(docs[index]),
          );
        }, childCount: docs.length),
      ),
    );
  }

  void _confirmDelete(QueryDocumentSnapshot doc) {
    DialogHelper.showDeleteConfirmation(
      context: context,
      title: "Delete Food Entry?",
      subtitle:
          "This action will permanently delete this food entry.\nAre you sure you want to proceed?",
      onDelete: () async {
        await doc.reference.delete();
        if (mounted) Navigator.of(context).pop();
      },
      dismissDialogTitle: "Deleted",
      dismissDialogSubTitle: "Food entry removed successfully.",
      dismissButtonText: "Back",
      onDeleteSuccess: () {},
    );
  }

  Widget _buildBottomBar(AppColors appColors) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        child: AppButton(
          text: "Open Scanner",
          backgroundColor: appColors.primary,
          onPressed: _openScanner,
        ),
      ),
    );
  }
}

// --- Component Classes ---

class CalorieCard extends StatelessWidget {
  final String iconPath;
  final String label;
  final int calories;

  const CalorieCard({
    super.key,
    required this.iconPath,
    required this.label,
    required this.calories,
  });

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: appColors.bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.asset(
            iconPath,
            width: 24,
            height: 24,
            color: appColors.primary,
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(fontSize: 16, color: appColors.textPrimary),
          ),
          const SizedBox(height: 4),
          Text(
            '$calories kcal',
            style: TextStyle(
              fontSize: 14,
              color: appColors.textSecondary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class FoodItemCard extends StatelessWidget {
  final FoodItem foodItem;
  final VoidCallback onDelete;
  final bool isAppOwner;

  const FoodItemCard({
    super.key,
    required this.foodItem,
    required this.onDelete,
    this.isAppOwner = false,
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
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: foodItem.imagePath.startsWith('http')
                ? Image.network(
                    foodItem.imagePath,
                    width: 54,
                    height: 54,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _buildPlaceholder(),
                    loadingBuilder: (ctx, child, progress) => progress == null
                        ? child
                        : _buildPlaceholder(loading: true),
                  )
                : _buildPlaceholder(),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  foodItem.name,
                  style: TextStyle(
                    fontSize: 16,
                    color: appColors.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      foodItem.brand,
                      style: TextStyle(
                        fontSize: 13,
                        color: appColors.textSecondary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '• ${foodItem.calories} kcal',
                      style: TextStyle(fontSize: 13, color: appColors.primary),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (isAppOwner)
            IconButton(
              onPressed: onDelete,
              icon: Image.asset(
                Assets.deleteIcon,
                width: 20,
                height: 20,
                color: Colors.red.withOpacity(0.7),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPlaceholder({bool loading = false}) {
    return Container(
      width: 54,
      height: 54,
      color: Colors.grey[100],
      child: loading
          ? const Padding(
              padding: EdgeInsets.all(15),
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.fastfood, color: Colors.grey, size: 24),
    );
  }
}
