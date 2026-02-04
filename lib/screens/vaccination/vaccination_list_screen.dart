import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:remindus/blocs/user/user_bloc.dart';
import 'package:remindus/blocs/vaccination/vaccination_bloc.dart';
import 'package:remindus/generated/assets.dart';
import 'package:remindus/helpers/snackbar_helper.dart';
import 'package:remindus/models/vaccination_record.dart';
import 'package:remindus/screens/tab/main_tab_screen.dart';
import 'package:remindus/screens/vaccination/add_edit_vaccination_screen.dart';
import 'package:remindus/theme/app_colors.dart';
import 'package:remindus/widgets/custom_button.dart';
import 'package:remindus/helpers/custom_dialog_helpers.dart';
import 'package:remindus/services/permission_service.dart';
import 'package:remindus/widgets/dialog/notification_permission_dialog.dart';
import 'package:intl/intl.dart';
import 'package:remindus/widgets/main_header_appbar.dart';
import 'package:remindus/widgets/app_gradient_background.dart';

class VaccinationListScreen extends StatefulWidget {
  static const String routeName = '/vaccination-list';

  const VaccinationListScreen({super.key});

  @override
  State<VaccinationListScreen> createState() => _VaccinationListScreenState();
}

class _VaccinationListScreenState extends State<VaccinationListScreen> {
  @override
  void initState() {
    super.initState();
    _loadVaccinations();
  }

  void _loadVaccinations() {
    final userState = context.read<UserBloc>().state;
    if (userState is UserLoadedState) {
      context.read<VaccinationBloc>().add(
        LoadVaccinationsEvent(userState.activeFamilyId),
      );
    }
  }

  Widget _buildHeader(AppColors appColors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Immunizations",
          style: TextStyle(
            fontWeight: FontWeight.w400,
            color: appColors.textPrimary,
            fontSize: 28,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          "Manage your vaccination records",
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
    final canEdit = context.select<UserBloc, bool>((userBloc) {
      return userBloc.state is UserLoadedState
          ? (userBloc.state as UserLoadedState).currentUserRole == "fullControl"
          : false;
    });
    return Scaffold(
      backgroundColor: appColors.bgColor,
      body: AppGradientBackground(
        child: BlocListener<VaccinationBloc, VaccinationState>(
          listener: (context, state) {
            if (state is VaccinationError) {
              SnackbarHelper.showError(context, state.message);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const VaccinationListScreen(),
                ),
              );
            } else if (state is VaccinationOperationSuccess) {}
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 20.0,
              vertical: 50.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MainHeaderAppBar(
                  onClose: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MainTabScreen(initialIndex: 3),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),
                _buildHeader(appColors),

                const SizedBox(height: 16),
                Expanded(
                  child: BlocBuilder<VaccinationBloc, VaccinationState>(
                    builder: (context, state) {
                      if (state is VaccinationLoading) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (state is VaccinationLoaded) {
                        if (state.records.isEmpty) {
                          return Center(
                            child: Text(
                              "No vaccination records found.",
                              style: TextStyle(color: appColors.textSecondary),
                            ),
                          );
                        }
                        return ListView.separated(
                          physics: const BouncingScrollPhysics(),
                          itemCount: state.records.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final record = state.records[index];
                            return _buildVaccinationCard(
                              context,
                              record,
                              appColors,
                              canEdit,
                            );
                          },
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BlocBuilder<UserBloc, UserState>(
        builder: (context, userState) {
          bool showAddButton = false;
          if (userState is UserLoadedState) {
            showAddButton = userState.currentUserRole == 'fullControl';
          }

          if (!showAddButton) return const SizedBox.shrink();

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: AppButton(
              text: "Add New Vaccination Record",
              onPressed: () async {
                bool allowed = await PermissionService()
                    .checkNotificationPermission();
                if (allowed) {
                  if (context.mounted) {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AddEditVaccinationScreen(),
                      ),
                    );
                    if (context.mounted) _loadVaccinations();
                  }
                } else {
                  if (context.mounted) {
                    NotificationPermissionDialog.show(
                      context,
                      onAllowed: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const AddEditVaccinationScreen(),
                          ),
                        );
                        if (context.mounted) _loadVaccinations();
                      },
                    );
                  }
                }
              },
              backgroundColor: appColors.primary,
            ),
          );
        },
      ),
    );
  }

  Widget _buildVaccinationCard(
    BuildContext context,
    VaccinationRecord record,
    AppColors appColors,
    bool canEdit,
  ) {
    // Format dates
    final lastDate = record.dateReceived != null
        ? DateFormat('MMM d, yyyy').format(record.dateReceived!)
        : 'N/A';
    final nextDate = record.nextDoseDue != null
        ? DateFormat('MMM d, yyyy').format(record.nextDoseDue!)
        : 'N/A';

    return GestureDetector(
      onTap: canEdit
          ? () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      AddEditVaccinationScreen(record: record),
                ),
              );
              if (context.mounted) _loadVaccinations();
            }
          : null,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: appColors.bgColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: appColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Image.asset(
                Assets.vaccinationO1Icon,
                height: 24,
                width: 24,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                // Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        record.vaccineName ?? "Unknown Vaccine",
                        style: TextStyle(
                          color: appColors.textPrimary,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Last: $lastDate",
                            style: TextStyle(
                              color: appColors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            "Next due: $nextDate",
                            style: TextStyle(
                              color: appColors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
