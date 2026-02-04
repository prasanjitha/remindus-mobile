import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:remindus/blocs/user/user_bloc.dart';
import 'package:remindus/helpers/snackbar_helper.dart';
import 'package:remindus/repositories/reminder/reminder_repository.dart';
import 'package:remindus/theme/app_colors.dart';
import 'package:remindus/widgets/app_gradient_background.dart';
import 'package:remindus/widgets/common_header_with_back.dart';
import 'package:remindus/widgets/custom_button.dart';

class BloodTypeScreen extends StatefulWidget {
  const BloodTypeScreen({super.key});

  @override
  State<BloodTypeScreen> createState() => _BloodTypeScreenState();
}

class _BloodTypeScreenState extends State<BloodTypeScreen> {
  String? selectedBloodType;
  final ReminderRepository _reminderRepository = ReminderRepository();

  bool _isLoading = false;

  final List<String> bloodTypes = [
    'A+',
    'A-',
    'B+',
    'B-',
    'O+',
    'O-',
    'AB+',
    'AB-',
  ];

  Future<void> _onDonePressed(String? activeFamilyId) async {
    try {
      if (selectedBloodType == null) {
        SnackbarHelper.showError(
          context,
          "Please select a blood type before proceeding",
        );
      } else {
        setState(() => _isLoading = true);
        bool success = await _reminderRepository.updateFamilyHealthData(
          familyId: activeFamilyId!,
          bloodGroup: selectedBloodType!,
        );
        setState(() => _isLoading = false);
        if (success) {
          Navigator.of(context).pop();
        }
      }
    } catch (e) {
      SnackbarHelper.showError(
        context,
        "An error occurred while updating blood type. Please try again.",
      );
    }
  }

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
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CommonHeaderWithBack(
                        onMainLogoTap: () {
                          Navigator.of(context).pop();
                        },
                      ),
                      const SizedBox(height: 20),
                      Text(
                        "Blood Type Identification",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w500,
                          color: appColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Securely store blood type for emergency reference",
                        style: TextStyle(
                          fontSize: 14,
                          color: appColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 30),
                      Text(
                        "Select Blood Type",
                        style: TextStyle(
                          fontSize: 16,
                          color: appColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Blood Type Grid
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 4,
                              crossAxisSpacing: 10,
                              mainAxisSpacing: 10,
                              childAspectRatio: 1.5,
                            ),
                        itemCount: bloodTypes.length,
                        itemBuilder: (context, index) {
                          final type = bloodTypes[index];
                          final isSelected = selectedBloodType == type;
                          return GestureDetector(
                            onTap: () =>
                                setState(() => selectedBloodType = type),
                            child: Container(
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? appColors.primaryLightBlue
                                    : appColors.bgColor,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Center(
                                child: Text(
                                  type,
                                  style: TextStyle(
                                    color: appColors.textPrimary,
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: AppButton(
                  text: 'Done',
                  onPressed: () => _onDonePressed(activeFamilyId),
                  backgroundColor: appColors.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
