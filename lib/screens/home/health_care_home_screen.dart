import 'dart:developer';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:remindus/blocs/user/user_bloc.dart';

import 'package:remindus/generated/assets.dart';
import 'package:remindus/models/alert_model.dart';
import 'package:remindus/models/base_reminder_model.dart';
import 'package:remindus/models/medicine_store_model.dart';
import 'package:remindus/models/user_model.dart';
import 'package:remindus/screens/reminders/add_reminder_screen.dart';
import 'package:remindus/services/reminder_service.dart';
import 'package:remindus/theme/app_colors.dart';
import 'package:remindus/utils/app_utils.dart';
import 'package:remindus/widgets/common-header.dart';
import 'package:remindus/widgets/custom_button.dart';

class HealthcareHomeScreen extends StatefulWidget {
  final VoidCallback onProfileTap;
  const HealthcareHomeScreen({Key? key, required this.onProfileTap}) : super(key: key);

  @override
  State<HealthcareHomeScreen> createState() => _HealthcareHomeScreenState();
}

class _HealthcareHomeScreenState extends State<HealthcareHomeScreen> {
  bool _hasLoadedOnce = false;

  Widget _buildFamilySwitcher(BuildContext context) {
    return BlocBuilder<UserBloc, UserState>(
      builder: (context, state) {
        if (state is UserLoadingState) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is UserLoadedState) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.0),
                child: Text(
                  "Select Profile",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 110,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: state.joinedFamilies.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(width: 16),
                  itemBuilder: (context, index) {
                    final familyMap = state.joinedFamilies[index];
                    final String id = familyMap['id'];
                    final String name = familyMap['name'];
                    final bool isSelected = id == state.activeFamilyId;
                    final bool isMyHome = id == state.userId;

                    return GestureDetector(
                      onTap: () {
                        if (!isSelected) {
                          context.read<UserBloc>().add(
                            SwitchActiveFamilyEvent(familyId: id),
                          );
                        }
                      },
                      child: Column(
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            padding: const EdgeInsets.all(3),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSelected
                                    ? Colors.blue
                                    : Colors.grey.withOpacity(0.2),
                                width: 2.5,
                              ),
                            ),
                            child: CircleAvatar(
                              radius: 20,
                              backgroundColor: isMyHome
                                  ? Colors.blue.shade50
                                  : Colors.orange.shade50,
                              child: Icon(
                                isMyHome
                                    ? Icons.home_rounded
                                    : Icons.people_alt_rounded,
                                color: isMyHome ? Colors.blue : Colors.orange,
                                size: 28,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            width: 80,
                            child: Text(
                              isMyHome ? "My Home" : name,
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.w500,
                                color: isSelected
                                    ? Colors.blue
                                    : Colors.black54,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        }
        return const SizedBox();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final reminderService = ReminderService();
    final activeFamilyId = context.select<UserBloc, String?>((bloc) {
      final state = bloc.state;
      return (state is UserLoadedState) ? state.activeFamilyId : null;
    });
    return Scaffold(
      backgroundColor: context.appColors.bgColor,
      body: BlocConsumer<UserBloc, UserState>(
        listener: (context, state) {
          if (state is UserLoadingState) {
            log("inside listner isloading ----> ${state.isLoading}");
          }
        },
        builder: (context, state) {
          if (state is UserLoadingState || state is UserInitialState) {
            return Scaffold(
              backgroundColor: context.appColors.bgColor,
              body: Center(
                child: CircularProgressIndicator(
                  color: context.appColors.primary,
                ),
              ),
            );
          }
          if (state is UserLoadedState) {
            return SizedBox(
              width: double.infinity,
              height: double.infinity,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Image.asset(
                      Assets.bgColorMap,
                      fit: BoxFit.cover,
                      opacity: const AlwaysStoppedAnimation(0.6),
                    ),
                  ),

                  SafeArea(
                    child: SingleChildScrollView(
                      physics: BouncingScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CommonHeader(onProfileTap: widget.onProfileTap,),
                          _buildFamilySwitcher(context),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20.0,
                            ),
                            child: Text(
                              state.userName,
                              style: TextStyle(color: Colors.green),
                            ),
                          ),
                          const SizedBox(height: 10.0),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20.0,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                StreamBuilder<UserModel>(
                                  stream: reminderService.getUserData(
                                    activeFamilyId: activeFamilyId!,
                                  ),
                                  builder: (context, snapshot) {
                                    final greeting = AppUtils.getGreeting();
                                    if (snapshot.hasError) {
                                      return const Text("Error loading user");
                                    }
                                    if (!snapshot.hasData ||
                                        snapshot.data == null) {
                                      return const Text("No user data found");
                                    }
                                    final user = snapshot.data!;
                                    final userName = user.name ?? "User";
                                    return Wrap(
                                      crossAxisAlignment:
                                          WrapCrossAlignment.center,
                                      spacing: 4,
                                      runSpacing: 2,

                                      children: [
                                        Text(
                                          "$greeting, ",
                                          style: TextStyle(
                                            fontSize: 28.0,
                                            fontWeight: FontWeight.w400,
                                            color:
                                                context.appColors.textPrimary,
                                          ),
                                        ),
                                        Text(
                                          userName,
                                          style: TextStyle(
                                            fontSize: 28.0,
                                            fontWeight: FontWeight.w400,
                                            color:
                                                context.appColors.textPrimary,
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                ),
                                SizedBox(height: 6.0),
                                Wrap(
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  spacing: 4,
                                  runSpacing: 2,
                                  children: [
                                    Text(
                                      'Start your day with the right care',
                                      style: TextStyle(
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.w400,
                                        color: context.appColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 30.0),

                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              StreamBuilder<List<ReminderModel>>(
                                stream: reminderService.getLatestTwoUpcoming(
                                  activeFamilyId: activeFamilyId!,
                                ),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                          ConnectionState.waiting &&
                                      !_hasLoadedOnce) {
                                    return Center(
                                      child: CircularProgressIndicator(
                                        backgroundColor: context
                                            .appColors
                                            .primary
                                            .withOpacity(0.1),
                                      ),
                                    );
                                  }
                                  final reminders = snapshot.data;

                                  if (reminders == null || reminders.isEmpty) {
                                    return const SizedBox.shrink();
                                  }
                                  _hasLoadedOnce = true;
                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 20.0,
                                        ),
                                        child: _SectionHeader(
                                          title: 'Upcoming Reminders',
                                          context: context,
                                          onViewAll: () {
                                            // View all logic
                                          },
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 20.0,
                                        ),
                                        child: ListView.separated(
                                          shrinkWrap: true,
                                          physics:
                                              const NeverScrollableScrollPhysics(),
                                          itemCount: reminders.length,
                                          separatorBuilder: (_, __) =>
                                              const SizedBox(height: 12.0),
                                          itemBuilder: (context, index) {
                                            return ReminderCard(
                                              reminder: reminders[index],
                                              context: context,
                                            );
                                          },
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                              const SizedBox(height: 12),
                              StreamBuilder<List<MedicineStoreModel>>(
                                stream: reminderService.getRefillAlerts(
                                  activeFamilyId: activeFamilyId,
                                ),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return const SizedBox.shrink();
                                  }

                                  final refillMedicines = snapshot.data ?? [];

                                  if (refillMedicines.isEmpty) {
                                    return const SizedBox.shrink();
                                  }

                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 20.0,
                                        ),
                                        child: _SectionHeader(
                                          title: 'Alerts',
                                          context: context,
                                          onViewAll: () {},
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          left: 20.0,
                                        ),
                                        child: SizedBox(
                                          height: 56,
                                          child: ListView.separated(
                                            scrollDirection: Axis.horizontal,
                                            itemCount: refillMedicines.length,
                                            separatorBuilder: (_, __) =>
                                                const SizedBox(width: 12),
                                            itemBuilder: (context, index) {
                                              final medicine =
                                                  refillMedicines[index];

                                              return AlertCard(
                                                alert: Alert(
                                                  title:
                                                      '${medicine.name} Refill Needed',
                                                  description:
                                                      'Refill prescription now',
                                                  icon: Icons.warning,
                                                  backgroundColor: context
                                                      .appColors
                                                      .lightRed!,
                                                ),
                                                context: context,
                                              );
                                            },
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 20),
                                    ],
                                  );
                                },
                              ),

                              const SizedBox(height: 24),

                              // Quick Actions Section
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20.0,
                                ),
                                child: Text(
                                  'Quick Actions',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w400,
                                    color: context.appColors.textPrimary,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                  left: 20.0,
                                  right: 20.0,
                                  top: 12.0,
                                  bottom: 24.0,
                                ),
                                child: IntrinsicHeight(
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      Column(
                                        children: [
                                          QuickGridAction(
                                            context: context,
                                            title: 'Scan',
                                            subtitle: 'Scan NHS Prescription',
                                            imagePath: Assets.scanIcon,
                                            onTap: () {},
                                            isTalking: false,
                                          ),
                                          const SizedBox(height: 12),
                                          QuickGridAction(
                                            context: context,
                                            title: 'Add Reminder',
                                            subtitle: 'Upload NHS Prescription',
                                            imagePath: Assets.addSquareIcon,
                                            onTap: () {
                                              log("Add Reminder Tapped");
                                              Navigator.pushAndRemoveUntil(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      const AddReminderScreen(),
                                                ),
                                                (route) => true,
                                              );
                                            },
                                            isTalking: false,
                                          ),
                                        ],
                                      ),
                                      const SizedBox(width: 12),

                                      Expanded(
                                        child: QuickGridAction(
                                          context: context,
                                          title: 'Talk to AI Assistant',
                                          subtitle:
                                              'Voice assistant for hands-free reminders',
                                          imagePath: Assets.aiMagicIcon,
                                          onTap: () {},
                                          isTalking: true,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
          if (state is UserErrorState) {
            return Center(child: Text(state.message));
          }

          return const Scaffold(body: SizedBox());
        },
      ),
    );
  }
}

class QuickGridAction extends StatelessWidget {
  final BuildContext context;
  final String title;
  final String subtitle;
  final String imagePath;
  final VoidCallback onTap;
  final bool isTalking;
  const QuickGridAction({
    super.key,
    required this.context,
    required this.title,
    required this.subtitle,
    required this.imagePath,
    required this.onTap,
    required this.isTalking,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: (MediaQuery.of(context).size.width - 60) / 2,
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: context.appColors.bgColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isTalking)
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 32.0,
                    height: 32.0,
                    padding: EdgeInsets.all(4.0),
                    decoration: BoxDecoration(
                      color: context.appColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Image.asset(imagePath, width: 32, height: 32),
                  ),
                  SizedBox(height: 8),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: context.appColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: context.appColors.textSecondary,
                        ),
                        softWrap: true, // Allows wrapping
                        maxLines: 2, // Allows up to 2 lines
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ],
              ),

            if (!isTalking)
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 32.0,
                    height: 32.0,
                    padding: EdgeInsets.all(4.0),
                    decoration: BoxDecoration(
                      color: context.appColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Image.asset(imagePath, width: 32, height: 32),
                  ),
                  SizedBox(height: 8),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: context.appColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: context.appColors.textSecondary,
                        ),
                        softWrap: true,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ],
              ),

            if (isTalking)
              AppButton(
                text: 'Start Talking',
                onPressed: () {},
                backgroundColor: context.appColors.primary,
              ),
          ],
        ),
      ),
    );
  }
}

