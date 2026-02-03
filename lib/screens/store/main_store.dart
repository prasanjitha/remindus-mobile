import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:remindus/blocs/user/user_bloc.dart';
import 'package:remindus/generated/assets.dart';
import 'package:remindus/screens/store/add_to_store.dart';
import 'package:remindus/theme/app_colors.dart';
import 'package:remindus/widgets/app_gradient_background.dart';
import 'package:remindus/widgets/common-header.dart';
import 'package:remindus/widgets/custom_button.dart';
import 'package:remindus/widgets/medicine_card.dart';
import 'package:remindus/models/medicine_store_model.dart';

class MainStoreScreen extends StatefulWidget {
  final VoidCallback onProfileTap;

  const MainStoreScreen({Key? key, required this.onProfileTap})
    : super(key: key);

  @override
  State<MainStoreScreen> createState() => _MainStoreScreenState();
}

class _MainStoreScreenState extends State<MainStoreScreen> {
  MedicineStatus _getStatusEnum(String? status) {
    switch (status) {
      case 'wellStocked':
        return MedicineStatus.wellStocked;
      case 'lowRemaining':
        return MedicineStatus.lowRemaining;
      case 'refill':
        return MedicineStatus.refill;
      default:
        return MedicineStatus.wellStocked;
    }
  }

  Future<void> _deleteMedicine(String userId, String? docId) async {
    if (docId == null) return;
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('medicinesStore')
        .doc(docId)
        .delete();
  }

