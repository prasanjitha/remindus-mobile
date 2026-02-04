import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:remindus/generated/assets.dart';
import 'package:remindus/theme/app_colors.dart';
import 'package:remindus/blocs/user/user_bloc.dart';
import 'package:remindus/widgets/common-header.dart';
import 'package:remindus/blocs/theme/theme_cubit.dart';
import 'package:remindus/blocs/theme/theme_state.dart';
import 'package:remindus/widgets/app_gradient_background.dart';
import 'package:remindus/screens/appInfo/about_us_screen.dart';
import 'package:remindus/widgets/feature_quick_action_card.dart';
import 'package:remindus/screens/tab/watch_connect_now_screen.dart';
import 'package:remindus/screens/appInfo/privacy_policy_screen.dart';
import 'package:remindus/screens/sos/emwrgency_sos_main_screen.dart';
import 'package:remindus/screens/appInfo/terms_and_conditions_screen.dart';
import 'package:remindus/screens/vaccination/vaccination_list_screen.dart';
import 'package:remindus/screens/food-tacker/food_tracker_home_screen.dart';
import 'package:remindus/screens/location-tracking/map_tracking_screen.dart';

class OtherFeatureMainScreen extends StatelessWidget {
  final VoidCallback onProfileTap;

  const OtherFeatureMainScreen({super.key, required this.onProfileTap});

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColors>()!;
    final activeFamilyId = context.select<UserBloc, String?>((bloc) {
      final state = bloc.state;
      return (state is UserLoadedState) ? state.activeFamilyId : null;
    });
    return AppGradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Custom Header
                Padding(
                  padding: EdgeInsets.only(top: 10.0),
                  child: CommonHeader(onProfileTap: onProfileTap),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20.0),
                      Text(
                        'More Ways to Help',
                        style: TextStyle(
                          fontSize: 28.0,
                          fontWeight: FontWeight.w400,
                          color: appColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8.0),
                      Text(
                        'Extra features for your wellbeing',
                        style: TextStyle(
                          fontSize: 16,
                          color: appColors.textPrimary.withOpacity(0.7),
                        ),
                      ),
                      const SizedBox(height: 30.0),

                      // Main Banner Image
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.asset(
                          Assets.healthMainIcon,
                          width: double.infinity,
                          height: 250,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(height: 30.0),

                      // Section Title
                      Text(
                        'Health and Tracking',
                        style: TextStyle(
                          fontSize: 20,
                          color: appColors.textPrimary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 16.0),

                      // Responsive Grid of Cards
                      Row(
                        children: [
                          Expanded(
                            child: QuickActionCard(
                              title: "Health",
                              iconPath: Assets.healthIcon,
                              onTap: () {
                                // Navigate to Health Screen
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const WatchConnceNowScreen(),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: QuickActionCard(
                              title: "Food Track",
                              iconPath: Assets.healthVegetarianFoodIcon,
                              onTap: () {
                                // Navigate to Food Track Screen
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const FoodTrackerScreen(),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: QuickActionCard(
                              title: "Vaccines",
                              iconPath: Assets.healthVaccineIcon,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const VaccinationListScreen(),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 40.0),
                      Text(
                        'Safety and Care',
                        style: TextStyle(
                          fontSize: 20,
                          color: appColors.textPrimary,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(height: 20.0),
                      Row(
                        children: [
                          Expanded(
                            child: QuickActionCard(
                              title: "SOS Help",
                              iconPath: Assets.healthIcon,
                              onTap: () {
                                // Navigate to SOS Help Screen
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => EmergencySOSScreen(),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: QuickActionCard(
                              title: "Location",
                              iconPath: Assets.healthMapLocationsIcon,
                              onTap: () {
                                // Navigate to Location Tracking Screen
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => MapTrackingScreen(
                                      activeFamilyId: activeFamilyId!,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 40.0),

                      // Theme Toggle Section
                      Text(
                        'Appearance',
                        style: TextStyle(
                          fontSize: 20,
                          color: appColors.textPrimary,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(height: 16.0),

                      BlocBuilder<ThemeCubit, ThemeState>(
                        builder: (context, themeState) {
                          return Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: _ThemeButton(
                                    label: 'System',
                                    icon: Icons.brightness_auto,
                                    isSelected:
                                        themeState.themeMode ==
                                        ThemeMode.system,
                                    onTap: () => context
                                        .read<ThemeCubit>()
                                        .setSystemTheme(),
                                    appColors: appColors,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: _ThemeButton(
                                    label: 'Light',
                                    icon: Icons.light_mode,
                                    isSelected:
                                        themeState.themeMode == ThemeMode.light,
                                    onTap: () => context
                                        .read<ThemeCubit>()
                                        .setLightTheme(),
                                    appColors: appColors,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: _ThemeButton(
                                    label: 'Dark',
                                    icon: Icons.dark_mode,
                                    isSelected:
                                        themeState.themeMode == ThemeMode.dark,
                                    onTap: () => context
                                        .read<ThemeCubit>()
                                        .setDarkTheme(),
                                    appColors: appColors,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 40.0),

                      // App Information Section
                      Text(
                        'App Information',
                        style: TextStyle(
                          fontSize: 20,
                          color: appColors.textPrimary,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(height: 16.0),
                      Row(
                        children: [
                          Expanded(
                            child: QuickActionCard(
                              title: "About Us",
                              iconPath: Assets.appInfoAboutIcon,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const AboutUsScreen(),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: QuickActionCard(
                              title: "Privacy",
                              iconPath: Assets.appInfoPrivacyIcon,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const PrivacyPolicyScreen(),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: QuickActionCard(
                              title: "Terms",
                              iconPath: Assets.appInfoTermsIcon,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const TermsAndConditionsScreen(),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 40.0),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Theme button widget
class _ThemeButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;
  final AppColors appColors;

  const _ThemeButton({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
    required this.appColors,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? appColors.primary : appColors.bgColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected
                  ? Colors.white
                  : appColors.textPrimary.withOpacity(0.7),
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: isSelected
                    ? Colors.white
                    : appColors.textPrimary.withOpacity(0.7),
                fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
