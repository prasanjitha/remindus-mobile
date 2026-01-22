import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:remindus/blocs/user/user_bloc.dart';
import 'package:remindus/generated/assets.dart';
import 'package:remindus/screens/food-tacker/food_tracker_home_screen.dart';
import 'package:remindus/screens/location-tracking/map_tracking_screen.dart';
import 'package:remindus/screens/sos/emwrgency_sos_main_screen.dart';
import 'package:remindus/screens/tab/watch_connected_screen.dart';
import 'package:remindus/theme/app_colors.dart';
import 'package:remindus/widgets/common-header.dart';
import 'package:remindus/widgets/feature_quick_action_card.dart';

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
    return Scaffold(
      backgroundColor: appColors.bgColor,
      body: Stack(
        children: [
        
          Positioned.fill(
            child: Image.asset(
              Assets.bgColorMap,
              fit: BoxFit.cover,
              opacity: const AlwaysStoppedAnimation(.5),
            ),
          ),

          
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Custom Header
                   Padding(
                    padding: EdgeInsets.only(top: 10.0),
                    child: CommonHeader(onProfileTap: onProfileTap,),
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
                                   Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const HealthCheckupScreen(),
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
                                      builder: (context) => const FoodTrackerScreen(),
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
                                  // Navigate to Vaccines Screen
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
                                      builder: (context) =>  EmergencySOSScreen(),
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
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