// Custom Widgets
class _SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback onViewAll;
  final BuildContext context;

  const _SectionHeader({
    required this.title,
    required this.onViewAll,
    required this.context,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16.0,
            fontWeight: FontWeight.w400,
            color: this.context.appColors.textPrimary,
          ),
        ),
        TextButton(
          onPressed: onViewAll,
          child: Text(
            'View All',
            style: TextStyle(
              color: this.context.appColors.primary,
              fontSize: 14.0,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ],
    );
  }
}

class ReminderCard extends StatelessWidget {
  final ReminderModel reminder;
  final BuildContext context;

  const ReminderCard({Key? key, required this.reminder, required this.context})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;
    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: context.appColors.bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 20.0,
                height: 20.0,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    width: 2.0,
                    color: context.appColors.primary,
                  ),
                  color: context.appColors.primary.withOpacity(0.1),
                ),
              ),
              Image.asset(
                reminder.type == 'Medicine'
                    ? Assets.pillIcon
                    : Assets.calenderAddIcon,
                width: 20,
                height: 20,
              ),
            ],
          ),
          const SizedBox(height: 12.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 4,
                      runSpacing: 2,
                      children: [
                        Text(
                          reminder.title!,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            color: context.appColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
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
                            fontWeight: FontWeight.w500,
                            color: appColors.textPrimary,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          ' - ',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: context.appColors.textSecondary,
                          ),
                        ),

                        Text(
                          reminder.time!,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: context.appColors.textSecondary,
                          ),
                        ),
                        if (reminder.type == 'Medicine') ...[
                          Text(
                            ' - ',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: context.appColors.textSecondary,
                            ),
                          ),
                          Text(
                            reminder.medicineName!,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: context.appColors.textSecondary,
                            ),
                          ),
                        ],

                        if (reminder.type == 'Medicine')
                          if (reminder.dose!.isNotEmpty) ...[
                            Text(
                              ' • ',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: context.appColors.textSecondary,
                              ),
                            ),
                            Text(
                              reminder.dose!,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: context.appColors.textSecondary,
                              ),
                            ),
                          ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class AlertCard extends StatelessWidget {
  final Alert alert;
  final BuildContext context;

  const AlertCard({Key? key, required this.alert, required this.context})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: context.appColors.lightRed,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: context.appColors.darkRed,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Image.asset(Assets.pillOffIcon, width: 20, height: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  alert.title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: context.appColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  alert.description,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: context.appColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
