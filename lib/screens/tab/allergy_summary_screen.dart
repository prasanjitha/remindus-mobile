import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:remindus/blocs/user/user_bloc.dart';
import 'package:remindus/generated/assets.dart';
import 'package:remindus/helpers/snackbar_helper.dart';
import 'package:remindus/repositories/reminder/reminder_repository.dart';
import 'package:remindus/screens/tab/watch_connect_now_screen.dart';
import 'package:remindus/screens/tab/watch_connected_screen.dart';
import 'package:remindus/theme/app_colors.dart';
import 'package:remindus/widgets/app_gradient_background.dart';
import 'package:remindus/widgets/custom_button.dart';
import 'package:remindus/widgets/manage_allergies_screen.dart';

class AllergySummaryScreen extends StatefulWidget {
  final Map<String, Set<String>> selectedData;

  const AllergySummaryScreen({super.key, required this.selectedData});

  @override
  State<AllergySummaryScreen> createState() => _AllergySummaryScreenState();
}

class _AllergySummaryScreenState extends State<AllergySummaryScreen> {
  bool _isLoading = false;
  final ReminderRepository _reminderRepository = ReminderRepository();
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
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ManageAllergiesHeader(
                        title: "Manage Allergies",
                        subtitle: "Keep track of what you're allergic to",
                        onBackTap: () => Navigator.of(context).pop(),
                        onCloseTap: () => Navigator.of(context).pop(),
                      ),
                      const SizedBox(height: 40.0),
                      ...widget.selectedData.entries.map((entry) {
                        if (entry.value.isEmpty) return const SizedBox();
                        return _buildSummarySection(
                          entry.key,
                          entry.value.toList(),
                          appColors,
                        );
                      }).toList(),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: AppButton(
                  isLoading: _isLoading,
                  text: 'Update Allergy',
                  onPressed: () async {
                    if (activeFamilyId == null) {
                      SnackbarHelper.showError(
                        context,
                        "No active family found.",
                      );
                      return;
                    }

                    setState(() => _isLoading = true);

                    // 2. Call the repository
                    bool success = await _reminderRepository
                        .updateFamilyHealthData(
                          familyId: activeFamilyId,
                          allergies: widget.selectedData,
                        );

                    setState(() => _isLoading = false);

                    if (success) {
                      SnackbarHelper.showSuccess(
                        context,
                        "Allergies updated successfully!",
                      );
                      if (context.mounted) {
                        Navigator.of(context).pop();
                      }
                    } else {
                      SnackbarHelper.showError(
                        context,
                        "Failed to update allergies.",
                      );
                    }
                  },
                  backgroundColor: appColors.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummarySection(
    String title,
    List<String> items,
    AppColors appColors,
  ) {
    List<Widget> rows = [];
    for (int i = 0; i < items.length; i += 2) {
      bool hasSecond = i + 1 < items.length;

      rows.add(
        Row(
          children: [
            Expanded(child: _buildItemCard(items[i], appColors)),
            if (hasSecond) const SizedBox(width: 10),
            if (hasSecond)
              Expanded(child: _buildItemCard(items[i + 1], appColors)),
          ],
        ),
      );
      rows.add(const SizedBox(height: 10));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "$title Allergies",
          style: TextStyle(fontSize: 20, color: appColors.textPrimary),
        ),
        const SizedBox(height: 12),
        ...rows,
        const SizedBox(height: 14),
      ],
    );
  }

  Widget _buildItemCard(String text, AppColors appColors) {
    return Container(
      height: 50,
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      decoration: BoxDecoration(
        color: appColors.bgColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: appColors.textPrimary.withOpacity(0.1)),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 16,
          color: appColors.textSecondary,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }
}
