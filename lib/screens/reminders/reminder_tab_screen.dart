import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:remindus/blocs/user/user_bloc.dart';
import 'package:remindus/generated/assets.dart';
import 'package:remindus/models/base_reminder_model.dart';
import 'package:remindus/screens/reminders/add_reminder_screen.dart';
import 'package:remindus/services/reminder_service.dart';
import 'package:remindus/theme/app_colors.dart';
import 'package:remindus/widgets/common-header.dart';
import 'package:remindus/widgets/custom_button.dart';
import 'package:intl/intl.dart';

enum ReminderFilter { upcoming, completed, all }

class ReminderTabScreen extends StatefulWidget {
  final VoidCallback onProfileTap;

  const ReminderTabScreen({super.key, required this.onProfileTap});

  @override
  State<ReminderTabScreen> createState() => _ReminderTabScreenState();
}

class _ReminderTabScreenState extends State<ReminderTabScreen> {
  final ReminderService _service = ReminderService();
  ReminderFilter selectedFilter = ReminderFilter.upcoming;

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;
    final isAdmin = context.select<UserBloc, bool>((bloc) {
      final state = bloc.state;
      if (state is UserLoadedState) {
        return state.isAdmin;
      }
      return false;
    });
    return Scaffold(
      backgroundColor: appColors.bgColor,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(Assets.bgColorMap),
            fit: BoxFit.cover,
            opacity: 0.6,
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CommonHeader(onProfileTap: widget.onProfileTap,),
              const SizedBox(height: 10.0),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Upcoming Reminders",
                      style: TextStyle(
                        fontWeight: FontWeight.w400,
                        color: appColors.textPrimary,
                        fontSize: 28.0,
                      ),
                    ),
                    const SizedBox(height: 4.0),
                    Text(
                      "What's coming up next",
                      style: TextStyle(
                        fontWeight: FontWeight.w400,
                        color: appColors.textSecondary,
                        fontSize: 16.0,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20.0),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          _buildFilterTab("Upcoming", ReminderFilter.upcoming),
                          _buildFilterTab(
                            "Completed",
                            ReminderFilter.completed,
                          ),
                          _buildFilterTab("All", ReminderFilter.all),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12.0),
                    if (isAdmin) _buildAddButton(appColors),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              Expanded(child: _buildReminderList(appColors)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAddButton(dynamic appColors) {
    return GestureDetector(
      onTap: () async {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const AddReminderScreen()),
          (route) => true,
        );
      },
      child: Container(
        height: 48.0,
        width: 48.0,
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: appColors.bgColor,
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Image.asset(
          Assets.addSquareIcon,
          width: 20.0,
          height: 20.0,
          color: appColors.textPrimary,
        ),
      ),
    );
  }

  Widget _buildFilterTab(String label, ReminderFilter filter) {
    final isSelected = selectedFilter == filter;

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => selectedFilter = filter),
        child: Container(
          height: 46,
          margin: const EdgeInsets.only(right: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? context.appColors.primary.withOpacity(0.12)
                : context.appColors.bgColor,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: context.appColors.textSecondary,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildReminderList(dynamic appColors) {
    final activeFamilyId = context.select<UserBloc, String?>((bloc) {
      final state = bloc.state;
      return (state is UserLoadedState) ? state.activeFamilyId : null;
    });
    return StreamBuilder<List<ReminderModel>>(
      stream: _service.getReminders(
        selectedFilter,
        activeFamilyId: activeFamilyId!,
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return const Center(child: Text("Something went wrong"));
        }

        final reminders = snapshot.data ?? [];

        if (reminders.isEmpty) {
          return const Center(child: Text("No reminders found"));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: reminders.length,
          itemBuilder: (context, index) {
            return Builder(
              builder: (innerContext) {
                final isAdmin = innerContext.select<UserBloc, bool>((bloc) {
                  final state = bloc.state;
                  return state is UserLoadedState ? state.isAdmin : false;
                });
                return ReminderCard(
                  isAdmin: isAdmin,
                  reminder: reminders[index],
                  appColors: appColors,
                );
              },
            );
          },
        );
      },
    );
  }
}

class ReminderCard extends StatelessWidget {
  final ReminderModel reminder;
  final dynamic appColors;
  final bool isAdmin;