  bool canEdit(BuildContext context) {
    return context.select<UserBloc, bool>((bloc) {
      final state = bloc.state;
      if (state is UserLoadedState) {
        return state.isAdmin;
      }
      return false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;
    final activeFamilyId = context.read<UserBloc>().state is UserLoadedState
        ? (context.read<UserBloc>().state as UserLoadedState).activeFamilyId
        : FirebaseAuth.instance.currentUser?.uid;

    return AppGradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SizedBox(
          width: double.infinity,
          height: double.infinity,
          child:
              // 2. Main Content
              activeFamilyId == null
              ? const Center(child: Text("Please Login First"))
              : StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('users')
                      .doc(activeFamilyId)
                      .collection('medicinesStore')
                      .orderBy('createdAt', descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return _buildEmptyState(context, appColors);
                    }
                    List<MedicineStoreModel> allItems = snapshot.data!.docs.map(
                      (doc) {
                        var model = MedicineStoreModel.fromMap(
                          doc.data() as Map<String, dynamic>,
                        );
                        model.medicineStoreId = doc.id;
                        return model;
                      },
                    ).toList();

                    List<MedicineStoreModel> needsAttention = allItems
                        .where(
                          (item) =>
                              (item.status == 'refill' ||
                              item.status == 'lowRemaining'),
                        )
                        .toList();

                    List<MedicineStoreModel> wellStocked = allItems
                        .where((item) => item.status == 'wellStocked')
                        .toList();

                    return SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 30.0, bottom: 100),
                        child: Column(
                          children: [
                            CommonHeader(onProfileTap: widget.onProfileTap),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20.0,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'My Medicines',
                                    style: TextStyle(
                                      fontSize: 28.0,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                  const Text(
                                    'Track and manage your medications',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  const SizedBox(height: 32),

                                  // --- Needs Attention Section ---
                                  if (needsAttention.isNotEmpty) ...[
                                    _buildSectionTitle(
                                      'Needs Attention',
                                      appColors,
                                    ),
                                    const SizedBox(height: 10),
                                    ListView.builder(
                                      shrinkWrap: true,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      itemCount: needsAttention.length,
                                      itemBuilder: (context, index) {
                                        final med = needsAttention[index];
                                        return Builder(
                                          builder: (innerContext) {
                                            final isAdmin = innerContext
                                                .select<UserBloc, bool>((bloc) {
                                                  final state = bloc.state;
                                                  return state
                                                          is UserLoadedState
                                                      ? state.isAdmin
                                                      : false;
                                                });

                                            return MedicineCard(
                                              canEdit: isAdmin,
                                              name: med.name,
                                              detail: med.status == 'refill'
                                                  ? "Stock Empty"
                                                  : "Remaining: ${med.quantity} Tablets",
                                              status: _getStatusEnum(
                                                med.status,
                                              ),
                                              imageUrl: med.imageUrl,
                                              onEdit: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        AddMedicineToStoreScreen(
                                                          medicineStrore: med,
                                                          isEditMode: true,
                                                        ),
                                                  ),
                                                );
                                              },
                                              onDelete: () =>
                                                  _showDeleteConfirmation(
                                                    context,
                                                    med.medicineStoreId!,
                                                    activeFamilyId,
                                                  ),
                                            );
                                          },
                                        );
                                      },
                                    ),
                                    const SizedBox(height: 20),
                                  ],

                                  // --- Well Stocked Section ---
                                  if (wellStocked.isNotEmpty) ...[
                                    _buildSectionTitle(
                                      'Well Stocked',
                                      appColors,
                                    ),
                                    const SizedBox(height: 10),
                                    ListView.builder(
                                      shrinkWrap: true,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      itemCount: wellStocked.length,
                                      itemBuilder: (context, index) {
                                        final med = wellStocked[index];
                                        return Builder(
                                          builder: (innerContext) {
                                            final isAdmin = innerContext
                                                .select<UserBloc, bool>((bloc) {
                                                  final state = bloc.state;
                                                  return state
                                                          is UserLoadedState
                                                      ? state.isAdmin
                                                      : false;
                                                });
                                            return MedicineCard(
                                              canEdit: isAdmin,
                                              name: med.name,
                                              detail:
                                                  "Remaining: ${med.quantity} Tablets",
                                              status:
                                                  MedicineStatus.wellStocked,
                                              imageUrl: med.imageUrl,
                                              onEdit: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        AddMedicineToStoreScreen(
                                                          medicineStrore: med,
                                                          isEditMode: true,
                                                        ),
                                                  ),
                                                );
                                              },
                                              onDelete: () =>
                                                  _showDeleteConfirmation(
                                                    context,
                                                    med.medicineStoreId!,
                                                    activeFamilyId,
                                                  ),
                                            );
                                          },
                                        );
                                      },
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
        bottomNavigationBar: canEdit(context)
            ? Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20.0,
                  vertical: 10.0,
                ),
                child: AppButton(
                  text: 'Add New Medicine',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AddMedicineToStoreScreen(),
                      ),
                    );
                  },
                  backgroundColor: appColors.primary,
                ),
              )
            : const SizedBox.shrink(),
      ),
    );
  }

  Widget _buildSectionTitle(String title, dynamic appColors) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w400,
        color: appColors.textPrimary,
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, dynamic appColors) {
    return Padding(
      padding: const EdgeInsets.only(top: 50.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CommonHeader(),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'My Medicines',
                  style: TextStyle(fontSize: 28.0, fontWeight: FontWeight.w400),
                ),
                Text(
                  'Track and manage your medications',
                  style: TextStyle(
                    fontSize: 16,
                    color: appColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 60),
                Icon(
                  Icons.medication_outlined,
                  size: 36.0,
                  color: appColors.textSecondary.withOpacity(0.3),
                ),
                const SizedBox(height: 16),
                Text(
                  "No medicines added yet.",
                  style: TextStyle(
                    fontSize: 18,
                    color: appColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(
    BuildContext context,
    String reminderId,
    String activeFamilyId,
  ) {
    final screenContext = context;
    final appColors = context.appColors;
    showDialog(
      context: screenContext,
      barrierDismissible: true,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: appColors.bgColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTrashIcon(context),
                const SizedBox(height: 20.0),
                Text(
                  "Delete Medicine?",
                  style: TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.w400,
                    color: appColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12.0),
                Text(
                  "Are you sure you want to delete from your medical store?\n This action cannot be undone.",
                  style: TextStyle(
                    fontSize: 14.0,
                    color: appColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 20.0),
                Row(
                  children: [
                    Expanded(
                      child: AppButton(
                        height: 54,
                        text: "Delete",
                        onPressed: () async {
                          final String docId = reminderId;
                          _deleteMedicine(activeFamilyId, docId);
                          if (Navigator.canPop(dialogContext)) {
                            Navigator.pop(dialogContext);
                          }
                          Future.delayed(const Duration(milliseconds: 10), () {
                            if (screenContext.mounted) {
                              _showSuccessModal(screenContext);
                            }
                          });
                        },

                        backgroundColor: appColors.errorRed,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: AppButton(
                        height: 54,
                        text: "Cancel",
                        textColor: appColors.textPrimary,
                        onPressed: () => Navigator.pop(dialogContext),
                        backgroundColor: appColors.primary.withOpacity(0.2),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showSuccessModal(BuildContext context) {
    final appColors = context.appColors;
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return Dialog(
          backgroundColor: appColors.bgColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTrashIcon(context),
                const SizedBox(height: 20.0),
                Text(
                  "Medicine Deleted",
                  style: TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.w400,
                    color: appColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12.0),
                Text(
                  "Has been removed from your store.",
                  style: TextStyle(
                    fontSize: 14.0,
                    color: appColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 20.0),
                AppButton(
                  text: "Back to Store",
                  onPressed: () => Navigator.pop(context),
                  backgroundColor: appColors.lightRed,
                  textColor: appColors.textPrimary,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTrashIcon(BuildContext context) {
    final colors = context.appColors;
    return Container(
      width: 40.0,
      height: 40.0,
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: colors.lightRed,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Image.asset(
        Assets.deleteIcon,
        width: 24.0,
        height: 24.0,
        color: colors.darkRed,
      ),
    );
  }
}
