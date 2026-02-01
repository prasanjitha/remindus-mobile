import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:remindus/DummyHome.dart';
import 'package:remindus/blocs/user/user_bloc.dart';

import 'package:remindus/generated/assets.dart';
import 'package:remindus/home_page.dart';
import 'package:remindus/screens/home/health_care_home_screen.dart';
import 'package:remindus/screens/other-features/other_feature_main_screen.dart';
import 'package:remindus/screens/profile/add_guardian_screen.dart';
import 'package:remindus/screens/profile/add_guardient_success_screen.dart';
import 'package:remindus/screens/profile/my_profile_screen.dart';
import 'package:remindus/screens/reminders/reminder_tab_screen.dart';
import 'package:remindus/screens/store/main_store.dart';
import 'package:remindus/screens/tab/watch_connected_screen.dart';
import 'package:remindus/services/reminder_notification_sync.dart';
import 'package:remindus/services/battery_service.dart';
import 'package:remindus/theme/app_colors.dart';

class MainTabScreen extends StatefulWidget {
  final int? initialIndex;
  const MainTabScreen({super.key, this.initialIndex});

  @override
  State<MainTabScreen> createState() => _MainTabScreenState();
}

class _MainTabScreenState extends State<MainTabScreen> {
  int _selectedIndex = 0;
  final reminderNotificationSync = ReminderNotificationSync();
  final _batteryService = BatteryService();

  void _goToProfile() {
    setState(() {
      _selectedIndex = 4;
    });
  }

  @override
  void initState() {
    super.initState();
    if (widget.initialIndex != null) {
      _selectedIndex = widget.initialIndex!;
    }
    _batteryService.startMonitoring();
  }

  @override
  void dispose() {
    _batteryService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> _pages = [
      // HealthCheckupScreen(),
      HealthcareHomeScreen(onProfileTap: _goToProfile),
      ReminderTabScreen(onProfileTap: _goToProfile),
      MainStoreScreen(onProfileTap: _goToProfile),
      OtherFeatureMainScreen(onProfileTap: _goToProfile),
      const MyProfileScreen(),
    ];
    return BlocConsumer<UserBloc, UserState>(
      listener: (context, state) {
        if (state is UserLoadedState) {
          reminderNotificationSync.start(
            state.activeFamilyId,
            state.isAppowner,
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          body: _pages[_selectedIndex],
          bottomNavigationBar: BottomNavBar(
            selectedIndex: _selectedIndex,
            onTap: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
          ),
        );
      },
    );
  }
}

class BottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTap;

  const BottomNavBar({required this.selectedIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(color: context.appColors.bgColor),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(context, 0, Assets.homeIcon, 'Home'),
            _buildNavItem(
              context,
              1,
              Assets.notificationSquareIcon,
              'Reminders',
            ),
            _buildNavItem(context, 2, Assets.pillBottleIcon, 'Store'),
            _buildNavItem(context, 3, Assets.frameIcon, 'More'),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context,
    int index,
    String iconPath,
    String label,
  ) {
    bool isActive = selectedIndex == index;
    Color activeColor = context.appColors.primary;

    return GestureDetector(
      onTap: () => onTap(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            width: 40.0,
            height: 32.0,
            decoration: BoxDecoration(
              color: isActive
                  ? activeColor.withOpacity(0.1)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Image.asset(
              iconPath,
              width: 24,
              height: 24,
              fit: BoxFit.cover,
              color: isActive ? activeColor : Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              color: isActive ? activeColor : context.appColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