  const ReminderCard({
    super.key,
    required this.reminder,
    required this.appColors,
    required this.isAdmin,
  });

  @override
  Widget build(BuildContext context) {
    final activeFamilyId = context.select<UserBloc, String?>((bloc) {
      final state = bloc.state;
      return (state is UserLoadedState) ? state.activeFamilyId : null;
    });
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: appColors.bgColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              reminder.isRead == true
                  ? Image.asset(
                      Assets.completeBorderIcon,
                      width: 22.0,
                      height: 22.0,
                    )
                  : Container(
                      width: 22.0,
                      height: 22.0,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          width: 2.0,
                          color: context.appColors.primary,
                        ),
                      ),
                    ),
              // Icon Row
              Row(
                children: [
                  Image.asset(Assets.pillIcon, width: 18.0, height: 18.0),

                  if (reminder.isRead == false) ...[
                    if (isAdmin) ...[
                      const SizedBox(width: 12.0),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AddReminderScreen(
                                existingReminder: reminder,
                                isEditReminder: true,
                              ),
                            ),
                          );
                        },
                        child: Image.asset(
                          Assets.pencilEditIcon,
                          width: 18.0,
                          height: 18.0,
                        ),
                      ),
                    ],
                  ],
                  if (isAdmin) ...[
                    const SizedBox(width: 12.0),
                    GestureDetector(
                      onTap: () => _showDeleteConfirmation(
                        context,
                        reminder.reminderId!,
                        activeFamilyId: activeFamilyId!,
                      ),
                      child: Image.asset(
                        Assets.deleteIcon,
                        width: 18.0,
                        height: 18.0,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              Text(
                reminder.title ??
                    (reminder.type == "Medicine" ? "Medicine" : "Meeting"),
                style: TextStyle(
                  fontWeight: FontWeight.w400,
                  color: appColors.textPrimary,
                  fontSize: 16,
                ),
              ),
              if (reminder.type == "Medicine" &&
                  reminder.medicineName != null) ...[
                Text(
                  " - ",
                  style: TextStyle(
                    fontWeight: FontWeight.w400,
                    color: appColors.textPrimary,
                  ),
                ),
                Text(
                  reminder.medicineName!,
                  style: TextStyle(
                    fontWeight: FontWeight.w400,
                    color: appColors.textPrimary,
                    fontSize: 16,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 12),

          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 4,
            runSpacing: 2,
            children: [
              Text(
                reminder.scheduledAt != null
                    ? DateFormat(
                        'yyyy/MM/dd',
                      ).format(reminder.scheduledAt!.toDate())
                    : (reminder.time ?? "Time"),
                style: TextStyle(
                  fontWeight: FontWeight.w400,
                  color: appColors.textPrimary,
                  fontSize: 16,
                ),
              ),
              Text(
                " - ",
                style: TextStyle(
                  fontWeight: FontWeight.w400,
                  color: appColors.textPrimary,
                ),
              ),
              Text(
                reminder.time ?? "Time",
                style: TextStyle(
                  fontWeight: FontWeight.w400,
                  color: appColors.textPrimary,
                  fontSize: 16,
                ),
              ),
              if (reminder.type == "Medicine") ...[
                Text(
                  " - ",
                  style: TextStyle(
                    fontWeight: FontWeight.w400,
                    color: appColors.textPrimary,
                  ),
                ),
                Text(
                  reminder.dose ?? "Dose",
                  style: TextStyle(
                    fontWeight: FontWeight.w400,
                    color: appColors.textPrimary,
                    fontSize: 16,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(
    BuildContext context,
    String reminderId, {
    required String activeFamilyId,
  }) {
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
                  "Delete Reminder?",
                  style: TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.w400,
                    color: appColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12.0),
                Text(
                  "Are you sure you want to delete this reminder?\nThis action cannot be undone.",
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
                          await ReminderService().deleteReminder(
                            reminderId,
                            activeFamilyId: activeFamilyId,
                          );
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
                  "Reminder Deleted",
                  style: TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.w400,
                    color: appColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12.0),
                Text(
                  "Has been removed from your reminders.",
                  style: TextStyle(
                    fontSize: 14.0,
                    color: appColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 20.0),
                AppButton(
                  text: "Back to Reminders",
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
